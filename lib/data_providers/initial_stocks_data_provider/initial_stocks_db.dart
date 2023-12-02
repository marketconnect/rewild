import 'package:sqflite/sqflite.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';

class InitialStocksDb extends InitialStockModel {
  InitialStocksDb(
      {required super.id,
      required super.date,
      required super.nmId,
      required super.wh,
      required super.name,
      required super.sizeOptionId,
      required super.qty});

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS initial_stocks (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        date INTEGER,
        sizeOptionId INTEGER,
        nmId INTEGER,
        wh INTEGER,
        name TEXT,
        qty INTEGER,
        UNIQUE(nmId, wh, sizeOptionId) ON CONFLICT REPLACE
      );
      ''');
  }

  // static Future<void> printTableContent(Database db, int nmId) async {
  //   final List<Map<String, dynamic>> rows = await db.query(
  //     'initial_stocks',
  //     where: 'nmId = ?',
  //     whereArgs: [nmId],
  //   );
  //   for (final row in rows) {
  //     print(row);
  //   }
  //   print('Initial Stocks count: ${rows.length}');
  // }
}
