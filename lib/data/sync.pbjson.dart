// This is a generated file - do not edit.
//
// Generated from sync.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use sQLTypeDescriptor instead')
const SQLType$json = {
  '1': 'SQLType',
  '2': [
    {'1': 'INSERT', '2': 0},
    {'1': 'UPDATE', '2': 1},
    {'1': 'DELETE', '2': 2},
    {'1': 'CUSTOM', '2': 3},
    {'1': 'BATCH', '2': 4},
  ],
};

/// Descriptor for `SQLType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sQLTypeDescriptor = $convert.base64Decode(
    'CgdTUUxUeXBlEgoKBklOU0VSVBAAEgoKBlVQREFURRABEgoKBkRFTEVURRACEgoKBkNVU1RPTR'
    'ADEgkKBUJBVENIEAQ=');

@$core.Deprecated('Use syncOperationDescriptor instead')
const SyncOperation$json = {
  '1': 'SyncOperation',
  '2': [
    {'1': 'time', '3': 1, '4': 1, '5': 4, '10': 'time'},
    {'1': 'sql_query', '3': 10, '4': 1, '5': 11, '6': '.vx.SqlQuery', '9': 0, '10': 'sqlQuery'},
    {'1': 'add_handler', '3': 11, '4': 1, '5': 11, '6': '.vx.AddHandler', '9': 0, '10': 'addHandler'},
    {'1': 'sql_operation', '3': 12, '4': 1, '5': 11, '6': '.vx.SqlOperation', '9': 0, '10': 'sqlOperation'},
    {'1': 'server_operation', '3': 13, '4': 1, '5': 11, '6': '.vx.ServerOperation', '9': 0, '10': 'serverOperation'},
    {'1': 'common_ssh_key_operation', '3': 14, '4': 1, '5': 11, '6': '.vx.CommonSshKeyOperation', '9': 0, '10': 'commonSshKeyOperation'},
  ],
  '8': [
    {'1': 'type'},
  ],
};

/// Descriptor for `SyncOperation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncOperationDescriptor = $convert.base64Decode(
    'Cg1TeW5jT3BlcmF0aW9uEhIKBHRpbWUYASABKARSBHRpbWUSLwoJc3FsX3F1ZXJ5GAogASgLMh'
    'AudnByb3h5LlNxbFF1ZXJ5SABSCHNxbFF1ZXJ5EjUKC2FkZF9oYW5kbGVyGAsgASgLMhIudnBy'
    'b3h5LkFkZEhhbmRsZXJIAFIKYWRkSGFuZGxlchI7Cg1zcWxfb3BlcmF0aW9uGAwgASgLMhQudn'
    'Byb3h5LlNxbE9wZXJhdGlvbkgAUgxzcWxPcGVyYXRpb24SRAoQc2VydmVyX29wZXJhdGlvbhgN'
    'IAEoCzIXLnZwcm94eS5TZXJ2ZXJPcGVyYXRpb25IAFIPc2VydmVyT3BlcmF0aW9uElgKGGNvbW'
    '1vbl9zc2hfa2V5X29wZXJhdGlvbhgOIAEoCzIdLnZwcm94eS5Db21tb25Tc2hLZXlPcGVyYXRp'
    'b25IAFIVY29tbW9uU3NoS2V5T3BlcmF0aW9uQgYKBHR5cGU=');

@$core.Deprecated('Use syncOperationsDescriptor instead')
const SyncOperations$json = {
  '1': 'SyncOperations',
  '2': [
    {'1': 'operations', '3': 1, '4': 3, '5': 11, '6': '.vx.SyncOperation', '10': 'operations'},
  ],
};

/// Descriptor for `SyncOperations`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncOperationsDescriptor = $convert.base64Decode(
    'Cg5TeW5jT3BlcmF0aW9ucxI1CgpvcGVyYXRpb25zGAEgAygLMhUudnByb3h5LlN5bmNPcGVyYX'
    'Rpb25SCm9wZXJhdGlvbnM=');

@$core.Deprecated('Use addHandlerDescriptor instead')
const AddHandler$json = {
  '1': 'AddHandler',
  '2': [
    {'1': 'handlers', '3': 1, '4': 3, '5': 12, '10': 'handlers'},
    {'1': 'group', '3': 2, '4': 1, '5': 9, '10': 'group'},
  ],
};

/// Descriptor for `AddHandler`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addHandlerDescriptor = $convert.base64Decode(
    'CgpBZGRIYW5kbGVyEhoKCGhhbmRsZXJzGAEgAygMUghoYW5kbGVycxIUCgVncm91cBgCIAEoCV'
    'IFZ3JvdXA=');

@$core.Deprecated('Use updateHandlerDescriptor instead')
const UpdateHandler$json = {
  '1': 'UpdateHandler',
  '2': [
    {'1': 'new_handler', '3': 1, '4': 1, '5': 12, '10': 'newHandler'},
    {'1': 'old_handler', '3': 2, '4': 1, '5': 12, '10': 'oldHandler'},
  ],
};

/// Descriptor for `UpdateHandler`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateHandlerDescriptor = $convert.base64Decode(
    'Cg1VcGRhdGVIYW5kbGVyEh8KC25ld19oYW5kbGVyGAEgASgMUgpuZXdIYW5kbGVyEh8KC29sZF'
    '9oYW5kbGVyGAIgASgMUgpvbGRIYW5kbGVy');

@$core.Deprecated('Use deleteHandlerDescriptor instead')
const DeleteHandler$json = {
  '1': 'DeleteHandler',
  '2': [
    {'1': 'handler', '3': 1, '4': 1, '5': 12, '10': 'handler'},
  ],
};

/// Descriptor for `DeleteHandler`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteHandlerDescriptor = $convert.base64Decode(
    'Cg1EZWxldGVIYW5kbGVyEhgKB2hhbmRsZXIYASABKAxSB2hhbmRsZXI=');

@$core.Deprecated('Use addSubscriptionDescriptor instead')
const AddSubscription$json = {
  '1': 'AddSubscription',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `AddSubscription`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addSubscriptionDescriptor = $convert.base64Decode(
    'Cg9BZGRTdWJzY3JpcHRpb24SEgoEbmFtZRgBIAEoCVIEbmFtZRIQCgN1cmwYAiABKAlSA3VybA'
    '==');

@$core.Deprecated('Use updateSubscriptionDescriptor instead')
const UpdateSubscription$json = {
  '1': 'UpdateSubscription',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
    {'1': 'name_changed', '3': 3, '4': 1, '5': 8, '10': 'nameChanged'},
    {'1': 'url_changed', '3': 4, '4': 1, '5': 8, '10': 'urlChanged'},
  ],
};

/// Descriptor for `UpdateSubscription`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSubscriptionDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVTdWJzY3JpcHRpb24SEgoEbmFtZRgBIAEoCVIEbmFtZRIQCgN1cmwYAiABKAlSA3'
    'VybBIhCgxuYW1lX2NoYW5nZWQYAyABKAhSC25hbWVDaGFuZ2VkEh8KC3VybF9jaGFuZ2VkGAQg'
    'ASgIUgp1cmxDaGFuZ2Vk');

@$core.Deprecated('Use deleteSubscriptionDescriptor instead')
const DeleteSubscription$json = {
  '1': 'DeleteSubscription',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `DeleteSubscription`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteSubscriptionDescriptor = $convert.base64Decode(
    'ChJEZWxldGVTdWJzY3JpcHRpb24SEAoDdXJsGAEgASgJUgN1cmw=');

@$core.Deprecated('Use serverOperationDescriptor instead')
const ServerOperation$json = {
  '1': 'ServerOperation',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.vx.ServerOperation.Type', '10': 'type'},
    {'1': 'row', '3': 2, '4': 1, '5': 9, '10': 'row'},
    {'1': 'storage_key', '3': 3, '4': 1, '5': 9, '10': 'storageKey'},
    {'1': 'secure_storage', '3': 4, '4': 1, '5': 9, '10': 'secureStorage'},
    {'1': 'id', '3': 5, '4': 1, '5': 3, '10': 'id'},
  ],
  '4': [ServerOperation_Type$json],
};

@$core.Deprecated('Use serverOperationDescriptor instead')
const ServerOperation_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'ADD', '2': 0},
    {'1': 'UPDATE', '2': 1},
    {'1': 'DELETE', '2': 2},
  ],
};

/// Descriptor for `ServerOperation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverOperationDescriptor = $convert.base64Decode(
    'Cg9TZXJ2ZXJPcGVyYXRpb24SMAoEdHlwZRgBIAEoDjIcLnZwcm94eS5TZXJ2ZXJPcGVyYXRpb2'
    '4uVHlwZVIEdHlwZRIQCgNyb3cYAiABKAlSA3JvdxIfCgtzdG9yYWdlX2tleRgDIAEoCVIKc3Rv'
    'cmFnZUtleRIlCg5zZWN1cmVfc3RvcmFnZRgEIAEoCVINc2VjdXJlU3RvcmFnZRIOCgJpZBgFIA'
    'EoA1ICaWQiJwoEVHlwZRIHCgNBREQQABIKCgZVUERBVEUQARIKCgZERUxFVEUQAg==');

@$core.Deprecated('Use commonSshKeyOperationDescriptor instead')
const CommonSshKeyOperation$json = {
  '1': 'CommonSshKeyOperation',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.vx.CommonSshKeyOperation.Type', '10': 'type'},
    {'1': 'row', '3': 2, '4': 1, '5': 9, '10': 'row'},
    {'1': 'storage_key', '3': 3, '4': 1, '5': 9, '10': 'storageKey'},
    {'1': 'secure_storage', '3': 4, '4': 1, '5': 9, '10': 'secureStorage'},
    {'1': 'id', '3': 5, '4': 1, '5': 3, '10': 'id'},
  ],
  '4': [CommonSshKeyOperation_Type$json],
};

@$core.Deprecated('Use commonSshKeyOperationDescriptor instead')
const CommonSshKeyOperation_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'ADD', '2': 0},
    {'1': 'DELETE', '2': 1},
  ],
};

/// Descriptor for `CommonSshKeyOperation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commonSshKeyOperationDescriptor = $convert.base64Decode(
    'ChVDb21tb25Tc2hLZXlPcGVyYXRpb24SNgoEdHlwZRgBIAEoDjIiLnZwcm94eS5Db21tb25Tc2'
    'hLZXlPcGVyYXRpb24uVHlwZVIEdHlwZRIQCgNyb3cYAiABKAlSA3JvdxIfCgtzdG9yYWdlX2tl'
    'eRgDIAEoCVIKc3RvcmFnZUtleRIlCg5zZWN1cmVfc3RvcmFnZRgEIAEoCVINc2VjdXJlU3Rvcm'
    'FnZRIOCgJpZBgFIAEoA1ICaWQiGwoEVHlwZRIHCgNBREQQABIKCgZERUxFVEUQAQ==');

@$core.Deprecated('Use sqlOperationDescriptor instead')
const SqlOperation$json = {
  '1': 'SqlOperation',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.vx.SQLType', '10': 'type'},
    {'1': 'table', '3': 2, '4': 1, '5': 9, '10': 'table'},
    {'1': 'rows', '3': 3, '4': 3, '5': 9, '10': 'rows'},
    {'1': 'ids', '3': 4, '4': 3, '5': 3, '10': 'ids'},
    {'1': 'names', '3': 5, '4': 3, '5': 9, '10': 'names'},
  ],
};

/// Descriptor for `SqlOperation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sqlOperationDescriptor = $convert.base64Decode(
    'CgxTcWxPcGVyYXRpb24SIwoEdHlwZRgBIAEoDjIPLnZwcm94eS5TUUxUeXBlUgR0eXBlEhQKBX'
    'RhYmxlGAIgASgJUgV0YWJsZRISCgRyb3dzGAMgAygJUgRyb3dzEhAKA2lkcxgEIAMoA1IDaWRz'
    'EhQKBW5hbWVzGAUgAygJUgVuYW1lcw==');

@$core.Deprecated('Use sqlQueryDescriptor instead')
const SqlQuery$json = {
  '1': 'SqlQuery',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.vx.SQLType', '10': 'type'},
    {'1': 'statement', '3': 10, '4': 1, '5': 9, '10': 'statement'},
    {'1': 'arguments', '3': 11, '4': 3, '5': 11, '6': '.vx.SqlArgument', '10': 'arguments'},
  ],
};

/// Descriptor for `SqlQuery`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sqlQueryDescriptor = $convert.base64Decode(
    'CghTcWxRdWVyeRIjCgR0eXBlGAEgASgOMg8udnByb3h5LlNRTFR5cGVSBHR5cGUSHAoJc3RhdG'
    'VtZW50GAogASgJUglzdGF0ZW1lbnQSMQoJYXJndW1lbnRzGAsgAygLMhMudnByb3h5LlNxbEFy'
    'Z3VtZW50Uglhcmd1bWVudHM=');

@$core.Deprecated('Use sqlArgumentDescriptor instead')
const SqlArgument$json = {
  '1': 'SqlArgument',
  '2': [
    {'1': 'string', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'string'},
    {'1': 'int64', '3': 2, '4': 1, '5': 3, '9': 0, '10': 'int64'},
    {'1': 'int32', '3': 3, '4': 1, '5': 5, '9': 0, '10': 'int32'},
    {'1': 'bool', '3': 4, '4': 1, '5': 8, '9': 0, '10': 'bool'},
    {'1': 'bytes', '3': 5, '4': 1, '5': 12, '9': 0, '10': 'bytes'},
    {'1': 'double', '3': 6, '4': 1, '5': 2, '9': 0, '10': 'double'},
    {'1': 'is_null', '3': 10, '4': 1, '5': 8, '10': 'isNull'},
  ],
  '8': [
    {'1': 'type'},
  ],
};

/// Descriptor for `SqlArgument`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sqlArgumentDescriptor = $convert.base64Decode(
    'CgtTcWxBcmd1bWVudBIYCgZzdHJpbmcYASABKAlIAFIGc3RyaW5nEhYKBWludDY0GAIgASgDSA'
    'BSBWludDY0EhYKBWludDMyGAMgASgFSABSBWludDMyEhQKBGJvb2wYBCABKAhIAFIEYm9vbBIW'
    'CgVieXRlcxgFIAEoDEgAUgVieXRlcxIYCgZkb3VibGUYBiABKAJIAFIGZG91YmxlEhcKB2lzX2'
    '51bGwYCiABKAhSBmlzTnVsbEIGCgR0eXBl');

