import 'package:rewild/api_clients/advert_api_client.dart';
import 'package:rewild/api_clients/initial_stocks_api_client.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/data_providers/auto_stat_data_provider/auto_stat_data_provider.dart';
import 'package:rewild/data_providers/card_of_product_data_provider/card_of_product_data_provider.dart';
import 'package:rewild/data_providers/initial_stocks_data_provider/initial_stocks_data_provider.dart';
import 'package:rewild/data_providers/last_update_day_data_provider.dart';
import 'package:rewild/data_providers/pursued_data_provider/pursued_data_provider.dart';
import 'package:rewild/data_providers/secure_storage_data_provider.dart';
import 'package:rewild/data_providers/supply_data_provider/supply_data_provider.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';

class BackgroundService {
  BackgroundService();

  static DateTime? autoLastReq;

  static updateInitialStocks() async {
    print(
        "1111111111111 UPDATAEDED INITIAL !STOCKS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    // get cards from the local storage
    final cardsOfProductsResource =
        await CardOfProductDataProvider.getAllInBackGround();
    if (cardsOfProductsResource is Error) {
      return Resource.error(cardsOfProductsResource.message!);
    }
    final allSavedCardsOfProducts = cardsOfProductsResource.data!;

    if (allSavedCardsOfProducts.isEmpty) {
      return Resource.empty();
    }

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
      // delete supplies because they are not today`s
      final deleteSuppliesResource =
          await SupplyDataProvider.deleteInBackground(nmId: stock.nmId);
      if (deleteSuppliesResource is Error) {
        return Resource.error(deleteSuppliesResource.message!);
      }

      // set were updated today
      await LastUpdateDayDataProvider.updateInBackground();
    }
    print(
        "UPDATAEDED INITIAL !STOCKS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    print(
        "UPDATAEDED INITIAL !STOCKS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    print(
        "UPDATAEDED INITIAL !STOCKS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  }

  static Future<Resource<List<InitialStockModel>>>
      _fetchTodayInitialStocksFromServer(
          List<int> cardsWithoutTodayInitStocksIds) async {
    List<InitialStockModel> initialStocksFromServer = [];
    if (cardsWithoutTodayInitStocksIds.isNotEmpty) {
      final initialStocksResource =
          await InitialStocksApiClient.getInBackground(
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
            await InitialStockDataProvider.insertInBackground(stock);
        if (insertStockresource is Error) {
          return Resource.error(insertStockresource.message!);
        }
      }
    }
    return Resource.success(initialStocksFromServer);
  }

  static fetchAll() async {
    final pursuedResource = await PursuedDataProvider.getAllInBackground();
    if (pursuedResource is Error) {
      return;
    }
    final pursuedList = pursuedResource.data!;
    final tokenResource =
        await SecureStorageProvider.getApiKeyFromBackground('Продвижение');
    if (tokenResource is Error || tokenResource is Empty) {
      return;
    }
    final token = tokenResource.data!;

    for (final pursued in pursuedList) {
      if (pursued.property == "auto") {
        // request to API
        if (autoLastReq != null) {
          await _ready(
              autoLastReq, APIConstants.autoStatNumsDurationBetweenReqInMs);
        }

        final advertResource = await AdvertApiClient.getAutoStatInBackground(
            token.token, pursued.parentId);
        autoLastReq = DateTime.now();
        if (advertResource is Error) {
          continue;
        }
        final advert = advertResource.data!;
        final saveResource =
            await AutoStatDataProvider.saveInBackground(advert);

        if (saveResource is Error) {
          continue;
        }
      }
    }
  }

  static Future<void> _ready(DateTime? lastReq, Duration duration) async {
    if (lastReq == null) {
      return;
    }
    while (DateTime.now().difference(lastReq) < duration) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return;
  }
}
