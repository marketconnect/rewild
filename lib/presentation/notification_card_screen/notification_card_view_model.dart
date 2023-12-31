import 'package:flutter/widgets.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/notification.dart';
import 'package:rewild/domain/entities/warehouse.dart';

abstract class NotificationCardNotificationService {
  Future<Either<RewildError, void>> addForParent(
      {required List<ReWildNotificationModel> notifications,
      required int parentId,
      required bool wasEmpty});
  Future<Either<RewildError, List<ReWildNotificationModel>>> getForParent(
      {required int parentId});
}

class NotificationCardState {
  final int nmId;
  final int price;
  final String name;
  final String promo;
  final int pics;
  final double reviewRating;
  final Map<Warehouse, int> warehouses;
  NotificationCardState(
      {required this.nmId,
      required this.pics,
      required this.reviewRating,
      required this.price,
      required this.name,
      required this.promo,
      required this.warehouses});

  factory NotificationCardState.empty() {
    return NotificationCardState(
        nmId: 0,
        pics: 0,
        name: '',
        reviewRating: 0,
        price: 0,
        promo: "",
        warehouses: {});
  }

  NotificationCardState copyWith({
    int? nmId,
    int? price,
    String? promo,
    int? pics,
    String? name,
    double? reviewRating,
    Map<Warehouse, int>? warehouses,
  }) {
    return NotificationCardState(
      nmId: nmId ?? this.nmId,
      price: price ?? this.price,
      promo: promo ?? this.promo,
      name: name ?? this.name,
      pics: pics ?? this.pics,
      reviewRating: reviewRating ?? this.reviewRating,
      warehouses: warehouses ?? this.warehouses,
    );
  }
}

class CardNotificationViewModel extends ResourceChangeNotifier {
  final NotificationCardNotificationService notificationService;
  final NotificationCardState state;
  CardNotificationViewModel(this.state,
      {required this.notificationService,
      required super.context,
      required super.internetConnectionChecker}) {
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    SqfliteService.printTableContent('notifications');
    SqfliteService.printTableContent('background_messages');
    final savedNotifications = await fetch(
        () => notificationService.getForParent(parentId: state.nmId));
    if (savedNotifications == null) {
      return;
    }

    if (savedNotifications.isNotEmpty) {
      setWasNotEmpty();
    }

    Map<int, ReWildNotificationModel> notifications = {};

    for (var element in savedNotifications) {
      notifications[element.condition] = element;
    }

    _stocks = state.warehouses.entries
        .fold(0, (previousValue, element) => previousValue! + element.value);

    setNotifications(notifications);
  }

  // there were notifications before
  bool _wasEmpty = true;
  void setWasNotEmpty() {
    _wasEmpty = false;
  }

  int? _stocks;

  int get stocks => _stocks ?? 0;

  // Fields
  Map<int, ReWildNotificationModel> _notifications = {};
  void setNotifications(Map<int, ReWildNotificationModel> notifications) {
    _notifications = notifications;
    notify();
  }

  Map<int, ReWildNotificationModel> get notifications => _notifications;

  Future<void> save() async {
    final listToAdd = _notifications.values.toList();

    await notificationService.addForParent(
        notifications: listToAdd, parentId: state.nmId, wasEmpty: _wasEmpty);

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

  void addNotification(int condition, int? value) {
    switch (condition) {
      case NotificationConditionConstants.nameChanged:
        _notifications[condition] = ReWildNotificationModel(
            condition: NotificationConditionConstants.nameChanged,
            value: state.name,
            reusable: true,
            parentId: state.nmId);

        break;
      case NotificationConditionConstants.picsChanged:
        _notifications[condition] = ReWildNotificationModel(
            condition: NotificationConditionConstants.picsChanged,
            value: state.pics.toString(),
            reusable: true,
            parentId: state.nmId);

        break;
      case NotificationConditionConstants.priceChanged:
        _notifications[condition] = ReWildNotificationModel(
            condition: NotificationConditionConstants.priceChanged,
            value: state.price.toString(),
            reusable: true,
            parentId: state.nmId);

        break;
      case NotificationConditionConstants.promoChanged:
        _notifications[condition] = ReWildNotificationModel(
            condition: NotificationConditionConstants.promoChanged,
            value: state.promo,
            reusable: true,
            parentId: state.nmId);

        break;
      case NotificationConditionConstants.reviewRatingChanged:
        _notifications[condition] = ReWildNotificationModel(
            condition: NotificationConditionConstants.reviewRatingChanged,
            value: state.reviewRating.toString(),
            reusable: true,
            parentId: state.nmId);

        break;
      case NotificationConditionConstants.stocksLessThan:
        _notifications[condition] = ReWildNotificationModel(
            condition: NotificationConditionConstants.stocksLessThan,
            reusable: true,
            value: value.toString(),
            parentId: state.nmId);

        break;

      case NotificationConditionConstants.stocksInWhLessThan:
      default:
        break;
    }
    notify();
  }
}
