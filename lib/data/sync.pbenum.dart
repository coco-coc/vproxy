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

import 'package:protobuf/protobuf.dart' as $pb;

class SQLType extends $pb.ProtobufEnum {
  static const SQLType INSERT = SQLType._(0, _omitEnumNames ? '' : 'INSERT');
  static const SQLType UPDATE = SQLType._(1, _omitEnumNames ? '' : 'UPDATE');
  static const SQLType DELETE = SQLType._(2, _omitEnumNames ? '' : 'DELETE');
  static const SQLType CUSTOM = SQLType._(3, _omitEnumNames ? '' : 'CUSTOM');
  static const SQLType BATCH = SQLType._(4, _omitEnumNames ? '' : 'BATCH');

  static const $core.List<SQLType> values = <SQLType> [
    INSERT,
    UPDATE,
    DELETE,
    CUSTOM,
    BATCH,
  ];

  static final $core.List<SQLType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static SQLType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SQLType._(super.value, super.name);
}

class ServerOperation_Type extends $pb.ProtobufEnum {
  static const ServerOperation_Type ADD = ServerOperation_Type._(0, _omitEnumNames ? '' : 'ADD');
  static const ServerOperation_Type UPDATE = ServerOperation_Type._(1, _omitEnumNames ? '' : 'UPDATE');
  static const ServerOperation_Type DELETE = ServerOperation_Type._(2, _omitEnumNames ? '' : 'DELETE');

  static const $core.List<ServerOperation_Type> values = <ServerOperation_Type> [
    ADD,
    UPDATE,
    DELETE,
  ];

  static final $core.List<ServerOperation_Type?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ServerOperation_Type? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ServerOperation_Type._(super.value, super.name);
}

class CommonSshKeyOperation_Type extends $pb.ProtobufEnum {
  static const CommonSshKeyOperation_Type ADD = CommonSshKeyOperation_Type._(0, _omitEnumNames ? '' : 'ADD');
  static const CommonSshKeyOperation_Type DELETE = CommonSshKeyOperation_Type._(1, _omitEnumNames ? '' : 'DELETE');

  static const $core.List<CommonSshKeyOperation_Type> values = <CommonSshKeyOperation_Type> [
    ADD,
    DELETE,
  ];

  static final $core.List<CommonSshKeyOperation_Type?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 1);
  static CommonSshKeyOperation_Type? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CommonSshKeyOperation_Type._(super.value, super.name);
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
