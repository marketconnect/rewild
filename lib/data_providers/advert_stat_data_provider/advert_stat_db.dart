import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:sqflite/sqflite.dart';

class AdvertStatDb extends AdvertStatModel {
  AdvertStatDb(
      {required super.views,
      required super.clicks,
      required super.ctr,
      required super.cpc,
      required super.spend,
      required super.campaignId,
      required super.createdAt});

  static Future<void> createTable(Database db) async {
    await db.execute(
      '''
          CREATE TABLE IF NOT EXISTS advert_stat (
            views INTEGER,
            clicks REAL,
            ctr REAL,
            cpc REAL,
            spend INTEGER,
            campaignId INTEGER,
            createdAt TEXT
          )
          ''',
    );
  }
}
