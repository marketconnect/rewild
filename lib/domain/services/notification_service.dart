import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/notification.dart';
import 'package:rewild/presentation/notification_advert_screen/notification_advert_view_model.dart';
import 'package:rewild/presentation/background_messages_screen/background_messages_view_model.dart';
import 'package:rewild/presentation/notification_card_screen/notification_card_view_model.dart';
import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';

abstract class NotificationServiceNotificationDataProvider {
  Future<Resource<List<ReWildNotificationModel>>> getAll();
  Future<Resource<bool>> save(ReWildNotificationModel notificate);
  Future<Resource<int>> deleteAll(int parentId);
  Future<Resource<List<ReWildNotificationModel>>> getForParent(int parentId);
  Future<Resource<bool>> delete(int parentId, int condition,
      [bool? reusableAlso]);
}

class NotificationService
    implements
        SingleAdvertStatsViewModelNotificationService,
        NotificationAdvertNotificationService,
        BackgroundMessagesNotificationService,
        NotificationCardNotificationService {
  final NotificationServiceNotificationDataProvider notificationDataProvider;
  NotificationService({required this.notificationDataProvider});

  @override
  Future<Resource<bool>> delete(int id, int condition) async {
    final resource = await notificationDataProvider.delete(id, condition);
    if (resource is Error) {
      return Resource.error(resource.message!);
    }

    return resource;
  }

  @override
  Future<Resource<void>> addNotification(
      ReWildNotificationModel notificate) async {
    final resource = await notificationDataProvider.save(notificate);
    if (resource is Error) {
      return Resource.error(resource.message!);
    }

    return resource;
  }

  @override
  Future<Resource<void>> addForParent(
      List<ReWildNotificationModel> notifications, int parentId) async {
    final resource = await notificationDataProvider.deleteAll(parentId);
    if (resource is Error) {
      return Resource.error(resource.message!);
    }
    for (final notification in notifications) {
      final resource = await notificationDataProvider.save(notification);
      if (resource is Error) {
        return Resource.error(resource.message!);
      }
    }

    return Resource.empty();
  }

  @override
  Future<Resource<List<ReWildNotificationModel>>> getForParent(
      int parentId) async {
    final resource = await notificationDataProvider.getForParent(parentId);
    if (resource is Error) {
      return Resource.error(resource.message!);
    }
    if (resource is Empty) {
      return Resource.success([]);
    }
    return resource;
  }

  // @override
  // Future<Resource<List<NotificationModel>>> getAll() async {
  //   final resource = await notificationDataProvider.getAll();
  //   if (resource is Error) {
  //     return Resource.error(resource.message!);
  //   }

  //   if (resource is Empty) {
  //     return Resource.success([]);
  //   }

  //   return resource;
  // }
}
