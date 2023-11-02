import 'package:sqflite/sqflite.dart';
import 'package:rewild/domain/entities/seller_model.dart';

class SellerDb extends SellerModel {
  SellerDb(
      {required super.supplierId,
      required super.name,
      super.fineName,
      super.ogrn,
      super.trademark,
      super.legalAddress});

  static Future<void> createTable(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS sellers (
            supplierId INTEGER PRIMARY KEY,
            name TEXT,
            fineName TEXT,
            ogrn TEXT,
            trademark TEXT,
            legalAddress TEXT
          );
          ''');
  }
}
