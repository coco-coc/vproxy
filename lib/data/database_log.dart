import 'dart:async';
import 'dart:ffi';

import 'package:drift/drift.dart';
import 'package:fixnum/fixnum.dart';
import 'package:vx/data/sync.dart';
import 'package:vx/data/sync.pb.dart';
import 'package:vx/utils/logger.dart';

class LogInterceptor extends QueryInterceptor {
  Future<T> _run<T>(
      String description, FutureOr<T> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    print('Running $description');

    try {
      final result = await operation();
      print(' => succeeded after ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } on Object catch (e) {
      print(' => failed after ${stopwatch.elapsedMilliseconds}ms ($e)');
      rethrow;
    }
  }

  @override
  TransactionExecutor beginTransaction(QueryExecutor parent) {
    print('begin');
    return super.beginTransaction(parent);
  }

  @override
  Future<void> commitTransaction(TransactionExecutor inner) {
    return _run('commit', () => inner.send());
  }

  @override
  Future<void> rollbackTransaction(TransactionExecutor inner) {
    return _run('rollback', () => inner.rollback());
  }

  @override
  Future<void> runBatched(
      QueryExecutor executor, BatchedStatements statements) {
    return _run(
        'batch with $statements', () => executor.runBatched(statements));
  }

  @override
  Future<int> runInsert(
      QueryExecutor executor, String statement, List<Object?> args) {
    return _run(
        '$statement with $args', () => executor.runInsert(statement, args));
  }

  @override
  Future<int> runUpdate(
      QueryExecutor executor, String statement, List<Object?> args) {
    return _run(
        '$statement with $args', () => executor.runUpdate(statement, args));
  }

  @override
  Future<int> runDelete(
      QueryExecutor executor, String statement, List<Object?> args) {
    return _run(
        '$statement with $args', () => executor.runDelete(statement, args));
  }

  @override
  Future<void> runCustom(
      QueryExecutor executor, String statement, List<Object?> args) {
    return _run(
        '$statement with $args', () => executor.runCustom(statement, args));
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(
      QueryExecutor executor, String statement, List<Object?> args) {
    return _run(
        '$statement with $args', () => executor.runSelect(statement, args));
  }
}

extension SqlArgumentExtension on SqlArgument {
  static SqlArgument fromObject(Object? arg) {
    if (arg == null) {
      return SqlArgument();
    }
    switch (arg) {
      case String s:
        return SqlArgument(string: s);
      case BigInt b:
        return SqlArgument(int64: Int64((b).toInt()));
      case int i:
        return SqlArgument(int32: i);
      case bool b:
        return SqlArgument(bool_4: b);
      case Uint8List u:
        return SqlArgument(bytes: u);
      case double d:
        return SqlArgument(double_6: d);
      default:
        throw Exception('Unsupported argument type: ${arg.runtimeType}');
    }
  }

  Object? toObject() {
    if (hasIsNull()) {
      return null;
    }
    switch (whichType()) {
      case SqlArgument_Type.string:
        return string;
      case SqlArgument_Type.int64:
        return int64.toInt();
      case SqlArgument_Type.int32:
        return int32;
      case SqlArgument_Type.bool_4:
        return bool_4;
      case SqlArgument_Type.bytes:
        return bytes;
      case SqlArgument_Type.double_6:
        return double_6;
      case SqlArgument_Type.notSet:
        return null;
    }
  }
}

class DbSyncInterceptor extends QueryInterceptor {
  bool pause = false;
  Future<void> Function(SqlQuery)? uploadSqlQuery;

  DbSyncInterceptor();

  void _sync(SQLType type, String statements, List<Object?>? args) async {
    logger.d('$statements $args');
    await uploadSqlQuery!(SqlQuery(
      type: type,
      statement: statements,
      arguments: args?.map((e) => SqlArgumentExtension.fromObject(e)),
    ));
  }

  @override
  TransactionExecutor beginTransaction(QueryExecutor parent) {
    print('begin');
    return super.beginTransaction(parent);
  }

  @override
  Future<void> commitTransaction(TransactionExecutor inner) {
    print('commit');
    return inner.send();
  }

  @override
  Future<void> rollbackTransaction(TransactionExecutor inner) {
    print('rollback');
    return inner.rollback();
  }

  @override
  Future<void> runBatched(
      QueryExecutor executor, BatchedStatements statements) async {
    await executor.runBatched(statements);
    if (uploadSqlQuery != null && !pause) {
      _sync(SQLType.BATCH, statements.toString(), null);
    }
  }

  @override
  Future<int> runInsert(
      QueryExecutor executor, String statement, List<Object?> args) async {
    final result = await executor.runInsert(statement, args);
    if (uploadSqlQuery != null) {
      _sync(SQLType.INSERT, statement, args);
    }
    return result;
  }

  @override
  Future<int> runUpdate(
      QueryExecutor executor, String statement, List<Object?> args) async {
    final result = await executor.runUpdate(statement, args);
    if (uploadSqlQuery != null && !pause) {
      _sync(SQLType.UPDATE, statement, args);
    }
    return result;
  }

  @override
  Future<int> runDelete(
      QueryExecutor executor, String statement, List<Object?> args) async {
    final result = await executor.runDelete(statement, args);
    if (uploadSqlQuery != null && !pause) {
      _sync(SQLType.DELETE, statement, args);
    }
    return result;
  }

  @override
  Future<void> runCustom(
      QueryExecutor executor, String statement, List<Object?> args) async {
    await executor.runCustom(statement, args);
    if (uploadSqlQuery != null && !pause) {
      _sync(SQLType.CUSTOM, statement, args);
    }
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(
      QueryExecutor executor, String statement, List<Object?> args) async {
    final result = await executor.runSelect(statement, args);
    if (uploadSqlQuery != null && !pause && statement.startsWith('UPDATE')) {
      _sync(SQLType.UPDATE, statement, args);
    }
    return result;
  }
}
