import 'package:sqflite/sqflite.dart';
import 'package:rewild/domain/entities/stocks_model.dart';

class StocksDB extends StocksModel {
  StocksDB({
    required super.id,
    required super.wh,
    required super.name,
    required super.sizeOptionId,
    required super.qty,
    required super.nmId,
  });

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stocks (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        wh INTEGER,
        name TEXT,
        sizeOptionId INTEGER,
        qty INTEGER,
        nmId INTEGER,
        UNIQUE(nmId, wh, sizeOptionId) ON CONFLICT REPLACE
      );''');
  }
}
