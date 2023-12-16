import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/services/all_cards_filter_service.dart';
import 'package:rewild/domain/services/card_of_product_service.dart';
import 'package:rewild/domain/services/update_service.dart';

class CardOfProductDataProvider
    implements
        CardOfProductServiceCardOfProductDataProvider,
        UpdateServiceCardOfProductDataProvider,
        AllCardsFilterServiceCardsOfProductDataProvider {
  const CardOfProductDataProvider();
  @override
  Future<Either<RewildError, int>> insertOrUpdate(
      {required CardOfProductModel card}) async {
    try {
      final numOfUpdatedResource = await _update(card: card);
      if (numOfUpdatedResource.isLeft()) {
        return numOfUpdatedResource;
      }

      final numOfUpdated = numOfUpdatedResource.getRight();
      if (numOfUpdated.getOrElse(() => 0) == 0) {
        return _insert(card: card);
      }

      return numOfUpdatedResource;
    } catch (e) {
      return left(RewildError(
        'Не удалось обновить карточку в памяти телефона: ${e.toString()}',
        source: runtimeType.toString(),
        name: "insertOrUpdate",
        args: [card],
      ));
    }
  }

  @override
  Future<Either<RewildError, String>> getImage({required int id}) async {
    try {
      final db = await SqfliteService().database;
      final image =
          await db.rawQuery('SELECT img FROM cards WHERE nmId = ?', [id]);
      if (image.isEmpty) {
        return right("");
      }
      return right(image.first['img'].toString());
    } catch (e) {
      return left(RewildError(
        e.toString(),
        source: runtimeType.toString(),
        name: "getImage",
        args: [id],
      ));
    }
  }

  Future<Either<RewildError, int>> _insert(
      {required CardOfProductModel card}) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert('''
      INSERT INTO cards(
        nmId,
        name,
        img,
        sellerId,
        tradeMark,
        subjectId,
        subjectParentId,
        brand,
        supplierId,
        basicPriceU,
        pics,
        rating,
        reviewRating,
        feedbacks,
        promoTextCard,
        createdAt
      ) VALUES(
        ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
      )''', [
        card.nmId,
        card.name,
        card.img,
        card.sellerId,
        card.tradeMark,
        card.subjectId,
        card.subjectParentId,
        card.brand,
        card.supplierId,
        card.basicPriceU,
        card.pics,
        card.rating,
        card.reviewRating,
        card.feedbacks,
        card.promoTextCard,
        DateTime.now().millisecondsSinceEpoch
      ]);
      return right(id);
    } catch (e) {
      return left(RewildError(
        'Failed to add card to phone memory: ${e.toString()}',
        source: runtimeType.toString(),
        name: "insert",
        args: [card],
      ));
    }
  }

  @override
  Future<Either<RewildError, int>> delete({required int id}) async {
    try {
      final db = await SqfliteService().database;
      final resId =
          await db.rawDelete('DELETE FROM cards WHERE nmId = ?', [id]);

      return right(resId);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        source: runtimeType.toString(),
        name: "delete",
        args: [id],
      ));
    }
  }

  @override
  Future<Either<RewildError, CardOfProductModel>> get(
      {required int nmId}) async {
    try {
      final db = await SqfliteService().database;
      final card =
          await db.rawQuery('SELECT * FROM cards WHERE nmId = ?', [nmId]);
      return right(CardOfProductModel.fromMap(card.first));
    } catch (e) {
      return left(RewildError(
        e.toString(),
        source: runtimeType.toString(),
        name: "get",
        args: [nmId],
      ));
    }
  }

  Future<Either<RewildError, int>> _update(
      {required CardOfProductModel card}) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawUpdate(
        '''
  UPDATE cards
  SET
    name = ?,
    sellerId = ?,
    tradeMark = ?,
    subjectId = ?,
    subjectParentId = ?,
    brand = ?,
    supplierId = ?,
    basicPriceU = ?,
    pics = ?,
    rating = ?,
    reviewRating = ?,
    feedbacks = ?,
    promoTextCard = ?
  WHERE
    nmId = ?
  ''',
        [
          card.name,
          card.sellerId,
          card.tradeMark,
          card.subjectId,
          card.subjectParentId,
          card.brand,
          card.supplierId,
          card.basicPriceU,
          card.pics,
          card.rating,
          card.reviewRating,
          card.feedbacks,
          card.promoTextCard,
          card.nmId
        ],
      );
      return right(id);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        source: runtimeType.toString(),
        name: "update",
        args: [card],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]) async {
    try {
      final db = await SqfliteService().database;
      if (nmIds != null) {
        final cards = await db.rawQuery(
          '''
            SELECT * FROM cards
            WHERE nmId IN (${nmIds.map((e) => '?').join(',')})
          ''',
          nmIds,
        );

        return right(
          cards.map((e) => CardOfProductModel.fromMap(e)).toList(),
        );
      }

      final cards = await db.rawQuery(
        '''
          SELECT * FROM cards
        ''',
      );
      return right(cards.map((e) => CardOfProductModel.fromMap(e)).toList());
    } catch (e) {
      return left(RewildError(
        'Не удалось получить карточки из памяти телефона: ${e.toString()}',
        source: runtimeType.toString(),
        name: "getAll",
        args: [nmIds],
      ));
    }
  }

  static Future<Either<RewildError, List<CardOfProductModel>>>
      getAllInBackGround([List<int>? nmIds]) async {
    try {
      final db = await SqfliteService().database;
      if (nmIds != null) {
        final cards = await db.rawQuery(
          '''
            SELECT * FROM cards
            WHERE nmId IN (${nmIds.map((e) => '?').join(',')})
          ''',
          nmIds,
        );

        return right(
          cards.map((e) => CardOfProductModel.fromMap(e)).toList(),
        );
      }

      final cards = await db.rawQuery(
        '''
          SELECT * FROM cards
        ''',
      );
      return right(cards.map((e) => CardOfProductModel.fromMap(e)).toList());
    } catch (e) {
      return left(RewildError(
        'Не удалось получить карточки из памяти телефона: ${e.toString()}',
        source: "CardOfProductDataProvider",
        name: "getAll",
        args: [nmIds],
      ));
    }
  }

  static Future<Either<RewildError, int>> updateInBackGround(
      {required CardOfProductModel card}) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawUpdate(
        '''
  UPDATE cards
  SET
    name = ?,
    sellerId = ?,
    tradeMark = ?,
    subjectId = ?,
    subjectParentId = ?,
    brand = ?,
    supplierId = ?,
    basicPriceU = ?,
    pics = ?,
    rating = ?,
    reviewRating = ?,
    feedbacks = ?,
    promoTextCard = ?
  WHERE
    nmId = ?
  ''',
        [
          card.name,
          card.sellerId,
          card.tradeMark,
          card.subjectId,
          card.subjectParentId,
          card.brand,
          card.supplierId,
          card.basicPriceU,
          card.pics,
          card.rating,
          card.reviewRating,
          card.feedbacks,
          card.promoTextCard,
          card.nmId
        ],
      );
      return right(id);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        source: "CardOfProductDataProvider",
        name: "update",
        args: [card],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<CardOfProductModel>>> getAllBySupplierId(
      {required int supplierId}) async {
    try {
      final db = await SqfliteService().database;
      final cards = await db.rawQuery(
        '''
          SELECT * FROM cards
          WHERE supplierId = ?
        ''',
        [supplierId],
      );

      return right(
        cards.map((e) => CardOfProductModel.fromMap(e)).toList(),
      );
    } catch (e) {
      return left(RewildError(
        e.toString(),
        source: runtimeType.toString(),
        name: "getAllBySupplierId",
        args: [supplierId],
      ));
    }
  }
}
