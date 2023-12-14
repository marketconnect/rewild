import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/services/card_of_product_service.dart';
import 'package:rewild/domain/services/init_stock_service.dart';
import 'package:rewild/domain/services/update_service.dart';

class InitialStockDataProvider
    implements
        UpdateServiceInitStockDataProvider,
        InitStockServiceInitStockDataProvider,
        CardOfProductServiceInitStockDataProvider {
  const InitialStockDataProvider();
  @override
  Future<Either<RewildError, int>> insert(
      InitialStockModel initialStock) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert('''
  INSERT INTO initial_stocks(
    date,
    nmId,
    wh,
    name,
    sizeOptionId,
    qty
  ) VALUES(
    ?,?,?,?,?,?
  )''', [
        initialStock.date.millisecondsSinceEpoch,
        initialStock.nmId,
        initialStock.wh,
        initialStock.name,
        initialStock.sizeOptionId,
        initialStock.qty,
      ]);
      return right(id);
    } catch (e) {
      return left(RewildError('Не удалось сохранить остатки на начало дня $e',
          source: runtimeType.toString(),
          name: "insert",
          args: [initialStock]));
    }
  }

  static Future<Either<RewildError, int>> insertInBackground(
      InitialStockModel initialStock) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert('''
  INSERT INTO initial_stocks(
    date,
    nmId,
    wh,
    name,
    sizeOptionId,
    qty
  ) VALUES(
    ?,?,?,?,?,?
  )''', [
        initialStock.date.millisecondsSinceEpoch,
        initialStock.nmId,
        initialStock.wh,
        initialStock.name,
        initialStock.sizeOptionId,
        initialStock.qty,
      ]);
      return right(id);
    } catch (e) {
      return left(RewildError('Не удалось сохранить остатки на начало дня $e',
          source: "InitialStockDataProvider",
          name: "insertInBackground",
          args: [initialStock]));
    }
  }

  Future<Either<RewildError, void>> delete(int id) async {
    try {
      final db = await SqfliteService().database;

      await db.rawDelete('DELETE FROM initial_stocks WHERE nmId = ?', [id]);
      return right(null);
    } catch (e) {
      return left(RewildError('Не удалось удалить остатки на начало дня $e',
          source: runtimeType.toString(), name: "delete", args: [id]));
    }
  }

  @override
  Future<Either<RewildError, List<InitialStockModel>>> get(
      int nmId, DateTime dateFrom, DateTime dateTo) async {
    try {
      final db = await SqfliteService().database;
      final initialStocks = await db.rawQuery(
        '''
          SELECT * FROM initial_stocks WHERE nmId = ? AND date >= ? AND date <= ?
        ''',
        [nmId, dateFrom.millisecondsSinceEpoch, dateTo.millisecondsSinceEpoch],
      );
      final initStocks = initialStocks.map((e) {
        return InitialStockModel.fromMap(e);
      }).toList();
      return right(initStocks);
    } catch (e) {
      return left(RewildError('Не удалось получить остатки на начало дня $e',
          source: runtimeType.toString(),
          name: "get",
          args: [nmId, dateFrom, dateTo]));
    }
  }

  @override
  Future<Either<RewildError, InitialStockModel?>> getOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo,
      required int wh,
      required int sizeOptionId}) async {
    try {
      final db = await SqfliteService().database;
      final initialStock = await db.rawQuery(
        '''
          SELECT * FROM initial_stocks WHERE nmId = ? AND date >= ? AND date <= ? AND wh = ? AND sizeOptionId = ?
        ''',
        [
          nmId,
          dateFrom.millisecondsSinceEpoch,
          dateTo.millisecondsSinceEpoch,
          wh,
          sizeOptionId
        ],
      );
      if (initialStock.isEmpty) {
        return right(null);
      }
      return right(InitialStockModel.fromMap(initialStock.first));
    } catch (e) {
      return left(RewildError('Не удалось получить остатки на начало дня $e',
          source: runtimeType.toString(),
          name: "getOne",
          args: [nmId, dateFrom, dateTo, wh, sizeOptionId]));
    }
  }

  Future<Either<RewildError, int>> update(
      InitialStockModel initialStock) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawUpdate('''
  UPDATE initial_stocks
  SET
  date = ?,
  nmId = ?,
  wh = ?,
  sizeOptionId = ?,
  name = ?,
  qty = ?
  WHERE
  nmId = ?
  ''', [
        initialStock.date.millisecondsSinceEpoch,
        initialStock.nmId,
        initialStock.wh,
        initialStock.sizeOptionId,
        initialStock.name,
        initialStock.qty,
        initialStock.id
      ]);
      return right(id);
    } catch (e) {
      return left(RewildError('Не удалось обновить остатки на начало дня $e',
          source: runtimeType.toString(),
          name: "update",
          args: [initialStock]));
    }
  }

  @override
  Future<Either<RewildError, List<InitialStockModel>>> getAll(
      DateTime dateFrom, DateTime dateTo) async {
    try {
      final db = await SqfliteService().database;
      final initialStocks = await db.rawQuery(
        '''
          SELECT * FROM initial_stocks WHERE date >= ? AND date <= ?
        ''',
        [dateFrom.millisecondsSinceEpoch, dateTo.millisecondsSinceEpoch],
      );
      final initStocks = initialStocks.map((e) {
        return InitialStockModel.fromMap(e);
      }).toList();
      return right(initStocks);
    } catch (e) {
      return left(RewildError('Не удалось получить остатки на начало дня $e',
          source: runtimeType.toString(),
          name: "getAll",
          args: [dateFrom, dateTo]));
    }
  }
}
