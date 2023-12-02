import 'dart:async';

import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/notification.dart';
import 'package:rewild/domain/entities/stream_notification_event.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/notification_advert_screen/notification_advert_view_model.dart';
import 'package:rewild/presentation/background_messages_screen/background_messages_view_model.dart';
import 'package:rewild/presentation/notification_card_screen/notification_card_view_model.dart';
import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';
// import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';

abstract class NotificationServiceNotificationDataProvider {
  Future<Resource<List<ReWildNotificationModel>>> getAll();
  Future<Resource<bool>> save(ReWildNotificationModel notificate);
  Future<Resource<int>> deleteAll(int parentId);
  Future<Resource<List<ReWildNotificationModel>>> getForParent(int parentId);
  Future<Resource<bool>> delete(int parentId, int condition,
      [bool? reusableAlso]);
  Future<Resource<bool>> checkForParent(int id);
}

class NotificationService
    implements
        SingleAdvertStatsViewModelNotificationService,
        SingleCardScreenNotificationService,
        NotificationAdvertNotificationService,
        AllCardsScreenNotificationsService,
        BackgroundMessagesNotificationService,
        NotificationCardNotificationService {
  final NotificationServiceNotificationDataProvider notificationDataProvider;
  final StreamController<StreamNotificationEvent>
      updatedNotificationStreamController;
  NotificationService(
      {required this.notificationDataProvider,
      required this.updatedNotificationStreamController});

  @override
  Future<Resource<bool>> delete(int id, int condition, [bool? isEmpty]) async {
    final resource = await notificationDataProvider.delete(id, condition);
    if (resource is Error) {
      return Resource.error(resource.message!,
          source: runtimeType.toString(),
          name: 'delete',
          args: [id, condition, isEmpty]);
    }
    if (isEmpty != null && isEmpty) {
      updatedNotificationStreamController.add(StreamNotificationEvent(
          parentId: id,
          parentType: condition == NotificationConditionConstants.budgetLessThan
              ? ParentType.advert
              : ParentType.card,
          exists: false));
    }
    return resource;
  }

  @override
  Future<Resource<bool>> checkForParent(int id) async {
    final resource = await notificationDataProvider.checkForParent(id);

    return resource;
  }

  @override
  Future<Resource<void>> addForParent(
      List<ReWildNotificationModel> notifications,
      int parentId,
      bool wasEmpty) async {
    final resource = await notificationDataProvider.deleteAll(parentId);
    if (resource is Error) {
      return Resource.error(resource.message!,
          source: runtimeType.toString(), name: 'deleteAll', args: [parentId]);
    }
    for (final notification in notifications) {
      final resource = await notificationDataProvider.save(notification);
      if (resource is Error) {
        return Resource.error(resource.message!,
            source: runtimeType.toString(), name: 'save', args: [notification]);
      }
    }
    if ((wasEmpty && notifications.isNotEmpty) ||
        (!wasEmpty && notifications.isEmpty)) {
      updatedNotificationStreamController.add(StreamNotificationEvent(
          parentId: parentId,
          parentType: ParentType.card,
          exists: notifications.isNotEmpty));
    }

    return Resource.empty();
  }

  @override
  Future<Resource<List<ReWildNotificationModel>>> getForParent(
      int parentId) async {
    final resource = await notificationDataProvider.getForParent(parentId);
    if (resource is Error) {
      return Resource.error(resource.message!,
          source: runtimeType.toString(),
          name: 'getForParent',
          args: [parentId]);
    }
    if (resource is Empty) {
      return Resource.success([]);
    }
    return resource;
  }

  @override
  Future<Resource<List<ReWildNotificationModel>>> getAll() async {
    final resource = await notificationDataProvider.getAll();
    if (resource is Error) {
      return Resource.error(resource.message!,
          source: runtimeType.toString(), name: 'getAll', args: []);
    }

    if (resource is Empty) {
      return Resource.success([]);
    }

    return resource;
  }
}
