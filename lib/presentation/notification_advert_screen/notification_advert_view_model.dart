import 'package:flutter/widgets.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/notification.dart';

abstract class NotificationAdvertNotificationService {
  Future<Either<RewildError, void>> addForParent(
      List<ReWildNotificationModel> notifications, int parentId, bool wasEmpty);
  Future<Either<RewildError, List<ReWildNotificationModel>>> getForParent(
      int bnmId);
}

class NotificationAdvertState {
  final int nmId;
  final int budget;

  NotificationAdvertState({
    required this.nmId,
    required this.budget,
  });

  factory NotificationAdvertState.empty() {
    return NotificationAdvertState(nmId: 0, budget: 0);
  }

  NotificationAdvertState copyWith({
    int? budget,
  }) {
    return NotificationAdvertState(
      budget: budget ?? this.budget,
      nmId: nmId,
    );
  }
}

class NotificationAdvertViewModel extends ResourceChangeNotifier {
  final NotificationAdvertNotificationService notificationService;
  final NotificationAdvertState state;
  NotificationAdvertViewModel(this.state,
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
    if (savedNotifications.isNotEmpty) {
      setWasNotEmpty();
    }
    final notifMap = <int, ReWildNotificationModel>{};
    for (var element in savedNotifications) {
      notifMap[element.condition] = element;
    }

    setNotifications(notifMap);
    // final notBudget = savedNotifications.where((element) =>
    //     element.condition == NotificationConditionConstants.budgetLessThan);
  }

  // Fields
  // there were notifications before
  bool _wasEmpty = true;
  void setWasNotEmpty() {
    _wasEmpty = false;
  }

  Map<int, ReWildNotificationModel> _notifications = {};
  void setNotifications(Map<int, ReWildNotificationModel> notifications) {
    _notifications = notifications;
    notify();
  }

  Map<int, ReWildNotificationModel> get notifications => _notifications;

  Future<void> save() async {
    final toSave = _notifications.values.toList();

    await notificationService.addForParent(toSave, state.nmId, _wasEmpty);

    if (context.mounted) Navigator.of(context).pop();
  }

  bool isInNotifications(int condition) {
    final notification = _notifications[condition];

    if (notification == null) {
      return false;
    }
    return true;
  }

  void dropNotification(int condition) {
    _notifications.remove(condition);
    notifyListeners();
  }

  void addNotification(int condition, int? value, [bool? reusable]) {
    switch (condition) {
      case NotificationConditionConstants.budgetLessThan:
        _notifications[condition] = ReWildNotificationModel(
            condition: NotificationConditionConstants.budgetLessThan,
            value: value.toString(),
            reusable: reusable ?? false,
            parentId: state.nmId);

        break;

      default:
        break;
    }
    notify();
  }
}
