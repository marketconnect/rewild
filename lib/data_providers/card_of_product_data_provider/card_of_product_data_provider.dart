import 'package:rewild/core/utils/resource.dart';
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
  @override
  Future<Resource<int>> insertOrUpdate(CardOfProductModel card) async {
    try {
      final numOfUpdatedResource = await update(card);
      if (numOfUpdatedResource is Error) {
        return Resource.error(numOfUpdatedResource.message!);
      }
      final numOfUpdated = numOfUpdatedResource.data!;
      if (numOfUpdated == 0) {
        return insert(card: card);
      }
      return Resource.success(numOfUpdated);
    } catch (e) {
      return Resource.error(
        'Не удалось обновить карточку в памяти телефона: ${e.toString()}',
      );
    }
  }

  Future<Resource<int>> insert({required CardOfProductModel card}) async {
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
      return Resource.success(id);
    } catch (e) {
      return Resource.error(
        'Failed to add card to phone memory: ${e.toString()}',
      );
    }
  }

  @override
  Future<Resource<int>> delete(int id) async {
    try {
      final db = await SqfliteService().database;
      final resId =
          await db.rawDelete('DELETE FROM cards WHERE nmId = ?', [id]);

      return Resource.success(resId);
    } catch (e) {
      return Resource.error(
        'Не удалось удалить карточку из памяти телефона: ${e.toString()}',
      );
    }
  }

  @override
  Future<Resource<CardOfProductModel>> get(int id) async {
    try {
      final db = await SqfliteService().database;
      final card =
          await db.rawQuery('SELECT * FROM cards WHERE nmId = ?', [id]);
      return Resource.success(CardOfProductModel.fromMap(card.first));
    } catch (e) {
      return Resource.error(
        'Не удалось получить карточку из памяти телефона: ${e.toString()}',
      );
    }
  }

  Future<Resource<int>> update(CardOfProductModel card) async {
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
      return Resource.success(id);
    } catch (e) {
      return Resource.error(
        'Не удалось обновить карточку в памяти телефона: ${e.toString()}',
      );
    }
  }

  @override
  Future<Resource<List<CardOfProductModel>>> getAll([List<int>? nmIds]) async {
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

        return Resource.success(
          cards.map((e) => CardOfProductModel.fromMap(e)).toList(),
        );
      }

      final cards = await db.rawQuery(
        '''
          SELECT * FROM cards
        ''',
      );
      return Resource.success(
          cards.map((e) => CardOfProductModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error(
        'Не удалось получить карточки из памяти телефона: ${e.toString()}',
      );
    }
  }

  @override
  Future<Resource<List<CardOfProductModel>>> getAllBySupplierId(
      int sellerId) async {
    try {
      final db = await SqfliteService().database;
      final cards = await db.rawQuery(
        '''
          SELECT * FROM cards
          WHERE sellerId = ?
        ''',
        [sellerId],
      );
      return Resource.success(
        cards.map((e) => CardOfProductModel.fromMap(e)).toList(),
      );
    } catch (e) {
      return Resource.error(
        'Не удалось получить карточки из памяти телефона: ${e.toString()}',
      );
    }
  }
}
