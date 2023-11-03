import 'package:rewild/domain/entities/price_history_model.dart';
import 'package:sqflite/sqflite.dart';

class PriceHistoryDb extends PriceHistoryModel {
  PriceHistoryDb(
      {required super.nmId,
      required super.dt,
      required super.price,
      required super.updateAt});

  static Future<void> createTable(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS price_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nmId INTEGER,
            dt INTEGER,
            price INTEGER,
            updateAt INTEGER
          );
          ''');
  }
}
