import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rewild/api_clients/advert_api_client.dart';
import 'package:rewild/api_clients/details_api_client.dart';
import 'package:rewild/api_clients/initial_stocks_api_client.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/data_providers/advert_stat_data_provider/advert_stat_data_provider.dart';

import 'package:rewild/data_providers/card_of_product_data_provider/card_of_product_data_provider.dart';
import 'package:rewild/data_providers/initial_stocks_data_provider/initial_stocks_data_provider.dart';
import 'package:rewild/data_providers/last_update_day_data_provider.dart';
import 'package:rewild/data_providers/notificate_data_provider/notificate_data_provider.dart';

import 'package:rewild/data_providers/secure_storage_data_provider.dart';
import 'package:rewild/data_providers/supply_data_provider/supply_data_provider.dart';

import 'package:rewild/domain/entities/advert_model.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';

import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/entities/notification.dart';
import 'package:rewild/domain/services/notification_content.dart';

class BackgroundService {
  const BackgroundService();

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

  static DateTime? _autoLastReq;
  static DateTime? _searchLastReq;
  static DateTime? _budgetLastReq;
  static DateTime? _advertsLastReq;

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
    print(
        "FETCH_ALL =========================================================================  ");
    // since the token does not uses for card of products details request
    // make it nullable
    String? token;

    // get token and all notifications
    final values = await Future.wait([
      SecureStorageProvider.getApiKeyFromBackground('Продвижение'),
      NotificationDataProvider.getAllInBackground(),
    ]);

    final tokenResource = values[0] as Resource<ApiKeyModel>;
    final notificationResource = values[1] as Resource<List<NotificationModel>>;

    // token
    if (tokenResource is Success) {
      token = tokenResource.data!.token;
    }

    // fetch adverts
    final advertResource = await fetchAdverts(token);
    if (advertResource is Error) {
      return Resource.error(advertResource.message!);
    }
    // save all
    if (advertResource is Success) {
      for (final advert in advertResource.data!) {
        await AdvertStatDataProvider.saveInBackground(advert);
      }
    }

    if (notificationResource is Error) {
      return Resource.error(notificationResource.message!);
    }
    if (notificationResource is Empty) {
      return;
    }

    final notifications = notificationResource.data!;

    List<NotificationModel> cardsNotifications = notifications
        .where((element) =>
            element.condition != NotificationConditionConstants.budgetLessThan)
        .toList();
    List<NotificationModel> advertsNotifications = notifications
        .where((element) =>
            element.condition == NotificationConditionConstants.budgetLessThan)
        .toList();
    // ids
    List<int> cardsIds = cardsNotifications.map((e) => e.parentId).toList();
    List<int> advertsIds = cardsNotifications.map((e) => e.parentId).toList();

    List<NotificationContent> notificationContents = [];

    // fetch cards
    final cardsResource = await DetailsApiClient.getInBackground(cardsIds);
    if (cardsResource is Error) {
      return Resource.error(cardsResource.message!);
    }
    if (cardsResource is Success) {
      for (final card in cardsResource.data!) {
        final notificationsList = cardsNotifications
            .where((element) => element.parentId == card.nmId)
            .toList();
        final notContentList = card.notifications(notificationsList);
        notificationContents.addAll(notContentList);
      }
    }

    if (token != null) {
      for (final advertId in advertsIds) {
        // fetch budget
        final budgetResource = await budgetRequest(token, advertId);
        if (budgetResource is Error) {
          return Resource.error(budgetResource.message!);
        }
        if (budgetResource is Empty) {
          continue;
        }
        final budget = budgetResource.data!;
        final notificationsList = advertsNotifications
            .where((element) => element.parentId == advertId)
            .toList();
        if (notificationsList.isEmpty) {
          continue;
        }
        final nBudg = int.tryParse(notificationsList.first.value) ?? 0;
        if (budget < nBudg) {
          final title = "Бюджет кампании $advertId";
          final body = "Бюджет: $budget, был $nBudg";
          final notContent = NotificationContent(title: title, body: body);
          notificationContents.add(notContent);
        }
      }
    }

    for (final notCont in notificationContents) {
      await _instantNotification(notCont.title, notCont.body);
    }
  }

  static Future<Resource<List<AdvertStatModel>>> fetchAdverts(
      String? token) async {
    if (token == null) {
      return Resource.empty();
    }
    List<AdvertStatModel> fetchedAdverts = [];
    // getr all adverts
    if (_advertsLastReq != null) {
      await _ready(_advertsLastReq, APIConstants.budgetDurationBetweenReqInMs);
    }

    final advertResource = await AdvertApiClient.getAdvertsInBackground(token);

    _advertsLastReq = DateTime.now();
    if (advertResource is Error) {
      return Resource.error(advertResource.message!);
    }
    final allAdverts = advertResource.data!;

    for (final advertInfo in allAdverts) {
      if (advertInfo.status != AdvertStatusConstants.active &&
          advertInfo.status != AdvertStatusConstants.paused) {
        continue;
      }
      switch (advertInfo.type) {
        case AdvertTypeConstants.auto:
          final advertStat = await _fetchAutoAdvertStat(token, advertInfo);
          if (advertStat is Success) {
            fetchedAdverts.add(advertStat.data!);
          }
          break;
        case AdvertTypeConstants.inSearch:
          final advertStat = await _fetchSearchAdvertStat(token, advertInfo);
          if (advertStat is Success) {
            fetchedAdverts.add(advertStat.data!);
          }
          break;
        case AdvertTypeConstants.inCard:
          final advertStat = await _fetchFullAdvertStat(token, advertInfo);
          if (advertStat is Success) {
            fetchedAdverts.add(advertStat.data!);
          }
          break;
        case AdvertTypeConstants.inCatalog:
          final advertStat = await _fetchFullAdvertStat(token, advertInfo);
          if (advertStat is Success) {
            fetchedAdverts.add(advertStat.data!);
          }
          break;
        case AdvertTypeConstants.inRecomendation:
          final advertStat = await _fetchFullAdvertStat(token, advertInfo);
          if (advertStat is Success) {
            fetchedAdverts.add(advertStat.data!);
          }
          break;
        case AdvertTypeConstants.searchPlusCatalog:
          final advertStat = await _fetchFullAdvertStat(token, advertInfo);
          if (advertStat is Success) {
            fetchedAdverts.add(advertStat.data!);
          }
          break;
        default:
      }
    }
    return Resource.success(fetchedAdverts);
  }

  static Future<Resource<AdvertStatModel>> _fetchAutoAdvertStat(
      String token, AdvertInfoModel advertInfo) async {
    if (_autoLastReq != null) {
      await _ready(
          _autoLastReq, APIConstants.autoStatNumsDurationBetweenReqInMs);
    }

    final advertStatResource = await AdvertApiClient.getAutoStatInBackground(
        token, advertInfo.advertId);
    _autoLastReq = DateTime.now();
    if (advertStatResource is Error) {
      return Resource.error(advertStatResource.message!);
    }

    final advertStat = advertStatResource.data!;
    return Resource.success(advertStat);
  }

  static Future<Resource<AdvertStatModel>> _fetchFullAdvertStat(
      String token, AdvertInfoModel advertInfo) async {
    if (_autoLastReq != null) {
      await _ready(
          _autoLastReq, APIConstants.fullStatNumsDurationBetweenReqInMs);
    }

    final advertStatResource = await AdvertApiClient.getFullStatInBackground(
        token, advertInfo.advertId);
    _autoLastReq = DateTime.now();
    if (advertStatResource is Error) {
      return Resource.error(advertStatResource.message!);
    }

    final advertStat = advertStatResource.data!;
    return Resource.success(advertStat);
  }

  static Future<Resource<AdvertStatModel>> _fetchSearchAdvertStat(
      String token, AdvertInfoModel advertInfo) async {
    if (_searchLastReq != null) {
      await _ready(_searchLastReq, APIConstants.wordsDurationBetweenReqInMs);
    }

    final advertStatResource = await AdvertApiClient.getSearchStatInBackground(
        token, advertInfo.advertId);
    _searchLastReq = DateTime.now();
    if (advertStatResource is Error) {
      return Resource.error(advertStatResource.message!);
    }

    final advertStat = advertStatResource.data!;
    return Resource.success(advertStat);
  }

  static Future<Resource<int>> budgetRequest(String token, int id) async {
    if (_budgetLastReq != null) {
      await _ready(_budgetLastReq, APIConstants.budgetDurationBetweenReqInMs);
    }

    final budgetResource =
        await AdvertApiClient.getCompanyBudgetInBackground(token, id);
    _budgetLastReq = DateTime.now();
    if (budgetResource is Error) {
      return Resource.error(budgetResource.message!);
    }

    final budget = budgetResource.data!;
    return Resource.success(budget);
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
    await LastUpdateDayDataProvider.updateInBackground();
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
