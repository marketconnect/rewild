import 'package:flutter/widgets.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/notification.dart';
import 'package:rewild/domain/entities/warehouse.dart';

abstract class CardNotificationNotificationService {
  Future<Resource<void>> addForParent(
      List<NotificationModel> notifications, int parentId);
  Future<Resource<List<NotificationModel>>> getForParent(int bnmId);
}

class CardNotificationState {
  final int nmId;
  final int price;
  final String name;
  final String promo;
  final int pics;
  final double reviewRating;
  final Map<Warehouse, int> warehouses;
  CardNotificationState(
      {required this.nmId,
      required this.pics,
      required this.reviewRating,
      required this.price,
      required this.name,
      required this.promo,
      required this.warehouses});

  factory CardNotificationState.empty() {
    return CardNotificationState(
        nmId: 0,
        pics: 0,
        name: '',
        reviewRating: 0,
        price: 0,
        promo: "",
        warehouses: {});
  }

  CardNotificationState copyWith({
    int? nmId,
    int? price,
    String? promo,
    int? pics,
    String? name,
    double? reviewRating,
    Map<Warehouse, int>? warehouses,
  }) {
    return CardNotificationState(
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
  final CardNotificationNotificationService notificationService;
  final CardNotificationState state;
  CardNotificationViewModel(this.state,
      {required this.notificationService,
      required super.context,
      required super.internetConnectionChecker}) {
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    SqfliteService.printTableContent('notifications');
    SqfliteService.printTableContent('background_messages');
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

  bool isInNotifications(int condition) {
    return _notifications
        .where((element) => element.condition == condition)
        .isNotEmpty;
  }

  void dropNotification(int condition) {
    _notifications.removeWhere((element) => element.condition == condition);
    notifyListeners();
  }

  void addNotification(int condition, [int? value, int? wh]) {
    if (wh != null) {
      _notifications.removeWhere(
          (element) => element.condition == condition && element.wh == wh);
    } else {
      _notifications.removeWhere((element) => element.condition == condition);
    }

    switch (condition) {
      case NotificationConditionConstants.nameChanged:
        _notifications.add(NotificationModel(
            condition: NotificationConditionConstants.nameChanged,
            value: state.name,
            parentId: state.nmId));

        break;
      case NotificationConditionConstants.picsChanged:
        _notifications.add(NotificationModel(
            condition: NotificationConditionConstants.picsChanged,
            value: state.pics.toString(),
            parentId: state.nmId));

        break;
      case NotificationConditionConstants.priceChanged:
        _notifications.add(NotificationModel(
            condition: NotificationConditionConstants.priceChanged,
            value: state.price.toString(),
            parentId: state.nmId));

        break;
      case NotificationConditionConstants.promoChanged:
        _notifications.add(NotificationModel(
            condition: NotificationConditionConstants.promoChanged,
            value: state.promo,
            parentId: state.nmId));

        break;
      case NotificationConditionConstants.reviewRatingChanged:
        _notifications.add(NotificationModel(
            condition: NotificationConditionConstants.reviewRatingChanged,
            value: state.reviewRating.toString(),
            parentId: state.nmId));

        break;
      case NotificationConditionConstants.stocksLessThan:
        final v = state.warehouses.entries
            .fold(0, (previousValue, element) => previousValue + element.value)
            .toString();
        _notifications.add(NotificationModel(
            condition: NotificationConditionConstants.stocksLessThan,
            value: v,
            parentId: state.nmId));

        break;

      case NotificationConditionConstants.stocksInWhLessThan:
      default:
        break;
    }
    notify();
  }
}
