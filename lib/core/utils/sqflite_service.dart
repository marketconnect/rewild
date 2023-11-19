import 'package:flutter/material.dart';
import 'package:rewild/core/utils/strings.dart';
import 'package:rewild/data_providers/advert_stat_data_provider/advert_stat_db.dart';

import 'package:rewild/data_providers/card_of_product_data_provider/card_of_product_db.dart';
import 'package:rewild/data_providers/filter_data_provider/filter_db.dart';
import 'package:rewild/data_providers/notificate_data_provider/notification_db.dart';

import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:rewild/data_providers/commission_data_provider/commission_db.dart';
import 'package:rewild/data_providers/group_data_provider/group_db.dart';
import 'package:rewild/data_providers/initial_stocks_data_provider/initial_stocks_db.dart';
import 'package:rewild/data_providers/orders_history_data_provider/orders_history_db.dart';
import 'package:rewild/data_providers/seller_data_provider/seller_db.dart';
import 'package:rewild/data_providers/stock_data_provider.dart/stock_db.dart';
import 'package:rewild/data_providers/supply_data_provider/supply_db.dart';

class SqfliteService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    const name = 'rewild.db';
    final dbPath = await getDatabasesPath();
    return join(dbPath, name);
  }

  Future<Database> _initialize() async {
    final path = await fullPath;

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );
    return database;
  }

  Future<void> create(Database db, int version) async {
    await CardOfProductDb.createTable(db);
    await GroupDb.createTable(db);
    await StocksDB.createTable(db);
    await InitialStocksDb.createTable(db);
    await SellerDb.createTable(db);
    await CommissionDb.createTable(db);
    await SupplyDb.createTable(db);
    await OrdersHistoryDb.createTable(db);
    await FilterDb.createTable(db);
    await AdvertStatDb.createTable(db);
    await NotificationDb.createTable(db);
  }

  static Future<void> printTableContent(String tableName) async {
    final db = await SqfliteService().database;
    final List<Map<String, dynamic>> rows = await db.query(tableName);
    for (final row in rows) {
      debugPrint(row.toString());
    }
    debugPrint('${tableName.capitalize()} count: ${rows.length}');
  }
}
