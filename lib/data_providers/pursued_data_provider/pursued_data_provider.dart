import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/pursued.dart';
import 'package:rewild/domain/services/advert_service.dart';

class PursuedDataProvider implements AdvertServicePursuedDataProvider {
  const PursuedDataProvider();
  @override
  Future<Resource<void>> delete(PursuedModel pursued) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawDelete(
          "DELETE FROM pursued WHERE parentId = ? AND property = ?", [
        pursued.parentId,
        pursued.property,
      ]);
      return Resource.empty();
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  @override
  Future<Resource<void>> save(PursuedModel pursued) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db
          .rawInsert("INSERT INTO pursued (parentId, property) VALUES (?, ?)", [
        pursued.parentId,
        pursued.property,
      ]);
      return Resource.empty();
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  @override
  Future<Resource<List<PursuedModel>>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final pursueds = await db.rawQuery('SELECT * FROM pursued');
      return Resource.success(
          pursueds.map((e) => PursuedModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  static Future<Resource<List<PursuedModel>>> getAllInBackground() async {
    try {
      final db = await SqfliteService().database;
      final pursueds = await db.rawQuery('SELECT * FROM pursued');
      return Resource.success(
          pursueds.map((e) => PursuedModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error(e.toString());
    }
  }
}
