import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/filter_model.dart';
import 'package:rewild/domain/services/all_cards_filter_service.dart';

class FilterDataProvider implements AllCardsFilterFilterDataProvider {
  const FilterDataProvider();
  @override
  Future<Either<RewildError, void>> insert(
      {required FilterModel filter}) async {
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
      // withSales
      if (filter.withSales != null) {
        await db.rawInsert(
          'INSERT INTO filters(sectionName,itemId,itemName) VALUES(?,?,?)',
          ["withSales", 1, ""],
        );
      }
      // withStocks
      if (filter.withStocks != null) {
        await db.rawInsert(
          'INSERT INTO filters(sectionName,itemId,itemName) VALUES(?,?,?)',
          ["withStocks", 1, ""],
        );
      }
      return right(null);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "insert", args: [filter]));
    }
  }

  @override
  Future<Either<RewildError, void>> delete() async {
    try {
      final db = await SqfliteService().database;
      await db.rawDelete(
        'DELETE FROM filters',
      );
      return right(null);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "delete", args: []));
    }
  }

  @override
  Future<Either<RewildError, FilterModel>> get() async {
    try {
      final db = await SqfliteService().database;
      final result = await db.rawQuery('SELECT * FROM filters');
      if (result.isEmpty) {
        return right(FilterModel.empty());
      }
      Map<int, String> subjects = {};
      Map<int, String> brands = {};
      Map<int, String> suppliers = {};
      Map<int, String> promos = {};
      bool? withSales;
      bool? withStocks;

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
        if (row['sectionName'] == 'withSales') {
          withSales = true;
        }
        if (row['sectionName'] == 'withStocks') {
          withStocks = false;
        }
      }
      final newFilter = FilterModel(
          brands: brands,
          promos: promos,
          subjects: subjects,
          suppliers: suppliers,
          withSales: withSales,
          withStocks: withStocks);

      return right(newFilter);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "get", args: []));
    }
  }
}
