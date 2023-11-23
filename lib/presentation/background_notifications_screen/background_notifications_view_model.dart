import 'package:flutter/material.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/background_message.dart';
import 'package:rewild/presentation/background_notifications_screen/background_notifications_screen.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

abstract class BackgroundNotificationsBackgroundMessageService {
  Future<Resource<List<BackgroundMessage>>> getAll();
  Future<Resource<bool>> delete(BackgroundMessage message);
}

abstract class BackgroundNotificationsNotificationService {
  Future<Resource<bool>> delete(int id, int condition);
}

class BackgroundNotificationsViewModel extends ResourceChangeNotifier {
  final BackgroundNotificationsBackgroundMessageService
      backgroundNotificationsBackgroundMessageService;
  final BackgroundNotificationsNotificationService notificationService;

  BackgroundNotificationsViewModel(
      {required this.backgroundNotificationsBackgroundMessageService,
      required this.notificationService,
      required super.context,
      required super.internetConnectionChecker}) {
    _asyncInit();
  }

  List<MessageCard> _messages = [];
  List<MessageCard> get messages => _messages;

  Future<void> _asyncInit() async {
    final backgroundMessages = await fetch(
        () => backgroundNotificationsBackgroundMessageService.getAll());
    if (backgroundMessages == null) {
      return;
    }

    for (var backgroundMessage in backgroundMessages) {
      // final subject = backgroundMessage.subject;
      final condition = backgroundMessage.condition;
      String title = "";
      String description = "";
      int id = backgroundMessage.id;
      String routeName = "";

      switch (condition) {
        case NotificationConditionConstants.budgetLessThan:
          title = "Кампания ${backgroundMessage.id}";
          description = "Бюджет ${backgroundMessage.value} руб.";
          routeName = MainNavigationRouteNames.singleAdvertStatsScreen;
          break;

        case NotificationConditionConstants.nameChanged:
          title = "Товар ${backgroundMessage.id}";
          description = "Новое название: ${backgroundMessage.value}";
          routeName = MainNavigationRouteNames.singleCardScreen;
          break;

        case NotificationConditionConstants.priceChanged:
          title = "Товар ${backgroundMessage.id}";
          description = "Новая цена: ${backgroundMessage.value} руб.";
          routeName = MainNavigationRouteNames.singleCardScreen;
          break;

        case NotificationConditionConstants.picsChanged:
          title = "Товар ${backgroundMessage.id}";
          description = "Стало ${backgroundMessage.value} фото";
          routeName = MainNavigationRouteNames.singleCardScreen;
          break;

        case NotificationConditionConstants.promoChanged:
          title = "Товар ${backgroundMessage.id}";
          description = "Новая акция: ${backgroundMessage.value}";
          routeName = MainNavigationRouteNames.singleCardScreen;
          break;

        case NotificationConditionConstants.reviewRatingChanged:
          title = "Товар ${backgroundMessage.id}";
          description = "Новое рейтинг: ${backgroundMessage.value}";
          routeName = MainNavigationRouteNames.singleCardScreen;
          break;

        case NotificationConditionConstants.stocksLessThan:
          title = "Товар ${backgroundMessage.id}";
          description = "Остатки на складах: ${backgroundMessage.value}";
          routeName = MainNavigationRouteNames.singleCardScreen;
          break;

        default:
          break;
      }

      _messages.add(MessageCard(
          header: title,
          id: id,
          routeName: routeName,
          description: description,
          condition: condition,
          dateTime: formatDateTime(backgroundMessage.dateTime)));
    }

    notify();
  }

  Future<void> pressed(String routeName, int id, int condition) async {
    final resource =
        await fetch(() => notificationService.delete(id, condition));

    if (resource == null) {
      return;
    }

    if (context.mounted) {
      Navigator.pushNamed(context, routeName, arguments: id);
    }
  }
}
