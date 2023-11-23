import 'package:flutter/widgets.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/notification.dart';

abstract class AdvertNotificationNotificationService {
  Future<Resource<void>> addForParent(
      List<NotificationModel> notifications, int parentId);
  Future<Resource<List<NotificationModel>>> getForParent(int bnmId);
}

class AdvertNotificationState {
  final int nmId;
  final int budget;

  AdvertNotificationState({
    required this.nmId,
    required this.budget,
  });

  factory AdvertNotificationState.empty() {
    return AdvertNotificationState(nmId: 0, budget: 0);
  }

  AdvertNotificationState copyWith({
    int? budget,
  }) {
    return AdvertNotificationState(
      budget: budget ?? this.budget,
      nmId: nmId,
    );
  }
}

class AdvertNotificationViewModel extends ResourceChangeNotifier {
  final AdvertNotificationNotificationService notificationService;
  final AdvertNotificationState state;
  AdvertNotificationViewModel(this.state,
      {required this.notificationService,
      required super.context,
      required super.internetConnectionChecker}) {
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    SqfliteService.printTableContent('notifications');
    final savedNotifications =
        await fetch(() => notificationService.getForParent(state.nmId));
    if (savedNotifications == null) {
      return;
    }

    setNotifications(savedNotifications);
  }

  // Fields
  List<NotificationModel> _notifications = [];
  void setNotifications(List<NotificationModel> notifications) {
    _notifications = notifications;
    notify();
  }

  List<NotificationModel> get notifications => _notifications;

  Future<void> save() async {
    await notificationService.addForParent(_notifications, state.nmId);
    if (context.mounted) Navigator.of(context).pop();
  }

  int isInNotifications(int condition) {
    final notification =
        _notifications.where((element) => element.condition == condition);

    if (notification.isEmpty) {
      return 0;
    } else if (notification.first.reusable) {
      return 2;
    } else {
      return 1;
    }
  }

  void dropNotification(int condition) {
    _notifications.removeWhere((element) => element.condition == condition);
    notifyListeners();
  }

  void addNotification(int condition, int? value, [bool? reusable]) {
    _notifications.removeWhere((element) => element.condition == condition);

    switch (condition) {
      case NotificationConditionConstants.budgetLessThan:
        _notifications.add(NotificationModel(
            condition: NotificationConditionConstants.budgetLessThan,
            value: state.budget.toString(),
            reusable: reusable ?? false,
            parentId: state.nmId));

        break;

      default:
        break;
    }
    notify();
  }
}
