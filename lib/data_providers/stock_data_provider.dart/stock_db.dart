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

  // final int id;
  // final int wh;
  // final String name;
  // final int sizeOptionId;
  // final int qty;
  // final int nmId;

  // StocksDB({
  //   this.id = 0,
  //   required this.nmId,
  //   required this.wh,
  //   required this.name,
  //   required this.sizeOptionId,
  //   required this.qty,
  // });

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

  // static Future<void> printTableContent(Database db) async {
  //   final List<Map<String, dynamic>> rows = await db.query('stocks');
  //   for (final row in rows) {
  //     print(row);
  //   }
  //   print("Stocks count: ${rows.length}");
  // }
}
