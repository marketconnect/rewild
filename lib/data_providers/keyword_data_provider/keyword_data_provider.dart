import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/keyword.dart';
import 'package:rewild/domain/services/keywords_service.dart';

class KeywordDataProvider implements KeywordsServiceKeywordsDataProvider {
  const KeywordDataProvider();
  @override
  Future<Resource<bool>> save(Keyword keyword) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert(
          'INSERT INTO keywords(keyword, count, campaignId) VALUES(?, ?, ?)',
          [keyword.keyword, keyword.count, keyword.campaignId]);
      return Resource.success(id > 0);
    } catch (e) {
      return Resource.error(e.toString());
    }
  }

  // @override
  // Future<Resource<bool>> delete(Keyword keyword) async {
  //   try {
  //     final db = await SqfliteService().database;
  //     final id = await db.rawDelete(
  //         'DELETE FROM keywords WHERE keyword = ? AND campaignId = ?',
  //         [keyword.keyword, keyword.campaignId]);
  //     return Resource.success(id > 0);
  //   } catch (e) {
  //     return Resource.error(e.toString());
  //   }
  // }

  @override
  Future<Resource<List<Keyword>>> getAll(int campaignId) async {
    try {
      final db = await SqfliteService().database;
      final result = await db.rawQuery(
          'SELECT * FROM keywords WHERE campaignId = ?', [
        campaignId
      ]).then((value) => value
          .map((e) => Keyword(
              keyword: e['keyword'].toString(),
              count: e['count'] as int,
              campaignId: e['campaignId'] as int))
          .toList());
      return Resource.success(result);
    } catch (e) {
      return Resource.error(e.toString());
    }
  }
}
