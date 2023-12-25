import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';

class ReviewAnswerDataProvider {
  const ReviewAnswerDataProvider();
  @override
  Future<Either<RewildError, bool>> delete({required String questionId}) async {
    try {
      final db = await SqfliteService().database;

      final deletedID = await db.rawDelete(
        'DELETE FROM review_answers WHERE questionId = ? ',
        [questionId],
      );
      return right(deletedID > 0);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "delete", args: [questionId]));
    }
  }

  @override
  Future<Either<RewildError, bool>> insert(
      {required String questionId, required String answer}) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert(
        'INSERT INTO review_answers (questionId, answer) VALUES (?, ?)',
        [questionId, answer],
      );
      return right(id > 0);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "insert", args: [questionId]));
    }
  }

  @override
  Future<Either<RewildError, List<String>>> getAllReviewsIds() async {
    try {
      final db = await SqfliteService().database;
      final answers = await db.rawQuery(
        'SELECT * FROM review_answers',
      );
      if (answers.isEmpty) {
        return right([]);
      }
      return right(answers.map((e) => e['questionId'] as String).toList());
    } catch (e) {
      return left(RewildError(
        e.toString(),
        source: runtimeType.toString(),
        name: "getAllReviewsIds",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<String>>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final answers = await db.rawQuery(
        'SELECT * FROM review_answers',
      );
      if (answers.isEmpty) {
        return right([]);
      }
      return right(answers.map((e) => e['answer'] as String).toList());
    } catch (e) {
      return left(RewildError(
        e.toString(),
        source: runtimeType.toString(),
        name: "getAll",
        args: [],
      ));
    }
  }
}
