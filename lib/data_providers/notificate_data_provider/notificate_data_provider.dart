import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/notification.dart';
import 'package:rewild/domain/services/notificate_service.dart';

class NotificationDataProvider
    implements NotificationServiceNotificationDataProvider {
  const NotificationDataProvider();

  @override
  Future<Resource<void>> save(NotificationModel notificate) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawInsert(
          "INSERT INTO notifications (parentId, condition, value, sizeId, wh) VALUES (?, ?, ?, ?, ?)",
          [
            notificate.parentId,
            notificate.condition,
            notificate.value,
            notificate.sizeId,
            notificate.wh
          ]);
      return Resource.empty();
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  @override
  Future<Resource<List<NotificationModel>>> getForParent(int parentId) async {
    try {
      final db = await SqfliteService().database;
      final notificates = await db.rawQuery(
          'SELECT * FROM notifications WHERE parentId = ?', [parentId]);

      if (notificates.isEmpty) {
        return Resource.empty();
      }
      return Resource.success(
          notificates.map((e) => NotificationModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  @override
  Future<Resource<List<NotificationModel>>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final notifications = await db.rawQuery('SELECT * FROM notifications');
      if (notifications.isEmpty) {
        return Resource.empty();
      }
      return Resource.success(
          notifications.map((e) => NotificationModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  @override
  Future<Resource<void>> delete(
      int parentId, String property, String condition) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawDelete(
          "DELETE FROM notifications WHERE parentId = ? AND condition = ?",
          [parentId, condition]);
      return Resource.empty();
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  static Future<Resource<List<NotificationModel>>> getAllInBackground() async {
    try {
      final db = await SqfliteService().database;
      final notifications = await db.rawQuery('SELECT * FROM notifications');

      if (notifications.isEmpty) {
        Resource.success([]);
      }
      return Resource.success(
          notifications.map((e) => NotificationModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error(e.toString());
    }
  }
}
