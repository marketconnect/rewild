import 'package:rewild/domain/entities/notification.dart';
import 'package:sqflite/sqflite.dart';

class NotificationDb extends NotificationModel {
  NotificationDb(
      {required super.parentId,
      required super.condition,
      required super.value,
      super.reusable,
      super.sizeId,
      super.wh});

  static Future<void> createTable(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS notifications (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            parentId INTEGER,
            condition INTEGER,
            value TEXT,
            sizeId INTEGER,
            wh INTEGER,
            reusable INTEGER,
            UNIQUE(parentId, condition) ON CONFLICT REPLACE
          );    
          ''');
  }
}
