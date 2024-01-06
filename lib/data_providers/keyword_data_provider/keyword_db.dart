import 'package:rewild/domain/entities/keyword.dart';
import 'package:sqflite/sqflite.dart';

class KeywordDb extends Keyword {
  KeywordDb(
      {required super.keyword,
      required super.count,
      required super.normquery,
      required super.campaignId});

  static Future<void> createTable(Database db) async {
    await db.execute(
      '''
       CREATE TABLE IF NOT EXISTS keywords (
         id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
         keyword TEXT,
         normquery TEXT,
         count INTEGER,
         campaignId INTEGER,
         UNIQUE(campaignId, keyword) ON CONFLICT REPLACE
       );
       ''',
    );
  }
}
