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

  // int nmId;

  // String name;

  // String? img;

  // int? sellerId;

  // String? tradeMark;

  // int? subjectId;

  // int? subjectParentId;

  // String? brand;

  // int? supplierId;

  // int? basicPriceU;

  // int? pics;

  // int? rating;

  // double? reviewRating;

  // int? feedbacks;

  // String? promoTextCard;

  // CardOfProductDb({
  //   required this.nmId,
  //   required this.name,
  //   this.img,
  //   this.sellerId,
  //   this.tradeMark,
  //   this.subjectId,
  //   this.subjectParentId,
  //   this.brand,
  //   this.supplierId,
  //   this.basicPriceU,
  //   this.pics,
  //   this.rating,
  //   this.reviewRating,
  //   this.feedbacks,
  //   this.promoTextCard,
  // });

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
        promoTextCard TEXT
      )
      ''',
    );
  }

  // static Future<void> printTableContent(Database db) async {
  //   final List<Map<String, dynamic>> rows = await db.query('cards');
  //   for (final row in rows) {
  //     print(row);
  //   }
  //   print('Cards count: ${rows.length}');
  // }
}
