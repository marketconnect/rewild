import 'package:rewild/domain/entities/notificate.dart';
import 'package:sqflite/sqflite.dart';

class NotificationDb extends NotificationModel {
  NotificationDb(
      {required super.parentId,
      required super.property,
      super.minValue,
      super.maxValue,
      super.changed});

  static Future<void> createTable(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS notification (
            parentId INTEGER,
            property TEXT,
            minValue REAL,
            maxValue REAL,
            changed INTEGER,
            UNIQUE(parentId, property, minValue, maxValue, changed) ON CONFLICT REPLACE
          )
          ''');
  }
}
