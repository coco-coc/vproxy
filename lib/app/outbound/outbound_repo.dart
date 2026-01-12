// Copyright (C) 2026 5V Network LLC <5vnetwork@proton.me>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';

import 'package:drift/drift.dart';
import 'package:lru_cache/lru_cache.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:vx/app/outbound/outbounds_bloc.dart';
import 'package:vx/app/outbound/subscription.dart';
import 'package:vx/app/routing/routing_page.dart';
import 'package:vx/data/database.dart';
import 'package:vx/data/database_provider.dart';
import 'package:vx/data/sync.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/random.dart';
// import 'package:vx/data/object_box.dart';

// tag handlers change, single handler change,
class OutboundRepo {
  OutboundRepo({required this.databaseProvider});

  DatabaseProvider databaseProvider;

  final LruCache<String, String> _handlerIdToName = LruCache(500);

  /// id might be "1" or "1-2-3"(in the case of chain handler)
  /// return the name of the handler if it is a single handler or "→${name of the land handler}"
  Future<String> getHandlerName(String id) async {
    if (id == directEN) {
      return id;
    }

    if (id.isEmpty) {
      return "";
    }

    try {
      final name = await _handlerIdToName.get(id);
      if (name != null) {
        return name;
      }
      if (id.contains('-')) {
        final last = id.split('-').last;
        final handler = await getHandlerById(int.parse(last));
        if (handler != null) {
          final name = '🛬${handler.name}';
          _handlerIdToName.put(id, name);
          return name;
        }
      } else {
        final handler = await getHandlerById(int.parse(id));
        if (handler != null) {
          _handlerIdToName.put(id, handler.name);
          return handler.name;
        }
      }
    } catch (e) {
      logger.e('getHandlerName error: $e. id: $id');
    }
    return id;
  }

  Future<List<OutboundHandler>> getAllHandlers() async {
    return await databaseProvider.database.managers.outboundHandlers.get();
  }

  Future<List<OutboundHandler>> getHandlersByNodeGroup(NodeGroup group) async {
    if (group is OutboundHandlerGroup) {
      return await getHandlersByGroup(group.name);
    } else if (group is Subscription) {
      return await getHandlers(subId: (group as Subscription).id);
    }
    return [];
  }

  Future<void> addHandlerGroup(String name) async {
    await databaseProvider.database.insertReturning(
        databaseProvider.database.outboundHandlerGroups,
        OutboundHandlerGroupsCompanion(name: Value(name)));
    // await database
    //     .into(databaseProvider.database.outboundHandlerGroups)
    //     .insert(OutboundHandlerGroupsCompanion(name: Value(name)));
  }

  Future<void> removeHandlerGroup(String name) async {
    await databaseProvider.database
        .deleteByName(databaseProvider.database.outboundHandlerGroups, name);
    // await (databaseProvider.database.delete(databaseProvider.database.outboundHandlerGroups)
    //       ..where((g) => g.name.equals(name)))
    //     .go();
  }

  Future<void> addHandlerToGroup(String groupName, List<int> handlerIds) async {
    await databaseProvider.database.transactionInsert(
      databaseProvider.database.outboundHandlerGroupRelations,
      handlerIds
          .map((e) => OutboundHandlerGroupRelationsCompanion(
              handlerId: Value(e), groupName: Value(groupName)))
          .toList(),
    );
  }

  /// Get all handlers belonging to a specific group
  Future<List<OutboundHandler>> getHandlersByGroup(String groupName) async {
    // Join with the junction table to filter by group name
    final q = databaseProvider.database
        .select(databaseProvider.database.outboundHandlers)
        .join([
      innerJoin(
          databaseProvider.database.outboundHandlerGroupRelations,
          databaseProvider.database.outboundHandlerGroupRelations.handlerId
              .equalsExp(databaseProvider.database.outboundHandlers.id),
          useColumns: false),
    ])
      ..where(databaseProvider.database.outboundHandlerGroupRelations.groupName
          .equals(groupName));
    return q
        .map((row) => row.readTable(databaseProvider.database.outboundHandlers))
        .get();
  }

  Future<List<String>> getAllCountryCodes() async {
    final query = databaseProvider.database
        .selectOnly(databaseProvider.database.outboundHandlers, distinct: true)
      ..addColumns([databaseProvider.database.outboundHandlers.countryCode])
      ..where(
          databaseProvider.database.outboundHandlers.countryCode.isNotNull())
      ..where(databaseProvider.database.outboundHandlers.countryCode
          .isNotValue(''));

    final results = await query.get();
    return results
        .map((row) =>
            row.read(databaseProvider.database.outboundHandlers.countryCode) ??
            '')
        .where((code) => code.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<OutboundHandler>> getHandlers(
      {int? subId,
      double? speed1MBLessEqual,
      bool? usable,
      int? ok,
      bool? selected,
      bool orderBySpeed1MBDesc = false,
      String? country,
      int? limit}) async {
    // Create a query to get handlers filtered by the parameters
    final query = _getQueryBuilder(
        subId: subId,
        usable: usable,
        selected: selected,
        limit: limit,
        ok: ok,
        country: country,
        orderBySpeed1MBDesc: orderBySpeed1MBDesc);

    // Execute the query and return the results
    return query.get();
  }

  SimpleSelectStatement<$OutboundHandlersTable, OutboundHandler>
      _getQueryBuilder(
          {int? subId,
          bool? usable,
          String? country,
          int? ok,
          bool? selected,
          bool orderBySpeed1MBDesc = false,
          bool orderByPingAsc = false,
          int? limit}) {
    // Create a query to get handlers filtered by the parameters
    final query = databaseProvider.database
        .select(databaseProvider.database.outboundHandlers);

    // Apply filters based on parameters
    if (subId != null) {
      query.where((tbl) => tbl.subId.equals(subId));
    }

    // if (defaultGroup != null && defaultGroup) {
    //   query.where((tbl) => tbl.subId.isNull());
    // }

    if (usable != null) {
      query.where((tbl) => tbl.ok.isBiggerOrEqualValue(0));
    }

    if (ok != null) {
      query.where((tbl) => tbl.ok.equals(ok));
    }

    // if (usableNotEqual != null) {
    //   query.where((tbl) => tbl.ok.isNotValue(usableNotEqual));
    // }

    if (selected != null) {
      query.where((tbl) => tbl.selected.equals(selected));
    }

    if (country != null) {
      query.where((tbl) => tbl.countryCode.equals(country));
    }

    if (orderBySpeed1MBDesc) {
      query.orderBy(
          [(t) => OrderingTerm(expression: t.speed, mode: OrderingMode.desc)]);
    } else if (orderByPingAsc) {
      query.where((tbl) => tbl.ping.isBiggerThanValue(0));
      query.orderBy(
          [(t) => OrderingTerm(expression: t.ping, mode: OrderingMode.asc)]);
    }

    // Apply limit if specified
    if (limit != null) {
      query.limit(limit);
    }

    return query;
  }

  /// Get a stream of handlers. Stream will emit whenever there is a change
  Stream<List<OutboundHandler>> getHandlersStream({
    int? subId,
    double? speed1MBLessEqual,
    bool orderBySpeed1MBDesc = false,
    bool orderByPingAsc = false,
    int? limit,
    bool? usable,
    bool? selected,
    String? groupName,
  }) {
    final q = _getQueryBuilder(
        subId: subId,
        usable: usable,
        selected: selected,
        limit: limit,
        orderBySpeed1MBDesc: orderBySpeed1MBDesc,
        orderByPingAsc: orderByPingAsc);
    return q.watch();
  }

  Future<OutboundHandler?> getHandlerById(int id) async {
    return await (databaseProvider.database
            .select(databaseProvider.database.outboundHandlers)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Subscription>> getAllSubs() async {
    return await (databaseProvider.database
            .select(databaseProvider.database.subscriptions))
        .get();
  }

  // Future<void> removeHandlerById(int id) async {
  //   await (databaseProvider.database.delete(databaseProvider.database.outboundHandlers)..where((tbl) => tbl.id.equals(id)))
  //       .go();
  // }

  Future<void> removeHandlersByIds(List<int> ids) async {
    await databaseProvider.database
        .deleteById(databaseProvider.database.outboundHandlers, ids);
    // await (databaseProvider.database.delete(databaseProvider.database.outboundHandlers)..where((tbl) => tbl.id.isIn(ids)))
    //     .go();
  }

  /// handlers should all have id 0.
  /// if group does not exist, it will be created.
  Future<List<OutboundHandler?>> insertHandlersWithGroup(
      List<HandlerConfig> handlers,
      {String groupName = defaultGroupName}) async {
    final result = <OutboundHandler?>[];
    await databaseProvider.database.transaction(() async {
      // create group if not exists
      final existingGroup = await (databaseProvider.database
              .select(databaseProvider.database.outboundHandlerGroups)
            ..where((g) => g.name.equals(groupName)))
          .getSingleOrNull();
      if (existingGroup == null) {
        await databaseProvider.database
            .into(databaseProvider.database.outboundHandlerGroups)
            .insert(OutboundHandlerGroupsCompanion(name: Value(groupName)));
      }
      // insert handlers and relations
      for (var handler in handlers) {
        final h = await databaseProvider.database.insertReturning(
          databaseProvider.database.outboundHandlers,
          OutboundHandlersCompanion(
            id: Value(SnowflakeId.generate()),
            config: Value(handler),
          ),
        );
        result.add(h);
        await databaseProvider.database.insertReturning(
          databaseProvider.database.outboundHandlerGroupRelations,
          OutboundHandlerGroupRelationsCompanion(
              handlerId: Value(h.id), groupName: Value(groupName)),
        );
        // await databaseProvider.database.into(databaseProvider.database.outboundHandlerGroupRelations).insert(
        //     OutboundHandlerGroupRelationsCompanion(
        //         handlerId: Value(h.id), groupName: Value(groupName)));
      }
    });
    // unawaited(syncService.addHandler(handlers, group: groupName));
    return result;
  }

  // Future<void> updateHandlers(
  //     List<OutboundHandlersCompanion> companions) async {
  //   await databaseProvider.database.transaction(() async {
  //     for (var companion in companions) {
  //       await databaseProvider.database.update(databaseProvider.database.outboundHandlers).write(companion);
  //     }
  //   });
  // }

  /// clear fields of all handlers
  Future<void> updateHandlerFields(List<int> ids,
      {double? speed, int? ping, int? ok, bool? enabled}) async {
    OutboundHandlersCompanion companion = OutboundHandlersCompanion(
      speed: speed != null ? Value(speed) : const Value.absent(),
      ping: ping != null ? Value(ping) : const Value.absent(),
      ok: ok != null ? Value(ok) : const Value.absent(),
    );
    await databaseProvider.database.transaction(() async {
      for (var id in ids) {
        await (databaseProvider.database
                .update(databaseProvider.database.outboundHandlers)
              ..where((t) => t.id.equals(id)))
            .write(companion);
      }
    });
  }

  Future<void> updateHandlersTx(Map<int, OutboundHandlersCompanion> map) async {
    await databaseProvider.database.transaction(() async {
      for (var entry in map.entries) {
        await (databaseProvider.database
                .update(databaseProvider.database.outboundHandlers)
              ..where((t) => t.id.equals(entry.key)))
            .write(entry.value);
      }
    });
  }

  Future<OutboundHandler?> updateHandler(int id,
      {double? speed,
      int? ping,
      int? dping,
      int? ok,
      int? pingTestTime,
      int? speedTestTime,
      String? country,
      bool? selected,
      bool? enabled,
      String? serverIp}) async {
    return (await (databaseProvider.database
                .update(databaseProvider.database.outboundHandlers)
              ..where((t) => t.id.equals(id)))
            .writeReturning(OutboundHandlersCompanion(
      countryCode: country != null ? Value(country) : const Value.absent(),
      speed: speed != null ? Value(speed) : const Value.absent(),
      // speed1: speed1 != null ? Value(speed1) : const Value.absent(),
      ping: ping != null ? Value(ping) : const Value.absent(),
      pingTestTime:
          pingTestTime != null ? Value(pingTestTime) : const Value.absent(),
      speedTestTime:
          speedTestTime != null ? Value(speedTestTime) : const Value.absent(),
      ok: ok != null ? Value(ok) : const Value.absent(),
      selected: selected != null ? Value(selected) : const Value.absent(),
      serverIp: serverIp != null ? Value(serverIp) : const Value.absent(),
    )))
        .firstOrNull;
  }

  /// Replace an existing handler
  Future<void> replaceHandler(OutboundHandler h) async {
    await (databaseProvider.database.updateById(
      databaseProvider.database.outboundHandlers,
      h.id,
      h.toCompanion().copyWith(updatedAt: Value(DateTime.now())),
    ));
  }

  Future<int> getNumOfSubs() async {
    return (await (databaseProvider.database
                .select(databaseProvider.database.subscriptions))
            .get())
        .length;
  }

  Future<List<Subscription>> getSubsByName(String name) async {
    return await (databaseProvider.database
            .select(databaseProvider.database.subscriptions)
          ..where((tbl) => tbl.name.equals(name)))
        .get();
  }

  Future<List<OutboundHandlerGroup>> getGroups() async {
    return await (databaseProvider.database
            .select(databaseProvider.database.outboundHandlerGroups))
        .get();
  }

  Stream<List<OutboundHandlerGroup>> getStreamOfGroups() {
    return databaseProvider.database
        .select(databaseProvider.database.outboundHandlerGroups)
        .watch();
  }

  Stream<List<MySubscription>> getStreamOfSubs({int? limit, bool? stared}) {
    final q = databaseProvider.database
        .select(databaseProvider.database.subscriptions);
    if (stared != null) {
      q.where((tbl) => tbl.placeOnTop.equals(stared));
    }

    q.orderBy([
      (t) => OrderingTerm(expression: t.placeOnTop, mode: OrderingMode.desc)
    ]);

    if (limit != null) {
      q.limit(limit);
    }

    return q.watch().map((q) => q
        .map((e) => MySubscription(
              id: e.id,
              name: e.name,
              link: e.link,
              lastUpdate: e.lastUpdate,
              remainingData: e.remainingData,
              endTime: e.endTime,
              website: e.website,
              description: e.description,
              lastSuccessUpdate: e.lastSuccessUpdate,
              placeOnTop: e.placeOnTop,
            ))
        .toList());
  }

  Future<Subscription> insertSubscription(
    SubscriptionsCompanion sub,
  ) async {
    final newSub = await databaseProvider.database.insertReturning(
        databaseProvider.database.subscriptions, sub,
        mode: InsertMode.insert);
    return newSub;
  }

  Future<Subscription> updateSubscription(int id,
      {String? name, String? link, bool? enabled, bool? placeOnTop}) async {
    return await databaseProvider.database.updateById(
      databaseProvider.database.subscriptions,
      id,
      SubscriptionsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        link: link != null ? Value(link) : const Value.absent(),
        placeOnTop:
            placeOnTop != null ? Value(placeOnTop) : const Value.absent(),
      ),
    );
  }

  Future<OutboundHandlerGroup> updateOutboundHandlerGroup(String name,
      {bool? placeOnTop}) async {
    return (await (databaseProvider.database
                .update(databaseProvider.database.outboundHandlerGroups)
              ..where((t) => t.name.equals(name)))
            .writeReturning(OutboundHandlerGroupsCompanion(
      updatedAt: Value(DateTime.now()),
      placeOnTop: placeOnTop != null ? Value(placeOnTop) : const Value.absent(),
    )))
        .first;
  }

  /// remove a subscription and all its handlers
  Future<void> removeSubscription(int id) async {
    // await (databaseProvider.database.delete(databaseProvider.database.subscriptions)..where((t) => t.id.equals(id))).go();
    await databaseProvider.database.deleteById(
      databaseProvider.database.subscriptions,
      [id],
    );
  }
}

/// Handler configs from handlers
///
/// Each handler should have a non-zero id
List<HandlerConfig> handlersToHandlerConfig(List<OutboundHandler> handlers) {
  return handlers.map((e) => e.toConfig()).toList();
}
