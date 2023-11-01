import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/filter_model.dart';

class FilterDataProvider {
  Future<Resource<void>> insert(FilterModel filter) async {
    try {
      final db = await SqfliteService().database;
      // subjects
      if (filter.subjects != null) {
        for (final subjId in filter.subjects!.keys) {
          await db.rawInsert(
            'INSERT INTO filter(sectionName,itemId,itemName) VALUES(?,?,?)',
            ["subjects", subjId, filter.subjects![subjId]],
          );
        }
      }
      // brands
      if (filter.brands != null) {
        for (final brandId in filter.brands!.keys) {
          await db.rawInsert(
            'INSERT INTO filter(sectionName,itemId,itemName) VALUES(?,?,?)',
            ["brands", brandId, filter.brands![brandId]],
          );
        }
      }
      // suppliers
      if (filter.suppliers != null) {
        for (final supplierId in filter.suppliers!.keys) {
          await db.rawInsert(
            'INSERT INTO filter(sectionName,itemId,itemName) VALUES(?,?,?)',
            ["suppliers", supplierId, filter.suppliers![supplierId]],
          );
        }
      }
      // promos
      if (filter.promos != null) {
        for (final promoId in filter.promos!.keys) {
          await db.rawInsert(
            'INSERT INTO filter(sectionName,itemId,itemName) VALUES(?,?,?)',
            ["promos", promoId, filter.promos![promoId]],
          );
        }
      }
      return Resource.empty();
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  Future<Resource<void>> delete(FilterModel filter) async {
    try {
      final db = await SqfliteService().database;
      await db.rawDelete(
        'DELETE * FROM filter',
      );
      return Resource.empty();
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  Future<Resource<List<FilterModel>>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final result = await db.rawQuery('SELECT * FROM filter');
      return Resource.success(
          result.map((e) => FilterModel.fromMap(e)).toList());
    } catch (e) {
      return Resource.error(e.toString());
    }
  }
}
