import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/notificate.dart';
import 'package:rewild/presentation/auto_advert_screen/auto_advert_view_model.dart';

abstract class NotificationServiceNotificationDataProvider {
  Future<Resource<List<NotificationModel>>> getAll();
  Future<Resource<void>> save(NotificationModel notificate);
  Future<Resource<void>> delete(int parentId, String property);
  Future<Resource<List<NotificationModel>>> getForParent(int parentId);
}

class NotificationService implements AutoAdvertViewModelNotificationService {
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

  @override
  Future<Resource<void>> delete(int parentId, String property) async {
    final resource = await notificationDataProvider.delete(parentId, property);
    if (resource is Error) {
      return Resource.error(resource.message!);
    }

    return resource;
  }
}
