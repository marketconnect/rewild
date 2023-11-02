import 'package:sqflite/sqlite_api.dart';

class FilterDb {
  final int id;
  final String sectionName;
  final int itemId;
  final String itemName;

  FilterDb(
      {required this.id,
      required this.sectionName,
      required this.itemId,
      required this.itemName});

  static Future<void> createTable(Database db) async {
    await db.execute(
      '''
          CREATE TABLE IF NOT EXISTS filters (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            sectionName TEXT,
            itemId INTEGER,
            itemName TEXT,
            UNIQUE(sectionName, itemId) ON CONFLICT REPLACE
          );
          ''',
    );
  }
}
