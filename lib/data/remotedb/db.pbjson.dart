// This is a generated file - do not edit.
//
// Generated from db.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use receiptDescriptor instead')
const Receipt$json = {
  '1': 'Receipt',
};

/// Descriptor for `Receipt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List receiptDescriptor =
    $convert.base64Decode('CgdSZWNlaXB0');

@$core.Deprecated('Use getHandlerRequestDescriptor instead')
const GetHandlerRequest$json = {
  '1': 'GetHandlerRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `GetHandlerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHandlerRequestDescriptor =
    $convert.base64Decode('ChFHZXRIYW5kbGVyUmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQ=');

@$core.Deprecated('Use getAllHandlersRequestDescriptor instead')
const GetAllHandlersRequest$json = {
  '1': 'GetAllHandlersRequest',
};

/// Descriptor for `GetAllHandlersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAllHandlersRequestDescriptor =
    $convert.base64Decode('ChVHZXRBbGxIYW5kbGVyc1JlcXVlc3Q=');

@$core.Deprecated('Use getHandlersByGroupRequestDescriptor instead')
const GetHandlersByGroupRequest$json = {
  '1': 'GetHandlersByGroupRequest',
  '2': [
    {'1': 'group', '3': 1, '4': 1, '5': 9, '10': 'group'},
  ],
};

/// Descriptor for `GetHandlersByGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHandlersByGroupRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRIYW5kbGVyc0J5R3JvdXBSZXF1ZXN0EhQKBWdyb3VwGAEgASgJUgVncm91cA==');

@$core.Deprecated('Use getBatchedHandlersRequestDescriptor instead')
const GetBatchedHandlersRequest$json = {
  '1': 'GetBatchedHandlersRequest',
  '2': [
    {'1': 'batch_size', '3': 1, '4': 1, '5': 13, '10': 'batchSize'},
    {'1': 'offset', '3': 2, '4': 1, '5': 13, '10': 'offset'},
  ],
};

/// Descriptor for `GetBatchedHandlersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBatchedHandlersRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRCYXRjaGVkSGFuZGxlcnNSZXF1ZXN0Eh0KCmJhdGNoX3NpemUYASABKA1SCWJhdGNoU2'
        'l6ZRIWCgZvZmZzZXQYAiABKA1SBm9mZnNldA==');

@$core.Deprecated('Use dbHandlersDescriptor instead')
const DbHandlers$json = {
  '1': 'DbHandlers',
  '2': [
    {
      '1': 'handlers',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.vx.db.DbOutboundHandler',
      '10': 'handlers'
    },
  ],
};

/// Descriptor for `DbHandlers`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dbHandlersDescriptor = $convert.base64Decode(
    'CgpEYkhhbmRsZXJzEjQKCGhhbmRsZXJzGAEgAygLMhgudnguZGIuRGJPdXRib3VuZEhhbmRsZX'
    'JSCGhhbmRsZXJz');

@$core.Deprecated('Use dbOutboundHandlerDescriptor instead')
const DbOutboundHandler$json = {
  '1': 'DbOutboundHandler',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'tag', '3': 2, '4': 1, '5': 9, '10': 'tag'},
    {'1': 'ok', '3': 3, '4': 1, '5': 5, '10': 'ok'},
    {'1': 'speed', '3': 4, '4': 1, '5': 2, '10': 'speed'},
    {'1': 'speed_test_time', '3': 5, '4': 1, '5': 5, '10': 'speedTestTime'},
    {'1': 'ping', '3': 6, '4': 1, '5': 5, '10': 'ping'},
    {'1': 'ping_test_time', '3': 7, '4': 1, '5': 5, '10': 'pingTestTime'},
    {'1': 'support6', '3': 8, '4': 1, '5': 5, '10': 'support6'},
    {
      '1': 'support6_test_time',
      '3': 9,
      '4': 1,
      '5': 5,
      '10': 'support6TestTime'
    },
    {'1': 'config', '3': 10, '4': 1, '5': 12, '10': 'config'},
    {'1': 'selected', '3': 11, '4': 1, '5': 8, '10': 'selected'},
    {'1': 'sub_id', '3': 12, '4': 1, '5': 3, '10': 'subId'},
  ],
};

/// Descriptor for `DbOutboundHandler`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dbOutboundHandlerDescriptor = $convert.base64Decode(
    'ChFEYk91dGJvdW5kSGFuZGxlchIOCgJpZBgBIAEoA1ICaWQSEAoDdGFnGAIgASgJUgN0YWcSDg'
    'oCb2sYAyABKAVSAm9rEhQKBXNwZWVkGAQgASgCUgVzcGVlZBImCg9zcGVlZF90ZXN0X3RpbWUY'
    'BSABKAVSDXNwZWVkVGVzdFRpbWUSEgoEcGluZxgGIAEoBVIEcGluZxIkCg5waW5nX3Rlc3RfdG'
    'ltZRgHIAEoBVIMcGluZ1Rlc3RUaW1lEhoKCHN1cHBvcnQ2GAggASgFUghzdXBwb3J0NhIsChJz'
    'dXBwb3J0Nl90ZXN0X3RpbWUYCSABKAVSEHN1cHBvcnQ2VGVzdFRpbWUSFgoGY29uZmlnGAogAS'
    'gMUgZjb25maWcSGgoIc2VsZWN0ZWQYCyABKAhSCHNlbGVjdGVkEhUKBnN1Yl9pZBgMIAEoA1IF'
    'c3ViSWQ=');

@$core.Deprecated('Use updateHandlerRequestDescriptor instead')
const UpdateHandlerRequest$json = {
  '1': 'UpdateHandlerRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'ok', '3': 2, '4': 1, '5': 5, '9': 0, '10': 'ok', '17': true},
    {'1': 'speed', '3': 3, '4': 1, '5': 2, '9': 1, '10': 'speed', '17': true},
    {'1': 'ping', '3': 4, '4': 1, '5': 5, '9': 2, '10': 'ping', '17': true},
    {
      '1': 'support6',
      '3': 5,
      '4': 1,
      '5': 5,
      '9': 3,
      '10': 'support6',
      '17': true
    },
    {
      '1': 'speed_test_time',
      '3': 6,
      '4': 1,
      '5': 5,
      '9': 4,
      '10': 'speedTestTime',
      '17': true
    },
    {
      '1': 'ping_test_time',
      '3': 7,
      '4': 1,
      '5': 5,
      '9': 5,
      '10': 'pingTestTime',
      '17': true
    },
    {
      '1': 'support6_test_time',
      '3': 8,
      '4': 1,
      '5': 5,
      '9': 6,
      '10': 'support6TestTime',
      '17': true
    },
  ],
  '8': [
    {'1': '_ok'},
    {'1': '_speed'},
    {'1': '_ping'},
    {'1': '_support6'},
    {'1': '_speed_test_time'},
    {'1': '_ping_test_time'},
    {'1': '_support6_test_time'},
  ],
};

/// Descriptor for `UpdateHandlerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateHandlerRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVIYW5kbGVyUmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQSEwoCb2sYAiABKAVIAFICb2'
    'uIAQESGQoFc3BlZWQYAyABKAJIAVIFc3BlZWSIAQESFwoEcGluZxgEIAEoBUgCUgRwaW5niAEB'
    'Eh8KCHN1cHBvcnQ2GAUgASgFSANSCHN1cHBvcnQ2iAEBEisKD3NwZWVkX3Rlc3RfdGltZRgGIA'
    'EoBUgEUg1zcGVlZFRlc3RUaW1liAEBEikKDnBpbmdfdGVzdF90aW1lGAcgASgFSAVSDHBpbmdU'
    'ZXN0VGltZYgBARIxChJzdXBwb3J0Nl90ZXN0X3RpbWUYCCABKAVIBlIQc3VwcG9ydDZUZXN0VG'
    'ltZYgBAUIFCgNfb2tCCAoGX3NwZWVkQgcKBV9waW5nQgsKCV9zdXBwb3J0NkISChBfc3BlZWRf'
    'dGVzdF90aW1lQhEKD19waW5nX3Rlc3RfdGltZUIVChNfc3VwcG9ydDZfdGVzdF90aW1l');

@$core.Deprecated('Use addGeoDomainRequestDescriptor instead')
const AddGeoDomainRequest$json = {
  '1': 'AddGeoDomainRequest',
  '2': [
    {'1': 'domain', '3': 1, '4': 1, '5': 9, '10': 'domain'},
  ],
};

/// Descriptor for `AddGeoDomainRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addGeoDomainRequestDescriptor =
    $convert.base64Decode(
        'ChNBZGRHZW9Eb21haW5SZXF1ZXN0EhYKBmRvbWFpbhgBIAEoCVIGZG9tYWlu');
