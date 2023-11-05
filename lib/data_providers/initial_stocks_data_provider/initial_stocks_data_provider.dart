import 'package:rewild/core/utils/resource.dart';
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
  Future<Resource<int>> insert(InitialStockModel initialStock) async {
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
      return Resource.success(id);
    } catch (e) {
      return Resource.error('Не удалось сохранить остатки на начало дня $e');
    }
  }

  Future<Resource<void>> delete(int id) async {
    try {
      final db = await SqfliteService().database;

      await db.rawDelete('DELETE FROM initial_stocks WHERE nmId = ?', [id]);
      return Resource.empty();
    } catch (e) {
      return Resource.error('Не удалось удалить остатки на начало дня $e');
    }
  }

  @override
  Future<Resource<List<InitialStockModel>>> get(
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
      return Resource.success(initStocks);
    } catch (e) {
      return Resource.error('Не удалось получить остатки на начало дня $e');
    }
  }

  @override
  Future<Resource<InitialStockModel>> getOne(
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
        return Resource.empty();
      }
      return Resource.success(InitialStockModel.fromMap(initialStock.first));
    } catch (e) {
      return Resource.error('Не удалось получить остатки на начало дня $e');
    }
  }

  Future<Resource<int>> update(InitialStockModel initialStock) async {
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
      return Resource.success(id);
    } catch (e) {
      return Resource.error('Не удалось обновить остатки на начало дня $e');
    }
  }

  @override
  Future<Resource<List<InitialStockModel>>> getAll(
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
      return Resource.success(initStocks);
    } catch (e) {
      return Resource.error('Не удалось получить остатки на начало дня $e');
    }
  }
}
