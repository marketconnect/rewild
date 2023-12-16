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
  Future<Either<RewildError, List<CardOfProductModel>>> get(
      {required List<int> ids});
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
  });
}

// Card of product data provider
abstract class UpdateServiceCardOfProductDataProvider {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll();
  Future<Either<RewildError, int>> insertOrUpdate(
      {required CardOfProductModel card});
  Future<Either<RewildError, CardOfProductModel>> get({required int nmId});
  Future<Either<RewildError, int>> delete({required int id});
}

// Card of product api client
abstract class UpdateServiceCardOfProductApiClient {
  Future<Either<RewildError, void>> save(
      {required String token, required List<CardOfProductModel> productCards});
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      {required String token});
  Future<Either<RewildError, void>> delete(
      {required String token, required int id});
}

// initial stock api client
abstract class UpdateServiceInitialStockApiClient {
  Future<Either<RewildError, List<InitialStockModel>>> get(
      {required List<int> skus,
      required DateTime dateFrom,
      required DateTime dateTo});
}

// init stock data provider
abstract class UpdateServiceInitStockDataProvider {
  Future<Either<RewildError, int>> insert(
      {required InitialStockModel initialStock});
  Future<Either<RewildError, List<InitialStockModel>>> get(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo});
  Future<Either<RewildError, InitialStockModel?>> getOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo,
      required int wh,
      required int sizeOptionId});
}

// stock data provider
abstract class UpdateServiceStockDataProvider {
  Future<Either<RewildError, int>> insert({required StocksModel stock});
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

    final cardsInDbEither = await cardOfProductDataProvider.getAll();
    if (cardsInDbEither.isLeft()) {
      return left(
          cardsInDbEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final cardsInDB = cardsInDbEither.getOrElse((l) => []);

    // Empty - try to fetch cards from server
    if (cardsInDB.isEmpty) {
      final cardsFromServerEither =
          await cardOfProductApiClient.getAll(token: token);
      if (cardsFromServerEither.isLeft()) {
        return left(cardsFromServerEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      final cards = cardsFromServerEither.getOrElse((l) => []);
      // there are cards on server - save
      if (cards.isNotEmpty) {
        final insertOrUpdateEither =
            await insert(token: token, cardOfProductsToInsert: cards);
        if (insertOrUpdateEither.isLeft()) {
          return left(insertOrUpdateEither.fold(
              (l) => l, (r) => throw UnimplementedError()));
        }
      }
    }
    return right(null);
  }

  // returns quantity of inserted cards ========================================================================
  @override
  Future<Either<RewildError, int>> insert(
      {required String token,
      required List<CardOfProductModel> cardOfProductsToInsert}) async {
    // get all cards from local db
    final cardsInDBEither = await cardOfProductDataProvider.getAll();

    if (cardsInDBEither.isLeft()) {
      return left(
          cardsInDBEither.fold((l) => l, (r) => throw UnimplementedError()));
    }

    final cardsInDB = cardsInDBEither.getOrElse((l) => []);
    final cardsInDBIds = cardsInDB.map((e) => e.nmId).toList();

    // if a card already exists skip that
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

    final saveOnServerEither =
        await cardOfProductApiClient.save(token: token, productCards: newCards);

    if (saveOnServerEither.isLeft()) {
      return left(
          saveOnServerEither.fold((l) => l, (r) => throw UnimplementedError()));
    }

    // try to fetch today`s initial stocks from server
    // in case when there are cards that was saved on server
    // earlier by somebody else
    List<InitialStockModel> initStocksFromServer = [];

    // ids of cards that initial stocks do not exist on server yet
    List<int> abscentOnServerNewCardsIds = newCards.map((e) => e.nmId).toList();

    // initial stocks from server
    final initialStocksEither = await initialStockApiClient.get(
      skus: newCards.map((e) => e.nmId).toList(),
      dateFrom: yesterdayEndOfTheDay(),
      dateTo: DateTime.now(),
    );

    initStocksFromServer = initialStocksEither.getOrElse((l) => []);

    // save fetched from server initial stocks to local db
    for (final stock in initStocksFromServer) {
      final insertStockEither =
          await initialStockDataProvider.insert(initialStock: stock);

      if (insertStockEither.isLeft()) {
        return left(insertStockEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      // remove nmId that initial stock exists on server and in local db
      abscentOnServerNewCardsIds.remove(stock.nmId);
    }

    // fetch details for all new cards from wb

    final fetchedCardsOfProductsEither =
        await detailsApiClient.get(ids: newCards.map((e) => e.nmId).toList());
    if (fetchedCardsOfProductsEither.isLeft()) {
      return left(fetchedCardsOfProductsEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }
    final fetchedCardsOfProducts =
        fetchedCardsOfProductsEither.getOrElse((l) => []);

    // add to db cards
    for (final card in fetchedCardsOfProducts) {
      // append img
      final img = newCards.firstWhere((e) => e.nmId == card.nmId).img;
      card.img = img;
      // insert

      final insertEither =
          await cardOfProductDataProvider.insertOrUpdate(card: card);
      if (insertEither.isLeft()) {
        return left(
            insertEither.fold((l) => l, (r) => throw UnimplementedError()));
      }

      // add stocks
      for (final size in card.sizes) {
        for (final stock in size.stocks) {
          final insertStockEither =
              await stockDataProvider.insert(stock: stock);
          if (insertStockEither.isLeft()) {
            return left(insertStockEither.fold(
                (l) => l, (r) => throw UnimplementedError()));
          }
          // if the miracle does not happen
          // and initial stocks do not exist on server yet
          if (abscentOnServerNewCardsIds.contains(stock.nmId)) {
            final insertInitialStockEither =
                await initialStockDataProvider.insert(
                    initialStock: InitialStockModel(
              nmId: stock.nmId,
              sizeOptionId: stock.sizeOptionId,
              date: DateTime.now(),
              wh: stock.wh,
              qty: stock.qty,
            ));
            if (insertInitialStockEither.isLeft()) {
              return left(insertInitialStockEither.fold(
                  (l) => l, (r) => throw UnimplementedError()));
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

    final cardsOfProductsEither = await cardOfProductDataProvider.getAll();
    if (cardsOfProductsEither.isLeft()) {
      return left(cardsOfProductsEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }
    final allSavedCardsOfProducts = cardsOfProductsEither.getOrElse((l) => []);

    if (allSavedCardsOfProducts.isEmpty) {
      return right(null);
    }

    // if it is Today`s first time update - update initial stocks
    // were today updated?

    final isUpdatedEither = await lastUpdateDayDataProvider.todayUpdated();
    if (isUpdatedEither.isLeft()) {
      return left(
          isUpdatedEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final isUpdated = isUpdatedEither.getOrElse((l) => false);

    // were not updated - update
    // Update initial stocks!
    if (!isUpdated) {
      // delete old adverts statistics
      final deleteEither =
          await advertStatDataProvider.deleteOldRecordsOlderThanMonth();
      if (deleteEither.isLeft()) {
        return left(
            deleteEither.fold((l) => l, (r) => throw UnimplementedError()));
      }
      // try to fetch today`s initial stocks from server
      final todayInitialStocksFromServerEither =
          await _fetchTodayInitialStocksFromServer(
              allSavedCardsOfProducts.map((e) => e.nmId).toList());
      if (todayInitialStocksFromServerEither.isLeft()) {
        return left(todayInitialStocksFromServerEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      final todayInitialStocksFromServer =
          todayInitialStocksFromServerEither.getOrElse((l) => []);

      // save today`s initial stocks to local db and delete supplies
      for (final stock in todayInitialStocksFromServer) {
        // saved in _fetchTodayInitialStocksFromServer
        final deleteSuppliesEither =
            await supplyDataProvider.delete(nmId: stock.nmId);
        if (deleteSuppliesEither.isLeft()) {
          return left(deleteSuppliesEither.fold(
              (l) => l, (r) => throw UnimplementedError()));
        }
      }

      // set were updated today
      await lastUpdateDayDataProvider.update();
    }

    // fetch details for all saved cards from wb
    final fetchedCardsOfProductsEither = await detailsApiClient.get(
        ids: allSavedCardsOfProducts.map((e) => e.nmId).toList());
    if (fetchedCardsOfProductsEither.isLeft()) {
      return left(fetchedCardsOfProductsEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }
    final fetchedCardsOfProducts =
        fetchedCardsOfProductsEither.getOrElse((l) => []);

    // ADD OTHER INFORMATION FOR EVERY FETCHED CARD

    for (final card in fetchedCardsOfProducts) {
      // add the card to db
      final insertEither =
          await cardOfProductDataProvider.insertOrUpdate(card: card);
      if (insertEither.isLeft()) {
        return left(
            insertEither.fold((l) => l, (r) => throw UnimplementedError()));
      }

      // add stocks
      final addStocksEither = await _addStocks(card.sizes);
      if (addStocksEither.isLeft()) {
        return left(
            addStocksEither.fold((l) => l, (r) => throw UnimplementedError()));
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
        // final initStockResource = await initialStockDataProvider.getOne(
        //     nmId: stock.nmId,
        //     dateFrom: dateFrom,
        //     dateTo: dateTo,
        //     wh: stock.wh,
        //     sizeOptionId: stock.sizeOptionId);
        // if (initStockResource is Error) {
        //   return left(RewildError(initStockResource.message!,
        //       source: runtimeType.toString(), name: 'update', args: []);
        // }
        final initStockEither = await initialStockDataProvider.getOne(
            nmId: stock.nmId,
            dateFrom: dateFrom,
            dateTo: dateTo,
            wh: stock.wh,
            sizeOptionId: stock.sizeOptionId);
        if (initStockEither.isLeft()) {
          return left(initStockEither.fold(
              (l) => l, (r) => throw UnimplementedError()));
        }
        final initStock = initStockEither.getOrElse((l) => null);
        // if init stock does not exist
        if (initStock == null) {
          // insert zero init stock
          // final insertInitStockResource = await initialStockDataProvider.insert(
          //    initialStock:  InitialStockModel(
          //         date: dateFrom,
          //         nmId: stock.nmId,
          //         wh: stock.wh,
          //         sizeOptionId: stock.sizeOptionId,
          //         qty: 0));
          // if (insertInitStockResource is Error) {
          //   return left(RewildError(insertInitStockResource.message!,
          //       source: runtimeType.toString(), name: 'update', args: []);
          // }
          final insertInitStockEither = await initialStockDataProvider.insert(
              initialStock: InitialStockModel(
                  date: dateFrom,
                  nmId: stock.nmId,
                  wh: stock.wh,
                  sizeOptionId: stock.sizeOptionId,
                  qty: 0));
          if (insertInitStockEither.isLeft()) {
            return left(insertInitStockEither.fold(
                (l) => l, (r) => throw UnimplementedError()));
          }

          // if init stock does not exist and stocks more than threshold insert supply
          if (stock.qty > NumericConstants.supplyThreshold) {
            // insert supply
            // final insertSupplyResource = await supplyDataProvider.insert(
            //    supply:  SupplyModel(
            //         wh: stock.wh,
            //         nmId: stock.nmId,
            //         sizeOptionId: stock.sizeOptionId,
            //         lastStocks: 0,
            //         qty: stock.qty));
            // if (insertSupplyResource is Error) {
            //   return left(RewildError(insertSupplyResource.message!,
            //       source: runtimeType.toString(), name: 'update', args: []);
            // }
            final insertSupplyEither = await supplyDataProvider.insert(
                supply: SupplyModel(
                    wh: stock.wh,
                    nmId: stock.nmId,
                    sizeOptionId: stock.sizeOptionId,
                    lastStocks: 0,
                    qty: stock.qty));
            if (insertSupplyEither.isLeft()) {
              return left(insertSupplyEither.fold(
                  (l) => l, (r) => throw UnimplementedError()));
            }
          }
        } else {
          // if init stock exists

          // if stocks difference more than threshold insert supply
          if ((stock.qty - initStock.qty) > NumericConstants.supplyThreshold) {
            // check if supply already exists
            // final supplyResource = await supplyDataProvider.getOne(
            //   nmId: stock.nmId,
            //   wh: stock.wh,
            //   sizeOptionId: stock.sizeOptionId,
            // );
            // if (supplyResource is Error) {
            //   return left(RewildError(supplyResource.message!,
            //       source: runtimeType.toString(), name: 'update', args: []);
            // }
            final supplyEither = await supplyDataProvider.getOne(
              nmId: stock.nmId,
              wh: stock.wh,
              sizeOptionId: stock.sizeOptionId,
            );
            if (supplyEither.isLeft()) {
              return left(supplyEither.fold(
                  (l) => l, (r) => throw UnimplementedError()));
            }
            // init stock exists and supply does not exists
            // first time insert supply
            final supply = supplyEither.getOrElse((l) => null);
            if (supply == null) {
              // last saved stocks
              // final savedStock = await stockDataProvider.getOne(
              //   nmId: stock.nmId,
              //   wh: stock.wh,
              //   sizeOptionId: stock.sizeOptionId,
              // );
              // if (savedStock is Error) {
              //   return left(RewildError(savedStock.message!,
              //       source: runtimeType.toString(), name: 'update', args: []);
              // }
              final savedStockEither = await stockDataProvider.getOne(
                nmId: stock.nmId,
                wh: stock.wh,
                sizeOptionId: stock.sizeOptionId,
              );
              if (savedStockEither.isLeft()) {
                return left(savedStockEither.fold(
                    (l) => l, (r) => throw UnimplementedError()));
              }
              final savedStockData =
                  savedStockEither.getOrElse((l) => throw UnimplementedError());

              // insert supply with last saved stocks as lastStocks
              // final insertSupplyResource =
              //     await supplyDataProvider.insert(supply: SupplyModel(
              //   wh: stock.wh,
              //   nmId: stock.nmId,
              //   sizeOptionId: stock.sizeOptionId,
              //   lastStocks: savedStockData.qty,
              //   qty: stock.qty - initStock.qty,
              // ));
              // if (insertSupplyResource is Error) {
              //   return left(RewildError(insertSupplyResource.message!,
              //       source: runtimeType.toString(), name: 'update', args: []);
              // }
              final insertSupplyEither = await supplyDataProvider.insert(
                  supply: SupplyModel(
                wh: stock.wh,
                nmId: stock.nmId,
                sizeOptionId: stock.sizeOptionId,
                lastStocks: savedStockData.qty,
                qty: stock.qty - initStock.qty,
              ));
              if (insertSupplyEither.isLeft()) {
                return left(insertSupplyEither.fold(
                    (l) => l, (r) => throw UnimplementedError()));
              }
            } else {
              // init stock exists and supply exists - update qty
              //   final insertSupplyResource =
              //       await supplyDataProvider.insert(supply: SupplyModel(
              //     wh: supply.wh,
              //     nmId: supply.nmId,
              //     sizeOptionId: supply.sizeOptionId,
              //     lastStocks: supply.lastStocks,
              //     qty: stock.qty - initStock.qty,
              //   ));
              //   if (insertSupplyResource is Error) {
              //     return left(RewildError(insertSupplyResource.message!,
              //         source: runtimeType.toString(), name: 'update', args: []);
              //   }
              // }
              final insertSupplyEither = await supplyDataProvider.insert(
                  supply: SupplyModel(
                wh: supply.wh,
                nmId: supply.nmId,
                sizeOptionId: supply.sizeOptionId,
                lastStocks: supply.lastStocks,
                qty: stock.qty - initStock.qty,
              ));
              if (insertSupplyEither.isLeft()) {
                return left(insertSupplyEither.fold(
                    (l) => l, (r) => throw UnimplementedError()));
              }
            }
          }

          // save stock to local db
          // final insertStockResource = await stockDataProvider.insert(stock);
          // if (insertStockResource is Error) {
          //   return left(RewildError(insertStockResource.message!,
          //       source: runtimeType.toString(), name: 'update', args: []);
          // }
          final insertStockEither =
              await stockDataProvider.insert(stock: stock);
          if (insertStockEither.isLeft()) {
            return left(insertStockEither.fold(
                (l) => l, (r) => throw UnimplementedError()));
          }
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
      // initialStocksFromServer = initialStocksResource.data!;
      final initialStocksEither = await initialStockApiClient.get(
        skus: cardsWithoutTodayInitStocksIds,
        dateFrom: yesterdayEndOfTheDay(),
        dateTo: DateTime.now(),
      );
      if (initialStocksEither.isLeft()) {
        return left(initialStocksEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      initialStocksFromServer =
          initialStocksEither.getOrElse((l) => throw UnimplementedError());

      // save initial stocks to local db
      for (final stock in initialStocksFromServer) {
        final insertStockEither =
            await initialStockDataProvider.insert(initialStock: stock);
        if (insertStockEither.isLeft()) {
          return left(insertStockEither.fold(
              (l) => l, (r) => throw UnimplementedError()));
        }
      }
    }
    return right(initialStocksFromServer);
  }

  @override
  Future<Either<RewildError, int>> delete(
      {required String token, required List<int> nmIds}) async {
    for (final id in nmIds) {
      // delete card from the server
      // final deleteFromServerResource =
      //     await cardOfProductApiClient.delete(token: token,id:  id);

      // if (deleteFromServerResource is Error) {
      //   return left(RewildError(deleteFromServerResource.message!,
      //       source: runtimeType.toString(), name: 'delete', args: [token, id]);
      // }

      final deleteFromServerEither =
          await cardOfProductApiClient.delete(token: token, id: id);
      if (deleteFromServerEither.isLeft()) {
        return left(deleteFromServerEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      // delete card from the local storage
      // final deleteResource = await cardOfProductDataProvider.delete(id: id);
      // if (deleteResource is Error) {
      //   return left(RewildError(deleteResource.message!,
      //       source: runtimeType.toString(), name: 'delete', args: [token, id]);
      // }
      final deleteEither = await cardOfProductDataProvider.delete(id: id);
      if (deleteEither.isLeft()) {
        return left(
            deleteEither.fold((l) => l, (r) => throw UnimplementedError()));
      }
    }
    // get all cards from local db
    // final cardsInDBResource = await cardOfProductDataProvider.getAll();

    // if (cardsInDBResource is Error) {
    //   return left(RewildError(cardsInDBResource.message!,
    //       source: runtimeType.toString(), name: 'delete', args: [token, ids]);
    // }
    // final cardsInDB = cardsInDBResource.data!;
    final cardsInDBEither = await cardOfProductDataProvider.getAll();
    if (cardsInDBEither.isLeft()) {
      return left(
          cardsInDBEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final cardsInDB =
        cardsInDBEither.getOrElse((l) => throw UnimplementedError());
    cardsNumberStreamController.add(cardsInDB.length);
    return right(nmIds.length);
  }
}
