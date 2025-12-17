import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protobuf/protobuf.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:vx/app/outbound/outbound_repo.dart';
import 'package:vx/app/outbound/outbounds_bloc.dart';
import 'package:vx/auth/auth_provider.dart';
import 'package:vx/data/database.dart';
import 'package:vx/data/database_log.dart';
import 'package:vx/data/ssh_server.dart';
import 'package:vx/data/sync.pb.dart';
import 'package:vx/main.dart' hide App;
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/encrypt.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/device.dart';

class SyncService with ChangeNotifier {
  final String deviceId;
  String? fcmToken;
  StreamSubscription<String>? fcmTokenSubscription;

  // Batch processing fields for incoming operations (from server)
  final List<SyncOperation> _cachedOperations = [];
  Timer? _batchTimer;
  final Duration _batchDelay = const Duration(seconds: 1);

  // Batch processing fields for outgoing operations (to server)
  final List<SyncOperation> _outgoingOperationsCache = [];
  Timer? _uploadBatchTimer;
  final Duration _uploadBatchDelay = const Duration(seconds: 1);
  bool _isUploading = false;

  final PrefHelper prefHelper;
  late final OutboundRepo outboundRepo;
  OutboundBloc? outboundBloc;
  FlutterSecureStorage storage;
  bool enable = false;
  final AuthProvider authProvider;
  StreamSubscription? _userSubscription;
  String? password;

  // Periodic sync fields
  Timer? _periodicSyncTimer;
  final Duration _periodicSyncInterval = const Duration(minutes: 5);

  SyncService(
      {required this.deviceId,
      required this.prefHelper,
      required this.storage,
      required this.authProvider}) {
    logger.i('SyncService initialized with deviceId: $deviceId');

    _userSubscription = authProvider.user.listen((user) {
      reset();
    });
  }

  void reset() async {
    logger.d('reset');
    enable = ((authProvider.currentUser?.pro ?? false) &&
        (prefHelper.syncNodeSub ||
            prefHelper.syncRoute ||
            prefHelper.syncServer ||
            prefHelper.syncSelectorSetting));

    password = await storage.read(key: 'syncPassword');

    if (enable) {
      logger.d('enable sync');
      if (fcmEnabled) {
        fcmToken ??= await FirebaseMessaging.instance.getToken();
        fcmTokenSubscription ??=
            FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
          this.fcmToken = fcmToken;
        });
      }
      await updateDeviceIdToken();

      // Start periodic sync
      _startPeriodicSync();
    } else {
      logger.d('disable sync');
      fcmTokenSubscription?.cancel();
      fcmTokenSubscription = null;

      // Cancel batch timer and process any remaining incoming operations
      _batchTimer?.cancel();
      if (_cachedOperations.isNotEmpty) {
        _processBatchedOperations();
      }

      // Cancel upload batch timer and upload any remaining outgoing operations
      _uploadBatchTimer?.cancel();
      _outgoingOperationsCache.clear();

      // Stop periodic sync
      _stopPeriodicSync();
    }
  }

  void _startPeriodicSync() async {
    // Cancel existing timer if any
    _periodicSyncTimer?.cancel();

    // Start periodic sync timer
    _periodicSyncTimer = Timer.periodic(_periodicSyncInterval, (timer) async {
      logger.i('Running periodic sync...');
      await sync();
    });

    logger.i(
        'Periodic sync started (every ${_periodicSyncInterval.inMinutes} minutes)');
    await sync();
  }

  void _stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
    logger.i('Periodic sync stopped');
  }

  Future<void> updateDeviceIdToken() async {
    // if never uploaded
    if (prefHelper.deviceIdRefreshTime == null) {
      // create a new device_id_token
      final body = {
        'deviceId': deviceId,
        'fcmToken': fcmToken,
      };
      final token = supabase.auth.currentSession?.accessToken ?? '';
      await supabase.functions.invoke('insert-deviceIdToken',
          headers: {
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body));
      prefHelper.setDeviceIdUpdateTime(DateTime.now());
    } else if (prefHelper.deviceIdRefreshTime!
            .isBefore(DateTime.now().subtract(const Duration(days: 15))) ||
        (prefHelper.fcmToken != fcmToken)) {
      supabase.from('device_id_tokens').update({
        'user_id': supabase.auth.currentUser!.id,
        'device_id': deviceId,
        'fcm_token': fcmToken,
        'updated_at': DateTime.now().toIso8601String(),
      });
      prefHelper.setDeviceIdUpdateTime(DateTime.now());
    }
    if (fcmToken != null) {
      prefHelper.setFcmToken(fcmToken!);
    }
  }

  /// Cache a sync operation for batched upload
  /// Operations are uploaded after 1 second of inactivity to reduce battery usage
  Future<void> _uploadSyncOperation(SyncOperation operation) async {
    if (!enable) {
      logger.d('Sync is disabled, skipping operation');
      return;
    }

    // Add operation to cache
    _outgoingOperationsCache.add(operation);
    logger.d('Cached operation (${_outgoingOperationsCache.length} total)');

    // Cancel existing timer and start a new one
    _uploadBatchTimer?.cancel();
    _uploadBatchTimer = Timer(_uploadBatchDelay, () async {
      await _uploadBatchedOperations();
    });
  }

  String _getSyncData(SyncOperations operations) {
    if (password != null && password!.isNotEmpty) {
      return encryptToBase64(operations.writeToBuffer(), password!);
    }
    return base64Encode(operations.writeToBuffer());
  }

  /// Upload all cached operations in a single batch
  Future<void> _uploadBatchedOperations() async {
    if (_outgoingOperationsCache.isEmpty || _isUploading) {
      return;
    }

    _isUploading = true;

    try {
      // Create a copy and clear the cache
      final operationsToUpload =
          List<SyncOperation>.from(_outgoingOperationsCache);
      _outgoingOperationsCache.clear();

      logger.i('Uploading ${operationsToUpload.length} batched operations');

      final body = {
        'deviceId': deviceId,
        'data': _getSyncData(SyncOperations(operations: operationsToUpload))
      };
      print(body);
      if (fcmToken != null) {
        body['fcmToken'] = fcmToken!;
      }
      final token = supabase.auth.currentSession?.accessToken ?? '';
      final rsp = await supabase.functions.invoke('syncrhonization',
          headers: {
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body));
      logger.i('Syncrhonization response: ${rsp.status}');
    } catch (e) {
      logger.e('Failed to upload batched operations: $e');
      rethrow;
    } finally {
      _isUploading = false;
    }
  }

  Future<void> addHandler(List<HandlerConfig> handlers, {String? group}) async {
    return _uploadSyncOperation(SyncOperation(
        time: Int64(DateTime.now().millisecondsSinceEpoch),
        addHandler: AddHandler(
            handlers: handlers.map((e) => e.writeToBuffer()).toList(),
            group: group)));
  }

  // Future<void> uploadSqlQuery(SqlQuery query) async {
  //   return _uploadSyncOperation(SyncOperation(
  //       time: Int64(DateTime.now().millisecondsSinceEpoch), sqlQuery: query));
  // }

  Future<void> sqlOperation(SqlOperation operation) async {
    if (_shouldSync(operation.table)) {
      return _uploadSyncOperation(SyncOperation(
          time: Int64(DateTime.now().millisecondsSinceEpoch),
          sqlOperation: operation));
    }
  }

  Future<void> addServerOperation(
      SshServer server, SshServerSecureStorage sss, String sssKey) async {
    if (_shouldSync('ssh_servers')) {
      return _uploadSyncOperation(SyncOperation(
          time: Int64(DateTime.now().millisecondsSinceEpoch),
          serverOperation: ServerOperation(
              type: ServerOperation_Type.ADD,
              row: jsonEncode(server.toJson()),
              storageKey: sssKey,
              secureStorage: jsonEncode(sss.toJson()))));
    }
  }

  Future<void> updateServerOperation(
      SshServer server, SshServerSecureStorage sss, String sssKey) async {
    if (_shouldSync('ssh_servers')) {
      return _uploadSyncOperation(SyncOperation(
          time: Int64(DateTime.now().millisecondsSinceEpoch),
          serverOperation: ServerOperation(
              type: ServerOperation_Type.UPDATE,
              row: jsonEncode(server.toJson()),
              storageKey: sssKey,
              secureStorage: jsonEncode(sss.toJson()))));
    }
  }

  Future<void> removeServerOperation(SshServer server) async {
    if (_shouldSync('ssh_servers')) {
      return _uploadSyncOperation(SyncOperation(
          time: Int64(DateTime.now().millisecondsSinceEpoch),
          serverOperation: ServerOperation(
              type: ServerOperation_Type.DELETE, id: Int64(server.id))));
    }
  }

  Future<void> addCommonSshKeyOperation(CommonSshKey commonSshKey,
      String sssKey, CommonSshKeySecureStorage sss) async {
    if (_shouldSync('common_ssh_keys')) {
      return _uploadSyncOperation(SyncOperation(
          time: Int64(DateTime.now().millisecondsSinceEpoch),
          commonSshKeyOperation: CommonSshKeyOperation(
              type: CommonSshKeyOperation_Type.ADD,
              row: jsonEncode(commonSshKey.toJson()),
              storageKey: sssKey,
              secureStorage: jsonEncode(sss.toJson()))));
    }
  }

  Future<void> removeCommonSshKeyOperation(CommonSshKey commonSshKey) async {
    if (_shouldSync('common_ssh_keys')) {
      return _uploadSyncOperation(SyncOperation(
          time: Int64(DateTime.now().millisecondsSinceEpoch),
          commonSshKeyOperation: CommonSshKeyOperation(
              type: CommonSshKeyOperation_Type.DELETE,
              id: Int64(commonSshKey.id))));
    }
  }

  SyncOperations _getSyncOperations(String data) {
    if (password != null && password!.isNotEmpty) {
      return SyncOperations.fromBuffer(decryptFromBase64(data, password!));
    }
    return SyncOperations.fromBuffer(base64Decode(data));
  }

  void setPassword(String password) async {
    this.password = password;
    await storage.write(key: 'syncPassword', value: password);
  }

  bool syncing = false;
  Future<void> sync() async {
    // fetch all sync operations of this user and device id
    syncing = true;
    notifyListeners();
    try {
      final operationsRaw = await supabase
          .from('sync_operations')
          .delete()
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('device_id', deviceId)
          .select();
      // if (operationsRaw.isNotEmpty) {
      //   // TODO: use trigger to make it more efficient
      //   // delete all sync operations of this user and device id
      //   supabase
      //       .from('sync_operations')
      //       .delete()
      //       .eq('user_id', supabase.auth.currentUser!.id)
      //       .eq('device_id', deviceId)
      //       .then((value) {
      //     logger.i('Deleted ${value} sync operations');
      //   }).catchError((e) {
      //     logger.e('Failed to delete sync operations', error: e);
      //   });
      // }

      final operations = operationsRaw
          .map((e) {
            print("sync operation: ${e['data']}");
            return _getSyncOperations(e['data']);
          })
          .expand((e) => e.operations)
          .toList();
      
      print("sync operations: ${operations.length}");

      // Add operation to cache
      _cachedOperations.addAll(operations);

      // Cancel existing timer if running
      _batchTimer?.cancel();

      // Start new timer for batch processing
      _batchTimer = Timer(_batchDelay, () async {
        await _processBatchedOperations();
      });
    } catch (e) {
      logger.e('Failed to sync', error: e);
      return;
    } finally {
      syncing = false;
      notifyListeners();
    }
  }

  Future<void> _processBatchedOperations() async {
    if (_cachedOperations.isEmpty) return;

    // Sort operations by time field
    _cachedOperations.sort((a, b) => a.time.compareTo(b.time));

    // Create a copy and clear the cache
    final operationsToProcess = List<SyncOperation>.from(_cachedOperations);
    _cachedOperations.clear();

    // Apply operations in order
    for (final operation in operationsToProcess) {
      try {
        await _applyOperation(operation);
      } catch (e) {
        logger.e('Failed to apply sync operation: $e');
        // Continue with next operation even if one fails
      }
    }

    logger.i('Applied ${operationsToProcess.length} batched sync operations');
  }

  Future<void> _applyOperation(SyncOperation operation) async {
    if (operation.hasAddHandler()) {
      final result = await outboundRepo.insertHandlersWithGroup(
          operation.addHandler.handlers
              .map((e) => HandlerConfig.fromBuffer(e))
              .toList(),
          groupName: operation.addHandler.group.isEmpty
              ? defaultGroupName
              : operation.addHandler.group);
      print(result);
    } else if (operation.hasSqlQuery()) {
      await _applySqlQuery(operation.sqlQuery);
    } else if (operation.hasSqlOperation()) {
      await _applySqlOperation(operation.sqlOperation);
      if (operation.sqlOperation.table == 'outbound_handlers') {
        outboundBloc?.add(SyncEvent());
      } else if (operation.sqlOperation.table.contains('selector')) {
        database.notifyUpdates({
          TableUpdate.onTable(database.handlerSelectors,
              kind: UpdateKind.update)
        });
      }
    } else if (operation.hasServerOperation()) {
      await _applyServerOperation(operation.serverOperation);
    } else if (operation.hasCommonSshKeyOperation()) {
      await _applyCommonSshKeyOperation(operation.commonSshKeyOperation);
    }
  }

  Future<void> _applyServerOperation(ServerOperation operation) async {
    if (_shouldSync('ssh_servers')) {
      if (operation.type == ServerOperation_Type.ADD) {
        await database
            .into(database.sshServers)
            .insert(SshServer.fromJson(jsonDecode(operation.row)));
        await storage.write(
            key: operation.storageKey, value: operation.secureStorage);
      } else if (operation.type == ServerOperation_Type.UPDATE) {
        await database
            .update(database.sshServers)
            .replace(SshServer.fromJson(jsonDecode(operation.row)));
        await storage.write(
            key: operation.storageKey, value: operation.secureStorage);
      } else {
        final server = (await (database.delete(database.sshServers)
                  ..where((t) => t.id.equals(operation.id.toInt())))
                .goAndReturn())
            .single;
        await storage.delete(key: server.storageKey);
      }
    }
  }

  Future<void> _applyCommonSshKeyOperation(
      CommonSshKeyOperation operation) async {
    if (_shouldSync('common_ssh_keys')) {
      if (operation.type == CommonSshKeyOperation_Type.ADD) {
        await database
            .into(database.commonSshKeys)
            .insert(CommonSshKey.fromJson(jsonDecode(operation.row)));
      }
    } else {
      final commonSshKey = (await (database.delete(database.commonSshKeys)
                ..where((t) => t.id.equals(operation.id.toInt())))
              .goAndReturn())
          .single;
      await storage.delete(key: "common_ssh_key_${commonSshKey.name}");
    }
  }

  static const nodeSubTables = {
    'outbound_handlers',
    'subscriptions',
    'outbound_handler_groups',
    'outbound_handler_group_relations'
  };
  static const routeTables = {
    'great_ip_sets',
    'atomic_ip_sets',
    'app_sets',
    'cidrs',
    'geo_domains',
    'atomic_domain_sets',
    'great_domain_sets',
    'dns_servers',
    'dns_records',
    'apps',
    'custom_route_modes',
    'handler_selectors'
  };
  static const selectorSetting = {
    'selector_handler_relations',
    'selector_handler_group_relations',
    'selector_subscription_relations',
  };
  static const serverTables = {
    'ssh_servers',
    'common_ssh_keys',
  };
  bool _shouldSync(String table) {
    if (nodeSubTables.contains(table) && prefHelper.syncNodeSub) {
      return true;
    } else if (routeTables.contains(table) && prefHelper.syncRoute) {
      return true;
    } else if (serverTables.contains(table) && prefHelper.syncServer) {
      return true;
    } else if (selectorSetting.contains(table) &&
        prefHelper.syncSelectorSetting) {
      return true;
    }
    return enable;
  }

  Future<void> _applySqlOperation(SqlOperation operation) async {
    if (_shouldSync(operation.table)) {
      logger.d('Applying sql operation: ${operation.table}');
      final table = database.getTableByName(operation.table)!;
      switch (operation.type) {
        case SQLType.INSERT:
          if (operation.rows.length == 1) {
            await database
                .into(table)
                .insert(_getInsertable(operation.table, operation.rows[0]));
          } else {
            await database.transaction(() async {
              for (var row in operation.rows) {
                await database
                    .into(table)
                    .insert(_getInsertable(operation.table, row));
              }
            });
          }
        case SQLType.UPDATE:
          if (operation.rows.length == 1) {
            await (database
                .update(table)
                .replace(_getInsertable(operation.table, operation.rows[0])));
          } else {
            await database.transaction(() async {
              for (var row in operation.rows) {
                await database
                    .update(table)
                    .replace(_getInsertable(operation.table, row));
              }
            });
          }
        case SQLType.DELETE:
          final columnsByName = table.columnsByName;
          for (final id in operation.ids) {
            await (database.delete(table)
                  ..where((t) {
                    final idColumn = columnsByName['id'];
                    if (idColumn == null) {
                      throw ArgumentError.value(
                          this, 'this', 'Must be a table with an id column');
                    }
                    if (idColumn.type != DriftSqlType.int) {
                      throw ArgumentError('Column `id` is not an integer');
                    }
                    return idColumn.equals(id.toInt());
                  }))
                .go();
          }
          for (final name in operation.names) {
            await (database.delete(table)
                  ..where((t) {
                    final nameColumn = columnsByName['name'];
                    if (nameColumn == null) {
                      throw ArgumentError.value(
                          this, 'this', 'Must be a table with an name column');
                    }
                    if (nameColumn.type != DriftSqlType.string) {
                      throw ArgumentError('Column `name` is not a string');
                    }
                    return nameColumn.equals(name);
                  }))
                .go();
          }
        default:
          throw Exception('Invalid SQL type: ${operation.type}');
      }
    }
  }

  Insertable _getInsertable(String table, String json) {
    switch (table) {
      case 'outbound_handlers':
        final handler = OutboundHandler.fromJson(jsonDecode(json));
        return OutboundHandlersCompanion(
          id: Value(handler.id),
          config: Value(handler.config),
          updatedAt: Value(handler.updatedAt),
        );
      case 'subscriptions':
        return Subscription.fromJson(jsonDecode(json)).toCompanion(true);
      case 'outbound_handler_groups':
        return OutboundHandlerGroup.fromJson(jsonDecode(json)).toCompanion();
      case 'outbound_handler_group_relations':
        return OutboundHandlerGroupRelation.fromJson(jsonDecode(json))
            .toCompanion(true);
      case 'great_ip_sets':
        return GreatIpSet.fromJson(jsonDecode(json)).toCompanion(true);
      case 'atomic_ip_sets':
        return AtomicIpSet.fromJson(jsonDecode(json)).toCompanion(true);
      case 'app_sets':
        return AppSet.fromJson(jsonDecode(json)).toCompanion(true);
      case 'dns_servers':
        return DnsServer.fromJson(jsonDecode(json)).toCompanion(true);
      case 'handler_selectors':
        return HandlerSelector.fromJson(jsonDecode(json)).toCompanion(true);
      case 'geo_domains':
        return GeoDomain.fromJson(jsonDecode(json)).toCompanion(true);
      case 'cidrs':
        return Cidr.fromJson(jsonDecode(json)).toCompanion(true);
      case 'apps':
        return App.fromJson(jsonDecode(json)).toCompanion(true);
      case 'custom_route_modes':
        return CustomRouteMode.fromJson(jsonDecode(json)).toCompanion(true);
      case 'atomic_domain_sets':
        return AtomicDomainSet.fromJson(jsonDecode(json)).toCompanion(true);
      case 'great_domain_sets':
        return GreatDomainSet.fromJson(jsonDecode(json)).toCompanion(true);
      case 'selector_handler_relations':
        return SelectorHandlerRelation.fromJson(jsonDecode(json))
            .toCompanion(true);
      case 'selector_handler_group_relations':
        return SelectorHandlerGroupRelation.fromJson(jsonDecode(json))
            .toCompanion(true);
      case 'selector_subscription_relations':
        return SelectorSubscriptionRelation.fromJson(jsonDecode(json))
            .toCompanion(true);
      default:
        throw Exception('Invalid table: $table');
    }
  }

  // //TODO: use transaction?
  Future<void> _applySqlQuery(SqlQuery query) async {
    if (enable) {
      // interceptor.pause = true;
      logger
          .d('Applying sync operation: ${query.statement} ${query.arguments}');
      try {
        switch (query.type) {
          case SQLType.INSERT:
            await database.customInsert(query.statement,
                variables: query.arguments
                    .map((e) => Variable<Object>(e.toObject()))
                    .toList());
          case SQLType.UPDATE:
            await database.customUpdate(query.statement,
                variables: query.arguments
                    .map((e) => Variable<Object>(e.toObject()))
                    .toList());
          case SQLType.DELETE:
            await database.customStatement(query.statement,
                query.arguments.map((e) => e.toObject()).toList());
          case SQLType.CUSTOM:
            await database.customStatement(query.statement,
                query.arguments.map((e) => e.toObject()).toList());
          case SQLType.BATCH:
            await database.customStatement(query.statement);
        }
      } catch (e) {
        logger.e('Error applying sync operation', error: e);
      } finally {
        // interceptor.pause = false;
      }
    }
  }

  /// Manually flush all cached outgoing operations immediately
  /// Useful before app shutdown or important state changes
  Future<void> flushPendingOperations() async {
    _uploadBatchTimer?.cancel();
    if (_outgoingOperationsCache.isNotEmpty) {
      await _uploadBatchedOperations();
    }
  }

  @override
  void dispose() {
    _stopPeriodicSync();
    _batchTimer?.cancel();
    _uploadBatchTimer?.cancel();
    fcmTokenSubscription?.cancel();
    _userSubscription?.cancel();

    // Flush any pending operations before disposal
    // Note: This is fire-and-forget as dispose is synchronous
    if (_outgoingOperationsCache.isNotEmpty) {
      _uploadBatchedOperations();
    }

    logger.i('SyncService disposed');
    super.dispose();
  }
}
