import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
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
  Future<Resource<void>> save(
      String token, List<CardOfProductModel> productCards) async {
    final channel = ClientChannel(
      APIConstants.apiHost,
      port: APIConstants.apiPort,
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
        return Resource.error(
          "Пользователь не авторизован",
        );
      }
      final request = AddProductsCardsRequest();
      for (final c in productCards) {
        request.productsCards
            .add(ProductCard(sku: Int64(c.nmId), name: c.name, image: c.img));
      }

      final _ = await stub.addProductsCards(request,
          options: CallOptions(metadata: headers));

      return Resource.empty();
    } catch (e) {
      if (e is GrpcError) {
        if (e.code == StatusCode.alreadyExists) {
          return Resource.error(
            "ALREADY_EXISTS",
          );
        } else if (e.code == StatusCode.invalidArgument) {
          return Resource.error(
            "Некорректные данные",
          );
        } else if (e.code == StatusCode.internal) {
          return Resource.error(
            "Ошибка сервера",
          );
        } else if (e.code == StatusCode.unavailable) {
          return Resource.error(
            ErrorsConstants.unavailable,
          );
        }
      }
    } finally {
      await channel.shutdown();
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  @override
  Future<Resource<List<CardOfProductModel>>> getAll(String token) async {
    final channel = ClientChannel(
      APIConstants.apiHost,
      port: APIConstants.apiPort,
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
        return Resource.error(
          "Пользователь не авторизован",
        );
      }
      final request = GetProductsCardsRequest();
      final response = await stub.getProductsCards(request,
          options: CallOptions(metadata: headers));
      List<CardOfProductModel> productsCards = [];
      for (final c in response.productsCards) {
        productsCards.add(CardOfProductModel(
            nmId: c.sku.toInt(), name: c.name, img: c.image));
      }
      return Resource.success(productsCards);
    } catch (e) {
      if (e is GrpcError) {
        if (e.code == StatusCode.notFound) {
          return Resource.error(
            "Пользователь не найден",
          );
        } else if (e.code == StatusCode.internal) {
          return Resource.error(
            "Ошибка сервера",
          );
        } else if (e.code == StatusCode.unavailable) {
          return Resource.error(
            ErrorsConstants.unavailable,
          );
        }
      }
    } finally {
      await channel.shutdown();
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  @override
  Future<Resource<void>> delete(String token, int id) async {
    final channel = ClientChannel(
      APIConstants.apiHost,
      port: APIConstants.apiPort,
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
        return Resource.error(
          "Пользователь не авторизован",
        );
      }
      final request = DeleteProductCardRequest(sku: Int64(id));

      final _ = await stub.deleteProductCard(request,
          options: CallOptions(metadata: headers));

      return Resource.empty();
    } catch (e) {
      if (e is GrpcError) {
        if (e.code == StatusCode.invalidArgument) {
          return Resource.error(
            "Некорректные данные",
          );
        } else if (e.code == StatusCode.internal) {
          return Resource.error(
            "Ошибка сервера",
          );
        } else if (e.code == StatusCode.unavailable) {
          return Resource.error(
            ErrorsConstants.unavailable,
          );
        }
      }
      return Resource.error(
        "Неизвестная ошибка в процессе удаления карточки на сервере: $e",
      );
    } finally {
      await channel.shutdown();
    }
  }
}
