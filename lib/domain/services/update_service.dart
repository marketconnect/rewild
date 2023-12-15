import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';

import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/entities/size_model.dart';
import 'package:rewild/domain/entities/stocks_model.dart';
import 'package:rewild/domain/entities/supply_model.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/all_groups_screen/all_groups_view_model.dart';
import 'package:rewild/presentation/my_web_view/my_web_view_screen_view_model.dart';
import 'package:rewild/presentation/splash_screen/splash_screen_view_model.dart';

// Details
abstract class UpdateServiceDetailsApiClient {
  Future<Either<RewildError, List<CardOfProductModel>>> get({required List<int> ids});
}

// Supply
abstract class UpdateServiceSupplyDataProvider {
  Future<Either<RewildError, int>> insert({required SupplyModel supply});
  Future<Either<RewildError, void>> delete({
    required int nmId,
    int? wh,
    int? sizeOptionId,
  });
  Future<Either<RewildError, SupplyModel?>> getOne({
    required int nmId,
    required int wh,
    required int sizeOptionId,
  }) ;
}

// Card of product data provider
abstract class UpdateServiceCardOfProductDataProvider {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll();
  Future<Either<RewildError, int>> insertOrUpdate({required CardOfProductModel card});
  Future<Either<RewildError, CardOfProductModel>> get({required int id});
  Future<Either<RewildError, int>> delete({required int id});
}

// Card of product api client
abstract class UpdateServiceCardOfProductApiClient {
  Future<Either<RewildError, void>> save(
      {required String token,required List<CardOfProductModel> productCards});
  Future<Either<RewildError, List<CardOfProductModel>>> getAll({required String token});
  Future<Either<RewildError, void>> delete({required String token,required int id});
}

// initial stock api client
abstract class UpdateServiceInitialStockApiClient {
  Future<Either<RewildError, List<InitialStockModel>>> get(
      {required List<int> skus,required DateTime dateFrom,required DateTime dateTo});
}

// init stock data provider
abstract class UpdateServiceInitStockDataProvider {
  Future<Either<RewildError, int>> insert({required InitialStockModel initialStock});
  Future<Either<RewildError, List<InitialStockModel>>> get(
      {required int nmId,required DateTime dateFrom,required DateTime dateTo});
  Future<Either<RewildError, InitialStockModel?>> getOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo,
      required int wh,
      required int sizeOptionId});
}

// stock data provider
abstract class UpdateServiceStockDataProvider {
  Future<Either<RewildError, int>> insert({required StocksModel stock}) ;
  Future<Either<RewildError, List<StocksModel>>> get({required int nmId});
  Future<Either<RewildError, StocksModel>> getOne(
      {required int nmId, required int wh, required int sizeOptionId});
}

// advert stat data provider
abstract class UpdateServiceAdvertStatDataProvider {
  Future<Either<RewildError, void>> deleteOldRecordsOlderThanMonth();
}

// last update day data provider
abstract class UpdateServiceLastUpdateDayDataProvider {
  Future<Either<RewildError, void>> update();
  Future<Either<RewildError, bool>> todayUpdated();
}

class UpdateService
    implements
        MyWebViewScreenViewModelUpdateService,
        AllCardsScreenUpdateService,
        AllGroupsScreenUpdateService,
        SplashScreenViewModelUpdateService {
  final UpdateServiceDetailsApiClient detailsApiClient;
  final UpdateServiceSupplyDataProvider supplyDataProvider;
  final UpdateServiceCardOfProductDataProvider cardOfProductDataProvider;
  final UpdateServiceCardOfProductApiClient cardOfProductApiClient;
  final UpdateServiceInitialStockApiClient initialStockApiClient;
  final UpdateServiceInitStockDataProvider initialStockDataProvider;
  final UpdateServiceStockDataProvider stockDataProvider;
  final UpdateServiceLastUpdateDayDataProvider lastUpdateDayDataProvider;
  final UpdateServiceAdvertStatDataProvider advertStatDataProvider;
  final StreamController<int> cardsNumberStreamController;
  UpdateService(
      {required this.stockDataProvider,
      required this.detailsApiClient,
      required this.cardsNumberStreamController,
      required this.initialStockDataProvider,
      required this.advertStatDataProvider,
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
  Future<Either<RewildError, void>> fetchAllUserCardsFromServer(
      String token) async {
    // check db is empty when app starts
    final cardsInDBResource = await cardOfProductDataProvider.getAll();

    if (cardsInDBResource is Error) {
      return left(RewildError(cardsInDBResource.message!,
          source: runtimeType.toString(),
          name: 'fetchAllUserCardsFromServer',
          args: [token]);
    }
    final cardsInDB = cardsInDBResource.data!;

    // Empty - try to fetch cards from server
    if (cardsInDB.isEmpty) {
      final cardsFromServer = await cardOfProductApiClient.getAll(token);
      if (cardsFromServer is Error) {
        return left(RewildError(cardsFromServer.message!,
            source: runtimeType.toString(),
            name: 'fetchAllUserCardsFromServer',
            args: [token]);
      }
      if (cardsFromServer is Success) {
        final cards = cardsFromServer.data!;
        // there are cards on server - save
        if (cards.isNotEmpty) {
          final insertOrUpdateResource = await insert(token, cards);
          if (insertOrUpdateResource is Error) {
            return left(RewildError(insertOrUpdateResource.message!,
                source: runtimeType.toString(),
                name: 'fetchAllUserCardsFromServer',
                args: [token]);
          }
        }
      }
    }
    return right(null);
  }

  // returns quantity of inserted cards ========================================================================
  @override
  Future<Either<RewildError, int>> insert(
      String token, List<CardOfProductModel> cardOfProductsToInsert) async {
    // get all cards from local db
    final cardsInDBResource = await cardOfProductDataProvider.getAll();

    if (cardsInDBResource is Error) {
      return left(RewildError(cardsInDBResource.message!,
          source: runtimeType.toString(),
          name: 'insert',
          args: [token, cardOfProductsToInsert]);
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
      return right(0);
    }

    // save on server cards that do not exist in DB
    final saveOnServerResource =
        await cardOfProductApiClient.save(token, newCards);
    if (saveOnServerResource is Error) {
      return left(RewildError(saveOnServerResource.message!,
          source: runtimeType.toString(),
          name: 'insert',
          args: [token, cardOfProductsToInsert]);
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
      return left(RewildError(initialStocksResource.message!,
          source: runtimeType.toString(),
          name: 'insert',
          args: [token, cardOfProductsToInsert]);
    }

    initStocksFromServer = initialStocksResource.data!;

    // save fetched from server initial stocks to local db
    for (final stock in initStocksFromServer) {
      final insertStockresource = await initialStockDataProvider.insert(stock);
      if (insertStockresource is Error) {
        return left(RewildError(insertStockresource.message!,
            source: runtimeType.toString(),
            name: 'insert',
            args: [token, cardOfProductsToInsert]);
      }

      // remove nmId that initial stock exists on server and in local db
      abscentOnServerNewCardsIds.remove(stock.nmId);
    }

    // fetch details for all new cards from wb
    final fetchedCardsOfProductsResource =
        await detailsApiClient.get(newCards.map((e) => e.nmId).toList());
    if (fetchedCardsOfProductsResource is Error) {
      return left(RewildError(fetchedCardsOfProductsResource.message!,
          source: runtimeType.toString(),
          name: 'insert',
          args: [token, cardOfProductsToInsert]);
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
        return left(RewildError(insertResource.message!,
            source: runtimeType.toString(),
            name: 'insert',
            args: [token, cardOfProductsToInsert]);
      }

      // add stocks
      for (final size in card.sizes) {
        for (final stock in size.stocks) {
          final insertStockresource = await stockDataProvider.insert(stock);
          if (insertStockresource is Error) {
            return left(RewildError(insertStockresource.message!,
                source: runtimeType.toString(),
                name: 'insert',
                args: [token, cardOfProductsToInsert]);
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
              return left(RewildError(insertStockresource.message!,
                  source: runtimeType.toString(),
                  name: 'insert',
                  args: [token, cardOfProductsToInsert]);
            }
          }
        }
      }
    }
    cardsNumberStreamController.add(newCards.length + cardsInDB.length);
    return right(newCards.length);
  }

  // update cards ==============================================================
  @override
  Future<Either<RewildError, void>> update() async {
    print("UPDATE");
    if (!timeToUpdated()) {
      return right(null);
    }
    // get cards from the local storage
    final cardsOfProductsResource = await cardOfProductDataProvider.getAll();
    if (cardsOfProductsResource is Error) {
      return left(RewildError(cardsOfProductsResource.message!,
          source: runtimeType.toString(), name: 'update', args: []);
    }
    final allSavedCardsOfProducts = cardsOfProductsResource.data!;

    if (allSavedCardsOfProducts.isEmpty) {
      return right(null);
    }

    // if it is Today`s first time update - update initial stocks
    // were today updated?
    final isUpdatedResource = await lastUpdateDayDataProvider.todayUpdated();
    if (isUpdatedResource is Error) {
      return left(RewildError(isUpdatedResource.message!,
          source: runtimeType.toString(), name: 'update', args: []);
    }
    final isUpdated = isUpdatedResource.data!;

    // were not updated - update
    // Update initial stocks!
    if (!isUpdated) {
      // delet old adverts statistics
      final deleteResource =
          await advertStatDataProvider.deleteOldRecordsOlderThanMonth();
      if (deleteResource is Error) {
        return left(RewildError(deleteResource.message!,
            source: runtimeType.toString(), name: 'update', args: []);
      }
      // try to fetch today`s initial stocks from server
      final todayInitialStocksFromServerResource =
          await _fetchTodayInitialStocksFromServer(
              allSavedCardsOfProducts.map((e) => e.nmId).toList());
      if (todayInitialStocksFromServerResource is Error) {
        return left(RewildError(todayInitialStocksFromServerResource.message!,
            source: runtimeType.toString(), name: 'update', args: []);
      }
      final todayInitialStocksFromServer =
          todayInitialStocksFromServerResource.data!;

      // save today`s initial stocks to local db and delete supplies
      for (final stock in todayInitialStocksFromServer) {
        // saved in _fetchTodayInitialStocksFromServer
        // final insertStockresource =
        //     await initialStockDataProvider.insert(stock);
        // if (insertStockresource is Error) {
        //   return left(RewildError(insertStockresource.message!);
        // }

        // delete supplies because they are not today`s
        final deleteSuppliesResource =
            await supplyDataProvider.delete(nmId: stock.nmId);
        if (deleteSuppliesResource is Error) {
          return left(RewildError(deleteSuppliesResource.message!,
              source: runtimeType.toString(), name: 'update', args: []);
        }
      }

      // set were updated today
      await lastUpdateDayDataProvider.update();
    }

    // fetch details for all saved cards from wb
    final fetchedCardsOfProductsResource = await detailsApiClient
        .get(allSavedCardsOfProducts.map((e) => e.nmId).toList());
    if (fetchedCardsOfProductsResource is Error) {
      return left(RewildError(fetchedCardsOfProductsResource.message!,
          source: runtimeType.toString(), name: 'update', args: []);
    }
    final fetchedCardsOfProducts = fetchedCardsOfProductsResource.data!;

    // ADD OTHER INFORMATION FOR EVERY FETCHED CARD

    for (final card in fetchedCardsOfProducts) {
      // add the card to db
      final insertResource =
          await cardOfProductDataProvider.insertOrUpdate(card);
      if (insertResource is Error) {
        return left(RewildError(insertResource.message!,
            source: runtimeType.toString(), name: 'update', args: []);
      }

      // add stocks
      final addStocksResource = await _addStocks(card.sizes);
      if (addStocksResource is Error) {
        return left(RewildError(addStocksResource.message!,
            source: runtimeType.toString(), name: 'update', args: []);
      }
    }
    setUpdatedAt();
    return right(null);
  }

  Future<Either<RewildError, void>> _addStocks(List<SizeModel> sizes) async {
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
          return left(RewildError(initStockResource.message!,
              source: runtimeType.toString(), name: 'update', args: []);
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
            return left(RewildError(insertInitStockResource.message!,
                source: runtimeType.toString(), name: 'update', args: []);
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
              return left(RewildError(insertSupplyResource.message!,
                  source: runtimeType.toString(), name: 'update', args: []);
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
              return left(RewildError(supplyResource.message!,
                  source: runtimeType.toString(), name: 'update', args: []);
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
                return left(RewildError(savedStock.message!,
                    source: runtimeType.toString(), name: 'update', args: []);
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
                return left(RewildError(insertSupplyResource.message!,
                    source: runtimeType.toString(), name: 'update', args: []);
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
                return left(RewildError(insertSupplyResource.message!,
                    source: runtimeType.toString(), name: 'update', args: []);
              }
            }
          }
        }

        // save stock to local db
        final insertStockResource = await stockDataProvider.insert(stock);
        if (insertStockResource is Error) {
          return left(RewildError(insertStockResource.message!,
              source: runtimeType.toString(), name: 'update', args: []);
        }
      }
    }
    return right(null);
  }

  Future<Either<RewildError, List<InitialStockModel>>>
      _fetchTodayInitialStocksFromServer(
          List<int> cardsWithoutTodayInitStocksIds) async {
    List<InitialStockModel> initialStocksFromServer = [];
    if (cardsWithoutTodayInitStocksIds.isNotEmpty) {
      final initialStocksResource = await initialStockApiClient.get(
        cardsWithoutTodayInitStocksIds,
        yesterdayEndOfTheDay(),
        DateTime.now(),
      );
      if (initialStocksResource is Error) {
        return left(RewildError(initialStocksResource.message!,
            source: runtimeType.toString(), name: 'update', args: []);
      }

      initialStocksFromServer = initialStocksResource.data!;

      // save initial stocks to local db
      for (final stock in initialStocksFromServer) {
        final insertStockresource =
            await initialStockDataProvider.insert(stock);
        if (insertStockresource is Error) {
          return left(RewildError(insertStockresource.message!,
              source: runtimeType.toString(), name: 'update', args: []);
        }
      }
    }
    return right(initialStocksFromServer);
  }

  @override
  Future<Either<RewildError, int>> delete(String token, List<int> ids) async {
    for (final id in ids) {
      // delete card from the server
      final deleteFromServerResource =
          await cardOfProductApiClient.delete(token, id);

      if (deleteFromServerResource is Error) {
        return left(RewildError(deleteFromServerResource.message!,
            source: runtimeType.toString(), name: 'delete', args: [token, id]);
      }

      // delete card from the local storage
      final deleteResource = await cardOfProductDataProvider.delete(id);
      if (deleteResource is Error) {
        return left(RewildError(deleteResource.message!,
            source: runtimeType.toString(), name: 'delete', args: [token, id]);
      }
    }
    // get all cards from local db
    final cardsInDBResource = await cardOfProductDataProvider.getAll();

    if (cardsInDBResource is Error) {
      return left(RewildError(cardsInDBResource.message!,
          source: runtimeType.toString(), name: 'delete', args: [token, ids]);
    }
    final cardsInDB = cardsInDBResource.data!;
    cardsNumberStreamController.add(cardsInDB.length);
    return right(ids.length);
  }
}
