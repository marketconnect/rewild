import 'package:rewild/domain/entities/notificate.dart';
import 'package:sqflite/sqflite.dart';

class NotificateDb extends NotificateModel {
  NotificateDb(
      {required super.parentId,
      required super.property,
      super.minValue,
      super.maxValue,
      super.changed});

  static Future<void> createTable(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS notificate (
            parentId INTEGER,
            property TEXT,
            minValue REAL,
            maxValue REAL,
            changed INTEGER
          )
          ''');
  }
}
