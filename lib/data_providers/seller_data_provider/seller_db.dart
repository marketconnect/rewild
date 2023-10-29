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

  // final int supplierId;
  // final String name;
  // String? fineName;
  // String? ogrn;
  // String? trademark;
  // String? legalAddress;

  // SellerDb(
  //     {required this.supplierId,
  //     required this.name,
  //     this.fineName,
  //     this.ogrn,
  //     this.trademark,
  //     this.legalAddress});

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

  // static Future<void> printTableContent(Database db) async {
  //   final List<Map<String, dynamic>> rows = await db.query('sellers');
  //   for (final row in rows) {
  //     print(row);
  //   }
  // }
}
