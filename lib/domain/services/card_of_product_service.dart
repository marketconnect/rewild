import 'package:rewild/core/utils/resource.dart';

import 'package:rewild/domain/entities/card_of_product_model.dart';

import 'package:rewild/domain/entities/seller_model.dart';

import 'package:rewild/domain/entities/warehouse.dart';
import 'package:rewild/presentation/all_cards/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/bottom_navigation_screen/bottom_navigation_view_model.dart';

import 'package:rewild/presentation/single_card/single_card_screen_view_model.dart';

// API clients
abstract class CardOfProductServiceSellerApiClient {
  Future<Resource<SellerModel>> fetchSeller(int sellerID);
}

abstract class CardOfProductServiceWarehouseApiCient {
  Future<Resource<List<Warehouse>>> fetchAll();
}

abstract class CardOfProductServiceCardOfProductApiClient {
  Future<Resource<void>> delete(String token, int id);
}

// Data providers
// warehouse
abstract class CardOfProductServiceWarehouseDataProvider {
  Future<Resource<bool>> update(List<Warehouse> warehouses);
  Future<Resource<String>> get(int id);
}

// // init stock
// abstract class CardOfProductServiceInitStockDataProvider {
//   Future<Resource<int>> insert(InitialStockModel initialStock);
//   // Future<Resource<List<InitialStockModel>>> get(
//   //     int nmId, DateTime dateFrom, DateTime dateTo);
// }

// card
abstract class CardOfProductServiceCardOfProductDataProvider {
  Future<Resource<List<CardOfProductModel>>> getAll();

  // Future<Resource<int>> insertOrUpdate(CardOfProductModel card);
  Future<Resource<CardOfProductModel>> get(int id);
  Future<Resource<int>> delete(int id);
}

class CardOfProductService
    implements
        SingleCardScreenCardOfProductService,
        BottomNavigationCardService,
        AllCardsScreenCardOfProductService {
  final CardOfProductServiceWarehouseDataProvider warehouseDataprovider;

  final CardOfProductServiceWarehouseApiCient warehouseApiClient;
  final CardOfProductServiceCardOfProductApiClient cardOfProductApiClient;
  final CardOfProductServiceCardOfProductDataProvider cardOfProductDataProvider;

  CardOfProductService({
    required this.warehouseDataprovider,
    required this.warehouseApiClient,
    required this.cardOfProductApiClient,
    required this.cardOfProductDataProvider,
  });

  @override
  Future<Resource<int>> count() async {
    final allCardsResource = await cardOfProductDataProvider.getAll();
    if (allCardsResource is Error) {
      return Resource.error(allCardsResource.message!);
    }
    return Resource.success(allCardsResource.data!.length);
  }

  @override
  Future<Resource<List<CardOfProductModel>>> getAll(
      DateTime dateFrom, DateTime dateTo) async {
    final allCardsResource = await cardOfProductDataProvider.getAll();
    if (allCardsResource is Error) {
      return Resource.error(allCardsResource.message!);
    }
    List<CardOfProductModel> allCards = allCardsResource.data!;

    return Resource.success(allCards);
  }

  @override
  Future<Resource<CardOfProductModel?>> getOne(int nmId) async {
    return await cardOfProductDataProvider.get(nmId);
  }

  @override
  Future<Resource<int>> delete(String token, List<int> ids) async {
    for (final id in ids) {
      // delete card from the server
      final deleteFromServerResource =
          await cardOfProductApiClient.delete(token, id);

      if (deleteFromServerResource is Error) {
        return Resource.error(deleteFromServerResource.message!);
      }

      // delete card from the local storage
      final deleteResource = await cardOfProductDataProvider.delete(id);
      if (deleteResource is Error) {
        return Resource.error(deleteResource.message!);
      }
    }

    return Resource.success(ids.length);
  }
}
