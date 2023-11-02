//
//  Generated code. Do not modify.
//  source: service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
// ignore: depend_on_referenced_packages
import 'package:protobuf/protobuf.dart' as $pb;

import 'message.pb.dart' as $0;

export 'service.pb.dart';

@$pb.GrpcServiceName('main.AuthService')
class AuthServiceClient extends $grpc.Client {
  static final _$register =
      $grpc.ClientMethod<$0.AuthRequest, $0.TokenResponse>(
          '/main.AuthService/Register',
          ($0.AuthRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.TokenResponse.fromBuffer(value));
  static final _$login = $grpc.ClientMethod<$0.AuthRequest, $0.TokenResponse>(
      '/main.AuthService/Login',
      ($0.AuthRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.TokenResponse.fromBuffer(value));

  AuthServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.TokenResponse> register($0.AuthRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$register, request, options: options);
  }

  $grpc.ResponseFuture<$0.TokenResponse> login($0.AuthRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$login, request, options: options);
  }
}

@$pb.GrpcServiceName('main.AuthService')
abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'main.AuthService';

  AuthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.AuthRequest, $0.TokenResponse>(
        'Register',
        register_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AuthRequest.fromBuffer(value),
        ($0.TokenResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AuthRequest, $0.TokenResponse>(
        'Login',
        login_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AuthRequest.fromBuffer(value),
        ($0.TokenResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.TokenResponse> register_Pre(
      $grpc.ServiceCall call, $async.Future<$0.AuthRequest> request) async {
    return register(call, await request);
  }

  $async.Future<$0.TokenResponse> login_Pre(
      $grpc.ServiceCall call, $async.Future<$0.AuthRequest> request) async {
    return login(call, await request);
  }

  $async.Future<$0.TokenResponse> register(
      $grpc.ServiceCall call, $0.AuthRequest request);
  $async.Future<$0.TokenResponse> login(
      $grpc.ServiceCall call, $0.AuthRequest request);
}

@$pb.GrpcServiceName('main.ProductCardService')
class ProductCardServiceClient extends $grpc.Client {
  static final _$addProductsCards = $grpc.ClientMethod<
          $0.AddProductsCardsRequest, $0.AddProductsCardsResponse>(
      '/main.ProductCardService/AddProductsCards',
      ($0.AddProductsCardsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.AddProductsCardsResponse.fromBuffer(value));
  static final _$getProductsCards = $grpc.ClientMethod<
          $0.GetProductsCardsRequest, $0.GetProductsCardsResponse>(
      '/main.ProductCardService/GetProductsCards',
      ($0.GetProductsCardsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.GetProductsCardsResponse.fromBuffer(value));
  static final _$deleteProductCard = $grpc.ClientMethod<
          $0.DeleteProductCardRequest, $0.DeleteProductCardResponse>(
      '/main.ProductCardService/DeleteProductCard',
      ($0.DeleteProductCardRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.DeleteProductCardResponse.fromBuffer(value));

  ProductCardServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.AddProductsCardsResponse> addProductsCards(
      $0.AddProductsCardsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$addProductsCards, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetProductsCardsResponse> getProductsCards(
      $0.GetProductsCardsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getProductsCards, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteProductCardResponse> deleteProductCard(
      $0.DeleteProductCardRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$deleteProductCard, request, options: options);
  }
}

@$pb.GrpcServiceName('main.ProductCardService')
abstract class ProductCardServiceBase extends $grpc.Service {
  $core.String get $name => 'main.ProductCardService';

  ProductCardServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.AddProductsCardsRequest,
            $0.AddProductsCardsResponse>(
        'AddProductsCards',
        addProductsCards_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AddProductsCardsRequest.fromBuffer(value),
        ($0.AddProductsCardsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetProductsCardsRequest,
            $0.GetProductsCardsResponse>(
        'GetProductsCards',
        getProductsCards_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetProductsCardsRequest.fromBuffer(value),
        ($0.GetProductsCardsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteProductCardRequest,
            $0.DeleteProductCardResponse>(
        'DeleteProductCard',
        deleteProductCard_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteProductCardRequest.fromBuffer(value),
        ($0.DeleteProductCardResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.AddProductsCardsResponse> addProductsCards_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.AddProductsCardsRequest> request) async {
    return addProductsCards(call, await request);
  }

  $async.Future<$0.GetProductsCardsResponse> getProductsCards_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.GetProductsCardsRequest> request) async {
    return getProductsCards(call, await request);
  }

  $async.Future<$0.DeleteProductCardResponse> deleteProductCard_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.DeleteProductCardRequest> request) async {
    return deleteProductCard(call, await request);
  }

  $async.Future<$0.AddProductsCardsResponse> addProductsCards(
      $grpc.ServiceCall call, $0.AddProductsCardsRequest request);
  $async.Future<$0.GetProductsCardsResponse> getProductsCards(
      $grpc.ServiceCall call, $0.GetProductsCardsRequest request);
  $async.Future<$0.DeleteProductCardResponse> deleteProductCard(
      $grpc.ServiceCall call, $0.DeleteProductCardRequest request);
}

@$pb.GrpcServiceName('main.StockService')
class StockServiceClient extends $grpc.Client {
  static final _$getStocksFromTo =
      $grpc.ClientMethod<$0.GetStocksFromToReq, $0.GetStocksFromToResp>(
          '/main.StockService/GetStocksFromTo',
          ($0.GetStocksFromToReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetStocksFromToResp.fromBuffer(value));

  StockServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.GetStocksFromToResp> getStocksFromTo(
      $0.GetStocksFromToReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getStocksFromTo, request, options: options);
  }
}

@$pb.GrpcServiceName('main.StockService')
abstract class StockServiceBase extends $grpc.Service {
  $core.String get $name => 'main.StockService';

  StockServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.GetStocksFromToReq, $0.GetStocksFromToResp>(
            'GetStocksFromTo',
            getStocksFromTo_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetStocksFromToReq.fromBuffer(value),
            ($0.GetStocksFromToResp value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetStocksFromToResp> getStocksFromTo_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.GetStocksFromToReq> request) async {
    return getStocksFromTo(call, await request);
  }

  $async.Future<$0.GetStocksFromToResp> getStocksFromTo(
      $grpc.ServiceCall call, $0.GetStocksFromToReq request);
}

@$pb.GrpcServiceName('main.CommissionService')
class CommissionServiceClient extends $grpc.Client {
  static final _$getCommission =
      $grpc.ClientMethod<$0.GetCommissionReq, $0.GetCommissionResp>(
          '/main.CommissionService/GetCommission',
          ($0.GetCommissionReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetCommissionResp.fromBuffer(value));

  CommissionServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.GetCommissionResp> getCommission(
      $0.GetCommissionReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getCommission, request, options: options);
  }
}

@$pb.GrpcServiceName('main.CommissionService')
abstract class CommissionServiceBase extends $grpc.Service {
  $core.String get $name => 'main.CommissionService';

  CommissionServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetCommissionReq, $0.GetCommissionResp>(
        'GetCommission',
        getCommission_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetCommissionReq.fromBuffer(value),
        ($0.GetCommissionResp value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetCommissionResp> getCommission_Pre($grpc.ServiceCall call,
      $async.Future<$0.GetCommissionReq> request) async {
    return getCommission(call, await request);
  }

  $async.Future<$0.GetCommissionResp> getCommission(
      $grpc.ServiceCall call, $0.GetCommissionReq request);
}

@$pb.GrpcServiceName('main.OrderService')
class OrderServiceClient extends $grpc.Client {
  static final _$getOrdersFromTo =
      $grpc.ClientMethod<$0.GetOrdersFromToReq, $0.GetOrdersFromToResp>(
          '/main.OrderService/GetOrdersFromTo',
          ($0.GetOrdersFromToReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetOrdersFromToResp.fromBuffer(value));

  OrderServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.GetOrdersFromToResp> getOrdersFromTo(
      $0.GetOrdersFromToReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getOrdersFromTo, request, options: options);
  }
}

@$pb.GrpcServiceName('main.OrderService')
abstract class OrderServiceBase extends $grpc.Service {
  $core.String get $name => 'main.OrderService';

  OrderServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.GetOrdersFromToReq, $0.GetOrdersFromToResp>(
            'GetOrdersFromTo',
            getOrdersFromTo_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetOrdersFromToReq.fromBuffer(value),
            ($0.GetOrdersFromToResp value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetOrdersFromToResp> getOrdersFromTo_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.GetOrdersFromToReq> request) async {
    return getOrdersFromTo(call, await request);
  }

  $async.Future<$0.GetOrdersFromToResp> getOrdersFromTo(
      $grpc.ServiceCall call, $0.GetOrdersFromToReq request);
}
