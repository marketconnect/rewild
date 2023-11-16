import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/notificate.dart';

class NotificateDataProvider {
  const NotificateDataProvider();

  Future<Resource<void>> save(NotificateModel notificate) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawInsert(
          "INSERT INTO notificate (parentId, property, minValue, maxValue, changed) VALUES (?, ?, ?, ?, ?)",
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

  Future<Resource<List<NotificateModel>>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final notificates = await db.rawQuery('SELECT * FROM notificate');
      return Resource.success(
          notificates.map((e) => NotificateModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  Future<Resource<void>> delete(NotificateModel notificate) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawDelete(
          "DELETE FROM notificate WHERE parentId = ? AND property = ?", [
        notificate.parentId,
        notificate.property,
      ]);
      return Resource.empty();
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  static Future<Resource<List<NotificateModel>>> getAllInBackground() async {
    try {
      final db = await SqfliteService().database;
      final notificates = await db.rawQuery('SELECT * FROM notificate');
      return Resource.success(
          notificates.map((e) => NotificateModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error(e.toString());
    }
  }
}
