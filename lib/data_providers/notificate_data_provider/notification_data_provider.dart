import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/notification.dart';
import 'package:rewild/domain/services/notification_service.dart';

class NotificationDataProvider
    implements NotificationServiceNotificationDataProvider {
  const NotificationDataProvider();

  @override
  Future<Either<RewildError, bool>> save(
      ReWildNotificationModel notificate) async {
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
      return right(id > 0);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "save", args: [notificate]));
    }
  }

  @override
  Future<Either<RewildError, List<ReWildNotificationModel>>> getForParent(
      int parentId) async {
    try {
      final db = await SqfliteService().database;
      final notificates = await db.rawQuery(
          'SELECT * FROM notifications WHERE parentId = ?', [parentId]);

      if (notificates.isEmpty) {
        return right([]);
      }
      return right(
          notificates.map((e) => ReWildNotificationModel.fromMap(e)).toList());
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(),
          name: "getForParent",
          args: [parentId]));
    }
  }

  @override
  Future<Either<RewildError, List<ReWildNotificationModel>?>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final notifications = await db.rawQuery('SELECT * FROM notifications');
      if (notifications.isEmpty) {
        return right(null);
      }
      return right(notifications
          .map((e) => ReWildNotificationModel.fromMap(e))
          .toList());
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "getAll", args: []));
    }
  }

  @override
  Future<Either<RewildError, int>> deleteAll(int parentId) async {
    try {
      final db = await SqfliteService().database;
      final numberOfChangesMade =
          await db.rawDelete("DELETE FROM notifications WHERE parentId = ?", [
        parentId,
      ]);
      return right(numberOfChangesMade);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "deleteAll", args: [parentId]));
    }
  }

  @override
  Future<Either<RewildError, bool>> delete(int parentId, int condition,
      [bool? reusableAlso]) async {
    try {
      final db = await SqfliteService().database;
      if (reusableAlso == true) {
        final numberOfChangesMade = await db.rawDelete(
            "DELETE FROM notifications WHERE parentId = ? AND condition = ?",
            [parentId, condition]);
        return right(numberOfChangesMade == 1);
      }

      final _ = await db.rawDelete(
          "DELETE FROM notifications WHERE parentId = ? AND condition = ? AND reusable != 1",
          [parentId, condition]);
      return right(true);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(),
          name: "delete",
          args: [parentId, condition]));
    }
  }

  static Future<Either<RewildError, List<ReWildNotificationModel>>>
      getAllInBackground() async {
    try {
      final db = await SqfliteService().database;
      final notifications = await db.rawQuery('SELECT * FROM notifications');

      if (notifications.isEmpty) {
        right([]);
      }
      return right(notifications
          .map((e) => ReWildNotificationModel.fromMap(e))
          .toList());
    } catch (e) {
      return left(RewildError(e.toString(),
          source: "NotificationDataProvider",
          name: "getAllInBackground",
          args: []));
    }
  }

  static Future<Either<RewildError, bool>> saveInBackground(
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
      return right(lastId > 0);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: "NotificationDataProvider",
          name: "saveInBackground",
          args: [notificate]));
    }
  }

  @override
  Future<Either<RewildError, bool>> checkForParent(int id) async {
    try {
      final db = await SqfliteService().database;
      final notifications = await db
          .rawQuery('SELECT * FROM notifications WHERE parentId = ?', [id]);
      if (notifications.isEmpty) {
        return right(false);
      }
      return right(true);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "checkForParent", args: [id]));
    }
  }
}
