import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/api_clients/advert_api_client.dart';
import 'package:rewild/api_clients/details_api_client.dart';
import 'package:rewild/api_clients/initial_stocks_api_client.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';

import 'package:rewild/core/utils/lists.dart';
import 'package:rewild/core/utils/rewild_error.dart';

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

  // updates initial stocks once a day
  static updateInitialStocks() async {
    // get cards from the local storage
    final cardsOfProductsEither =
        await CardOfProductDataProvider.getAllInBackGround();
    final allSavedCardsOfProducts =
        cardsOfProductsEither.fold((l) => null, (r) => r);
    if (allSavedCardsOfProducts == null || allSavedCardsOfProducts.isEmpty) {
      return;
    }

    // try to fetch today`s initial stocks from server
    final todayInitialStocksFromServerEither =
        await _fetchTodayInitialStocksFromServer(
            allSavedCardsOfProducts.map((e) => e.nmId).toList());

    final todayInitialStocksFromServer =
        todayInitialStocksFromServerEither.fold((l) => null, (r) => r);

    if (todayInitialStocksFromServer == null ||
        todayInitialStocksFromServer.isEmpty) {
      return;
    }

    // save today`s initial stocks to local db and delete supplies
    for (final stock in todayInitialStocksFromServer) {
      // delete supplies because they are not today`s
      final deleteSuppliesEither =
          await SupplyDataProvider.deleteInBackground(nmId: stock.nmId);

      if (deleteSuppliesEither.isLeft()) {
        return;
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
    print('1');
    final tokenEither = values[0] as Either<RewildError, ApiKeyModel?>;
    final notificationEither =
        values[1] as Either<RewildError, List<ReWildNotificationModel>>;
    print('2');
    if (tokenEither.fold((l) => null, (r) => r) == null) {
      final _ = RewildError('Не удалось получить токен',
          source: "BackgroundService", name: 'fetchAll', args: []);
      return;
    }
    print('3');
    // token
    token = tokenEither.fold((l) => null, (r) => r!.token);
    print('4');
    // Adverts for single advert stat screen
    // fetch adverts from API Wb
    final advertEither = await fetchAdverts(token);
    advertEither.fold((l) => null, (advertStatModels) async {
      // save all fetched adverts
      if (advertStatModels == null || advertStatModels.isEmpty) {
        for (final advert in advertStatModels!) {
          await AdvertStatDataProvider.saveInBackground(advert);
        }
      }
    });
    print('15');

    // Notifications
    final notifications = notificationEither.fold((l) => null, (r) => null);
    print('6');
    if (notifications == null || notifications.isEmpty) {
      return;
    }
    print('7');
    // separate cards and verts notifications
    List<ReWildNotificationModel> cardsNotifications = notifications
        .where((element) =>
            element.condition != NotificationConditionConstants.budgetLessThan)
        .toList();
    print('8');
    List<ReWildNotificationModel> advertsNotifications = notifications
        .where((element) =>
            element.condition == NotificationConditionConstants.budgetLessThan)
        .toList();
    print('9');
    // ids
    List<int> cardsIds = cardsNotifications.map((e) => e.parentId).toList();
    List<int> advertsIds = advertsNotifications.map((e) => e.parentId).toList();
    print('10');
    // fetch cards from Wb
    final cardsEither = await DetailsApiClient.getInBackground(
        ids: cardsIds.unique() as List<int>);
    // list to save notification contents
    print('11');
    List<ReWildNotificationContent> notificationContents = [];

    // insert notification contents to the list
    // and update notification in local db with current value
    cardsEither.fold((l) => null, (cards) {
      for (final card in cards) {
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
    });
    print('12');
    // get adverts budget from Wb for notification
    if (token != null) {
      final fetchedAdvertBudgetNotificationsEither = await _fetchAdvertBudgets(
          token, advertsIds.unique() as List<int>, advertsNotifications);

      fetchedAdvertBudgetNotificationsEither.fold(
        (l) => null,
        (r) => notificationContents.addAll(r),
      );
    }

    print('14');
    // if there are no notifications return
    if (notificationContents.isEmpty) {
      return;
    }

    print('15');
    // save all new notifications and messages to local db
    for (final notCont in notificationContents) {
      int subj = _getSubject(notCont);
      final message = BackgroundMessage(
          subject: subj,
          dateTime: DateTime.now(),
          condition: notCont.condition!,
          value: notCont.newValue!,
          id: notCont.id);
      await NotificationDataProvider.saveInBackground(ReWildNotificationModel(
          parentId: notCont.id,
          condition: notCont.condition!,
          value: notCont.newValue!));
      await BackgroundMessageDataProvider.saveInBackground(message);
    }
    print('16');
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

  static Future<Either<RewildError, List<ReWildNotificationContent>>>
      _fetchAdvertBudgets(String token, List<int> advertsIds,
          List<ReWildNotificationModel> advertsNotifications) async {
    List<ReWildNotificationContent> notificationContents = [];
    for (final campaignId in advertsIds) {
      // fetch budget
      final budgetEither = await budgetRequest(token, campaignId);

      final budget = budgetEither.fold((l) => null, (r) => r);
      if (budget == null) {
        continue;
      }
      final notificationsList = advertsNotifications
          .where((element) => element.parentId == campaignId)
          .toList();
      if (notificationsList.isEmpty) {
        continue;
      }

      final nBudg = int.tryParse(notificationsList.first.value) ?? 0;
      if (budget < nBudg) {
        final notContent = ReWildNotificationContent(
          id: campaignId,
          condition: NotificationConditionConstants.budgetLessThan,
          newValue: budget.toString(),
        );
        NotificationDataProvider.saveInBackground(ReWildNotificationModel(
          parentId: campaignId,
          condition: NotificationConditionConstants.budgetLessThan,
          value: budget.toString(),
        ));
        notificationContents.add(notContent);
      }
    }
    return right(notificationContents);
  }

  static Future<Either<RewildError, List<AdvertStatModel>?>> fetchAdverts(
      String? token) async {
    if (token == null) {
      return right(null);
    }
    List<AdvertStatModel> fetchedAdverts = [];

    // get all adverts Ids from Wb API
    final allAdvertsIdsEither =
        await AdvertApiClient.countInBackground(token: token);

    final allAdvertsIdsMap = allAdvertsIdsEither.fold(
      (l) => null,
      (r) => r,
    );
    if (allAdvertsIdsMap == null) {
      return right(null);
    }

    // convert map to list
    final ids = allAdvertsIdsMap.values.expand((element) => element).toList();

    final advertEither =
        await AdvertApiClient.getAdvertsInBackground(token: token, ids: ids);

    final allAdverts = advertEither.fold(
      (l) => null,
      (r) => r,
    );
    if (allAdverts == null) {
      return right(null);
    }

    for (final advertInfo in allAdverts) {
      if (advertInfo.status != AdvertStatusConstants.active &&
          advertInfo.status != AdvertStatusConstants.paused) {
        continue;
      }
      switch (advertInfo.type) {
        case AdvertTypeConstants.auto:
          final advertStatEither =
              await _fetchAutoAdvertStat(token, advertInfo);
          advertStatEither.fold(
            (l) => null,
            (r) => fetchedAdverts.add(r),
          );

          break;
        case AdvertTypeConstants.inSearch:
          final advertStatEither =
              await _fetchSearchAdvertStat(token, advertInfo);
          advertStatEither.fold(
            (l) => null,
            (r) => fetchedAdverts.add(r),
          );
          break;
        case AdvertTypeConstants.inCard:
          final advertStatEither =
              await _fetchFullAdvertStat(token, advertInfo);
          advertStatEither.fold(
            (l) => null,
            (r) => fetchedAdverts.add(r),
          );
          break;
        case AdvertTypeConstants.inCatalog:
          final advertStatEither =
              await _fetchFullAdvertStat(token, advertInfo);
          advertStatEither.fold(
            (l) => null,
            (r) => fetchedAdverts.add(r),
          );
          break;
        // case AdvertTypeConstants.inRecomendation:
        //   final advertStat = await _fetchFullAdvertStat(token, advertInfo);
        //   if (advertStat is Success) {
        //     fetchedAdverts.add(advertStat.data!);
        //   }
        //   break;
        case AdvertTypeConstants.searchPlusCatalog:
          final advertStatEither =
              await _fetchFullAdvertStat(token, advertInfo);
          advertStatEither.fold(
            (l) => null,
            (r) => fetchedAdverts.add(r),
          );
          break;
        default:
      }
    }
    return right(fetchedAdverts);
  }

  static Future<Either<RewildError, AdvertStatModel>> _fetchAutoAdvertStat(
      String token, AdvertInfoModel advertInfo) async {
    final advertStatEither = await AdvertApiClient.getAutoStatInBackground(
        token: token, campaignId: advertInfo.campaignId);

    final advertStat = advertStatEither.fold((l) => null, (r) => r);
    if (advertStat == null) {
      return left(RewildError(
        "An error occurred: $advertStat",
        source: "BackgroundService",
        name: "_fetchAutoAdvertStat",
        args: [token, advertInfo],
      ));
    }
    return right(advertStat);
  }

  static Future<Either<RewildError, AdvertStatModel>> _fetchFullAdvertStat(
      String token, AdvertInfoModel advertInfo) async {
    final advertStatEither = await AdvertApiClient.getFullStatInBackground(
        token: token, campaignId: advertInfo.campaignId);

    final advertStat = advertStatEither.fold((l) => null, (r) => r);
    if (advertStat == null) {
      return left(RewildError(
        "An error occurred: $advertStatEither",
        source: "BackgroundService",
        name: "_fetchFullAdvertStat",
        args: [token, advertInfo],
      ));
    }
    return right(advertStat);
  }

  static Future<Either<RewildError, AdvertStatModel>> _fetchSearchAdvertStat(
      String token, AdvertInfoModel advertInfo) async {
    final advertStatEither = await AdvertApiClient.getSearchStatInBackground(
        token: token, campaignId: advertInfo.campaignId);

    final advertStat = advertStatEither.fold((l) => null, (r) => r);
    if (advertStat == null) {
      return left(RewildError(
        "An error occurred: $advertStatEither",
        source: "BackgroundService",
        name: "_fetchSearchAdvertStat",
        args: [token, advertInfo],
      ));
    }
    return right(advertStat);
  }

  static Future<Either<RewildError, int>> budgetRequest(
      String token, int id) async {
    final budgetEither = await AdvertApiClient.getCompanyBudgetInBackground(
        token: token, campaignId: id);

    final budget = budgetEither.fold((l) => null, (r) => r);
    if (budget == null) {
      return left(RewildError(
        "An error occurred: $budgetEither",
        source: "BackgroundService",
        name: "budgetRequest",
        args: [token, id],
      ));
    }
    return right(budget);
  }

  // PRIVATE METHODS ===================================================================== PRIVATE METHODS

  static Future<Either<RewildError, List<InitialStockModel>>>
      _fetchTodayInitialStocksFromServer(
          List<int> cardsWithoutTodayInitStocksIds) async {
    List<InitialStockModel> initialStocksFromServer = [];
    if (cardsWithoutTodayInitStocksIds.isNotEmpty) {
      final initialStocksEither = await InitialStocksApiClient.getInBackground(
        skus: cardsWithoutTodayInitStocksIds,
        dateFrom: yesterdayEndOfTheDay(),
        dateTo: DateTime.now(),
      );

      initialStocksFromServer = initialStocksEither.fold((l) => [], (r) => r);

      // save initial stocks to local db
      for (final stock in initialStocksFromServer) {
        final insertStockEither =
            await InitialStockDataProvider.insertInBackground(
                initialStock: stock);
        final insertStock = insertStockEither.fold((l) => null, (r) => r);
        if (insertStock == null) {
          return left(RewildError(
            "An error occurred: $insertStockEither",
            source: "BackgroundService",
            name: "_fetchTodayInitialStocksFromServer",
            args: [cardsWithoutTodayInitStocksIds],
          ));
        }
      }
    }
    await LastUpdateDayDataProvider.updateInBackground();
    return right(initialStocksFromServer);
  }

  static Future _instantNotification(String title, String body) async {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 1, channelKey: 'basic_channel', title: title, body: body));
  }
}
