//
//  Generated code. Do not modify.
//  source: message.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor = $convert.base64Decode(
    'CgVFbXB0eQ==');

@$core.Deprecated('Use authRequestDescriptor instead')
const AuthRequest$json = {
  '1': 'AuthRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `AuthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authRequestDescriptor = $convert.base64Decode(
    'CgtBdXRoUmVxdWVzdBIaCgh1c2VybmFtZRgBIAEoCVIIdXNlcm5hbWUSGgoIcGFzc3dvcmQYAi'
    'ABKAlSCHBhc3N3b3Jk');

@$core.Deprecated('Use tokenResponseDescriptor instead')
const TokenResponse$json = {
  '1': 'TokenResponse',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {'1': 'freebie', '3': 2, '4': 1, '5': 8, '10': 'freebie'},
    {'1': 'timeToUpdateCommission', '3': 3, '4': 1, '5': 8, '10': 'timeToUpdateCommission'},
    {'1': 'expiredAt', '3': 4, '4': 1, '5': 3, '10': 'expiredAt'},
  ],
};

/// Descriptor for `TokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenResponseDescriptor = $convert.base64Decode(
    'Cg1Ub2tlblJlc3BvbnNlEhQKBXRva2VuGAEgASgJUgV0b2tlbhIYCgdmcmVlYmllGAIgASgIUg'
    'dmcmVlYmllEjYKFnRpbWVUb1VwZGF0ZUNvbW1pc3Npb24YAyABKAhSFnRpbWVUb1VwZGF0ZUNv'
    'bW1pc3Npb24SHAoJZXhwaXJlZEF0GAQgASgDUglleHBpcmVkQXQ=');

@$core.Deprecated('Use productCardDescriptor instead')
const ProductCard$json = {
  '1': 'ProductCard',
  '2': [
    {'1': 'sku', '3': 1, '4': 1, '5': 4, '10': 'sku'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'image', '3': 3, '4': 1, '5': 9, '10': 'image'},
  ],
};

/// Descriptor for `ProductCard`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productCardDescriptor = $convert.base64Decode(
    'CgtQcm9kdWN0Q2FyZBIQCgNza3UYASABKARSA3NrdRISCgRuYW1lGAIgASgJUgRuYW1lEhQKBW'
    'ltYWdlGAMgASgJUgVpbWFnZQ==');

@$core.Deprecated('Use addProductsCardsRequestDescriptor instead')
const AddProductsCardsRequest$json = {
  '1': 'AddProductsCardsRequest',
  '2': [
    {'1': 'productsCards', '3': 1, '4': 3, '5': 11, '6': '.main.ProductCard', '10': 'productsCards'},
  ],
};

/// Descriptor for `AddProductsCardsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addProductsCardsRequestDescriptor = $convert.base64Decode(
    'ChdBZGRQcm9kdWN0c0NhcmRzUmVxdWVzdBI3Cg1wcm9kdWN0c0NhcmRzGAEgAygLMhEubWFpbi'
    '5Qcm9kdWN0Q2FyZFINcHJvZHVjdHNDYXJkcw==');

@$core.Deprecated('Use addProductsCardsResponseDescriptor instead')
const AddProductsCardsResponse$json = {
  '1': 'AddProductsCardsResponse',
  '2': [
    {'1': 'qty', '3': 1, '4': 1, '5': 5, '10': 'qty'},
  ],
};

/// Descriptor for `AddProductsCardsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addProductsCardsResponseDescriptor = $convert.base64Decode(
    'ChhBZGRQcm9kdWN0c0NhcmRzUmVzcG9uc2USEAoDcXR5GAEgASgFUgNxdHk=');

@$core.Deprecated('Use getProductsCardsRequestDescriptor instead')
const GetProductsCardsRequest$json = {
  '1': 'GetProductsCardsRequest',
};

/// Descriptor for `GetProductsCardsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProductsCardsRequestDescriptor = $convert.base64Decode(
    'ChdHZXRQcm9kdWN0c0NhcmRzUmVxdWVzdA==');

@$core.Deprecated('Use getProductsCardsResponseDescriptor instead')
const GetProductsCardsResponse$json = {
  '1': 'GetProductsCardsResponse',
  '2': [
    {'1': 'productsCards', '3': 1, '4': 3, '5': 11, '6': '.main.ProductCard', '10': 'productsCards'},
  ],
};

/// Descriptor for `GetProductsCardsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProductsCardsResponseDescriptor = $convert.base64Decode(
    'ChhHZXRQcm9kdWN0c0NhcmRzUmVzcG9uc2USNwoNcHJvZHVjdHNDYXJkcxgBIAMoCzIRLm1haW'
    '4uUHJvZHVjdENhcmRSDXByb2R1Y3RzQ2FyZHM=');

@$core.Deprecated('Use getStocksFromToReqDescriptor instead')
const GetStocksFromToReq$json = {
  '1': 'GetStocksFromToReq',
  '2': [
    {'1': 'from', '3': 1, '4': 1, '5': 3, '10': 'from'},
    {'1': 'to', '3': 2, '4': 1, '5': 3, '10': 'to'},
    {'1': 'skus', '3': 3, '4': 3, '5': 4, '10': 'skus'},
  ],
};

/// Descriptor for `GetStocksFromToReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStocksFromToReqDescriptor = $convert.base64Decode(
    'ChJHZXRTdG9ja3NGcm9tVG9SZXESEgoEZnJvbRgBIAEoA1IEZnJvbRIOCgJ0bxgCIAEoA1ICdG'
    '8SEgoEc2t1cxgDIAMoBFIEc2t1cw==');

@$core.Deprecated('Use stockDescriptor instead')
const Stock$json = {
  '1': 'Stock',
  '2': [
    {'1': 'sku', '3': 1, '4': 1, '5': 4, '10': 'sku'},
    {'1': 'wh', '3': 2, '4': 1, '5': 4, '10': 'wh'},
    {'1': 'sizeOptionId', '3': 3, '4': 1, '5': 4, '10': 'sizeOptionId'},
    {'1': 'qty', '3': 4, '4': 1, '5': 5, '10': 'qty'},
  ],
};

/// Descriptor for `Stock`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stockDescriptor = $convert.base64Decode(
    'CgVTdG9jaxIQCgNza3UYASABKARSA3NrdRIOCgJ3aBgCIAEoBFICd2gSIgoMc2l6ZU9wdGlvbk'
    'lkGAMgASgEUgxzaXplT3B0aW9uSWQSEAoDcXR5GAQgASgFUgNxdHk=');

@$core.Deprecated('Use getStocksFromToRespDescriptor instead')
const GetStocksFromToResp$json = {
  '1': 'GetStocksFromToResp',
  '2': [
    {'1': 'stocks', '3': 1, '4': 3, '5': 11, '6': '.main.Stock', '10': 'stocks'},
  ],
};

/// Descriptor for `GetStocksFromToResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStocksFromToRespDescriptor = $convert.base64Decode(
    'ChNHZXRTdG9ja3NGcm9tVG9SZXNwEiMKBnN0b2NrcxgBIAMoCzILLm1haW4uU3RvY2tSBnN0b2'
    'Nrcw==');

@$core.Deprecated('Use deleteProductCardRequestDescriptor instead')
const DeleteProductCardRequest$json = {
  '1': 'DeleteProductCardRequest',
  '2': [
    {'1': 'sku', '3': 1, '4': 1, '5': 4, '10': 'sku'},
  ],
};

/// Descriptor for `DeleteProductCardRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteProductCardRequestDescriptor = $convert.base64Decode(
    'ChhEZWxldGVQcm9kdWN0Q2FyZFJlcXVlc3QSEAoDc2t1GAEgASgEUgNza3U=');

@$core.Deprecated('Use deleteProductCardResponseDescriptor instead')
const DeleteProductCardResponse$json = {
  '1': 'DeleteProductCardResponse',
};

/// Descriptor for `DeleteProductCardResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteProductCardResponseDescriptor = $convert.base64Decode(
    'ChlEZWxldGVQcm9kdWN0Q2FyZFJlc3BvbnNl');

@$core.Deprecated('Use getCommissionReqDescriptor instead')
const GetCommissionReq$json = {
  '1': 'GetCommissionReq',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
  ],
};

/// Descriptor for `GetCommissionReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCommissionReqDescriptor = $convert.base64Decode(
    'ChBHZXRDb21taXNzaW9uUmVxEg4KAmlkGAEgASgEUgJpZA==');

@$core.Deprecated('Use getCommissionRespDescriptor instead')
const GetCommissionResp$json = {
  '1': 'GetCommissionResp',
  '2': [
    {'1': 'commission', '3': 1, '4': 1, '5': 5, '10': 'commission'},
    {'1': 'category', '3': 2, '4': 1, '5': 9, '10': 'category'},
    {'1': 'subject', '3': 3, '4': 1, '5': 9, '10': 'subject'},
    {'1': 'fbs', '3': 4, '4': 1, '5': 5, '10': 'fbs'},
    {'1': 'fbo', '3': 5, '4': 1, '5': 5, '10': 'fbo'},
  ],
};

/// Descriptor for `GetCommissionResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCommissionRespDescriptor = $convert.base64Decode(
    'ChFHZXRDb21taXNzaW9uUmVzcBIeCgpjb21taXNzaW9uGAEgASgFUgpjb21taXNzaW9uEhoKCG'
    'NhdGVnb3J5GAIgASgJUghjYXRlZ29yeRIYCgdzdWJqZWN0GAMgASgJUgdzdWJqZWN0EhAKA2Zi'
    'cxgEIAEoBVIDZmJzEhAKA2ZibxgFIAEoBVIDZmJv');

@$core.Deprecated('Use getOrdersFromToReqDescriptor instead')
const GetOrdersFromToReq$json = {
  '1': 'GetOrdersFromToReq',
  '2': [
    {'1': 'from', '3': 1, '4': 1, '5': 3, '10': 'from'},
    {'1': 'to', '3': 2, '4': 1, '5': 3, '10': 'to'},
    {'1': 'skus', '3': 3, '4': 3, '5': 4, '10': 'skus'},
  ],
};

/// Descriptor for `GetOrdersFromToReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOrdersFromToReqDescriptor = $convert.base64Decode(
    'ChJHZXRPcmRlcnNGcm9tVG9SZXESEgoEZnJvbRgBIAEoA1IEZnJvbRIOCgJ0bxgCIAEoA1ICdG'
    '8SEgoEc2t1cxgDIAMoBFIEc2t1cw==');

@$core.Deprecated('Use orderDescriptor instead')
const Order$json = {
  '1': 'Order',
  '2': [
    {'1': 'sku', '3': 1, '4': 1, '5': 4, '10': 'sku'},
    {'1': 'qty', '3': 2, '4': 1, '5': 4, '10': 'qty'},
  ],
};

/// Descriptor for `Order`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orderDescriptor = $convert.base64Decode(
    'CgVPcmRlchIQCgNza3UYASABKARSA3NrdRIQCgNxdHkYAiABKARSA3F0eQ==');

@$core.Deprecated('Use getOrdersFromToRespDescriptor instead')
const GetOrdersFromToResp$json = {
  '1': 'GetOrdersFromToResp',
  '2': [
    {'1': 'orders', '3': 1, '4': 3, '5': 11, '6': '.main.Order', '10': 'orders'},
  ],
};

/// Descriptor for `GetOrdersFromToResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOrdersFromToRespDescriptor = $convert.base64Decode(
    'ChNHZXRPcmRlcnNGcm9tVG9SZXNwEiMKBm9yZGVycxgBIAMoCzILLm1haW4uT3JkZXJSBm9yZG'
    'Vycw==');

