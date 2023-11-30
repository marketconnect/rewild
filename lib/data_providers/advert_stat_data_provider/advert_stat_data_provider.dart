import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:rewild/domain/services/advert_stat_service.dart';
import 'package:rewild/domain/services/update_service.dart';

class AdvertStatDataProvider
    implements
        AdvertStatServiceAdvertStatDataProvider,
        UpdateServiceAdvertStatDataProvider {
  const AdvertStatDataProvider();
  @override
  Future<Resource<void>> save(AdvertStatModel autoStat) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawInsert(
          "INSERT INTO advert_stat (views, clicks, ctr, cpc, spend, campaignId, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?)",
          [
            autoStat.views,
            autoStat.clicks,
            autoStat.ctr,
            autoStat.cpc,
            autoStat.spend,
            autoStat.campaignId,
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
  Future<Resource<List<AdvertStatModel>>> getAll(int campaignId,
      [DateTime? from]) async {
    try {
      final db = await SqfliteService().database;

      if (from != null) {
        final List<Map<String, Object?>> maps = await db.rawQuery(
            'SELECT * FROM advert_stat WHERE campaignId = ? AND createdAt >= ?',
            [campaignId, from.toIso8601String()]);
        if (maps.isEmpty) {
          return Resource.empty();
        }
        return Resource.success(
            maps.map((e) => AdvertStatModel.fromMap(e, campaignId)).toList());
      }

      final List<Map<String, Object?>> maps = await db.rawQuery(
          'SELECT * FROM advert_stat WHERE campaignId = ?', [campaignId]);
      if (maps.isEmpty) {
        return Resource.empty();
      }

      return Resource.success(
          maps.map((e) => AdvertStatModel.fromMap(e, campaignId)).toList());
    } catch (e) {
      return Resource.error(
        "Не удалось получить статистику: $e",
      );
    }
  }

  Future<Resource<void>> deleteAll(int campaignId) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawDelete(
        'DELETE FROM advert_stat WHERE campaignId = ?',
      );
      return Resource.empty();
    } catch (e) {
      return Resource.error(
        "Не удалось удалить статистику: $e",
      );
    }
  }

  @override
  Future<Resource<void>> deleteOldRecordsOlderThanMonth() async {
    try {
      // Calculate the date one month ago
      DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));

      // Format the date in a way that matches your createdAt column
      String formattedDate = oneMonthAgo.toIso8601String();

      // Delete records older than one month
      final db = await SqfliteService().database;
      final _ = await db.delete(
        'advert_stat',
        where: 'createdAt < ?',
        whereArgs: [formattedDate],
      );
      return Resource.empty();
    } catch (e) {
      return Resource.error(
        "Не удалось удалить статистику: $e",
      );
    }
  }

  // Static methods
  static Future<Resource<void>> saveInBackground(
      AdvertStatModel autoStat) async {
    try {
      final db = await SqfliteService().database;
      final _ = await db.rawInsert(
          "INSERT INTO advert_stat (views, clicks, ctr, cpc, spend, campaignId, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?)",
          [
            autoStat.views,
            autoStat.clicks,
            autoStat.ctr,
            autoStat.cpc,
            autoStat.spend,
            autoStat.campaignId,
            DateTime.now().toIso8601String(),
          ]);
      return Resource.empty();
    } catch (e) {
      return Resource.error(
        "Не удалось сохранить статистику: $e",
      );
    }
  }
}
