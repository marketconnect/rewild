import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/domain/services/all_cards_filter_service.dart';
import 'package:rewild/domain/services/seller_service.dart';

class SellerDataProvider
    implements
        SellerServiceSellerDataProvider,
        AllCardsFilterServiceSellerDataProvider {
  const SellerDataProvider();
  @override
  Future<Either<RewildError, int>> insert(SellerModel seller) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert('''
  INSERT INTO sellers(
    supplierId,
    name,
    fineName,
    ogrn,
    trademark,
    legalAddress

  ) VALUES(
    ?,?,?,?,?,?
  )''', [
        seller.supplierId,
        seller.name,
        seller.fineName,
        seller.ogrn,
        seller.trademark,
        seller.legalAddress
      ]);
      return right(id);
    } catch (e) {
      return left(RewildError(
        "Не удалось данные продавца $e",
        source: runtimeType.toString(),
        name: 'insert',
        args: [seller],
      ));
    }
  }

  Future<Either<RewildError, void>> delete(int id) async {
    try {
      final db = await SqfliteService().database;
      final _ =
          await db.rawDelete('DELETE FROM sellers WHERE supplierId = ?', [id]);
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Не удалось удалить данные продавений $e",
        source: runtimeType.toString(),
        name: 'delete',
        args: [id],
      ));
    }
  }

  @override
  Future<Either<RewildError, SellerModel?>> get(int id) async {
    try {
      final db = await SqfliteService().database;
      final seller =
          await db.rawQuery('SELECT * FROM sellers WHERE supplierId = ?', [id]);
      if (seller.isEmpty) {
        return right(null);
      }
      return right(SellerModel.fromMap(seller.first));
    } catch (e) {
      return left(RewildError("Не удалось получить данные продавца $e",
          source: runtimeType.toString(), name: "get", args: [id]));
    }
  }

  Future<Either<RewildError, int>> update(SellerModel seller) async {
    try {
      final db = await SqfliteService().database;
      final resId = await db.rawUpdate('''
  UPDATE sellers
  SET
    name = ?,
    fineName = ?,
    ogrn = ?,
    trademark = ?,
    legalAddress = ?
  WHERE
    supplierId = ?
  ''', [
        seller.name,
        seller.fineName,
        seller.ogrn,
        seller.trademark,
        seller.legalAddress,
        seller.supplierId,
      ]);
      return right(resId);
    } catch (e) {
      return left(RewildError(
        "Не удалось обновить данные продавца $e",
        source: runtimeType.toString(),
        name: 'update',
        args: [seller],
      ));
    }
  }

  Future<Either<RewildError, List<SellerModel>>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final sellers = await db.rawQuery('SELECT * FROM sellers');
      return right(sellers.map((e) => SellerModel.fromMap(e)).toList());
    } catch (e) {
      return left(RewildError(
        "Не удалось получить данные продавцов $e",
        source: runtimeType.toString(),
        name: 'getAll',
        args: [],
      ));
    }
  }
}
