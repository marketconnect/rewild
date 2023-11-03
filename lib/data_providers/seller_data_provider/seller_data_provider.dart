import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/domain/services/all_cards_filter_service.dart';
import 'package:rewild/domain/services/seller_service.dart';

class SellerDataProvider
    implements
        SellerServiceSellerDataProvider,
        AllCardsFilterServiceSellerDataProvider {
  @override
  Future<Resource<int>> insert(SellerModel seller) async {
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
      return Resource.success(id);
    } catch (e) {
      return Resource.error(
        "Не удалось данные продавца $e",
      );
    }
  }

  Future<Resource<void>> delete(int id) async {
    try {
      final db = await SqfliteService().database;
      final _ =
          await db.rawDelete('DELETE FROM sellers WHERE supplierId = ?', [id]);
      return Resource.empty();
    } catch (e) {
      return Resource.error(
        "Не удалось удалить данные продавений $e",
      );
    }
  }

  @override
  Future<Resource<SellerModel>> get(int id) async {
    try {
      final db = await SqfliteService().database;
      final seller =
          await db.rawQuery('SELECT * FROM sellers WHERE supplierId = ?', [id]);
      if (seller.isEmpty) {
        return Resource.empty();
      }
      return Resource.success(SellerModel.fromMap(seller.first));
    } catch (e) {
      return Resource.error(
        "Не удалось получить данные продавца $e",
      );
    }
  }

  Future<Resource<int>> update(SellerModel seller) async {
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
      return Resource.success(resId);
    } catch (e) {
      return Resource.error(
        "Не удалось обновить данные продавца $e",
      );
    }
  }

  Future<Resource<List<SellerModel>>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final sellers = await db.rawQuery('SELECT * FROM sellers');
      return Resource.success(
          sellers.map((e) => SellerModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error(
        "Не удалось получить данные продавцов $e",
      );
    }
  }
}
