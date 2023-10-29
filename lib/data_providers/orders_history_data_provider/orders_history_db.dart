import 'package:sqflite/sqflite.dart';

class OrdersHistoryDb {
  final int nmId;
  final int qty;
  final bool highBuyout;
  final DateTime updatetAt;

  OrdersHistoryDb(
      {required this.nmId,
      required this.qty,
      required this.highBuyout,
      required this.updatetAt});

  static Future<void> createTable(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS orders_history (
            nmId INTEGER NOT NULL PRIMARY KEY,
            qty INTEGER,
            highBuyout INTEGER,
            updatetAt INTEGER
          );''');
  }
}
