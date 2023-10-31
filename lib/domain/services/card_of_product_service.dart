import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';

import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';

import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/domain/entities/size_model.dart';
import 'package:rewild/domain/entities/stocks_model.dart';
import 'package:rewild/domain/entities/supply_model.dart';

import 'package:rewild/domain/entities/warehouse.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/bottom_navigation_screen/bottom_navigation_view_model.dart';

import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';
import 'package:rewild/presentation/single_group_scrren/single_groups_screen_view_model.dart';

// API clients
abstract class CardOfProductServiceSellerApiClient {
  Future<Resource<SellerModel>> fetchSeller(int sellerID);
}

// Warehouse
abstract class CardOfProductServiceWarehouseApiCient {
  Future<Resource<List<Warehouse>>> fetchAll();
}

// Card
abstract class CardOfProductServiceCardOfProductApiClient {
  Future<Resource<void>> delete(String token, int id);
}

// Data providers
// warehouse
abstract class CardOfProductServiceWarehouseDataProvider {
  Future<Resource<bool>> update(List<Warehouse> warehouses);
  Future<Resource<String>> get(int id);
}

// stock
abstract class CardOfProductServiceStockDataProvider {
  Future<Resource<List<StocksModel>>> getAll();
}

// init stock
abstract class CardOfProductServiceInitStockDataProvider {
  Future<Resource<List<InitialStockModel>>> getAll(
      DateTime dateFrom, DateTime dateTo);
}

// supply
abstract class CardOfProductServiceSupplyDataProvider {
  Future<Resource<List<SupplyModel>>> get(int nmId);
}

// card
abstract class CardOfProductServiceCardOfProductDataProvider {
  Future<Resource<List<CardOfProductModel>>> getAll([List<int>? nmIds]);
  Future<Resource<CardOfProductModel>> get(int id);
  Future<Resource<int>> delete(int id);
}

class CardOfProductService
    implements
        SingleCardScreenCardOfProductService,
        BottomNavigationCardService,
        AllCardsScreenCardOfProductService,
        SingleGroupScreenViewModelCardsService {
  final CardOfProductServiceWarehouseDataProvider warehouseDataprovider;
  final CardOfProductServiceStockDataProvider stockDataprovider;
  final CardOfProductServiceWarehouseApiCient warehouseApiClient;
  final CardOfProductServiceCardOfProductApiClient cardOfProductApiClient;
  final CardOfProductServiceCardOfProductDataProvider cardOfProductDataProvider;
  final CardOfProductServiceInitStockDataProvider initStockDataProvider;
  final CardOfProductServiceSupplyDataProvider supplyDataProvider;
  CardOfProductService({
    required this.warehouseDataprovider,
    required this.warehouseApiClient,
    required this.cardOfProductApiClient,
    required this.cardOfProductDataProvider,
    required this.stockDataprovider,
    required this.initStockDataProvider,
    required this.supplyDataProvider,
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
  Future<Resource<List<CardOfProductModel>>> getAll([List<int>? nmIds]) async {
    List<CardOfProductModel> resultCards = [];
    // Cards
    final allCardsResource = await cardOfProductDataProvider.getAll(nmIds);
    if (allCardsResource is Error) {
      return Resource.error(allCardsResource.message!);
    }
    List<CardOfProductModel> allCards = allCardsResource.data!;

    // get stocks
    final stocksResource = await stockDataprovider.getAll();
    if (stocksResource is Error) {
      return Resource.error(stocksResource.message!);
    }
    final stocks = stocksResource.data!;
    final dateFrom = yesterdayEndOfTheDay();
    final dateTo = DateTime.now();

    // get init stocks
    final initStocksResource = await initStockDataProvider.getAll(
      dateFrom,
      dateTo,
    );
    if (initStocksResource is Error) {
      return Resource.error(initStocksResource.message!);
    }

    final initialStocks = initStocksResource.data!;

    // append stocks and init stocks to cards
    for (final card in allCards) {
      // append stocks
      final cardStocks =
          stocks.where((stock) => stock.nmId == card.nmId).toList();
      final sizes = [SizeModel(stocks: cardStocks)];
      final cardWithStocks = card.copyWith(sizes: sizes);

      // append init stocks
      final initStocks = initialStocks
          .where((initStock) => initStock.nmId == card.nmId)
          .toList();

      final newCard = cardWithStocks.copyWith(initialStocks: initStocks);

      // append supplies
      final suppliesResource = await supplyDataProvider.get(newCard.nmId);
      if (suppliesResource is Error) {
        return Resource.error(suppliesResource.message!);
      }

      final supplies = suppliesResource.data!;
      newCard.setSupplies(supplies);
      resultCards.add(newCard);
    }

    return Resource.success(resultCards);
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
