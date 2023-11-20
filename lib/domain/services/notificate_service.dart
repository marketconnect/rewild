import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/notification.dart';
import 'package:rewild/presentation/card_notification_screen/card_notification_view_model.dart';
import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';

abstract class NotificationServiceNotificationDataProvider {
  Future<Resource<List<NotificationModel>>> getAll();
  Future<Resource<void>> save(NotificationModel notificate);
  Future<Resource<void>> deleteAll(int parentId);
  Future<Resource<List<NotificationModel>>> getForParent(int parentId);
}

class NotificationService
    implements
        SingleAdvertStatsViewModelNotificationService,
        CardNotificationNotificationService {
  final NotificationServiceNotificationDataProvider notificationDataProvider;
  NotificationService({required this.notificationDataProvider});

  @override
  Future<Resource<void>> addNotification(NotificationModel notificate) async {
    final resource = await notificationDataProvider.save(notificate);
    if (resource is Error) {
      return Resource.error(resource.message!);
    }

    return resource;
  }

  @override
  Future<Resource<void>> addForParent(
      List<NotificationModel> notifications) async {
    final parentId = notifications.first.parentId;

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
  Future<Resource<List<NotificationModel>>> getForParent(int parentId) async {
    final resource = await notificationDataProvider.getForParent(parentId);
    if (resource is Error) {
      return Resource.error(resource.message!);
    }
    if (resource is Empty) {
      return Resource.success([]);
    }
    return resource;
  }

  @override
  Future<Resource<List<NotificationModel>>> getAll() async {
    final resource = await notificationDataProvider.getAll();
    if (resource is Error) {
      return Resource.error(resource.message!);
    }

    if (resource is Empty) {
      return Resource.success([]);
    }

    return resource;
  }
}
