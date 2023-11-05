import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/entities/size_model.dart';
import 'package:rewild/domain/entities/stocks_model.dart';
import 'package:rewild/domain/entities/supply_model.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/my_web_view/my_web_view_screen_view_model.dart';
import 'package:rewild/presentation/splash_screen/splash_screen_view_model.dart';

// Details
abstract class UpdateServiceDetailsApiClient {
  Future<Resource<List<CardOfProductModel>>> get(List<int> ids);
}

// Supply
abstract class UpdateServiceSupplyDataProvider {
  Future<Resource<int>> insert(SupplyModel supply);
  Future<Resource<void>> delete({
    required int nmId,
    int? wh,
    int? sizeOptionId,
  });
  Future<Resource<SupplyModel>> getOne({
    required int nmId,
    required int wh,
    required int sizeOptionId,
  });
}

// Card of product data provider
abstract class UpdateServiceCardOfProductDataProvider {
  Future<Resource<List<CardOfProductModel>>> getAll();
  Future<Resource<int>> insertOrUpdate(CardOfProductModel card);
  Future<Resource<CardOfProductModel>> get(int id);
  Future<Resource<int>> delete(int id);
}

// Card of product api client
abstract class UpdateServiceCardOfProductApiClient {
  Future<Resource<void>> save(
      String token, List<CardOfProductModel> productCards);
  Future<Resource<List<CardOfProductModel>>> getAll(String token);
  Future<Resource<void>> delete(String token, int id);
}

// initial stock api client
abstract class UpdateServiceInitialStockApiClient {
  Future<Resource<List<InitialStockModel>>> get(
      List<int> skus, DateTime dateFrom, DateTime dateTo);
}

// init stock data provider
abstract class UpdateServiceInitStockDataProvider {
  Future<Resource<int>> insert(InitialStockModel initialStock);
  Future<Resource<List<InitialStockModel>>> get(
      int nmId, DateTime dateFrom, DateTime dateTo);
  Future<Resource<InitialStockModel>> getOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo,
      required int wh,
      required int sizeOptionId});
}

// stock data provider
abstract class UpdateServiceStockDataProvider {
  Future<Resource<int>> insert(StocksModel initialStock);
  Future<Resource<List<StocksModel>>> get(int nmId);
  Future<Resource<StocksModel>> getOne(
      {required int nmId, required int wh, required int sizeOptionId});
}

// last update day data provider
abstract class UpdateServiceLastUpdateDayDataProvider {
  Future<Resource<void>> update();
  Future<Resource<bool>> updated();
}

class UpdateService
    implements
        MyWebViewScreenViewModelUpdateService,
        AllCardsScreenUpdateService,
        SplashScreenViewModelUpdateService {
  final UpdateServiceDetailsApiClient detailsApiClient;
  final UpdateServiceSupplyDataProvider supplyDataProvider;
  final UpdateServiceCardOfProductDataProvider cardOfProductDataProvider;
  final UpdateServiceCardOfProductApiClient cardOfProductApiClient;
  final UpdateServiceInitialStockApiClient initialStockApiClient;
  final UpdateServiceInitStockDataProvider initialStockDataProvider;
  final UpdateServiceStockDataProvider stockDataProvider;
  final UpdateServiceLastUpdateDayDataProvider lastUpdateDayDataProvider;
  UpdateService(
      {required this.stockDataProvider,
      required this.detailsApiClient,
      required this.initialStockDataProvider,
      required this.cardOfProductDataProvider,
      required this.initialStockApiClient,
      required this.supplyDataProvider,
      required this.lastUpdateDayDataProvider,
      required this.cardOfProductApiClient});

  // Time to update?
  DateTime? updatedAt;
  void setUpdatedAt() {
    updatedAt = DateTime.now();
  }

  bool timeToUpdated() => updatedAt == null
      ? true
      : DateTime.now().difference(updatedAt!) > TimeConstants.updatePeriod;

  @override
  Future<Resource<void>> fetchAllUserCardsFromServer(String token) async {
    // check db is empty when app starts
    final cardsInDBResource = await cardOfProductDataProvider.getAll();

    if (cardsInDBResource is Error) {
      return Resource.error(cardsInDBResource.message!);
    }
    final cardsInDB = cardsInDBResource.data!;

    // Empty - try to fetch cards from server
    if (cardsInDB.isEmpty) {
      final cardsFromServer = await cardOfProductApiClient.getAll(token);
      if (cardsFromServer is Error) {
        return Resource.error(cardsFromServer.message!);
      }
      if (cardsFromServer is Success) {
        final cards = cardsFromServer.data!;
        // there are cards on server - save
        if (cards.isNotEmpty) {
          final insertOrUpdateResource = await insert(token, cards);
          if (insertOrUpdateResource is Error) {
            return Resource.error(insertOrUpdateResource.message!);
          }
        }
      }
    }
    return Resource.empty();
  }

  // returns quantity of inserted cards ========================================================================
  @override
  Future<Resource<int>> insert(
      String token, List<CardOfProductModel> cardOfProductsToInsert) async {
    // get all cards from local db
    final cardsInDBResource = await cardOfProductDataProvider.getAll();

    if (cardsInDBResource is Error) {
      return Resource.error(cardsInDBResource.message!);
    }
    final cardsInDB = cardsInDBResource.data!;

    // if a card already exists skip that
    final cardsInDBIds = cardsInDB.map((e) => e.nmId).toList();
    List<CardOfProductModel> newCards = [];
    for (final c in cardOfProductsToInsert) {
      if (cardsInDBIds.contains(c.nmId)) {
        continue;
      }
      newCards.add(c);
    }

    // if there are no new cards - return 0
    if (newCards.isEmpty) {
      return Resource.success(0);
    }

    // save on server cards that do not exist in DB
    final saveOnServerResource =
        await cardOfProductApiClient.save(token, newCards);
    if (saveOnServerResource is Error) {
      return Resource.error(saveOnServerResource.message!);
    }

    // try to fetch today`s initial stocks from server
    // in case when there are cards that was saved on server
    // earlier by somebody else
    List<InitialStockModel> initStocksFromServer = [];

    // ids of cards that initial stocks do not exist on server yet
    List<int> abscentOnServerNewCardsIds = newCards.map((e) => e.nmId).toList();

    // initial stocks from server
    final initialStocksResource = await initialStockApiClient.get(
      newCards.map((e) => e.nmId).toList(),
      yesterdayEndOfTheDay(),
      DateTime.now(),
    );
    if (initialStocksResource is Error) {
      return Resource.error(initialStocksResource.message!);
    }

    initStocksFromServer = initialStocksResource.data!;

    // save fetched from server initial stocks to local db
    for (final stock in initStocksFromServer) {
      final insertStockresource = await initialStockDataProvider.insert(stock);
      if (insertStockresource is Error) {
        return Resource.error(insertStockresource.message!);
      }

      // remove nmId that initial stock exists on server and in local db
      abscentOnServerNewCardsIds.remove(stock.nmId);
    }

    // fetch details for all new cards from wb
    final fetchedCardsOfProductsResource =
        await detailsApiClient.get(newCards.map((e) => e.nmId).toList());
    if (fetchedCardsOfProductsResource is Error) {
      return Resource.error(fetchedCardsOfProductsResource.message!);
    }
    final fetchedCardsOfProducts = fetchedCardsOfProductsResource.data!;

    // add to db cards
    for (final card in fetchedCardsOfProducts) {
      // append img
      final img = newCards.firstWhere((e) => e.nmId == card.nmId).img;
      card.img = img;
      // insert
      final insertResource =
          await cardOfProductDataProvider.insertOrUpdate(card);
      if (insertResource is Error) {
        return Resource.error(insertResource.message!);
      }

      // add stocks
      for (final size in card.sizes) {
        for (final stock in size.stocks) {
          final insertStockresource = await stockDataProvider.insert(stock);
          if (insertStockresource is Error) {
            return Resource.error(insertStockresource.message!);
          }
          // if the miracle does not happen
          // and initial stocks do not exist on server yet
          if (abscentOnServerNewCardsIds.contains(stock.nmId)) {
            // save fetched stocks to local db as initial stocks
            final insertStockresource =
                await initialStockDataProvider.insert(InitialStockModel(
              nmId: stock.nmId,
              sizeOptionId: stock.sizeOptionId,
              date: DateTime.now(),
              wh: stock.wh,
              qty: stock.qty,
            ));
            if (insertStockresource is Error) {
              return Resource.error(insertStockresource.message!);
            }
          }
        }
      }
    }

    return Resource.success(newCards.length);
  }

  // update cards ==============================================================
  @override
  Future<Resource<void>> update() async {
    if (!timeToUpdated()) {
      return Resource.empty();
    }
    // get cards from the local storage
    final cardsOfProductsResource = await cardOfProductDataProvider.getAll();
    if (cardsOfProductsResource is Error) {
      return Resource.error(cardsOfProductsResource.message!);
    }
    final allSavedCardsOfProducts = cardsOfProductsResource.data!;

    if (allSavedCardsOfProducts.isEmpty) {
      return Resource.empty();
    }

    // if it is Today`s first time update - update initial stocks
    final isUpdatedResource = await lastUpdateDayDataProvider.updated();
    if (isUpdatedResource is Error) {
      return Resource.error(isUpdatedResource.message!);
    }
    final isUpdated = isUpdatedResource.data!;

    // Update initial stocks!
    if (!isUpdated) {
      // try to fetch today`s initial stocks from server
      final todayInitialStocksFromServerResource =
          await _fetchTodayInitialStocksFromServer(
              allSavedCardsOfProducts.map((e) => e.nmId).toList());
      if (todayInitialStocksFromServerResource is Error) {
        return Resource.error(todayInitialStocksFromServerResource.message!);
      }
      final todayInitialStocksFromServer =
          todayInitialStocksFromServerResource.data!;

      // save today`s initial stocks to local db and delete supplies
      for (final stock in todayInitialStocksFromServer) {
        // save
        final insertStockresource =
            await initialStockDataProvider.insert(stock);
        if (insertStockresource is Error) {
          return Resource.error(insertStockresource.message!);
        }

        // delete
        final deleteSuppliesResource =
            await supplyDataProvider.delete(nmId: stock.nmId);
        if (deleteSuppliesResource is Error) {
          return Resource.error(deleteSuppliesResource.message!);
        }
      }
      await lastUpdateDayDataProvider.update();
    }

    // fetch details for all saved cards from wb
    final fetchedCardsOfProductsResource = await detailsApiClient
        .get(allSavedCardsOfProducts.map((e) => e.nmId).toList());
    if (fetchedCardsOfProductsResource is Error) {
      return Resource.error(fetchedCardsOfProductsResource.message!);
    }
    final fetchedCardsOfProducts = fetchedCardsOfProductsResource.data!;

    // ADD OTHER INFORMATION FOR EVERY FETCHED CARD

    for (final card in fetchedCardsOfProducts) {
      // get already saved card
      // final oldCard = allSavedCardsOfProducts.firstWhere(
      //   (e) => e.nmId == card.nmId,
      // );

      // insert img link
      // final img = oldCard.img;
      // card.img = img;

      // add the card to db
      final insertResource =
          await cardOfProductDataProvider.insertOrUpdate(card);
      if (insertResource is Error) {
        return Resource.error(insertResource.message!);
      }

      // add stocks
      final addStocksResource = await addStocks(card.sizes);
      if (addStocksResource is Error) {
        return Resource.error(addStocksResource.message!);
      }
    }
    setUpdatedAt();
    return Resource.empty();
  }

  Future<Resource<void>> addStocks(List<SizeModel> sizes) async {
    final dateFrom = yesterdayEndOfTheDay();
    final dateTo = DateTime.now();
    for (final size in sizes) {
      for (final stock in size.stocks) {
        // get saved init stock
        final initStockResource = await initialStockDataProvider.getOne(
            nmId: stock.nmId,
            dateFrom: dateFrom,
            dateTo: dateTo,
            wh: stock.wh,
            sizeOptionId: stock.sizeOptionId);
        if (initStockResource is Error) {
          return Resource.error(initStockResource.message!);
        }
        // if init stock does not exist
        if (initStockResource is Empty) {
          // insert zero init stock
          final insertInitStockResource = await initialStockDataProvider.insert(
              InitialStockModel(
                  date: dateFrom,
                  nmId: stock.nmId,
                  wh: stock.wh,
                  sizeOptionId: stock.sizeOptionId,
                  qty: 0));
          if (insertInitStockResource is Error) {
            return Resource.error(insertInitStockResource.message!);
          }

          // if init stock does not exist and stocks more than threshold insert supply
          if (stock.qty > NumericConstants.supplyThreshold) {
            // insert supply
            final insertSupplyResource = await supplyDataProvider.insert(
                SupplyModel(
                    wh: stock.wh,
                    nmId: stock.nmId,
                    sizeOptionId: stock.sizeOptionId,
                    lastStocks: 0,
                    qty: stock.qty));
            if (insertSupplyResource is Error) {
              return Resource.error(insertSupplyResource.message!);
            }
          }
        } else {
          // if init stock exists
          final initStock = initStockResource.data!;
          // if stocks difference more than threshold insert supply
          if ((stock.qty - initStock.qty) > NumericConstants.supplyThreshold) {
            // check if supply already exists
            final supplyResource = await supplyDataProvider.getOne(
              nmId: stock.nmId,
              wh: stock.wh,
              sizeOptionId: stock.sizeOptionId,
            );
            if (supplyResource is Error) {
              return Resource.error(supplyResource.message!);
            }
            // init stock exists and supply does not exists
            // first time insert supply
            if (supplyResource is Empty) {
              // last saved stocks
              final savedStock = await stockDataProvider.getOne(
                nmId: stock.nmId,
                wh: stock.wh,
                sizeOptionId: stock.sizeOptionId,
              );
              if (savedStock is Error) {
                return Resource.error(savedStock.message!);
              }
              // insert supply with last saved stocks as lastStocks
              final insertSupplyResource =
                  await supplyDataProvider.insert(SupplyModel(
                wh: stock.wh,
                nmId: stock.nmId,
                sizeOptionId: stock.sizeOptionId,
                lastStocks: savedStock.data!.qty,
                qty: stock.qty - initStock.qty,
              ));
              if (insertSupplyResource is Error) {
                return Resource.error(insertSupplyResource.message!);
              }
            } else {
              // init stock exists and supply exists - update qty
              final supply = supplyResource.data!;
              final insertSupplyResource =
                  await supplyDataProvider.insert(SupplyModel(
                wh: supply.wh,
                nmId: supply.nmId,
                sizeOptionId: supply.sizeOptionId,
                lastStocks: supply.lastStocks,
                qty: stock.qty - initStock.qty,
              ));
              if (insertSupplyResource is Error) {
                return Resource.error(insertSupplyResource.message!);
              }
            }
          }
        }

        // save stock to local db
        final insertStockResource = await stockDataProvider.insert(stock);
        if (insertStockResource is Error) {
          return Resource.error(insertStockResource.message!);
        }
      }
    }
    return Resource.empty();
  }

  Future<Resource<List<InitialStockModel>>> _fetchTodayInitialStocksFromServer(
      List<int> cardsWithoutTodayInitStocksIds) async {
    List<InitialStockModel> initialStocksFromServer = [];
    if (cardsWithoutTodayInitStocksIds.isNotEmpty) {
      final initialStocksResource = await initialStockApiClient.get(
        cardsWithoutTodayInitStocksIds,
        yesterdayEndOfTheDay(),
        DateTime.now(),
      );
      if (initialStocksResource is Error) {
        return Resource.error(initialStocksResource.message!);
      }

      initialStocksFromServer = initialStocksResource.data!;

      // save initial stocks to local db
      for (final stock in initialStocksFromServer) {
        final insertStockresource =
            await initialStockDataProvider.insert(stock);
        if (insertStockresource is Error) {
          return Resource.error(insertStockresource.message!);
        }
      }
    }
    return Resource.success(initialStocksFromServer);
  }
}
