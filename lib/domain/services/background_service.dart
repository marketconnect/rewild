import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rewild/api_clients/advert_api_client.dart';
import 'package:rewild/api_clients/initial_stocks_api_client.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/data_providers/auto_stat_data_provider/auto_stat_data_provider.dart';
import 'package:rewild/data_providers/card_of_product_data_provider/card_of_product_data_provider.dart';
import 'package:rewild/data_providers/initial_stocks_data_provider/initial_stocks_data_provider.dart';
import 'package:rewild/data_providers/last_update_day_data_provider.dart';
import 'package:rewild/data_providers/notificate_data_provider/notificate_data_provider.dart';
import 'package:rewild/data_providers/pursued_data_provider/pursued_data_provider.dart';
import 'package:rewild/data_providers/secure_storage_data_provider.dart';
import 'package:rewild/data_providers/supply_data_provider/supply_data_provider.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/entities/notificate.dart';
import 'package:rewild/domain/entities/pursued.dart';

class BackgroundService {
  BackgroundService();

  static Future initial() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: _onDidReceiveLocalNotification);

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse);
  }

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static DateTime? autoLastReq;
  static DateTime? budgetLastReq;

  // updates initial stocks once a day
  static updateInitialStocks() async {
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
  }

  // update all every n minutes
  static fetchAll() async {
    final values = await Future.wait([
      PursuedDataProvider.getAllInBackground(),
      SecureStorageProvider.getApiKeyFromBackground('Продвижение'),
      NotificationDataProvider.getAllInBackground(),
    ]);

    // Advert Info
    final pursuedResource = values[0] as Resource<List<PursuedModel>>;
    final tokenResource = values[1] as Resource<ApiKeyModel>;
    final notificationResource = values[2] as Resource<List<NotificationModel>>;
    // update all pursued auto stat
    // final pursuedResource = await PursuedDataProvider.getAllInBackground();
    if (pursuedResource is Error) {
      return;
    }
    final pursuedList = pursuedResource.data!;
    // final tokenResource = await SecureStorageProvider.getApiKeyFromBackground('Продвижение');
    if (tokenResource is Error || tokenResource is Empty) {
      return;
    }
    final token = tokenResource.data!;

    if (notificationResource is Error) {
      return;
    }
    if (notificationResource is Empty) {
      return;
    }
    await _fetchAndSavePursued(pursuedList, token);

    final notificationList = notificationResource.data!;
    if (notificationList.isEmpty) {
      return;
    }

    // token for API request

    for (final notification in notificationList) {
      if (notification.property == "budget") {
        // request to API
        if (budgetLastReq != null) {
          await _ready(
              budgetLastReq, APIConstants.budgetDurationBetweenReqInMs);
        }

        final budgetResource =
            await AdvertApiClient.getCompanyBudgetInBackground(
                token.token, notification.parentId);
        budgetLastReq = DateTime.now();
        if (budgetResource is Error) {
          continue;
        }
        final budget = budgetResource.data!;
        if (budget < notification.minValue!) {
          await _instantNotification(
              "Бюджет меньше ", "${notification.minValue}");
        }
      }
    }
  }

  static Future<void> _fetchAndSavePursued(
      List<PursuedModel> pursuedList, ApiKeyModel token) async {
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

  // PRIVATE METHODS ===================================================================== PRIVATE METHODS
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

  static Future<void> _ready(DateTime? lastReq, Duration duration) async {
    if (lastReq == null) {
      return;
    }
    while (DateTime.now().difference(lastReq) < duration) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return;
  }

  static void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {}
  static void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {}

  static Future _instantNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('id', 'channel',
            channelDescription: 'description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: 'item x');
  }
}
