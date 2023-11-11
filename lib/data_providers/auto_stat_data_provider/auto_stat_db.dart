import 'package:rewild/domain/entities/auto_stat.dart';
import 'package:sqflite/sqflite.dart';

class AutoStatDb extends AutoStatModel {
  AutoStatDb(
      {required super.views,
      required super.clicks,
      required super.ctr,
      required super.cpc,
      required super.spend,
      required super.advertId,
      required super.createdAt});

  static Future<void> createTable(Database db) async {
    await db.execute(
      '''
          CREATE TABLE IF NOT EXISTS auto_stat (
            views INTEGER,
            clicks REAL,
            ctr REAL,
            cpc REAL,
            spend INTEGER,
            advertId INTEGER,
            createdAt INTEGER
          )
          ''',
    );
  }
}
