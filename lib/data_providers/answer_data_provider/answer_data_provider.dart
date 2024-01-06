import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/services/answer_service.dart';

class AnswerDataProvider implements AnswerServiceAnswerDataProvider {
  const AnswerDataProvider();

  Future<Either<RewildError, bool>> delete(
      {required String id, required String type}) async {
    try {
      final db = await SqfliteService().database;
      final deletedID = await db.rawDelete(
        'DELETE FROM answers WHERE id = ? AND type = ?',
        [id, type],
      );
      return right(deletedID > 0);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "delete", args: [id, type]));
    }
  }

  Future<Either<RewildError, bool>> insert(
      {required String id,
      required String answer,
      required String type}) async {
    try {
      final db = await SqfliteService().database;
      final insertedID = await db.rawInsert(
        'INSERT INTO answers (id, answer, type) VALUES (?, ?, ?)',
        [id, answer, type],
      );
      return right(insertedID > 0);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(),
          name: "insert",
          args: [id, answer, type]));
    }
  }

  Future<Either<RewildError, List<String>>> getAllIds(
      {required String type}) async {
    try {
      final db = await SqfliteService().database;
      final answers = await db.rawQuery(
        'SELECT * FROM answers WHERE type = ?',
        [type],
      );
      if (answers.isEmpty) {
        return right([]);
      }
      return right(answers.map((e) => e['id'] as String).toList());
    } catch (e) {
      return left(RewildError(
        e.toString(),
        source: runtimeType.toString(),
        name: "getAllIds",
        args: [type],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<String>>> getAll(
      {required String type}) async {
    try {
      final db = await SqfliteService().database;
      final answers = await db.rawQuery(
        'SELECT * FROM answers WHERE type = ?',
        [type],
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
        args: [type],
      ));
    }
  }
}
