import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/service_api.dart';
import 'package:tm/protos/google/protobuf/any.pb.dart';
import 'package:tm/protos/protos/db/db.pbgrpc.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:tm/protos/protos/proxy/vmess.pb.dart';
import 'package:vx/data/database.dart';
import 'package:vx/data/database_server.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mockito/mockito.dart';

// Mock ServiceCall
class MockServiceCall extends Mock implements ServiceCall {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late AppDatabase database;
  late DatabaseServer server;
  late MockServiceCall mockCall;

  setUp(() async {
    database = AppDatabase(DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ));
    server = DatabaseServer(database);
    mockCall = MockServiceCall();
  });

  tearDown(() async {
    await database.close();
  });

  // Helper function to create test handler data  
  OutboundHandlersCompanion createTestHandlerCompanion({
    int? id,
    bool selected = false,
    String countryCode = 'US',
    String sni = 'example.com',
    double speed = 50.0,
    int speedTestTime = 1000,
    int ping = 100,
    int pingTestTime = 2000,
    int ok = 1,
    String serverIp = '192.168.1.1',
    int support6 = 0,
    int support6TestTime = 3000,
    int? subId,
  }) {
    final handlerConfig = HandlerConfig(
      outbound: OutboundHandlerConfig(
        tag: 'test-handler-${id ?? 0}',
        address: '192.168.1.1',
        port: 443,
        protocol: Any.pack(VmessClientConfig()),
      ),
    );

    return OutboundHandlersCompanion(
      id: id != null ? Value(id) : const Value.absent(),
      selected: Value(selected),
      countryCode: Value(countryCode),
      sni: Value(sni),
      speed: Value(speed),
      speedTestTime: Value(speedTestTime),
      ping: Value(ping),
      pingTestTime: Value(pingTestTime),
      ok: Value(ok),
      serverIp: Value(serverIp),
      config: Value(handlerConfig),
      support6: Value(support6),
      support6TestTime: Value(support6TestTime),
      subId: subId != null ? Value(subId) : const Value.absent(),
    );
  }

  // Helper function to insert test handler and return its ID
  Future<int> insertTestHandler({
    bool selected = false,
    String countryCode = 'US',
    double speed = 50.0,
    int ping = 100,
    int ok = 1,
  }) async {
    final companion = createTestHandlerCompanion(
      selected: selected,
      countryCode: countryCode,
      speed: speed,
      ping: ping,
      ok: ok,
    );
    
    return await database.into(database.outboundHandlers).insert(companion);
  }

  group('DatabaseServer Basic Tests', () {
    test('should create DatabaseServer instance', () {
      expect(server, isA<DatabaseServer>());
      expect(server, isA<DbServiceBase>());
    });

    test('getAllHandlers should return empty list when no handlers exist', () async {
      // Arrange
      final request = GetAllHandlersRequest();

      // Act
      final result = await server.getAllHandlers(mockCall, request);

      // Assert
      expect(result, isA<DbHandlers>());
      expect(result.handlers, isEmpty);
    });

    test('getAllHandlers should return handlers when they exist', () async {
      // Arrange
      final handlerId = await insertTestHandler(speed: 100.0);
      final request = GetAllHandlersRequest();

      // Act
      final result = await server.getAllHandlers(mockCall, request);

      // Assert
      expect(result.handlers.length, 1);
      expect(result.handlers.first.id, handlerId);
      expect(result.handlers.first.speed, 100.0);
    });

    test('getHandler should return handler when found', () async {
      // Arrange
      final handlerId = await insertTestHandler(
        selected: true,
        countryCode: 'JP',
        speed: 75.5,
        ping: 25,
      );
      
      final request = GetHandlerRequest(id: handlerId);

      // Act
      final result = await server.getHandler(mockCall, request);

      // Assert
      expect(result.id, handlerId);
      expect(result.speed, 75.5);
      expect(result.ping, 25);
    });

    test('getHandler should throw exception when handler not found', () async {
      // Arrange
      final request = GetHandlerRequest(id: 99999);

      // Act & Assert
      expect(
        () => server.getHandler(mockCall, request),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Handler not found with id: 99999'),
        )),
      );
    });

    test('updateHandler should update handler fields', () async {
      // Arrange
      final handlerId = await insertTestHandler(
        speed: 50.0,
        ping: 100,
        ok: 0,
      );
      
      final request = UpdateHandlerRequest(
        id: handlerId,
        speed: 150.0,
        ping: 25,
        ok: 1,
      );

      // Act
      final result = await server.updateHandler(mockCall, request);

      // Assert
      expect(result, isA<Receipt>());
      
      // Verify the handler was actually updated
      final verifyResult = await server.getHandler(
        mockCall,
        GetHandlerRequest(id: handlerId),
      );
      
      expect(verifyResult.speed, 150.0);
      expect(verifyResult.ping, 25);
      expect(verifyResult.ok, 1);
    });

    test('getBatchedHandlers should respect limit parameter', () async {
      // Arrange
      await insertTestHandler(speed: 100.0);
      await insertTestHandler(speed: 90.0);
      await insertTestHandler(speed: 80.0);
      
      final request = GetBatchedHandlersRequest(batchSize: 2, offset: 0);

      // Act
      final result = await server.getBatchedHandlers(mockCall, request);

      // Assert
      expect(result.handlers.length, 2);
    });
  });

  group('DatabaseServer Group Tests', () {
    test('getHandlersByGroup should return empty list when group does not exist', () async {
      // Arrange
      final request = GetHandlersByGroupRequest(group: 'nonexistent-group');

      // Act
      final result = await server.getHandlersByGroup(mockCall, request);

      // Assert
      expect(result.handlers, isEmpty);
    });

    test('getHandlersByGroup should work with valid group', () async {
      // Arrange
      // Create a test group first
      await database.into(database.outboundHandlerGroups).insert(
        const OutboundHandlerGroupsCompanion(name: Value('test-group')),
      );
      
      final handlerId = await insertTestHandler(speed: 100.0);
      
      // Add handler to group
      await database.into(database.outboundHandlerGroupRelations).insert(
        OutboundHandlerGroupRelationsCompanion(
          handlerId: Value(handlerId),
          groupName: const Value('test-group'),
        ),
      );
      
      final request = GetHandlersByGroupRequest(group: 'test-group');

      // Act
      final result = await server.getHandlersByGroup(mockCall, request);

      // Assert
      expect(result.handlers.length, 1);
      expect(result.handlers.first.id, handlerId);
    });
  });

  group('DatabaseServer Error Handling', () {
    test('should handle invalid update gracefully', () async {
      // Arrange
      final request = UpdateHandlerRequest(
        id: 99999,
        speed: 100.0,
      );

      // Act & Assert - should not throw, just update 0 rows
      final result = await server.updateHandler(mockCall, request);
      expect(result, isA<Receipt>());
    });
  });
}