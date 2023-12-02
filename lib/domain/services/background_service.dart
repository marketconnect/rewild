import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:rewild/api_clients/advert_api_client.dart';
import 'package:rewild/api_clients/details_api_client.dart';
import 'package:rewild/api_clients/initial_stocks_api_client.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/api_duration_constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/lists.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/data_providers/advert_stat_data_provider/advert_stat_data_provider.dart';
import 'package:rewild/data_providers/background_message_data_provider/background_message_data_provider.dart';

import 'package:rewild/data_providers/card_of_product_data_provider/card_of_product_data_provider.dart';
import 'package:rewild/data_providers/initial_stocks_data_provider/initial_stocks_data_provider.dart';
import 'package:rewild/data_providers/last_update_day_data_provider.dart';
import 'package:rewild/data_providers/notificate_data_provider/notification_data_provider.dart';

import 'package:rewild/data_providers/secure_storage_data_provider.dart';
import 'package:rewild/data_providers/supply_data_provider/supply_data_provider.dart';

import 'package:rewild/domain/entities/advert_model.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:rewild/domain/entities/background_message.dart';

import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/entities/notification.dart';
import 'package:rewild/domain/entities/notification_content.dart';

class BackgroundService {
  const BackgroundService();

  static Future initial() async {}

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
      return Resource.error(cardsOfProductsResource.message!,
          source: "BackgroundService", name: "updateInitialStocks", args: []);
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
      return Resource.error(todayInitialStocksFromServerResource.message!,
          source: "BackgroundService", name: "updateInitialStocks", args: []);
    }
    final todayInitialStocksFromServer =
        todayInitialStocksFromServerResource.data!;

    // save today`s initial stocks to local db and delete supplies
    for (final stock in todayInitialStocksFromServer) {
      // delete supplies because they are not today`s
      final deleteSuppliesResource =
          await SupplyDataProvider.deleteInBackground(nmId: stock.nmId);
      if (deleteSuppliesResource is Error) {
        return Resource.error(deleteSuppliesResource.message!,
            source: "BackgroundService", name: "updateInitialStocks", args: []);
      }

      // set were updated today
      await LastUpdateDayDataProvider.updateInBackground();
    }
  }

  // update all every n minutes
  static fetchAll() async {
    // since the token does not uses for card of products details request
    // make it nullable
    String? token;

    // get token and all notifications
    final values = await Future.wait([
      SecureStorageProvider.getApiKeyFromBackground('Продвижение'),
      NotificationDataProvider.getAllInBackground(),
    ]);

    final tokenResource = values[0] as Resource<ApiKeyModel>;
    final notificationResource =
        values[1] as Resource<List<ReWildNotificationModel>>;

    // token
    if (tokenResource is Success) {
      token = tokenResource.data!.token;
    }

    // Adverts for single advert stat screen
    // fetch adverts from API Wb
    final advertResource = await fetchAdverts(token);
    if (advertResource is Error) {
      return Resource.error(advertResource.message!,
          source: "BackgroundService", name: "fetchAll", args: []);
    }
    // save all fetched adverts
    if (advertResource is Success) {
      for (final advert in advertResource.data!) {
        await AdvertStatDataProvider.saveInBackground(advert);
      }
    }

    if (notificationResource is Error) {
      return Resource.error(notificationResource.message!,
          source: "BackgroundService", name: "fetchAll", args: []);
    }
    if (notificationResource is Empty) {
      return;
    }

    // Notifications
    final notifications = notificationResource.data!;

    // separate cards and verts notifications
    List<ReWildNotificationModel> cardsNotifications = notifications
        .where((element) =>
            element.condition != NotificationConditionConstants.budgetLessThan)
        .toList();
    List<ReWildNotificationModel> advertsNotifications = notifications
        .where((element) =>
            element.condition == NotificationConditionConstants.budgetLessThan)
        .toList();

    // ids
    List<int> cardsIds = cardsNotifications.map((e) => e.parentId).toList();
    List<int> advertsIds = advertsNotifications.map((e) => e.parentId).toList();

    // fetch cards from Wb
    final cardsResource =
        await DetailsApiClient.getInBackground(cardsIds.unique() as List<int>);
    if (cardsResource is Error) {
      return Resource.error(cardsResource.message!,
          source: "BackgroundService", name: "fetchAll", args: []);
    }

    // get notification contents for cards

    // list to save notification contents
    List<ReWildNotificationContent> notificationContents = [];

    // insert notification contents to the list
    // and update notification in local db with current value
    if (cardsResource is Success) {
      for (final card in cardsResource.data!) {
        final notificationsList = cardsNotifications
            .where((element) => element.parentId == card.nmId)
            .toList();
        final notContentList = card.notifications(notificationsList);
        for (final notContent in notContentList) {
          NotificationDataProvider.saveInBackground(ReWildNotificationModel(
              parentId: card.nmId,
              condition: notContent.condition!,
              value: notContent.newValue!));
        }
        notificationContents.addAll(notContentList);
      }
    }

    // get adverts budget from Wb for notification
    if (token != null) {
      final fetchedAdvertBudgetNotifications = await _fetchAdvertBudgets(
          token, advertsIds.unique() as List<int>, advertsNotifications);

      if (fetchedAdvertBudgetNotifications is Error) {
        return Resource.error(fetchedAdvertBudgetNotifications.message!,
            source: "BackgroundService", name: "fetchAll", args: []);
      }
      if (fetchedAdvertBudgetNotifications is Success) {
        notificationContents.addAll(fetchedAdvertBudgetNotifications.data!);
      }
    }

    // if there are no notifications return
    if (notificationContents.isEmpty) {
      return;
    }

    // save all new notifications and messages to local db
    for (final notCont in notificationContents) {
      int subj = _getSubject(notCont);
      final message = BackgroundMessage(
          subject: subj,
          dateTime: DateTime.now(),
          condition: notCont.condition!,
          value: notCont.newValue!,
          // header: notCont.title,
          // message: notCont.body,
          id: notCont.id);
      await NotificationDataProvider.saveInBackground(ReWildNotificationModel(
          parentId: notCont.id,
          condition: notCont.condition!,
          value: notCont.newValue!));
      await BackgroundMessageDataProvider.saveInBackground(message);
    }

    // notify user
    await _instantNotification("У вас есть сообщение от ReWild", '');
  }

  static int _getSubject(ReWildNotificationContent notCont) {
    final subj =
        notCont.condition == NotificationConditionConstants.budgetLessThan
            ? BackgroundMessage.advert
            : BackgroundMessage.card;
    return subj;
  }

  static Future<Resource<List<ReWildNotificationContent>>> _fetchAdvertBudgets(
      String token,
      List<int> advertsIds,
      List<ReWildNotificationModel> advertsNotifications) async {
    List<ReWildNotificationContent> notificationContents = [];
    for (final campaignId in advertsIds) {
      // fetch budget
      final budgetResource = await budgetRequest(token, campaignId);
      if (budgetResource is Error) {
        return Resource.error(budgetResource.message!,
            source: "BackgroundService",
            name: "_fetchAdvertBudgets",
            args: [token, advertsIds, advertsNotifications]);
      }
      if (budgetResource is Empty) {
        continue;
      }
      final budget = budgetResource.data!;
      final notificationsList = advertsNotifications
          .where((element) => element.parentId == campaignId)
          .toList();
      if (notificationsList.isEmpty) {
        continue;
      }
      final nBudg = int.tryParse(notificationsList.first.value) ?? 0;
      if (budget < nBudg) {
        // final title = "Бюджет кампании $campaignId";
        // final body = "Бюджет: $budget, был $nBudg";
        final notContent = ReWildNotificationContent(
          id: campaignId,
          condition: NotificationConditionConstants.budgetLessThan,
          newValue: budget.toString(),
          // title: title,
          // body: body,
        );
        NotificationDataProvider.saveInBackground(ReWildNotificationModel(
          parentId: campaignId,
          condition: NotificationConditionConstants.budgetLessThan,
          value: budget.toString(),
        ));
        notificationContents.add(notContent);
      }
    }
    return Resource.success(notificationContents);
  }

  static Future<Resource<List<AdvertStatModel>>> fetchAdverts(
      String? token) async {
    if (token == null) {
      return Resource.empty();
    }
    List<AdvertStatModel> fetchedAdverts = [];
    // getr all adverts
    if (_advertsLastReq != null) {
      await ApiDurationConstants.ready(
          _advertsLastReq, ApiDurationConstants.budgetDurationBetweenReqInMs);
    }

    final advertResource =
        await AdvertApiClient.getAdvertsInBackground(token, []);

    _advertsLastReq = DateTime.now();
    if (advertResource is Error) {
      return Resource.error(advertResource.message!,
          source: "BackgroundService", name: "fetchAdverts", args: [token]);
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
      await ApiDurationConstants.ready(_autoLastReq,
          ApiDurationConstants.autoStatNumsDurationBetweenReqInMs);
    }

    final advertStatResource = await AdvertApiClient.getAutoStatInBackground(
        token, advertInfo.campaignId);
    _autoLastReq = DateTime.now();
    if (advertStatResource is Error) {
      return Resource.error(advertStatResource.message!,
          source: "BackgroundService",
          name: "_fetchAutoAdvertStat",
          args: [token, advertInfo]);
    }

    final advertStat = advertStatResource.data!;
    return Resource.success(advertStat);
  }

  static Future<Resource<AdvertStatModel>> _fetchFullAdvertStat(
      String token, AdvertInfoModel advertInfo) async {
    if (_autoLastReq != null) {
      await ApiDurationConstants.ready(_autoLastReq,
          ApiDurationConstants.fullStatNumsDurationBetweenReqInMs);
    }

    final advertStatResource = await AdvertApiClient.getFullStatInBackground(
        token, advertInfo.campaignId);
    _autoLastReq = DateTime.now();
    if (advertStatResource is Error) {
      return Resource.error(advertStatResource.message!,
          source: "BackgroundService",
          name: "_fetchFullAdvertStat",
          args: [token, advertInfo]);
    }

    final advertStat = advertStatResource.data!;
    return Resource.success(advertStat);
  }

  static Future<Resource<AdvertStatModel>> _fetchSearchAdvertStat(
      String token, AdvertInfoModel advertInfo) async {
    if (_searchLastReq != null) {
      await ApiDurationConstants.ready(
          _searchLastReq, ApiDurationConstants.wordsDurationBetweenReqInMs);
    }

    final advertStatResource = await AdvertApiClient.getSearchStatInBackground(
        token, advertInfo.campaignId);
    _searchLastReq = DateTime.now();
    if (advertStatResource is Error) {
      return Resource.error(advertStatResource.message!,
          source: "BackgroundService",
          name: "_fetchSearchAdvertStat",
          args: [token, advertInfo]);
    }

    final advertStat = advertStatResource.data!;
    return Resource.success(advertStat);
  }

  static Future<Resource<int>> budgetRequest(String token, int id) async {
    if (_budgetLastReq != null) {
      await ApiDurationConstants.ready(
          _budgetLastReq, ApiDurationConstants.budgetDurationBetweenReqInMs);
    }

    final budgetResource =
        await AdvertApiClient.getCompanyBudgetInBackground(token, id);
    _budgetLastReq = DateTime.now();
    if (budgetResource is Error) {
      return Resource.error(budgetResource.message!,
          source: "BackgroundService",
          name: "budgetRequest",
          args: [token, id]);
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
        return Resource.error(initialStocksResource.message!,
            source: "BackgroundService",
            name: "_fetchTodayInitialStocksFromServer",
            args: [cardsWithoutTodayInitStocksIds]);
      }

      initialStocksFromServer = initialStocksResource.data!;

      // save initial stocks to local db
      for (final stock in initialStocksFromServer) {
        final insertStockresource =
            await InitialStockDataProvider.insertInBackground(stock);
        if (insertStockresource is Error) {
          return Resource.error(insertStockresource.message!,
              source: "BackgroundService",
              name: "_fetchTodayInitialStocksFromServer",
              args: [cardsWithoutTodayInitStocksIds]);
        }
      }
    }
    await LastUpdateDayDataProvider.updateInBackground();
    return Resource.success(initialStocksFromServer);
  }

  // static void _onDidReceiveLocalNotification(
  //     int id, String? title, String? body, String? payload) async {}
  // static void _onDidReceiveNotificationResponse(
  //     NotificationResponse notificationResponse) async {}

  static Future _instantNotification(String title, String body) async {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 1, channelKey: 'basic_channel', title: title, body: body));
  }

  //   const NotificationDetails notificationDetails =
  //       NotificationDetails(android: androidNotificationDetails);
  //   await _flutterLocalNotificationsPlugin
  //       .show(0, title, body, notificationDetails, payload: 'item x');
  // }
}
