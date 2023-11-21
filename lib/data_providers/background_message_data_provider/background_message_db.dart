import 'package:rewild/domain/entities/background_message.dart';
import 'package:sqflite/sqflite.dart';

class BackgroundMessageDb extends BackgroundMessage {
  BackgroundMessageDb(
      {required super.header,
      required super.message,
      required super.dateTime,
      required super.subject,
      required super.id,
      required super.condition});

  static Future<void> createTable(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS background_messages (
            header TEXT,
            message TEXT,
            dateTime INTEGER,
            subject INTEGER,
            id INTEGER,
            condition INTEGER
          )
          ''');
  }
}
