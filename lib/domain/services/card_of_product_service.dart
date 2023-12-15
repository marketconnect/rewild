import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/rewild_error.dart';

import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';

import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/domain/entities/size_model.dart';
import 'package:rewild/domain/entities/stocks_model.dart';
import 'package:rewild/domain/entities/supply_model.dart';

import 'package:rewild/domain/entities/warehouse.dart';
import 'package:rewild/presentation/all_adverts_stat_screen/all_adverts_stat_screen_view_model.dart';
import 'package:rewild/presentation/all_adverts_words_screen/all_adverts_words_view_model.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';

import 'package:rewild/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild/presentation/all_products_feedback_screen/all_products_feedback_view_model.dart';

import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';
import 'package:rewild/presentation/single_group_screen/single_groups_screen_view_model.dart';

// API clients
abstract class CardOfProductServiceSellerApiClient {
  Future<Either<RewildError, SellerModel>> fetchSeller({required int sellerID});
}

// Warehouse
abstract class CardOfProductServiceWarehouseApiCient {
  Future<Either<RewildError, List<Warehouse>>> getAll();
}

// Card
abstract class CardOfProductServiceCardOfProductApiClient {
  Future<Either<RewildError, void>> delete(
      {required String token, required int id});
}

// Data providers
// warehouse
abstract class CardOfProductServiceWarehouseDataProvider {
  Future<Either<RewildError, String?>> get({required int id}) ;
  Future<Either<RewildError, bool>> update({required List<Warehouse> warehouses});
  
}

// stock
abstract class CardOfProductServiceStockDataProvider {
  Future<Either<RewildError, List<StocksModel>>> getAll();
}

// init stock
abstract class CardOfProductServiceInitStockDataProvider {
  Future<Either<RewildError, List<InitialStockModel>>> getAll(
      {required DateTime dateFrom, required DateTime dateTo});
}

// supply
abstract class CardOfProductServiceSupplyDataProvider {
  Future<Either<RewildError, List<SupplyModel>>> get(
      {required int nmId});
}

// card
abstract class CardOfProductServiceCardOfProductDataProvider {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]);
  Future<Either<RewildError, CardOfProductModel>> get({required int id});
  Future<Either<RewildError, int>> delete({required int id});
  Future<Either<RewildError, String>> getImage({required int id});
  Future<Either<RewildError, List<CardOfProductModel>>> getAllBySupplierId(
      {required int supplierId});
}

class CardOfProductService
    implements
        SingleCardScreenCardOfProductService,
        MainNavigationCardService,
        AllAdvertsStatScreenCardOfProductService,
        AllCardsScreenCardOfProductService,
        AllProductsFeedbackCardOfProductService,
        AllAdvertsWordsScreenCardOfProductService,
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
  Future<Either<RewildError, int>> count() async {
    final allCardsResource = await cardOfProductDataProvider.getAll();
    if (allCardsResource is Error) {
      return left(RewildError(allCardsResource.message!,
          source: runtimeType.toString(), name: 'count', args: []);
    }

    return right(allCardsResource.data!.length);
  }

  @override
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]) async {
    List<CardOfProductModel> resultCards = [];
    // Cards
    final allCardsResource = await cardOfProductDataProvider.getAll(nmIds);
    if (allCardsResource is Error) {
      return left(RewildError(allCardsResource.message!,
          source: runtimeType.toString(), name: 'getAll', args: [nmIds]);
    }
    List<CardOfProductModel> allCards = allCardsResource.data!;

    // get stocks
    final stocksResource = await stockDataprovider.getAll();
    if (stocksResource is Error) {
      return left(RewildError(stocksResource.message!,
          source: runtimeType.toString(), name: 'getAll', args: [nmIds]);
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
      return left(RewildError(initStocksResource.message!,
          source: runtimeType.toString(), name: 'getAll', args: [nmIds]);
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
        return left(RewildError(suppliesResource.message!,
            source: runtimeType.toString(), name: 'getAll', args: [nmIds]);
      }

      final supplies = suppliesResource.data!;
      newCard.setSupplies(supplies);
      resultCards.add(newCard);
    }

    return right(resultCards);
  }

  @override
  Future<Either<RewildError, CardOfProductModel?>> getOne(int nmId) async {
    return await cardOfProductDataProvider.get(nmId);
  }

  @override
  Future<Either<RewildError, String>> getImageForNmId(int id) async {
    final imgResource = await cardOfProductDataProvider.getImage(id);

    if (imgResource is Error) {
      return left(RewildError(imgResource.message!,
          source: runtimeType.toString(), name: 'getImageForNmId', args: [id]);
    }

    final img = imgResource.data;
    if (img == null || img.isEmpty) {
      return right('');
    }

    return right(img);
  }
}
