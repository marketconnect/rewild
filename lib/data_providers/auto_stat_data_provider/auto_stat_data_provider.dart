import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/auto_stat.dart';
import 'package:rewild/domain/services/auto_stat_service.dart';

class AutoStatDataProvider implements AutoStatServiceAutoStatDataProvider {
  const AutoStatDataProvider();
  @override
  Future<Resource<void>> save(AutoStatModel autoStat) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawInsert(
          "INSERT INTO auto_stat (views, clicks, ctr, cpc, spend, advertId, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?)",
          [
            autoStat.views,
            autoStat.clicks,
            autoStat.ctr,
            autoStat.cpc,
            autoStat.spend,
            autoStat.advertId,
            DateTime.now().toIso8601String(),
          ]);
      return Resource.empty();
    } catch (e) {
      return Resource.error(
        "Не удалось сохранить статистику: $e",
      );
    }
  }

  static Future<Resource<void>> saveInBackground(AutoStatModel autoStat) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawInsert(
          "INSERT INTO auto_stat (views, clicks, ctr, cpc, spend, advertId, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?)",
          [
            autoStat.views,
            autoStat.clicks,
            autoStat.ctr,
            autoStat.cpc,
            autoStat.spend,
            autoStat.advertId,
            DateTime.now().toIso8601String(),
          ]);
      return Resource.empty();
    } catch (e) {
      return Resource.error(
        "Не удалось сохранить статистику: $e",
      );
    }
  }

  @override
  Future<Resource<List<AutoStatModel>>> getAll(int advertId) async {
    try {
      final db = await SqfliteService().database;
      final List<Map<String, Object?>> maps = await db
          .rawQuery('SELECT * FROM auto_stat WHERE advertId = ?', [advertId]);
      if (maps.isEmpty) {
        return Resource.empty();
      }

      return Resource.success(
          maps.map((e) => AutoStatModel.fromMap(e, advertId)).toList());
    } catch (e) {
      return Resource.error(
        "Не удалось получить статистику: $e",
      );
    }
  }

  Future<Resource<void>> deleteAll(int advertId) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawDelete(
        'DELETE FROM auto_stat WHERE advertId = ?',
      );
      return Resource.empty();
    } catch (e) {
      return Resource.error(
        "Не удалось удалить статистику: $e",
      );
    }
  }
}
