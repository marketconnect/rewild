import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/supply_model.dart';
import 'package:rewild/domain/services/card_of_product_service.dart';
import 'package:rewild/domain/services/supply_service.dart';
import 'package:rewild/domain/services/update_service.dart';

class SupplyDataProvider
    implements
        UpdateServiceSupplyDataProvider,
        SupplyServiceSupplyDataProvider,
        CardOfProductServiceSupplyDataProvider {
  const SupplyDataProvider();
  @override
  Future<Resource<int>> insert(SupplyModel supply) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert('''
        INSERT INTO supplies(
          wh,
          nmId,
          sizeOptionId,
          lastStocks,
          qty
        ) VALUES(
          ?,?,?,?,?
        );''', [
        supply.wh,
        supply.nmId,
        supply.sizeOptionId,
        supply.lastStocks,
        supply.qty
      ]);

      return Resource.success(id);
    } catch (e) {
      return Resource.error('Не удалось сохранить поставки $e',
          source: runtimeType.toString(), name: "insert", args: [supply]);
    }
  }

  @override
  Future<Resource<void>> delete({
    required int nmId,
    int? wh,
    int? sizeOptionId,
  }) async {
    try {
      final db = await SqfliteService().database;
      if (wh == null || sizeOptionId == null) {
        await db.rawDelete('DELETE FROM supplies WHERE nmId = ?', [nmId]);
        return Resource.empty();
      }
      await db.rawDelete(
          'DELETE FROM supplies WHERE nmId = ? AND wh = ? AND sizeOptionId = ?',
          [
            nmId,
            wh,
            sizeOptionId,
          ]);
      return Resource.empty();
    } catch (e) {
      return Resource.error('Не удалось удалить поставки $e',
          source: runtimeType.toString(), name: "delete", args: [nmId]);
    }
  }

  static Future<Resource<void>> deleteInBackground({
    required int nmId,
    int? wh,
    int? sizeOptionId,
  }) async {
    try {
      final db = await SqfliteService().database;
      if (wh == null || sizeOptionId == null) {
        await db.rawDelete('DELETE FROM supplies WHERE nmId = ?', [nmId]);
        return Resource.empty();
      }
      await db.rawDelete(
          'DELETE FROM supplies WHERE nmId = ? AND wh = ? AND sizeOptionId = ?',
          [
            nmId,
            wh,
            sizeOptionId,
          ]);
      return Resource.empty();
    } catch (e) {
      return Resource.error('Не удалось удалить поставки $e',
          source: "SupplyDataProvider",
          name: "deleteInBackground",
          args: [nmId]);
    }
  }

  @override
  Future<Resource<SupplyModel>> getOne({
    required int nmId,
    required int wh,
    required int sizeOptionId,
  }) async {
    try {
      final db = await SqfliteService().database;
      final supplies = await db.rawQuery(
          'SELECT * FROM supplies WHERE nmId = ? AND wh = ? AND sizeOptionId = ?',
          [
            nmId,
            wh,
            sizeOptionId,
          ]);
      if (supplies.isEmpty) {
        return Resource.empty();
      }
      return Resource.success(
          supplies.map((e) => SupplyModel.fromMap(e)).first);
    } catch (e) {
      return Resource.error('Не удалось получить поставки: $e',
          source: runtimeType.toString(),
          name: "getOne",
          args: [nmId, wh, sizeOptionId]);
    }
  }

  @override
  Future<Resource<List<SupplyModel>>> getForOne(
    int nmId,
  ) async {
    try {
      final db = await SqfliteService().database;
      final supplies =
          await db.rawQuery('SELECT * FROM supplies WHERE nmId = ?', [
        nmId,
      ]);

      if (supplies.isEmpty) {
        return Resource.empty();
      }

      return Resource.success(
          supplies.map((e) => SupplyModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error('Не удалось получить поставки: $e',
          source: runtimeType.toString(), name: "getForOne", args: [nmId]);
    }
  }

  @override
  Future<Resource<List<SupplyModel>>> get(int nmId) async {
    try {
      final db = await SqfliteService().database;
      final supplies =
          await db.rawQuery('SELECT * FROM supplies WHERE nmId = ?', [nmId]);
      return Resource.success(
          supplies.map((e) => SupplyModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error('Не удалось получить поставки $e',
          source: runtimeType.toString(), name: "get", args: [nmId]);
    }
  }

  // @override
  // Future<Resource<List<SupplyModel>>> getAll() async {
  //   try {
  //     final db = await SqfliteService().database;
  //     final supplies = await db.rawQuery('SELECT * FROM supplies');
  //     return Resource.success(
  //         supplies.map((e) => SupplyModel.fromMap(e)).toList());
  //   } catch (e) {
  //     return Resource.error('Не удалось Получить поставки $e');
  //   }
  // }
}
