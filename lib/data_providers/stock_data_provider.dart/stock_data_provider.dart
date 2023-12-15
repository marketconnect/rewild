import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/stocks_model.dart';
import 'package:rewild/domain/services/card_of_product_service.dart';
import 'package:rewild/domain/services/stock_service.dart';
import 'package:rewild/domain/services/update_service.dart';

class StockDataProvider
    implements
        UpdateServiceStockDataProvider,
        StockServiceStocksDataProvider,
        CardOfProductServiceStockDataProvider {
  const StockDataProvider();
  @override
  Future<Either<RewildError, int>> insert({required StocksModel stock}) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert('''
  INSERT INTO stocks(
    wh,
    name,
    qty,
    sizeOptionId,
    nmId
  ) VALUES(
    
    ?,?,?,?,?
  );''', [
        stock.wh,
        stock.name,
        stock.qty,
        stock.sizeOptionId,
        stock.nmId,
      ]);
      return right(id);
    } catch (e) {
      return left(RewildError('Не удалось сохранить остатки $e',
          source: runtimeType.toString(), name: "insert", args: [stock]));
    }
  }

  Future<Either<RewildError, void>> delete(int nmId) async {
    try {
      final db = await SqfliteService().database;
      await db.rawDelete('DELETE FROM stocks WHERE nmId = ?', [nmId]);
      return right(null);
    } catch (e) {
      return left(RewildError('Не удалось удалить остатки $e',
          source: runtimeType.toString(), name: "delete", args: [nmId]));
    }
  }

  @override
  Future<Either<RewildError, List<StocksModel>>> get(
      {required int nmId}) async {
    try {
      final db = await SqfliteService().database;

      final stocks =
          await db.rawQuery('SELECT * FROM stocks WHERE nmId = ?', [nmId]);
      return right(stocks.map((e) => StocksModel.fromMap(e)).toList());
    } catch (e) {
      return left(RewildError('Не удалось получить остатки $e',
          source: runtimeType.toString(), name: "get", args: [nmId]));
    }
  }

  @override
  Future<Either<RewildError, StocksModel>> getOne(
      {required int nmId, required int wh, required int sizeOptionId}) async {
    try {
      final db = await SqfliteService().database;
      final stock = await db.rawQuery(
          'SELECT * FROM stocks WHERE nmId = ? AND wh = ? AND sizeOptionId = ?',
          [nmId, wh, sizeOptionId]);
      return right(StocksModel.fromMap(stock.first));
    } catch (e) {
      return left(RewildError('Не удалось получить остатки $e',
          source: runtimeType.toString(),
          name: "getOne",
          args: [nmId, wh, sizeOptionId]));
    }
  }

  Future<Either<RewildError, int>> update(
      {required StocksModel initialStock, required int nmId}) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawUpdate('''
  UPDATE stocks
  SET
    wh = ?,
    name = ?,
    qty = ?,
    sizeOptionId = ?
  WHERE
    nmId = ?
  ''', [
        initialStock.wh,
        initialStock.name,
        initialStock.qty,
        initialStock.sizeOptionId,
        nmId
      ]);
      return right(id);
    } catch (e) {
      return left(RewildError('Не удалось обновить остатки $e',
          source: runtimeType.toString(),
          name: "update",
          args: [initialStock, nmId]));
    }
  }

  @override
  Future<Either<RewildError, List<StocksModel>>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final stocks = await db.rawQuery('SELECT * FROM stocks');
      return right(stocks.map((e) => StocksModel.fromMap(e)).toList());
    } catch (e) {
      return left(RewildError('Не удалось получить остатки $e',
          source: runtimeType.toString(), name: "getAll", args: []));
    }
  }

  Future<Either<RewildError, List<StocksModel>>> getAllByWh(String wh) async {
    try {
      final db = await SqfliteService().database;
      final stocks =
          await db.rawQuery('SELECT * FROM stocks WHERE wh = ?', [wh]);
      return right(stocks.map((e) => StocksModel.fromMap(e)).toList());
    } catch (e) {
      return left(RewildError('Не удалось Получить остатки $e',
          source: runtimeType.toString(), name: "getAllByWh", args: [wh]));
    }
  }
}
