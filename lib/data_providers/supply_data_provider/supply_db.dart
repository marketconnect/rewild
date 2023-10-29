import 'package:sqflite/sqflite.dart';

import 'package:rewild/domain/entities/supply_model.dart';

class SupplyDb extends SupplyModel {
  SupplyDb(
      {required super.wh,
      required super.nmId,
      required super.sizeOptionId,
      required super.lastStocks,
      required super.qty});

  // final int wh;
  // final int nmId;
  // final int sizeOptionId;
  // final int qty;

  // SupplyDb({
  //   required this.wh,
  //   required this.nmId,
  //   required this.sizeOptionId,
  //   required this.qty,
  // });

  static Future<void> createTable(Database db) async {
    await db.execute('''
        CREATE TABLE IF NOT EXISTS supplies (
          wh INTEGER,
          nmId INTEGER,
          sizeOptionId INTEGER,
          qty INTEGER,
          lastStocks INTEGER,
          UNIQUE(nmId, wh, sizeOptionId) ON CONFLICT REPLACE
        );''');
  }
}
