import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/extensions/date_time.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/background_message.dart';
import 'package:rewild/presentation/background_messages_screen/background_messages_screen.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

abstract class BackgroundMessagesBackgroundMessageService {
  Future<Either<RewildError, List<BackgroundMessage>>> getAll();
  Future<Either<RewildError, bool>> delete(
      {required int id, required int subject, required int condition});
}

abstract class BackgroundMessagesNotificationService {
  Future<Either<RewildError, bool>> delete(
      {required int id, required int condition});
}

class BackgroundMessagesViewModel extends ResourceChangeNotifier {
  final BackgroundMessagesBackgroundMessageService messageService;
  final BackgroundMessagesNotificationService notificationService;

  BackgroundMessagesViewModel(
      {required this.messageService,
      required this.notificationService,
      required super.context,
      required super.internetConnectionChecker}) {
    _asyncInit();
  }

  List<MessageCard> _messages = [];
  set messages(List<MessageCard> value) {
    _messages = value;
    notifyListeners();
  }

  List<MessageCard> get messages => _messages;

  Future<void> _asyncInit() async {
    await _update();
  }

  _update() async {
    if (_messages.isNotEmpty) {
      _messages.clear();
    }
    final backgroundMessages = await fetch(() => messageService.getAll());
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
          subject: backgroundMessage.subject,
          description: description,
          condition: condition,
          dateTime: backgroundMessage.dateTime.formatDateTime()));
    }

    notify();
  }

  Future<void> pressed(
      {required String routeName,
      required int id,
      required int subject,
      required int condition}) async {
    final resource = await fetch(
        () => notificationService.delete(id: id, condition: condition));

    if (resource == null) {
      return;
    }

    final ok = await fetch(() =>
        messageService.delete(id: id, subject: subject, condition: condition));
    if (ok == null) {
      return;
    }

    await _update();
    if (context.mounted) {
      Navigator.pushNamed(context, routeName, arguments: id);
    }
  }
}
