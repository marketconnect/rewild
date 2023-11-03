import 'package:sqflite/sqflite.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';

class CardOfProductDb extends CardOfProductModel {
  CardOfProductDb(
      {required super.nmId,
      required super.name,
      super.img,
      super.sellerId,
      super.tradeMark,
      super.subjectId,
      super.subjectParentId,
      super.brand,
      super.supplierId,
      super.basicPriceU,
      super.pics,
      super.rating,
      super.reviewRating,
      super.feedbacks,
      super.promoTextCard});

  static Future<void> createTable(Database db) async {
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS cards (
        nmId INTEGER PRIMARY KEY,
        name TEXT,
        img TEXT,
        sellerId INTEGER,
        tradeMark TEXT,
        subjectId INTEGER,
        subjectParentId INTEGER,
        brand TEXT,
        supplierId INTEGER,
        basicPriceU INTEGER,
        pics INTEGER,
        rating INTEGER,
        reviewRating REAL,
        feedbacks INTEGER,
        promoTextCard TEXT,
        createdAt INTEGER
      )
      ''',
    );
  }
}
