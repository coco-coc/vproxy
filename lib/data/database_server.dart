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

import 'package:fixnum/fixnum.dart';
import 'package:grpc/service_api.dart';
import 'package:tm/protos/protos/db/db.pbgrpc.dart';
import 'package:vx/data/database.dart';
import 'package:drift/drift.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/logger.dart';

class DatabaseServer extends DbServiceBase {
  DatabaseServer({required this.database});

  late AppDatabase database;
  void setDatabase(AppDatabase database) {
    this.database = database;
  }

  @override
  Future<DbOutboundHandler> getHandler(
      ServiceCall call, GetHandlerRequest request) async {
    print('getHandler: ${request.id}');
    final handler = await (database.select(database.outboundHandlers)
          ..where((tbl) => tbl.id.equals(request.id.toInt())))
        .getSingleOrNull();
    if (handler == null) {
      throw Exception('Handler not found with id: ${request.id}');
    }
    return _convertToDbOutboundHandler(handler);
  }

  @override
  Future<DbHandlers> getBatchedHandlers(
      ServiceCall call, GetBatchedHandlersRequest request) async {
    logger.d('getBatchedHandlers: ${request.batchSize}, ${request.offset}');
    final handlers = await (database.select(database.outboundHandlers)
          ..limit(request.batchSize, offset: request.offset))
        .get();

    final dbHandlers = handlers.map(_convertToDbOutboundHandler).toList();
    return DbHandlers(handlers: dbHandlers);
  }

  @override
  Future<DbHandlers> getHandlersByGroup(
      ServiceCall call, GetHandlersByGroupRequest request) async {
    final query = database.select(database.outboundHandlers).join([
      innerJoin(
        database.outboundHandlerGroupRelations,
        database.outboundHandlerGroupRelations.handlerId
            .equalsExp(database.outboundHandlers.id),
      )
    ]);

    query.where(
        database.outboundHandlerGroupRelations.groupName.equals(request.group));
    final rows = await query.get();

    final dbHandlers = rows
        .map((row) => _convertToDbOutboundHandler(
            row.readTable(database.outboundHandlers)))
        .toList();
    return DbHandlers(handlers: dbHandlers);
  }

  @override
  Future<DbHandlers> getAllHandlers(
      ServiceCall call, GetAllHandlersRequest request) async {
    final handlers = await database.select(database.outboundHandlers).get();
    final dbHandlers = handlers.map(_convertToDbOutboundHandler).toList();
    return DbHandlers(handlers: dbHandlers);
  }

  @override
  Future<Receipt> updateHandler(
      ServiceCall call, UpdateHandlerRequest request) async {
    // Update handler by ID with new values from the request
    await (database.update(database.outboundHandlers)
          ..where((t) => t.id.equals(request.id.toInt())))
        .write(OutboundHandlersCompanion(
      speed: request.hasSpeed() ? Value(request.speed) : const Value.absent(),
      ping: request.hasPing() ? Value(request.ping) : const Value.absent(),
      ok: request.hasOk() ? Value(request.ok) : const Value.absent(),
      speedTestTime: request.hasSpeedTestTime()
          ? Value(request.speedTestTime)
          : const Value.absent(),
      pingTestTime: request.hasPingTestTime()
          ? Value(request.pingTestTime)
          : const Value.absent(),
      support6: request.hasSupport6()
          ? Value(request.support6)
          : const Value.absent(),
      support6TestTime: request.hasSupport6TestTime()
          ? Value(request.support6TestTime)
          : const Value.absent(),
    ));

    return Receipt();
  }

  DbOutboundHandler _convertToDbOutboundHandler(OutboundHandler row) {
    return DbOutboundHandler(
        id: Int64(row.id),
        tag: row.name,
        ok: row.ok,
        speed: row.speed,
        ping: row.ping,
        speedTestTime: row.speedTestTime,
        pingTestTime: row.pingTestTime,
        support6: row.support6,
        support6TestTime: row.support6TestTime,
        subId: row.subId != null ? Int64(row.subId!) : null,
        selected: row.selected,
        config: row.config.writeToBuffer());
  }
}
