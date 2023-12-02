import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/notification.dart';
import 'package:rewild/domain/services/notification_service.dart';

class NotificationDataProvider
    implements NotificationServiceNotificationDataProvider {
  const NotificationDataProvider();

  @override
  Future<Resource<bool>> save(ReWildNotificationModel notificate) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert(
          "INSERT INTO notifications (parentId, condition, value, sizeId, wh, reusable) VALUES (?, ?, ?, ?, ?, ?)",
          [
            notificate.parentId,
            notificate.condition,
            notificate.value,
            notificate.sizeId,
            notificate.wh,
            notificate.reusable
          ]);
      return Resource.success(id > 0);
    } catch (e) {
      return Resource.error(e.toString(),
          source: runtimeType.toString(), name: "save", args: [notificate]);
    }
  }

  @override
  Future<Resource<List<ReWildNotificationModel>>> getForParent(
      int parentId) async {
    try {
      final db = await SqfliteService().database;
      final notificates = await db.rawQuery(
          'SELECT * FROM notifications WHERE parentId = ?', [parentId]);

      if (notificates.isEmpty) {
        return Resource.success([]);
      }
      return Resource.success(
          notificates.map((e) => ReWildNotificationModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error(e.toString(),
          source: runtimeType.toString(),
          name: "getForParent",
          args: [parentId]);
    }
  }

  @override
  Future<Resource<List<ReWildNotificationModel>>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final notifications = await db.rawQuery('SELECT * FROM notifications');
      if (notifications.isEmpty) {
        return Resource.empty();
      }
      return Resource.success(notifications
          .map((e) => ReWildNotificationModel.fromMap(e))
          .toList());
    } catch (e) {
      return Resource.error(e.toString(),
          source: runtimeType.toString(), name: "getAll", args: []);
    }
  }

  @override
  Future<Resource<int>> deleteAll(int parentId) async {
    try {
      final db = await SqfliteService().database;
      final numberOfChangesMade =
          await db.rawDelete("DELETE FROM notifications WHERE parentId = ?", [
        parentId,
      ]);
      return Resource.success(numberOfChangesMade);
    } catch (e) {
      return Resource.error(e.toString(),
          source: runtimeType.toString(), name: "deleteAll", args: [parentId]);
    }
  }

  @override
  Future<Resource<bool>> delete(int parentId, int condition,
      [bool? reusableAlso]) async {
    try {
      final db = await SqfliteService().database;
      if (reusableAlso == true) {
        final numberOfChangesMade = await db.rawDelete(
            "DELETE FROM notifications WHERE parentId = ? AND condition = ?",
            [parentId, condition]);
        return Resource.success(numberOfChangesMade == 1);
      }

      final _ = await db.rawDelete(
          "DELETE FROM notifications WHERE parentId = ? AND condition = ? AND reusable != 1",
          [parentId, condition]);
      return Resource.success(true);
    } catch (e) {
      return Resource.error(e.toString(),
          source: runtimeType.toString(),
          name: "delete",
          args: [parentId, condition]);
    }
  }

  static Future<Resource<List<ReWildNotificationModel>>>
      getAllInBackground() async {
    try {
      final db = await SqfliteService().database;
      final notifications = await db.rawQuery('SELECT * FROM notifications');

      if (notifications.isEmpty) {
        Resource.success([]);
      }
      return Resource.success(notifications
          .map((e) => ReWildNotificationModel.fromMap(e))
          .toList());
    } catch (e) {
      return Resource.error(e.toString(),
          source: "NotificationDataProvider",
          name: "getAllInBackground",
          args: []);
    }
  }

  static Future<Resource<bool>> saveInBackground(
      ReWildNotificationModel notificate) async {
    try {
      final db = await SqfliteService().database;
      final lastId = await db.rawInsert(
          "INSERT INTO notifications (parentId, condition, value, sizeId, wh) VALUES (?, ?, ?, ?, ?)",
          [
            notificate.parentId,
            notificate.condition,
            notificate.value,
            notificate.sizeId,
            notificate.wh
          ]);
      return Resource.success(lastId > 0);
    } catch (e) {
      return Resource.error(e.toString(),
          source: "NotificationDataProvider",
          name: "saveInBackground",
          args: [notificate]);
    }
  }

  @override
  Future<Resource<bool>> checkForParent(int id) async {
    try {
      final db = await SqfliteService().database;
      final notifications = await db
          .rawQuery('SELECT * FROM notifications WHERE parentId = ?', [id]);
      if (notifications.isEmpty) {
        return Resource.success(false);
      }
      return Resource.success(true);
    } catch (e) {
      return Resource.error(e.toString(),
          source: runtimeType.toString(), name: "checkForParent", args: [id]);
    }
  }
}
