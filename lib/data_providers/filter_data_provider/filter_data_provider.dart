import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/filter_model.dart';
import 'package:rewild/domain/services/all_cards_filter_service.dart';

class FilterDataProvider implements AllCardsFilterFilterDataProvider {
  const FilterDataProvider();
  @override
  Future<Resource<void>> insert(FilterModel filter) async {
    try {
      final db = await SqfliteService().database;
      // subjects
      if (filter.subjects != null) {
        for (final subjId in filter.subjects!.keys) {
          await db.rawInsert(
            'INSERT INTO filters(sectionName,itemId,itemName) VALUES(?,?,?)',
            ["subjects", subjId, filter.subjects![subjId]],
          );
        }
      }
      // brands
      if (filter.brands != null) {
        for (final brandId in filter.brands!.keys) {
          await db.rawInsert(
            'INSERT INTO filters(sectionName,itemId,itemName) VALUES(?,?,?)',
            ["brands", brandId, filter.brands![brandId]],
          );
        }
      }
      // suppliers
      if (filter.suppliers != null) {
        for (final supplierId in filter.suppliers!.keys) {
          await db.rawInsert(
            'INSERT INTO filters(sectionName,itemId,itemName) VALUES(?,?,?)',
            ["suppliers", supplierId, filter.suppliers![supplierId]],
          );
        }
      }
      // promos
      if (filter.promos != null) {
        for (final promoId in filter.promos!.keys) {
          await db.rawInsert(
            'INSERT INTO filters(sectionName,itemId,itemName) VALUES(?,?,?)',
            ["promos", promoId, filter.promos![promoId]],
          );
        }
      }
      return Resource.empty();
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  @override
  Future<Resource<void>> delete() async {
    try {
      final db = await SqfliteService().database;
      await db.rawDelete(
        'DELETE FROM filters',
      );
      return Resource.empty();
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  @override
  Future<Resource<FilterModel>> get() async {
    try {
      final db = await SqfliteService().database;
      final result = await db.rawQuery('SELECT * FROM filters');
      if (result.isEmpty) {
        return Resource.empty();
      }
      Map<int, String> subjects = {};
      Map<int, String> brands = {};
      Map<int, String> suppliers = {};
      Map<int, String> promos = {};

      for (final row in result) {
        final itemId = row['itemId'] as int?;
        final itemName = row['itemName'] as String?;
        if (itemId == null || itemName == null) {
          continue;
        }
        if (row['sectionName'] == 'subjects') {
          subjects[itemId] = itemName;
        }
        if (row['sectionName'] == 'brands') {
          brands[itemId] = itemName;
        }
        if (row['sectionName'] == 'suppliers') {
          suppliers[itemId] = itemName;
        }
        if (row['sectionName'] == 'promos') {
          promos[itemId] = itemName;
        }
      }
      final newFilter = FilterModel(
          brands: brands,
          promos: promos,
          subjects: subjects,
          suppliers: suppliers);

      return Resource.success(newFilter);
    } catch (e) {
      return Resource.error(e.toString());
    }
  }
}
