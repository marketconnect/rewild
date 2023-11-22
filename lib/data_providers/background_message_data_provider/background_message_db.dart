import 'package:rewild/domain/entities/background_message.dart';
import 'package:sqflite/sqflite.dart';

class BackgroundMessageDb extends BackgroundMessage {
  BackgroundMessageDb(
      {required super.dateTime,
      required super.subject,
      required super.id,
      required super.condition,
      required super.value});

  static Future<void> createTable(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS background_messages (
            dateTime INTEGER,
            subject INTEGER,
            id INTEGER,
            value TEXT,
            condition INTEGER,
            UNIQUE(id, subject, condition) ON CONFLICT REPLACE
          )
          ''');
  }
}
