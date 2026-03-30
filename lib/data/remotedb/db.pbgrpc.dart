// This is a generated file - do not edit.
//
// Generated from db.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'db.pb.dart' as $0;

export 'db.pb.dart';

@$pb.GrpcServiceName('vx.db.DbService')
class DbServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  DbServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.DbOutboundHandler> getHandler(
    $0.GetHandlerRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHandler, request, options: options);
  }

  $grpc.ResponseFuture<$0.DbHandlers> getAllHandlers(
    $0.GetAllHandlersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAllHandlers, request, options: options);
  }

  $grpc.ResponseFuture<$0.DbHandlers> getHandlersByGroup(
    $0.GetHandlersByGroupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHandlersByGroup, request, options: options);
  }

  $grpc.ResponseFuture<$0.DbHandlers> getBatchedHandlers(
    $0.GetBatchedHandlersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getBatchedHandlers, request, options: options);
  }

  $grpc.ResponseFuture<$0.Receipt> updateHandler(
    $0.UpdateHandlerRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateHandler, request, options: options);
  }

  $grpc.ResponseFuture<$0.Receipt> addGeoDomain(
    $0.AddGeoDomainRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addGeoDomain, request, options: options);
  }

  // method descriptors

  static final _$getHandler =
      $grpc.ClientMethod<$0.GetHandlerRequest, $0.DbOutboundHandler>(
          '/vx.db.DbService/GetHandler',
          ($0.GetHandlerRequest value) => value.writeToBuffer(),
          $0.DbOutboundHandler.fromBuffer);
  static final _$getAllHandlers =
      $grpc.ClientMethod<$0.GetAllHandlersRequest, $0.DbHandlers>(
          '/vx.db.DbService/GetAllHandlers',
          ($0.GetAllHandlersRequest value) => value.writeToBuffer(),
          $0.DbHandlers.fromBuffer);
  static final _$getHandlersByGroup =
      $grpc.ClientMethod<$0.GetHandlersByGroupRequest, $0.DbHandlers>(
          '/vx.db.DbService/GetHandlersByGroup',
          ($0.GetHandlersByGroupRequest value) => value.writeToBuffer(),
          $0.DbHandlers.fromBuffer);
  static final _$getBatchedHandlers =
      $grpc.ClientMethod<$0.GetBatchedHandlersRequest, $0.DbHandlers>(
          '/vx.db.DbService/GetBatchedHandlers',
          ($0.GetBatchedHandlersRequest value) => value.writeToBuffer(),
          $0.DbHandlers.fromBuffer);
  static final _$updateHandler =
      $grpc.ClientMethod<$0.UpdateHandlerRequest, $0.Receipt>(
          '/vx.db.DbService/UpdateHandler',
          ($0.UpdateHandlerRequest value) => value.writeToBuffer(),
          $0.Receipt.fromBuffer);
  static final _$addGeoDomain =
      $grpc.ClientMethod<$0.AddGeoDomainRequest, $0.Receipt>(
          '/vx.db.DbService/AddGeoDomain',
          ($0.AddGeoDomainRequest value) => value.writeToBuffer(),
          $0.Receipt.fromBuffer);
}

@$pb.GrpcServiceName('vx.db.DbService')
abstract class DbServiceBase extends $grpc.Service {
  $core.String get $name => 'vx.db.DbService';

  DbServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetHandlerRequest, $0.DbOutboundHandler>(
        'GetHandler',
        getHandler_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetHandlerRequest.fromBuffer(value),
        ($0.DbOutboundHandler value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetAllHandlersRequest, $0.DbHandlers>(
        'GetAllHandlers',
        getAllHandlers_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetAllHandlersRequest.fromBuffer(value),
        ($0.DbHandlers value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetHandlersByGroupRequest, $0.DbHandlers>(
        'GetHandlersByGroup',
        getHandlersByGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetHandlersByGroupRequest.fromBuffer(value),
        ($0.DbHandlers value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetBatchedHandlersRequest, $0.DbHandlers>(
        'GetBatchedHandlers',
        getBatchedHandlers_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetBatchedHandlersRequest.fromBuffer(value),
        ($0.DbHandlers value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateHandlerRequest, $0.Receipt>(
        'UpdateHandler',
        updateHandler_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateHandlerRequest.fromBuffer(value),
        ($0.Receipt value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddGeoDomainRequest, $0.Receipt>(
        'AddGeoDomain',
        addGeoDomain_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AddGeoDomainRequest.fromBuffer(value),
        ($0.Receipt value) => value.writeToBuffer()));
  }

  $async.Future<$0.DbOutboundHandler> getHandler_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetHandlerRequest> $request) async {
    return getHandler($call, await $request);
  }

  $async.Future<$0.DbOutboundHandler> getHandler(
      $grpc.ServiceCall call, $0.GetHandlerRequest request);

  $async.Future<$0.DbHandlers> getAllHandlers_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetAllHandlersRequest> $request) async {
    return getAllHandlers($call, await $request);
  }

  $async.Future<$0.DbHandlers> getAllHandlers(
      $grpc.ServiceCall call, $0.GetAllHandlersRequest request);

  $async.Future<$0.DbHandlers> getHandlersByGroup_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetHandlersByGroupRequest> $request) async {
    return getHandlersByGroup($call, await $request);
  }

  $async.Future<$0.DbHandlers> getHandlersByGroup(
      $grpc.ServiceCall call, $0.GetHandlersByGroupRequest request);

  $async.Future<$0.DbHandlers> getBatchedHandlers_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetBatchedHandlersRequest> $request) async {
    return getBatchedHandlers($call, await $request);
  }

  $async.Future<$0.DbHandlers> getBatchedHandlers(
      $grpc.ServiceCall call, $0.GetBatchedHandlersRequest request);

  $async.Future<$0.Receipt> updateHandler_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateHandlerRequest> $request) async {
    return updateHandler($call, await $request);
  }

  $async.Future<$0.Receipt> updateHandler(
      $grpc.ServiceCall call, $0.UpdateHandlerRequest request);

  $async.Future<$0.Receipt> addGeoDomain_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddGeoDomainRequest> $request) async {
    return addGeoDomain($call, await $request);
  }

  $async.Future<$0.Receipt> addGeoDomain(
      $grpc.ServiceCall call, $0.AddGeoDomainRequest request);
}
