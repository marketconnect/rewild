import 'package:fpdart/fpdart.dart';

import 'package:rewild/core/utils/api_helpers/product_card_grpc_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/services/card_of_product_service.dart';
import 'package:rewild/domain/services/update_service.dart';
import 'package:rewild/pb/message.pb.dart';
import 'package:rewild/pb/service.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';

class CardOfProductApiClient
    implements
        CardOfProductServiceCardOfProductApiClient,
        UpdateServiceCardOfProductApiClient {
  const CardOfProductApiClient();
  @override
  Future<Either<RewildError, void>> save(
      String token, List<CardOfProductModel> productCards) async {
    final channel = ClientChannel(
      ProductCardApiHelper.grpcHost,
      port: ProductCardApiHelper.grpcPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectTimeout: Duration(seconds: 5),
        connectionTimeout: Duration(seconds: 5),
      ),
    );
    try {
      final stub = ProductCardServiceClient(channel);
      final headers = {'authorization': token};
      if (token.isEmpty) {
        return left(RewildError(
          "Пользователь не авторизован",
          source: runtimeType.toString(),
          name: "save",
          args: [token, productCards],
        ));
      }
      final request = AddProductsCardsRequest();
      for (final c in productCards) {
        request.productsCards
            .add(ProductCard(sku: Int64(c.nmId), name: c.name, image: c.img));
      }

      final _ = await stub.addProductsCards(request,
          options: CallOptions(metadata: headers));

      return right(null);
    } catch (e) {
      if (e is GrpcError) {
        final apiHelper = ProductCardApiHelper.get;
        final errString = apiHelper.errResponse(
          statusCode: e.code,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "save",
          args: [token, productCards],
        ));
      }
      return left(RewildError(
        "Неизвестная ошибка ${e.toString()}",
        source: runtimeType.toString(),
        name: "save",
        args: [token, productCards],
      ));
    } finally {
      await channel.shutdown();
    }
  }

  @override
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      String token) async {
    final channel = ClientChannel(
      ProductCardApiHelper.grpcHost,
      port: ProductCardApiHelper.grpcPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectTimeout: Duration(seconds: 5),
        connectionTimeout: Duration(seconds: 5),
      ),
    );
    try {
      final stub = ProductCardServiceClient(channel);
      final headers = {'authorization': token};
      if (token.isEmpty) {
        return left(RewildError(
          "Пользователь не авторизован",
          source: runtimeType.toString(),
          name: "getAll",
          args: [token],
        ));
      }
      final request = GetProductsCardsRequest();
      final response = await stub.getProductsCards(request,
          options: CallOptions(metadata: headers));
      List<CardOfProductModel> productsCards = [];
      for (final c in response.productsCards) {
        productsCards.add(CardOfProductModel(
            nmId: c.sku.toInt(), name: c.name, img: c.image));
      }
      return right(productsCards);
    } catch (e) {
      if (e is GrpcError) {
        final apiHelper = ProductCardApiHelper.getAll;
        final errString = apiHelper.errResponse(
          statusCode: e.code,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "getAll",
          args: [token],
        ));
      }
      return left(RewildError(
        "Неизвестная ошибка",
        source: runtimeType.toString(),
        name: "getAll",
        args: [token],
      ));
    } finally {
      await channel.shutdown();
    }
  }

  @override
  Future<Either<RewildError, void>> delete(String token, int id) async {
    final channel = ClientChannel(
      ProductCardApiHelper.grpcHost,
      port: ProductCardApiHelper.grpcPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectTimeout: Duration(seconds: 5),
        connectionTimeout: Duration(seconds: 5),
      ),
    );
    try {
      final stub = ProductCardServiceClient(channel);
      final headers = {'authorization': token};
      if (token.isEmpty) {
        return left(RewildError(
          "Пользователь не авторизован",
          source: runtimeType.toString(),
          name: "delete",
          args: [token, id],
        ));
      }
      final request = DeleteProductCardRequest(sku: Int64(id));

      final _ = await stub.deleteProductCard(request,
          options: CallOptions(metadata: headers));

      return right(null);
    } catch (e) {
      if (e is GrpcError) {
        if (e.code == StatusCode.invalidArgument) {
          final apiHelper = ProductCardApiHelper.delete;
          final errString = apiHelper.errResponse(
            statusCode: e.code,
          );
          return left(RewildError(
            errString,
            source: runtimeType.toString(),
            name: "getAll",
            args: [token],
          ));
        }
      }
      return left(RewildError(
        "Неизвестная ошибка в процессе удаления карточки на сервере: $e",
        source: runtimeType.toString(),
        name: "delete",
        args: [token, id],
      ));
    } finally {
      await channel.shutdown();
    }
  }
}
