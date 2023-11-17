import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/notificate.dart';
import 'package:rewild/domain/services/notificate_service.dart';

class NotificationDataProvider
    implements NotificationServiceNotificationDataProvider {
  const NotificationDataProvider();

  @override
  Future<Resource<void>> save(NotificationModel notificate) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawInsert(
          "INSERT INTO notification (parentId, property, minValue, maxValue, changed) VALUES (?, ?, ?, ?, ?)",
          [
            notificate.parentId,
            notificate.property,
            notificate.minValue ?? 0,
            notificate.maxValue ?? 0,
            notificate.changed ?? 0
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
          'SELECT * FROM notification WHERE parentId = ?', [parentId]);

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
      final notifications = await db.rawQuery('SELECT * FROM notification');
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
  Future<Resource<void>> delete(int parentId, String property) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawDelete(
          "DELETE FROM notification WHERE parentId = ? AND property = ?", [
        parentId,
        property,
      ]);
      return Resource.empty();
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  static Future<Resource<List<NotificationModel>>> getAllInBackground() async {
    try {
      final db = await SqfliteService().database;
      final notifications = await db.rawQuery('SELECT * FROM notification');

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
