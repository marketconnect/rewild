//
//  Generated code. Do not modify.
//  source: message.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
// ignore: depend_on_referenced_packages
import 'package:protobuf/protobuf.dart' as $pb;

class Empty extends $pb.GeneratedMessage {
  factory Empty() => create();
  Empty._() : super();
  factory Empty.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Empty.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Empty',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Empty clone() => Empty()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty)) as Empty;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Empty create() => Empty._();
  Empty createEmptyInstance() => create();
  static $pb.PbList<Empty> createRepeated() => $pb.PbList<Empty>();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty? _defaultInstance;
}

/// Auth
class AuthRequest extends $pb.GeneratedMessage {
  factory AuthRequest({
    $core.String? username,
    $core.String? password,
  }) {
    final $result = create();
    if (username != null) {
      $result.username = username;
    }
    if (password != null) {
      $result.password = password;
    }
    return $result;
  }
  AuthRequest._() : super();
  factory AuthRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AuthRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuthRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AuthRequest clone() => AuthRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AuthRequest copyWith(void Function(AuthRequest) updates) =>
      super.copyWith((message) => updates(message as AuthRequest))
          as AuthRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthRequest create() => AuthRequest._();
  AuthRequest createEmptyInstance() => create();
  static $pb.PbList<AuthRequest> createRepeated() => $pb.PbList<AuthRequest>();
  @$core.pragma('dart2js:noInline')
  static AuthRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AuthRequest>(create);
  static AuthRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => clearField(2);
}

class TokenResponse extends $pb.GeneratedMessage {
  factory TokenResponse({
    $core.String? token,
    $core.bool? freebie,
    $core.bool? timeToUpdateCommission,
    $fixnum.Int64? expiredAt,
  }) {
    final $result = create();
    if (token != null) {
      $result.token = token;
    }
    if (freebie != null) {
      $result.freebie = freebie;
    }
    if (timeToUpdateCommission != null) {
      $result.timeToUpdateCommission = timeToUpdateCommission;
    }
    if (expiredAt != null) {
      $result.expiredAt = expiredAt;
    }
    return $result;
  }
  TokenResponse._() : super();
  factory TokenResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TokenResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TokenResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..aOB(2, _omitFieldNames ? '' : 'freebie')
    ..aOB(3, _omitFieldNames ? '' : 'timeToUpdateCommission',
        protoName: 'timeToUpdateCommission')
    ..aInt64(4, _omitFieldNames ? '' : 'expiredAt', protoName: 'expiredAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TokenResponse clone() => TokenResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TokenResponse copyWith(void Function(TokenResponse) updates) =>
      super.copyWith((message) => updates(message as TokenResponse))
          as TokenResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TokenResponse create() => TokenResponse._();
  TokenResponse createEmptyInstance() => create();
  static $pb.PbList<TokenResponse> createRepeated() =>
      $pb.PbList<TokenResponse>();
  @$core.pragma('dart2js:noInline')
  static TokenResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TokenResponse>(create);
  static TokenResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get freebie => $_getBF(1);
  @$pb.TagNumber(2)
  set freebie($core.bool v) {
    $_setBool(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasFreebie() => $_has(1);
  @$pb.TagNumber(2)
  void clearFreebie() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get timeToUpdateCommission => $_getBF(2);
  @$pb.TagNumber(3)
  set timeToUpdateCommission($core.bool v) {
    $_setBool(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTimeToUpdateCommission() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeToUpdateCommission() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get expiredAt => $_getI64(3);
  @$pb.TagNumber(4)
  set expiredAt($fixnum.Int64 v) {
    $_setInt64(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasExpiredAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpiredAt() => clearField(4);
}

/// Products Cards
class ProductCard extends $pb.GeneratedMessage {
  factory ProductCard({
    $fixnum.Int64? sku,
    $core.String? name,
    $core.String? image,
  }) {
    final $result = create();
    if (sku != null) {
      $result.sku = sku;
    }
    if (name != null) {
      $result.name = name;
    }
    if (image != null) {
      $result.image = image;
    }
    return $result;
  }
  ProductCard._() : super();
  factory ProductCard.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ProductCard.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProductCard',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'sku', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'image')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ProductCard clone() => ProductCard()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ProductCard copyWith(void Function(ProductCard) updates) =>
      super.copyWith((message) => updates(message as ProductCard))
          as ProductCard;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProductCard create() => ProductCard._();
  ProductCard createEmptyInstance() => create();
  static $pb.PbList<ProductCard> createRepeated() => $pb.PbList<ProductCard>();
  @$core.pragma('dart2js:noInline')
  static ProductCard getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProductCard>(create);
  static ProductCard? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sku => $_getI64(0);
  @$pb.TagNumber(1)
  set sku($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSku() => $_has(0);
  @$pb.TagNumber(1)
  void clearSku() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get image => $_getSZ(2);
  @$pb.TagNumber(3)
  set image($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasImage() => $_has(2);
  @$pb.TagNumber(3)
  void clearImage() => clearField(3);
}

class AddProductsCardsRequest extends $pb.GeneratedMessage {
  factory AddProductsCardsRequest({
    $core.Iterable<ProductCard>? productsCards,
  }) {
    final $result = create();
    if (productsCards != null) {
      $result.productsCards.addAll(productsCards);
    }
    return $result;
  }
  AddProductsCardsRequest._() : super();
  factory AddProductsCardsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AddProductsCardsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddProductsCardsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..pc<ProductCard>(
        1, _omitFieldNames ? '' : 'productsCards', $pb.PbFieldType.PM,
        protoName: 'productsCards', subBuilder: ProductCard.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AddProductsCardsRequest clone() =>
      AddProductsCardsRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AddProductsCardsRequest copyWith(
          void Function(AddProductsCardsRequest) updates) =>
      super.copyWith((message) => updates(message as AddProductsCardsRequest))
          as AddProductsCardsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddProductsCardsRequest create() => AddProductsCardsRequest._();
  AddProductsCardsRequest createEmptyInstance() => create();
  static $pb.PbList<AddProductsCardsRequest> createRepeated() =>
      $pb.PbList<AddProductsCardsRequest>();
  @$core.pragma('dart2js:noInline')
  static AddProductsCardsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddProductsCardsRequest>(create);
  static AddProductsCardsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ProductCard> get productsCards => $_getList(0);
}

class AddProductsCardsResponse extends $pb.GeneratedMessage {
  factory AddProductsCardsResponse({
    $core.int? qty,
  }) {
    final $result = create();
    if (qty != null) {
      $result.qty = qty;
    }
    return $result;
  }
  AddProductsCardsResponse._() : super();
  factory AddProductsCardsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AddProductsCardsResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddProductsCardsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'qty', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AddProductsCardsResponse clone() =>
      AddProductsCardsResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AddProductsCardsResponse copyWith(
          void Function(AddProductsCardsResponse) updates) =>
      super.copyWith((message) => updates(message as AddProductsCardsResponse))
          as AddProductsCardsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddProductsCardsResponse create() => AddProductsCardsResponse._();
  AddProductsCardsResponse createEmptyInstance() => create();
  static $pb.PbList<AddProductsCardsResponse> createRepeated() =>
      $pb.PbList<AddProductsCardsResponse>();
  @$core.pragma('dart2js:noInline')
  static AddProductsCardsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddProductsCardsResponse>(create);
  static AddProductsCardsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get qty => $_getIZ(0);
  @$pb.TagNumber(1)
  set qty($core.int v) {
    $_setSignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasQty() => $_has(0);
  @$pb.TagNumber(1)
  void clearQty() => clearField(1);
}

class GetProductsCardsRequest extends $pb.GeneratedMessage {
  factory GetProductsCardsRequest() => create();
  GetProductsCardsRequest._() : super();
  factory GetProductsCardsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetProductsCardsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProductsCardsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetProductsCardsRequest clone() =>
      GetProductsCardsRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetProductsCardsRequest copyWith(
          void Function(GetProductsCardsRequest) updates) =>
      super.copyWith((message) => updates(message as GetProductsCardsRequest))
          as GetProductsCardsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProductsCardsRequest create() => GetProductsCardsRequest._();
  GetProductsCardsRequest createEmptyInstance() => create();
  static $pb.PbList<GetProductsCardsRequest> createRepeated() =>
      $pb.PbList<GetProductsCardsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetProductsCardsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProductsCardsRequest>(create);
  static GetProductsCardsRequest? _defaultInstance;
}

class GetProductsCardsResponse extends $pb.GeneratedMessage {
  factory GetProductsCardsResponse({
    $core.Iterable<ProductCard>? productsCards,
  }) {
    final $result = create();
    if (productsCards != null) {
      $result.productsCards.addAll(productsCards);
    }
    return $result;
  }
  GetProductsCardsResponse._() : super();
  factory GetProductsCardsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetProductsCardsResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProductsCardsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..pc<ProductCard>(
        1, _omitFieldNames ? '' : 'productsCards', $pb.PbFieldType.PM,
        protoName: 'productsCards', subBuilder: ProductCard.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetProductsCardsResponse clone() =>
      GetProductsCardsResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetProductsCardsResponse copyWith(
          void Function(GetProductsCardsResponse) updates) =>
      super.copyWith((message) => updates(message as GetProductsCardsResponse))
          as GetProductsCardsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProductsCardsResponse create() => GetProductsCardsResponse._();
  GetProductsCardsResponse createEmptyInstance() => create();
  static $pb.PbList<GetProductsCardsResponse> createRepeated() =>
      $pb.PbList<GetProductsCardsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetProductsCardsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProductsCardsResponse>(create);
  static GetProductsCardsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ProductCard> get productsCards => $_getList(0);
}

class GetStocksFromToReq extends $pb.GeneratedMessage {
  factory GetStocksFromToReq({
    $fixnum.Int64? from,
    $fixnum.Int64? to,
    $core.Iterable<$fixnum.Int64>? skus,
  }) {
    final $result = create();
    if (from != null) {
      $result.from = from;
    }
    if (to != null) {
      $result.to = to;
    }
    if (skus != null) {
      $result.skus.addAll(skus);
    }
    return $result;
  }
  GetStocksFromToReq._() : super();
  factory GetStocksFromToReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetStocksFromToReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStocksFromToReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'from')
    ..aInt64(2, _omitFieldNames ? '' : 'to')
    ..p<$fixnum.Int64>(3, _omitFieldNames ? '' : 'skus', $pb.PbFieldType.KU6)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetStocksFromToReq clone() => GetStocksFromToReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetStocksFromToReq copyWith(void Function(GetStocksFromToReq) updates) =>
      super.copyWith((message) => updates(message as GetStocksFromToReq))
          as GetStocksFromToReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStocksFromToReq create() => GetStocksFromToReq._();
  GetStocksFromToReq createEmptyInstance() => create();
  static $pb.PbList<GetStocksFromToReq> createRepeated() =>
      $pb.PbList<GetStocksFromToReq>();
  @$core.pragma('dart2js:noInline')
  static GetStocksFromToReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStocksFromToReq>(create);
  static GetStocksFromToReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get from => $_getI64(0);
  @$pb.TagNumber(1)
  set from($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasFrom() => $_has(0);
  @$pb.TagNumber(1)
  void clearFrom() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get to => $_getI64(1);
  @$pb.TagNumber(2)
  set to($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasTo() => $_has(1);
  @$pb.TagNumber(2)
  void clearTo() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$fixnum.Int64> get skus => $_getList(2);
}

class Stock extends $pb.GeneratedMessage {
  factory Stock({
    $fixnum.Int64? sku,
    $fixnum.Int64? wh,
    $fixnum.Int64? sizeOptionId,
    $core.int? qty,
  }) {
    final $result = create();
    if (sku != null) {
      $result.sku = sku;
    }
    if (wh != null) {
      $result.wh = wh;
    }
    if (sizeOptionId != null) {
      $result.sizeOptionId = sizeOptionId;
    }
    if (qty != null) {
      $result.qty = qty;
    }
    return $result;
  }
  Stock._() : super();
  factory Stock.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Stock.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Stock',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'sku', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'wh', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'sizeOptionId', $pb.PbFieldType.OU6,
        protoName: 'sizeOptionId', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'qty', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Stock clone() => Stock()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Stock copyWith(void Function(Stock) updates) =>
      super.copyWith((message) => updates(message as Stock)) as Stock;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Stock create() => Stock._();
  Stock createEmptyInstance() => create();
  static $pb.PbList<Stock> createRepeated() => $pb.PbList<Stock>();
  @$core.pragma('dart2js:noInline')
  static Stock getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Stock>(create);
  static Stock? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sku => $_getI64(0);
  @$pb.TagNumber(1)
  set sku($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSku() => $_has(0);
  @$pb.TagNumber(1)
  void clearSku() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get wh => $_getI64(1);
  @$pb.TagNumber(2)
  set wh($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasWh() => $_has(1);
  @$pb.TagNumber(2)
  void clearWh() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sizeOptionId => $_getI64(2);
  @$pb.TagNumber(3)
  set sizeOptionId($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasSizeOptionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSizeOptionId() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get qty => $_getIZ(3);
  @$pb.TagNumber(4)
  set qty($core.int v) {
    $_setSignedInt32(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasQty() => $_has(3);
  @$pb.TagNumber(4)
  void clearQty() => clearField(4);
}

class GetStocksFromToResp extends $pb.GeneratedMessage {
  factory GetStocksFromToResp({
    $core.Iterable<Stock>? stocks,
  }) {
    final $result = create();
    if (stocks != null) {
      $result.stocks.addAll(stocks);
    }
    return $result;
  }
  GetStocksFromToResp._() : super();
  factory GetStocksFromToResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetStocksFromToResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStocksFromToResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..pc<Stock>(1, _omitFieldNames ? '' : 'stocks', $pb.PbFieldType.PM,
        subBuilder: Stock.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetStocksFromToResp clone() => GetStocksFromToResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetStocksFromToResp copyWith(void Function(GetStocksFromToResp) updates) =>
      super.copyWith((message) => updates(message as GetStocksFromToResp))
          as GetStocksFromToResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStocksFromToResp create() => GetStocksFromToResp._();
  GetStocksFromToResp createEmptyInstance() => create();
  static $pb.PbList<GetStocksFromToResp> createRepeated() =>
      $pb.PbList<GetStocksFromToResp>();
  @$core.pragma('dart2js:noInline')
  static GetStocksFromToResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStocksFromToResp>(create);
  static GetStocksFromToResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Stock> get stocks => $_getList(0);
}

class DeleteProductCardRequest extends $pb.GeneratedMessage {
  factory DeleteProductCardRequest({
    $fixnum.Int64? sku,
  }) {
    final $result = create();
    if (sku != null) {
      $result.sku = sku;
    }
    return $result;
  }
  DeleteProductCardRequest._() : super();
  factory DeleteProductCardRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DeleteProductCardRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteProductCardRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'sku', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DeleteProductCardRequest clone() =>
      DeleteProductCardRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DeleteProductCardRequest copyWith(
          void Function(DeleteProductCardRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteProductCardRequest))
          as DeleteProductCardRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteProductCardRequest create() => DeleteProductCardRequest._();
  DeleteProductCardRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteProductCardRequest> createRepeated() =>
      $pb.PbList<DeleteProductCardRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteProductCardRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteProductCardRequest>(create);
  static DeleteProductCardRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sku => $_getI64(0);
  @$pb.TagNumber(1)
  set sku($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSku() => $_has(0);
  @$pb.TagNumber(1)
  void clearSku() => clearField(1);
}

class DeleteProductCardResponse extends $pb.GeneratedMessage {
  factory DeleteProductCardResponse() => create();
  DeleteProductCardResponse._() : super();
  factory DeleteProductCardResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DeleteProductCardResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteProductCardResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DeleteProductCardResponse clone() =>
      DeleteProductCardResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DeleteProductCardResponse copyWith(
          void Function(DeleteProductCardResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteProductCardResponse))
          as DeleteProductCardResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteProductCardResponse create() => DeleteProductCardResponse._();
  DeleteProductCardResponse createEmptyInstance() => create();
  static $pb.PbList<DeleteProductCardResponse> createRepeated() =>
      $pb.PbList<DeleteProductCardResponse>();
  @$core.pragma('dart2js:noInline')
  static DeleteProductCardResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteProductCardResponse>(create);
  static DeleteProductCardResponse? _defaultInstance;
}

/// Commissions
class GetCommissionReq extends $pb.GeneratedMessage {
  factory GetCommissionReq({
    $fixnum.Int64? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetCommissionReq._() : super();
  factory GetCommissionReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetCommissionReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCommissionReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetCommissionReq clone() => GetCommissionReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetCommissionReq copyWith(void Function(GetCommissionReq) updates) =>
      super.copyWith((message) => updates(message as GetCommissionReq))
          as GetCommissionReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCommissionReq create() => GetCommissionReq._();
  GetCommissionReq createEmptyInstance() => create();
  static $pb.PbList<GetCommissionReq> createRepeated() =>
      $pb.PbList<GetCommissionReq>();
  @$core.pragma('dart2js:noInline')
  static GetCommissionReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCommissionReq>(create);
  static GetCommissionReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class GetCommissionResp extends $pb.GeneratedMessage {
  factory GetCommissionResp({
    $core.int? commission,
    $core.String? category,
    $core.String? subject,
    $core.int? fbs,
    $core.int? fbo,
  }) {
    final $result = create();
    if (commission != null) {
      $result.commission = commission;
    }
    if (category != null) {
      $result.category = category;
    }
    if (subject != null) {
      $result.subject = subject;
    }
    if (fbs != null) {
      $result.fbs = fbs;
    }
    if (fbo != null) {
      $result.fbo = fbo;
    }
    return $result;
  }
  GetCommissionResp._() : super();
  factory GetCommissionResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetCommissionResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCommissionResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'main'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'commission', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'category')
    ..aOS(3, _omitFieldNames ? '' : 'subject')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'fbs', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'fbo', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetCommissionResp clone() => GetCommissionResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetCommissionResp copyWith(void Function(GetCommissionResp) updates) =>
      super.copyWith((message) => updates(message as GetCommissionResp))
          as GetCommissionResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCommissionResp create() => GetCommissionResp._();
  GetCommissionResp createEmptyInstance() => create();
  static $pb.PbList<GetCommissionResp> createRepeated() =>
      $pb.PbList<GetCommissionResp>();
  @$core.pragma('dart2js:noInline')
  static GetCommissionResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCommissionResp>(create);
  static GetCommissionResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get commission => $_getIZ(0);
  @$pb.TagNumber(1)
  set commission($core.int v) {
    $_setSignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasCommission() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommission() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get category => $_getSZ(1);
  @$pb.TagNumber(2)
  set category($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCategory() => $_has(1);
  @$pb.TagNumber(2)
  void clearCategory() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get subject => $_getSZ(2);
  @$pb.TagNumber(3)
  set subject($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasSubject() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubject() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get fbs => $_getIZ(3);
  @$pb.TagNumber(4)
  set fbs($core.int v) {
    $_setSignedInt32(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasFbs() => $_has(3);
  @$pb.TagNumber(4)
  void clearFbs() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get fbo => $_getIZ(4);
  @$pb.TagNumber(5)
  set fbo($core.int v) {
    $_setSignedInt32(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasFbo() => $_has(4);
  @$pb.TagNumber(5)
  void clearFbo() => clearField(5);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
