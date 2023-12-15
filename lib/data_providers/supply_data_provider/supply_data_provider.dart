import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
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
  Future<Either<RewildError, int>> insert({required SupplyModel supply}) async {
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

      return right(id);
    } catch (e) {
      return left(RewildError('Не удалось сохранить поставки $e',
          source: runtimeType.toString(), name: "insert", args: [supply]));
    }
  }

  @override
  Future<Either<RewildError, void>> delete({
    required int nmId,
    int? wh,
    int? sizeOptionId,
  }) async {
    try {
      final db = await SqfliteService().database;
      if (wh == null || sizeOptionId == null) {
        await db.rawDelete('DELETE FROM supplies WHERE nmId = ?', [nmId]);
        return right(null);
      }
      await db.rawDelete(
          'DELETE FROM supplies WHERE nmId = ? AND wh = ? AND sizeOptionId = ?',
          [
            nmId,
            wh,
            sizeOptionId,
          ]);
      return right(null);
    } catch (e) {
      return left(RewildError('Не удалось удалить поставки $e',
          source: runtimeType.toString(), name: "delete", args: [nmId]));
    }
  }

  static Future<Either<RewildError, void>> deleteInBackground({
    required int nmId,
    int? wh,
    int? sizeOptionId,
  }) async {
    try {
      final db = await SqfliteService().database;
      if (wh == null || sizeOptionId == null) {
        await db.rawDelete('DELETE FROM supplies WHERE nmId = ?', [nmId]);
        return right(null);
      }
      await db.rawDelete(
          'DELETE FROM supplies WHERE nmId = ? AND wh = ? AND sizeOptionId = ?',
          [
            nmId,
            wh,
            sizeOptionId,
          ]);
      return right(null);
    } catch (e) {
      return left(RewildError('Не удалось удалить поставки $e',
          source: "SupplyDataProvider",
          name: "deleteInBackground",
          args: [nmId]));
    }
  }

  @override
  Future<Either<RewildError, SupplyModel?>> getOne({
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
        return right(null);
      }
      return right(supplies.map((e) => SupplyModel.fromMap(e)).first);
    } catch (e) {
      return left(RewildError('Не удалось получить поставки: $e',
          source: runtimeType.toString(),
          name: "getOne",
          args: [nmId, wh, sizeOptionId]));
    }
  }

  @override
  Future<Either<RewildError, List<SupplyModel>?>> getForOne(
      {required int nmId}) async {
    try {
      final db = await SqfliteService().database;
      final supplies =
          await db.rawQuery('SELECT * FROM supplies WHERE nmId = ?', [
        nmId,
      ]);

      if (supplies.isEmpty) {
        return right(null);
      }

      return right(supplies.map((e) => SupplyModel.fromMap(e)).toList());
    } catch (e) {
      return left(RewildError('Не удалось получить поставки: $e',
          source: runtimeType.toString(), name: "getForOne", args: [nmId]));
    }
  }

  @override
  Future<Either<RewildError, List<SupplyModel>>> get(
      {required int nmId}) async {
    try {
      final db = await SqfliteService().database;
      final supplies =
          await db.rawQuery('SELECT * FROM supplies WHERE nmId = ?', [nmId]);
      return right(supplies.map((e) => SupplyModel.fromMap(e)).toList());
    } catch (e) {
      return left(RewildError('Не удалось получить поставки $e',
          source: runtimeType.toString(), name: "get", args: [nmId]));
    }
  }

  // @override
  // Future<Either<RewildError,List<SupplyModel>>> getAll() async {
  //   try {
  //     final db = await SqfliteService().database;
  //     final supplies = await db.rawQuery('SELECT * FROM supplies');
  //     return right(
  //         supplies.map((e) => SupplyModel.fromMap(e)).toList());
  //   } catch (e) {
  //     return left(RewildError('Не удалось Получить поставки $e');
  //   }
  // }
}
