import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/keyword.dart';
import 'package:rewild/domain/services/keywords_service.dart';

class KeywordDataProvider implements KeywordsServiceKeywordsDataProvider {
  const KeywordDataProvider();

  static Future<Either<RewildError, List<String>>>
      getKeywordsWithoutNormQuery() async {
    try {
      final db = await SqfliteService().database;
      return await db
          .rawQuery('SELECT keyword FROM keywords WHERE normQuery = \'\'')
          .then((value) =>
              right(value.map((e) => e['keyword'] as String).toList()));
    } catch (e) {
      return left(RewildError(e.toString(),
          source: "KeywordDataProvider",
          name: "getKeywordsWithoutNormQuery",
          args: []));
    }
  }

  static Future<Either<RewildError, bool>> updateWithNormQuery(
      String keyword, String normQuery) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawUpdate(
          'UPDATE keywords SET normquery = ? WHERE keyword = ?',
          [normQuery, keyword]);
      return right(id > 0);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: "KeywordDataProvider",
          name: "updateWithNormQuery",
          args: [keyword]));
    }
  }

  @override
  Future<Either<RewildError, bool>> save(Keyword keyword) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert(
          'INSERT INTO keywords(keyword, count, campaignId) VALUES(?, ?, ?)',
          [keyword.keyword, keyword.count, keyword.campaignId]);
      return right(id > 0);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "save", args: [keyword]));
    }
  }

  // @override
  // Future<Either<RewildError,bool>> delete(Keyword keyword) async {
  //   try {
  //     final db = await SqfliteService().database;
  //     final id = await db.rawDelete(
  //         'DELETE FROM keywords WHERE keyword = ? AND campaignId = ?',
  //         [keyword.keyword, keyword.campaignId]);
  //     return right(id > 0);
  //   } catch (e) {
  //     return left(RewildError(e.toString());
  //   }
  // }

  @override
  Future<Either<RewildError, List<Keyword>>> getAll(int campaignId) async {
    try {
      final db = await SqfliteService().database;
      final result = await db.rawQuery(
          'SELECT keyword, count, normquery, campaignId FROM keywords WHERE campaignId = ?',
          [
            campaignId
          ]).then((value) => value
          .map((e) => Keyword(
              keyword: e['keyword'].toString(),
              count: e['count'] as int,
              normquery: e['normquery'] == null
                  ? 'без кластера'
                  : e['normquery'].toString(),
              campaignId: e['campaignId'] as int))
          .toList());
      return right(result);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "getAll", args: [campaignId]));
    }
  }
}
