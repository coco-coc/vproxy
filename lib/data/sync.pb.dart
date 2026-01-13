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

// This is a generated file - do not edit.
//
// Generated from sync.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'sync.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'sync.pbenum.dart';

enum SyncOperation_Type {
  sqlQuery, 
  addHandler, 
  sqlOperation, 
  serverOperation, 
  commonSshKeyOperation, 
  notSet
}

class SyncOperation extends $pb.GeneratedMessage {
  factory SyncOperation({
    $fixnum.Int64? time,
    SqlQuery? sqlQuery,
    AddHandler? addHandler,
    SqlOperation? sqlOperation,
    ServerOperation? serverOperation,
    CommonSshKeyOperation? commonSshKeyOperation,
  }) {
    final result = create();
    if (time != null) result.time = time;
    if (sqlQuery != null) result.sqlQuery = sqlQuery;
    if (addHandler != null) result.addHandler = addHandler;
    if (sqlOperation != null) result.sqlOperation = sqlOperation;
    if (serverOperation != null) result.serverOperation = serverOperation;
    if (commonSshKeyOperation != null) result.commonSshKeyOperation = commonSshKeyOperation;
    return result;
  }

  SyncOperation._();

  factory SyncOperation.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SyncOperation.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SyncOperation_Type> _SyncOperation_TypeByTag = {
    10 : SyncOperation_Type.sqlQuery,
    11 : SyncOperation_Type.addHandler,
    12 : SyncOperation_Type.sqlOperation,
    13 : SyncOperation_Type.serverOperation,
    14 : SyncOperation_Type.commonSshKeyOperation,
    0 : SyncOperation_Type.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncOperation', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..oo(0, [10, 11, 12, 13, 14])
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'time', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<SqlQuery>(10, _omitFieldNames ? '' : 'sqlQuery', subBuilder: SqlQuery.create)
    ..aOM<AddHandler>(11, _omitFieldNames ? '' : 'addHandler', subBuilder: AddHandler.create)
    ..aOM<SqlOperation>(12, _omitFieldNames ? '' : 'sqlOperation', subBuilder: SqlOperation.create)
    ..aOM<ServerOperation>(13, _omitFieldNames ? '' : 'serverOperation', subBuilder: ServerOperation.create)
    ..aOM<CommonSshKeyOperation>(14, _omitFieldNames ? '' : 'commonSshKeyOperation', subBuilder: CommonSshKeyOperation.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncOperation clone() => SyncOperation()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncOperation copyWith(void Function(SyncOperation) updates) => super.copyWith((message) => updates(message as SyncOperation)) as SyncOperation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncOperation create() => SyncOperation._();
  @$core.override
  SyncOperation createEmptyInstance() => create();
  static $pb.PbList<SyncOperation> createRepeated() => $pb.PbList<SyncOperation>();
  @$core.pragma('dart2js:noInline')
  static SyncOperation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncOperation>(create);
  static SyncOperation? _defaultInstance;

  SyncOperation_Type whichType() => _SyncOperation_TypeByTag[$_whichOneof(0)]!;
  void clearType() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $fixnum.Int64 get time => $_getI64(0);
  @$pb.TagNumber(1)
  set time($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearTime() => $_clearField(1);

  @$pb.TagNumber(10)
  SqlQuery get sqlQuery => $_getN(1);
  @$pb.TagNumber(10)
  set sqlQuery(SqlQuery value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasSqlQuery() => $_has(1);
  @$pb.TagNumber(10)
  void clearSqlQuery() => $_clearField(10);
  @$pb.TagNumber(10)
  SqlQuery ensureSqlQuery() => $_ensure(1);

  @$pb.TagNumber(11)
  AddHandler get addHandler => $_getN(2);
  @$pb.TagNumber(11)
  set addHandler(AddHandler value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasAddHandler() => $_has(2);
  @$pb.TagNumber(11)
  void clearAddHandler() => $_clearField(11);
  @$pb.TagNumber(11)
  AddHandler ensureAddHandler() => $_ensure(2);

  @$pb.TagNumber(12)
  SqlOperation get sqlOperation => $_getN(3);
  @$pb.TagNumber(12)
  set sqlOperation(SqlOperation value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasSqlOperation() => $_has(3);
  @$pb.TagNumber(12)
  void clearSqlOperation() => $_clearField(12);
  @$pb.TagNumber(12)
  SqlOperation ensureSqlOperation() => $_ensure(3);

  @$pb.TagNumber(13)
  ServerOperation get serverOperation => $_getN(4);
  @$pb.TagNumber(13)
  set serverOperation(ServerOperation value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasServerOperation() => $_has(4);
  @$pb.TagNumber(13)
  void clearServerOperation() => $_clearField(13);
  @$pb.TagNumber(13)
  ServerOperation ensureServerOperation() => $_ensure(4);

  @$pb.TagNumber(14)
  CommonSshKeyOperation get commonSshKeyOperation => $_getN(5);
  @$pb.TagNumber(14)
  set commonSshKeyOperation(CommonSshKeyOperation value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasCommonSshKeyOperation() => $_has(5);
  @$pb.TagNumber(14)
  void clearCommonSshKeyOperation() => $_clearField(14);
  @$pb.TagNumber(14)
  CommonSshKeyOperation ensureCommonSshKeyOperation() => $_ensure(5);
}

class SyncOperations extends $pb.GeneratedMessage {
  factory SyncOperations({
    $core.Iterable<SyncOperation>? operations,
  }) {
    final result = create();
    if (operations != null) result.operations.addAll(operations);
    return result;
  }

  SyncOperations._();

  factory SyncOperations.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SyncOperations.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncOperations', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..pc<SyncOperation>(1, _omitFieldNames ? '' : 'operations', $pb.PbFieldType.PM, subBuilder: SyncOperation.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncOperations clone() => SyncOperations()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncOperations copyWith(void Function(SyncOperations) updates) => super.copyWith((message) => updates(message as SyncOperations)) as SyncOperations;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncOperations create() => SyncOperations._();
  @$core.override
  SyncOperations createEmptyInstance() => create();
  static $pb.PbList<SyncOperations> createRepeated() => $pb.PbList<SyncOperations>();
  @$core.pragma('dart2js:noInline')
  static SyncOperations getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncOperations>(create);
  static SyncOperations? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SyncOperation> get operations => $_getList(0);
}

class AddHandler extends $pb.GeneratedMessage {
  factory AddHandler({
    $core.Iterable<$core.List<$core.int>>? handlers,
    $core.String? group,
  }) {
    final result = create();
    if (handlers != null) result.handlers.addAll(handlers);
    if (group != null) result.group = group;
    return result;
  }

  AddHandler._();

  factory AddHandler.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AddHandler.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddHandler', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..p<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'handlers', $pb.PbFieldType.PY)
    ..aOS(2, _omitFieldNames ? '' : 'group')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddHandler clone() => AddHandler()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddHandler copyWith(void Function(AddHandler) updates) => super.copyWith((message) => updates(message as AddHandler)) as AddHandler;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddHandler create() => AddHandler._();
  @$core.override
  AddHandler createEmptyInstance() => create();
  static $pb.PbList<AddHandler> createRepeated() => $pb.PbList<AddHandler>();
  @$core.pragma('dart2js:noInline')
  static AddHandler getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddHandler>(create);
  static AddHandler? _defaultInstance;

  /// a list of HandlerConfig
  @$pb.TagNumber(1)
  $pb.PbList<$core.List<$core.int>> get handlers => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get group => $_getSZ(1);
  @$pb.TagNumber(2)
  set group($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroup() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroup() => $_clearField(2);
}

class UpdateHandler extends $pb.GeneratedMessage {
  factory UpdateHandler({
    $core.List<$core.int>? newHandler,
    $core.List<$core.int>? oldHandler,
  }) {
    final result = create();
    if (newHandler != null) result.newHandler = newHandler;
    if (oldHandler != null) result.oldHandler = oldHandler;
    return result;
  }

  UpdateHandler._();

  factory UpdateHandler.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UpdateHandler.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateHandler', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'newHandler', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'oldHandler', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateHandler clone() => UpdateHandler()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateHandler copyWith(void Function(UpdateHandler) updates) => super.copyWith((message) => updates(message as UpdateHandler)) as UpdateHandler;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateHandler create() => UpdateHandler._();
  @$core.override
  UpdateHandler createEmptyInstance() => create();
  static $pb.PbList<UpdateHandler> createRepeated() => $pb.PbList<UpdateHandler>();
  @$core.pragma('dart2js:noInline')
  static UpdateHandler getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateHandler>(create);
  static UpdateHandler? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get newHandler => $_getN(0);
  @$pb.TagNumber(1)
  set newHandler($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNewHandler() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewHandler() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get oldHandler => $_getN(1);
  @$pb.TagNumber(2)
  set oldHandler($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOldHandler() => $_has(1);
  @$pb.TagNumber(2)
  void clearOldHandler() => $_clearField(2);
}

class DeleteHandler extends $pb.GeneratedMessage {
  factory DeleteHandler({
    $core.List<$core.int>? handler,
  }) {
    final result = create();
    if (handler != null) result.handler = handler;
    return result;
  }

  DeleteHandler._();

  factory DeleteHandler.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DeleteHandler.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteHandler', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'handler', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteHandler clone() => DeleteHandler()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteHandler copyWith(void Function(DeleteHandler) updates) => super.copyWith((message) => updates(message as DeleteHandler)) as DeleteHandler;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteHandler create() => DeleteHandler._();
  @$core.override
  DeleteHandler createEmptyInstance() => create();
  static $pb.PbList<DeleteHandler> createRepeated() => $pb.PbList<DeleteHandler>();
  @$core.pragma('dart2js:noInline')
  static DeleteHandler getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteHandler>(create);
  static DeleteHandler? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get handler => $_getN(0);
  @$pb.TagNumber(1)
  set handler($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHandler() => $_has(0);
  @$pb.TagNumber(1)
  void clearHandler() => $_clearField(1);
}

class AddSubscription extends $pb.GeneratedMessage {
  factory AddSubscription({
    $core.String? name,
    $core.String? url,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    return result;
  }

  AddSubscription._();

  factory AddSubscription.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AddSubscription.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddSubscription', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddSubscription clone() => AddSubscription()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddSubscription copyWith(void Function(AddSubscription) updates) => super.copyWith((message) => updates(message as AddSubscription)) as AddSubscription;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddSubscription create() => AddSubscription._();
  @$core.override
  AddSubscription createEmptyInstance() => create();
  static $pb.PbList<AddSubscription> createRepeated() => $pb.PbList<AddSubscription>();
  @$core.pragma('dart2js:noInline')
  static AddSubscription getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddSubscription>(create);
  static AddSubscription? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);
}

class UpdateSubscription extends $pb.GeneratedMessage {
  factory UpdateSubscription({
    $core.String? name,
    $core.String? url,
    $core.bool? nameChanged,
    $core.bool? urlChanged,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    if (nameChanged != null) result.nameChanged = nameChanged;
    if (urlChanged != null) result.urlChanged = urlChanged;
    return result;
  }

  UpdateSubscription._();

  factory UpdateSubscription.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UpdateSubscription.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateSubscription', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..aOB(3, _omitFieldNames ? '' : 'nameChanged')
    ..aOB(4, _omitFieldNames ? '' : 'urlChanged')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSubscription clone() => UpdateSubscription()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSubscription copyWith(void Function(UpdateSubscription) updates) => super.copyWith((message) => updates(message as UpdateSubscription)) as UpdateSubscription;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSubscription create() => UpdateSubscription._();
  @$core.override
  UpdateSubscription createEmptyInstance() => create();
  static $pb.PbList<UpdateSubscription> createRepeated() => $pb.PbList<UpdateSubscription>();
  @$core.pragma('dart2js:noInline')
  static UpdateSubscription getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateSubscription>(create);
  static UpdateSubscription? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get nameChanged => $_getBF(2);
  @$pb.TagNumber(3)
  set nameChanged($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNameChanged() => $_has(2);
  @$pb.TagNumber(3)
  void clearNameChanged() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get urlChanged => $_getBF(3);
  @$pb.TagNumber(4)
  set urlChanged($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUrlChanged() => $_has(3);
  @$pb.TagNumber(4)
  void clearUrlChanged() => $_clearField(4);
}

class DeleteSubscription extends $pb.GeneratedMessage {
  factory DeleteSubscription({
    $core.String? url,
  }) {
    final result = create();
    if (url != null) result.url = url;
    return result;
  }

  DeleteSubscription._();

  factory DeleteSubscription.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DeleteSubscription.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteSubscription', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteSubscription clone() => DeleteSubscription()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteSubscription copyWith(void Function(DeleteSubscription) updates) => super.copyWith((message) => updates(message as DeleteSubscription)) as DeleteSubscription;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteSubscription create() => DeleteSubscription._();
  @$core.override
  DeleteSubscription createEmptyInstance() => create();
  static $pb.PbList<DeleteSubscription> createRepeated() => $pb.PbList<DeleteSubscription>();
  @$core.pragma('dart2js:noInline')
  static DeleteSubscription getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteSubscription>(create);
  static DeleteSubscription? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);
}

class ServerOperation extends $pb.GeneratedMessage {
  factory ServerOperation({
    ServerOperation_Type? type,
    $core.String? row,
    $core.String? storageKey,
    $core.String? secureStorage,
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (row != null) result.row = row;
    if (storageKey != null) result.storageKey = storageKey;
    if (secureStorage != null) result.secureStorage = secureStorage;
    if (id != null) result.id = id;
    return result;
  }

  ServerOperation._();

  factory ServerOperation.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ServerOperation.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ServerOperation', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..e<ServerOperation_Type>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: ServerOperation_Type.ADD, valueOf: ServerOperation_Type.valueOf, enumValues: ServerOperation_Type.values)
    ..aOS(2, _omitFieldNames ? '' : 'row')
    ..aOS(3, _omitFieldNames ? '' : 'storageKey')
    ..aOS(4, _omitFieldNames ? '' : 'secureStorage')
    ..aInt64(5, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerOperation clone() => ServerOperation()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerOperation copyWith(void Function(ServerOperation) updates) => super.copyWith((message) => updates(message as ServerOperation)) as ServerOperation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerOperation create() => ServerOperation._();
  @$core.override
  ServerOperation createEmptyInstance() => create();
  static $pb.PbList<ServerOperation> createRepeated() => $pb.PbList<ServerOperation>();
  @$core.pragma('dart2js:noInline')
  static ServerOperation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServerOperation>(create);
  static ServerOperation? _defaultInstance;

  @$pb.TagNumber(1)
  ServerOperation_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(ServerOperation_Type value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get row => $_getSZ(1);
  @$pb.TagNumber(2)
  set row($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRow() => $_has(1);
  @$pb.TagNumber(2)
  void clearRow() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get storageKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set storageKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStorageKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearStorageKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get secureStorage => $_getSZ(3);
  @$pb.TagNumber(4)
  set secureStorage($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSecureStorage() => $_has(3);
  @$pb.TagNumber(4)
  void clearSecureStorage() => $_clearField(4);

  /// delete only
  @$pb.TagNumber(5)
  $fixnum.Int64 get id => $_getI64(4);
  @$pb.TagNumber(5)
  set id($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasId() => $_has(4);
  @$pb.TagNumber(5)
  void clearId() => $_clearField(5);
}

class CommonSshKeyOperation extends $pb.GeneratedMessage {
  factory CommonSshKeyOperation({
    CommonSshKeyOperation_Type? type,
    $core.String? row,
    $core.String? storageKey,
    $core.String? secureStorage,
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (row != null) result.row = row;
    if (storageKey != null) result.storageKey = storageKey;
    if (secureStorage != null) result.secureStorage = secureStorage;
    if (id != null) result.id = id;
    return result;
  }

  CommonSshKeyOperation._();

  factory CommonSshKeyOperation.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CommonSshKeyOperation.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommonSshKeyOperation', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..e<CommonSshKeyOperation_Type>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: CommonSshKeyOperation_Type.ADD, valueOf: CommonSshKeyOperation_Type.valueOf, enumValues: CommonSshKeyOperation_Type.values)
    ..aOS(2, _omitFieldNames ? '' : 'row')
    ..aOS(3, _omitFieldNames ? '' : 'storageKey')
    ..aOS(4, _omitFieldNames ? '' : 'secureStorage')
    ..aInt64(5, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommonSshKeyOperation clone() => CommonSshKeyOperation()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommonSshKeyOperation copyWith(void Function(CommonSshKeyOperation) updates) => super.copyWith((message) => updates(message as CommonSshKeyOperation)) as CommonSshKeyOperation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommonSshKeyOperation create() => CommonSshKeyOperation._();
  @$core.override
  CommonSshKeyOperation createEmptyInstance() => create();
  static $pb.PbList<CommonSshKeyOperation> createRepeated() => $pb.PbList<CommonSshKeyOperation>();
  @$core.pragma('dart2js:noInline')
  static CommonSshKeyOperation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommonSshKeyOperation>(create);
  static CommonSshKeyOperation? _defaultInstance;

  @$pb.TagNumber(1)
  CommonSshKeyOperation_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(CommonSshKeyOperation_Type value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get row => $_getSZ(1);
  @$pb.TagNumber(2)
  set row($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRow() => $_has(1);
  @$pb.TagNumber(2)
  void clearRow() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get storageKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set storageKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStorageKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearStorageKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get secureStorage => $_getSZ(3);
  @$pb.TagNumber(4)
  set secureStorage($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSecureStorage() => $_has(3);
  @$pb.TagNumber(4)
  void clearSecureStorage() => $_clearField(4);

  /// delete only
  @$pb.TagNumber(5)
  $fixnum.Int64 get id => $_getI64(4);
  @$pb.TagNumber(5)
  set id($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasId() => $_has(4);
  @$pb.TagNumber(5)
  void clearId() => $_clearField(5);
}

class SqlOperation extends $pb.GeneratedMessage {
  factory SqlOperation({
    SQLType? type,
    $core.String? table,
    $core.Iterable<$core.String>? rows,
    $core.Iterable<$fixnum.Int64>? ids,
    $core.Iterable<$core.String>? names,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (table != null) result.table = table;
    if (rows != null) result.rows.addAll(rows);
    if (ids != null) result.ids.addAll(ids);
    if (names != null) result.names.addAll(names);
    return result;
  }

  SqlOperation._();

  factory SqlOperation.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SqlOperation.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SqlOperation', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..e<SQLType>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: SQLType.INSERT, valueOf: SQLType.valueOf, enumValues: SQLType.values)
    ..aOS(2, _omitFieldNames ? '' : 'table')
    ..pPS(3, _omitFieldNames ? '' : 'rows')
    ..p<$fixnum.Int64>(4, _omitFieldNames ? '' : 'ids', $pb.PbFieldType.K6)
    ..pPS(5, _omitFieldNames ? '' : 'names')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SqlOperation clone() => SqlOperation()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SqlOperation copyWith(void Function(SqlOperation) updates) => super.copyWith((message) => updates(message as SqlOperation)) as SqlOperation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SqlOperation create() => SqlOperation._();
  @$core.override
  SqlOperation createEmptyInstance() => create();
  static $pb.PbList<SqlOperation> createRepeated() => $pb.PbList<SqlOperation>();
  @$core.pragma('dart2js:noInline')
  static SqlOperation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SqlOperation>(create);
  static SqlOperation? _defaultInstance;

  @$pb.TagNumber(1)
  SQLType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SQLType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get table => $_getSZ(1);
  @$pb.TagNumber(2)
  set table($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTable() => $_has(1);
  @$pb.TagNumber(2)
  void clearTable() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get rows => $_getList(2);

  /// delete only
  @$pb.TagNumber(4)
  $pb.PbList<$fixnum.Int64> get ids => $_getList(3);

  /// delete only
  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get names => $_getList(4);
}

class SqlQuery extends $pb.GeneratedMessage {
  factory SqlQuery({
    SQLType? type,
    $core.String? statement,
    $core.Iterable<SqlArgument>? arguments,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (statement != null) result.statement = statement;
    if (arguments != null) result.arguments.addAll(arguments);
    return result;
  }

  SqlQuery._();

  factory SqlQuery.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SqlQuery.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SqlQuery', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..e<SQLType>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: SQLType.INSERT, valueOf: SQLType.valueOf, enumValues: SQLType.values)
    ..aOS(10, _omitFieldNames ? '' : 'statement')
    ..pc<SqlArgument>(11, _omitFieldNames ? '' : 'arguments', $pb.PbFieldType.PM, subBuilder: SqlArgument.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SqlQuery clone() => SqlQuery()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SqlQuery copyWith(void Function(SqlQuery) updates) => super.copyWith((message) => updates(message as SqlQuery)) as SqlQuery;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SqlQuery create() => SqlQuery._();
  @$core.override
  SqlQuery createEmptyInstance() => create();
  static $pb.PbList<SqlQuery> createRepeated() => $pb.PbList<SqlQuery>();
  @$core.pragma('dart2js:noInline')
  static SqlQuery getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SqlQuery>(create);
  static SqlQuery? _defaultInstance;

  @$pb.TagNumber(1)
  SQLType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SQLType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(10)
  $core.String get statement => $_getSZ(1);
  @$pb.TagNumber(10)
  set statement($core.String value) => $_setString(1, value);
  @$pb.TagNumber(10)
  $core.bool hasStatement() => $_has(1);
  @$pb.TagNumber(10)
  void clearStatement() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbList<SqlArgument> get arguments => $_getList(2);
}

enum SqlArgument_Type {
  string, 
  int64, 
  int32, 
  bool_4, 
  bytes, 
  double_6, 
  notSet
}

class SqlArgument extends $pb.GeneratedMessage {
  factory SqlArgument({
    $core.String? string,
    $fixnum.Int64? int64,
    $core.int? int32,
    $core.bool? bool_4,
    $core.List<$core.int>? bytes,
    $core.double? double_6,
    $core.bool? isNull,
  }) {
    final result = create();
    if (string != null) result.string = string;
    if (int64 != null) result.int64 = int64;
    if (int32 != null) result.int32 = int32;
    if (bool_4 != null) result.bool_4 = bool_4;
    if (bytes != null) result.bytes = bytes;
    if (double_6 != null) result.double_6 = double_6;
    if (isNull != null) result.isNull = isNull;
    return result;
  }

  SqlArgument._();

  factory SqlArgument.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SqlArgument.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SqlArgument_Type> _SqlArgument_TypeByTag = {
    1 : SqlArgument_Type.string,
    2 : SqlArgument_Type.int64,
    3 : SqlArgument_Type.int32,
    4 : SqlArgument_Type.bool_4,
    5 : SqlArgument_Type.bytes,
    6 : SqlArgument_Type.double_6,
    0 : SqlArgument_Type.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SqlArgument', package: const $pb.PackageName(_omitMessageNames ? '' : 'vx'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6])
    ..aOS(1, _omitFieldNames ? '' : 'string')
    ..aInt64(2, _omitFieldNames ? '' : 'int64')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'int32', $pb.PbFieldType.O3)
    ..aOB(4, _omitFieldNames ? '' : 'bool')
    ..a<$core.List<$core.int>>(5, _omitFieldNames ? '' : 'bytes', $pb.PbFieldType.OY)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'double', $pb.PbFieldType.OF)
    ..aOB(10, _omitFieldNames ? '' : 'isNull')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SqlArgument clone() => SqlArgument()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SqlArgument copyWith(void Function(SqlArgument) updates) => super.copyWith((message) => updates(message as SqlArgument)) as SqlArgument;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SqlArgument create() => SqlArgument._();
  @$core.override
  SqlArgument createEmptyInstance() => create();
  static $pb.PbList<SqlArgument> createRepeated() => $pb.PbList<SqlArgument>();
  @$core.pragma('dart2js:noInline')
  static SqlArgument getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SqlArgument>(create);
  static SqlArgument? _defaultInstance;

  SqlArgument_Type whichType() => _SqlArgument_TypeByTag[$_whichOneof(0)]!;
  void clearType() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get string => $_getSZ(0);
  @$pb.TagNumber(1)
  set string($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasString() => $_has(0);
  @$pb.TagNumber(1)
  void clearString() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get int64 => $_getI64(1);
  @$pb.TagNumber(2)
  set int64($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInt64() => $_has(1);
  @$pb.TagNumber(2)
  void clearInt64() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get int32 => $_getIZ(2);
  @$pb.TagNumber(3)
  set int32($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInt32() => $_has(2);
  @$pb.TagNumber(3)
  void clearInt32() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get bool_4 => $_getBF(3);
  @$pb.TagNumber(4)
  set bool_4($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBool_4() => $_has(3);
  @$pb.TagNumber(4)
  void clearBool_4() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get bytes => $_getN(4);
  @$pb.TagNumber(5)
  set bytes($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get double_6 => $_getN(5);
  @$pb.TagNumber(6)
  set double_6($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDouble_6() => $_has(5);
  @$pb.TagNumber(6)
  void clearDouble_6() => $_clearField(6);

  @$pb.TagNumber(10)
  $core.bool get isNull => $_getBF(6);
  @$pb.TagNumber(10)
  set isNull($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(10)
  $core.bool hasIsNull() => $_has(6);
  @$pb.TagNumber(10)
  void clearIsNull() => $_clearField(10);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
