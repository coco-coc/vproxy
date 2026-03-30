// This is a generated file - do not edit.
//
// Generated from db.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Receipt extends $pb.GeneratedMessage {
  factory Receipt() => create();

  Receipt._();

  factory Receipt.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Receipt.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Receipt',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vx.db'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Receipt clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Receipt copyWith(void Function(Receipt) updates) =>
      super.copyWith((message) => updates(message as Receipt)) as Receipt;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Receipt create() => Receipt._();
  @$core.override
  Receipt createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Receipt getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Receipt>(create);
  static Receipt? _defaultInstance;
}

class GetHandlerRequest extends $pb.GeneratedMessage {
  factory GetHandlerRequest({
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetHandlerRequest._();

  factory GetHandlerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHandlerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHandlerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vx.db'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHandlerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHandlerRequest copyWith(void Function(GetHandlerRequest) updates) =>
      super.copyWith((message) => updates(message as GetHandlerRequest))
          as GetHandlerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHandlerRequest create() => GetHandlerRequest._();
  @$core.override
  GetHandlerRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHandlerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHandlerRequest>(create);
  static GetHandlerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetAllHandlersRequest extends $pb.GeneratedMessage {
  factory GetAllHandlersRequest() => create();

  GetAllHandlersRequest._();

  factory GetAllHandlersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAllHandlersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAllHandlersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vx.db'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllHandlersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllHandlersRequest copyWith(
          void Function(GetAllHandlersRequest) updates) =>
      super.copyWith((message) => updates(message as GetAllHandlersRequest))
          as GetAllHandlersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAllHandlersRequest create() => GetAllHandlersRequest._();
  @$core.override
  GetAllHandlersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAllHandlersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAllHandlersRequest>(create);
  static GetAllHandlersRequest? _defaultInstance;
}

class GetHandlersByGroupRequest extends $pb.GeneratedMessage {
  factory GetHandlersByGroupRequest({
    $core.String? group,
  }) {
    final result = create();
    if (group != null) result.group = group;
    return result;
  }

  GetHandlersByGroupRequest._();

  factory GetHandlersByGroupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHandlersByGroupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHandlersByGroupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vx.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'group')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHandlersByGroupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHandlersByGroupRequest copyWith(
          void Function(GetHandlersByGroupRequest) updates) =>
      super.copyWith((message) => updates(message as GetHandlersByGroupRequest))
          as GetHandlersByGroupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHandlersByGroupRequest create() => GetHandlersByGroupRequest._();
  @$core.override
  GetHandlersByGroupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHandlersByGroupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHandlersByGroupRequest>(create);
  static GetHandlersByGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get group => $_getSZ(0);
  @$pb.TagNumber(1)
  set group($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
}

class GetBatchedHandlersRequest extends $pb.GeneratedMessage {
  factory GetBatchedHandlersRequest({
    $core.int? batchSize,
    $core.int? offset,
  }) {
    final result = create();
    if (batchSize != null) result.batchSize = batchSize;
    if (offset != null) result.offset = offset;
    return result;
  }

  GetBatchedHandlersRequest._();

  factory GetBatchedHandlersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBatchedHandlersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBatchedHandlersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vx.db'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'batchSize', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'offset', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBatchedHandlersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBatchedHandlersRequest copyWith(
          void Function(GetBatchedHandlersRequest) updates) =>
      super.copyWith((message) => updates(message as GetBatchedHandlersRequest))
          as GetBatchedHandlersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBatchedHandlersRequest create() => GetBatchedHandlersRequest._();
  @$core.override
  GetBatchedHandlersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBatchedHandlersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBatchedHandlersRequest>(create);
  static GetBatchedHandlersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get batchSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set batchSize($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBatchSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearBatchSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get offset => $_getIZ(1);
  @$pb.TagNumber(2)
  set offset($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => $_clearField(2);
}

class DbHandlers extends $pb.GeneratedMessage {
  factory DbHandlers({
    $core.Iterable<DbOutboundHandler>? handlers,
  }) {
    final result = create();
    if (handlers != null) result.handlers.addAll(handlers);
    return result;
  }

  DbHandlers._();

  factory DbHandlers.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DbHandlers.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DbHandlers',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vx.db'),
      createEmptyInstance: create)
    ..pPM<DbOutboundHandler>(1, _omitFieldNames ? '' : 'handlers',
        subBuilder: DbOutboundHandler.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DbHandlers clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DbHandlers copyWith(void Function(DbHandlers) updates) =>
      super.copyWith((message) => updates(message as DbHandlers)) as DbHandlers;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DbHandlers create() => DbHandlers._();
  @$core.override
  DbHandlers createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DbHandlers getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DbHandlers>(create);
  static DbHandlers? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DbOutboundHandler> get handlers => $_getList(0);
}

class DbOutboundHandler extends $pb.GeneratedMessage {
  factory DbOutboundHandler({
    $fixnum.Int64? id,
    $core.String? tag,
    $core.int? ok,
    $core.double? speed,
    $core.int? speedTestTime,
    $core.int? ping,
    $core.int? pingTestTime,
    $core.int? support6,
    $core.int? support6TestTime,
    $core.List<$core.int>? config,
    $core.bool? selected,
    $fixnum.Int64? subId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tag != null) result.tag = tag;
    if (ok != null) result.ok = ok;
    if (speed != null) result.speed = speed;
    if (speedTestTime != null) result.speedTestTime = speedTestTime;
    if (ping != null) result.ping = ping;
    if (pingTestTime != null) result.pingTestTime = pingTestTime;
    if (support6 != null) result.support6 = support6;
    if (support6TestTime != null) result.support6TestTime = support6TestTime;
    if (config != null) result.config = config;
    if (selected != null) result.selected = selected;
    if (subId != null) result.subId = subId;
    return result;
  }

  DbOutboundHandler._();

  factory DbOutboundHandler.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DbOutboundHandler.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DbOutboundHandler',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vx.db'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tag')
    ..aI(3, _omitFieldNames ? '' : 'ok')
    ..aD(4, _omitFieldNames ? '' : 'speed', fieldType: $pb.PbFieldType.OF)
    ..aI(5, _omitFieldNames ? '' : 'speedTestTime')
    ..aI(6, _omitFieldNames ? '' : 'ping')
    ..aI(7, _omitFieldNames ? '' : 'pingTestTime')
    ..aI(8, _omitFieldNames ? '' : 'support6')
    ..aI(9, _omitFieldNames ? '' : 'support6TestTime')
    ..a<$core.List<$core.int>>(
        10, _omitFieldNames ? '' : 'config', $pb.PbFieldType.OY)
    ..aOB(11, _omitFieldNames ? '' : 'selected')
    ..aInt64(12, _omitFieldNames ? '' : 'subId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DbOutboundHandler clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DbOutboundHandler copyWith(void Function(DbOutboundHandler) updates) =>
      super.copyWith((message) => updates(message as DbOutboundHandler))
          as DbOutboundHandler;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DbOutboundHandler create() => DbOutboundHandler._();
  @$core.override
  DbOutboundHandler createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DbOutboundHandler getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DbOutboundHandler>(create);
  static DbOutboundHandler? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tag => $_getSZ(1);
  @$pb.TagNumber(2)
  set tag($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTag() => $_has(1);
  @$pb.TagNumber(2)
  void clearTag() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get ok => $_getIZ(2);
  @$pb.TagNumber(3)
  set ok($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOk() => $_has(2);
  @$pb.TagNumber(3)
  void clearOk() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get speed => $_getN(3);
  @$pb.TagNumber(4)
  set speed($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSpeed() => $_has(3);
  @$pb.TagNumber(4)
  void clearSpeed() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get speedTestTime => $_getIZ(4);
  @$pb.TagNumber(5)
  set speedTestTime($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpeedTestTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpeedTestTime() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get ping => $_getIZ(5);
  @$pb.TagNumber(6)
  set ping($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPing() => $_has(5);
  @$pb.TagNumber(6)
  void clearPing() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get pingTestTime => $_getIZ(6);
  @$pb.TagNumber(7)
  set pingTestTime($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPingTestTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearPingTestTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get support6 => $_getIZ(7);
  @$pb.TagNumber(8)
  set support6($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSupport6() => $_has(7);
  @$pb.TagNumber(8)
  void clearSupport6() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get support6TestTime => $_getIZ(8);
  @$pb.TagNumber(9)
  set support6TestTime($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSupport6TestTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearSupport6TestTime() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.List<$core.int> get config => $_getN(9);
  @$pb.TagNumber(10)
  set config($core.List<$core.int> value) => $_setBytes(9, value);
  @$pb.TagNumber(10)
  $core.bool hasConfig() => $_has(9);
  @$pb.TagNumber(10)
  void clearConfig() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get selected => $_getBF(10);
  @$pb.TagNumber(11)
  set selected($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSelected() => $_has(10);
  @$pb.TagNumber(11)
  void clearSelected() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get subId => $_getI64(11);
  @$pb.TagNumber(12)
  set subId($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasSubId() => $_has(11);
  @$pb.TagNumber(12)
  void clearSubId() => $_clearField(12);
}

class UpdateHandlerRequest extends $pb.GeneratedMessage {
  factory UpdateHandlerRequest({
    $fixnum.Int64? id,
    $core.int? ok,
    $core.double? speed,
    $core.int? ping,
    $core.int? support6,
    $core.int? speedTestTime,
    $core.int? pingTestTime,
    $core.int? support6TestTime,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (ok != null) result.ok = ok;
    if (speed != null) result.speed = speed;
    if (ping != null) result.ping = ping;
    if (support6 != null) result.support6 = support6;
    if (speedTestTime != null) result.speedTestTime = speedTestTime;
    if (pingTestTime != null) result.pingTestTime = pingTestTime;
    if (support6TestTime != null) result.support6TestTime = support6TestTime;
    return result;
  }

  UpdateHandlerRequest._();

  factory UpdateHandlerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateHandlerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateHandlerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vx.db'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'ok')
    ..aD(3, _omitFieldNames ? '' : 'speed', fieldType: $pb.PbFieldType.OF)
    ..aI(4, _omitFieldNames ? '' : 'ping')
    ..aI(5, _omitFieldNames ? '' : 'support6')
    ..aI(6, _omitFieldNames ? '' : 'speedTestTime')
    ..aI(7, _omitFieldNames ? '' : 'pingTestTime')
    ..aI(8, _omitFieldNames ? '' : 'support6TestTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateHandlerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateHandlerRequest copyWith(void Function(UpdateHandlerRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateHandlerRequest))
          as UpdateHandlerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateHandlerRequest create() => UpdateHandlerRequest._();
  @$core.override
  UpdateHandlerRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateHandlerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateHandlerRequest>(create);
  static UpdateHandlerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get ok => $_getIZ(1);
  @$pb.TagNumber(2)
  set ok($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOk() => $_has(1);
  @$pb.TagNumber(2)
  void clearOk() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get speed => $_getN(2);
  @$pb.TagNumber(3)
  set speed($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSpeed() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpeed() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get ping => $_getIZ(3);
  @$pb.TagNumber(4)
  set ping($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPing() => $_has(3);
  @$pb.TagNumber(4)
  void clearPing() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get support6 => $_getIZ(4);
  @$pb.TagNumber(5)
  set support6($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSupport6() => $_has(4);
  @$pb.TagNumber(5)
  void clearSupport6() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get speedTestTime => $_getIZ(5);
  @$pb.TagNumber(6)
  set speedTestTime($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSpeedTestTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearSpeedTestTime() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get pingTestTime => $_getIZ(6);
  @$pb.TagNumber(7)
  set pingTestTime($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPingTestTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearPingTestTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get support6TestTime => $_getIZ(7);
  @$pb.TagNumber(8)
  set support6TestTime($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSupport6TestTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearSupport6TestTime() => $_clearField(8);
}

class AddGeoDomainRequest extends $pb.GeneratedMessage {
  factory AddGeoDomainRequest({
    $core.String? domain,
  }) {
    final result = create();
    if (domain != null) result.domain = domain;
    return result;
  }

  AddGeoDomainRequest._();

  factory AddGeoDomainRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddGeoDomainRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddGeoDomainRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vx.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'domain')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGeoDomainRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGeoDomainRequest copyWith(void Function(AddGeoDomainRequest) updates) =>
      super.copyWith((message) => updates(message as AddGeoDomainRequest))
          as AddGeoDomainRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddGeoDomainRequest create() => AddGeoDomainRequest._();
  @$core.override
  AddGeoDomainRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddGeoDomainRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddGeoDomainRequest>(create);
  static AddGeoDomainRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get domain => $_getSZ(0);
  @$pb.TagNumber(1)
  set domain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDomain() => $_has(0);
  @$pb.TagNumber(1)
  void clearDomain() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
