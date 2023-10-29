import 'package:sqflite/sqflite.dart';

class GroupDb {
  int id;
  final String name;
  final int bgColor;
  final int fontColor;
  final int nmId;
  GroupDb({
    required this.id,
    required this.name,
    required this.bgColor,
    required this.fontColor,
    required this.nmId,
  });

  static Future<void> createTable(Database db) async {
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS groups (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        bgColor INTEGER,
        fontColor INTEGER,
        nmId INTEGER,
        UNIQUE(nmId, name) ON CONFLICT REPLACE
      );
      ''',
    );
  }
}
