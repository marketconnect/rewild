import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/stocks_model.dart';
import 'package:rewild/domain/services/stock_service.dart';
import 'package:rewild/domain/services/update_service.dart';

class StockDataProvider
    implements UpdateServiceStockDataProvider, StockServiceStocksDataProvider {
  @override
  Future<Resource<int>> insert(StocksModel stock) async {
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
      return Resource.success(id);
    } catch (e) {
      return Resource.error('Не удалось сохранить остатки $e');
    }
  }

  Future<Resource<void>> delete(int nmId) async {
    try {
      final db = await SqfliteService().database;
      await db.rawDelete('DELETE FROM stocks WHERE nmId = ?', [nmId]);
      return Resource.empty();
    } catch (e) {
      return Resource.error('Не удалось удалить остатки $e');
    }
  }

  @override
  Future<Resource<List<StocksModel>>> get(int nmId) async {
    try {
      final db = await SqfliteService().database;

      final stocks =
          await db.rawQuery('SELECT * FROM stocks WHERE nmId = ?', [nmId]);
      return Resource.success(
          stocks.map((e) => StocksModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error('Не удалось получить остатки $e');
    }
  }

  @override
  Future<Resource<StocksModel>> getOne(
      {required int nmId, required int wh, required int sizeOptionId}) async {
    try {
      final db = await SqfliteService().database;
      final stock = await db.rawQuery(
          'SELECT * FROM stocks WHERE nmId = ? AND wh = ? AND sizeOptionId = ?',
          [nmId, wh, sizeOptionId]);
      return Resource.success(StocksModel.fromMap(stock.first));
    } catch (e) {
      return Resource.error('Не удалось получить остатки $e');
    }
  }

  Future<Resource<int>> update(StocksModel initialStock, int nmId) async {
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
      return Resource.success(id);
    } catch (e) {
      return Resource.error('Не удалось обновить остатки $e');
    }
  }

  @override
  Future<Resource<List<StocksModel>>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final stocks = await db.rawQuery('SELECT * FROM stocks');
      return Resource.success(
          stocks.map((e) => StocksModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error('Не удалось получить остатки $e');
    }
  }

  Future<Resource<List<StocksModel>>> getAllByWh(String wh) async {
    try {
      final db = await SqfliteService().database;
      final stocks =
          await db.rawQuery('SELECT * FROM stocks WHERE wh = ?', [wh]);
      return Resource.success(
          stocks.map((e) => StocksModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error('Не удалось Получить остатки $e');
    }
  }
}
