import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/keyword.dart';
import 'package:sqflite/sqflite.dart';

class KeywordDb extends Keyword {
  @override
  final int campaignId;
  KeywordDb(
      {required super.keyword, required super.count, required this.campaignId});

  static Future<void> createTable(Database db) async {
    await db.execute(
      '''
       CREATE TABLE IF NOT EXISTS keywords (
         id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
         keyword TEXT,
         count INTEGER,
         campaignId INTEGER,
         UNIQUE(campaignId, keyword) ON CONFLICT REPLACE
       );
       ''',
    );
  }
}
