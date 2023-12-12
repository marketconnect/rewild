import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/services/answer_service.dart';

class AnswerDataProvider implements AnswerServiceAnswerDataProvider {
  const AnswerDataProvider();
  @override
  Future<Resource<bool>> delete(
    String questionId,
  ) async {
    try {
      final db = await SqfliteService().database;

      final deletedID = await db.rawDelete(
        'DELETE FROM answers WHERE questionId = ? ',
        [questionId],
      );
      return Resource.success(deletedID > 0);
    } catch (e) {
      return Resource.error("Ошибка удаления сообщения",
          source: runtimeType.toString(), name: "delete", args: [questionId]);
    }
  }

  @override
  Future<Resource<bool>> insert(String questionId, String answer) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert(
        'INSERT INTO answers (questionId, answer) VALUES (?, ?)',
        [questionId, answer],
      );
      return Resource.success(id > 0);
    } catch (e) {
      return Resource.error("Ошибка добавления сообщения",
          source: runtimeType.toString(), name: "insert", args: [questionId]);
    }
  }

  @override
  Future<Resource<List<String>>> getAllQuestionsIds() async {
    try {
      final db = await SqfliteService().database;
      final answers = await db.rawQuery(
        'SELECT * FROM answers',
      );
      if (answers.isEmpty) {
        return Resource.empty();
      }
      return Resource.success(
          answers.map((e) => e['questionId'] as String).toList());
    } catch (e) {
      return Resource.error(
        'Не удалось получить answers из памяти телефона: ${e.toString()}',
        source: runtimeType.toString(),
        name: "getAllQuestionsIds",
        args: [],
      );
    }
  }

  @override
  Future<Resource<List<String>>> getAll() async {
    try {
      final db = await SqfliteService().database;
      final answers = await db.rawQuery(
        'SELECT * FROM answers',
      );
      if (answers.isEmpty) {
        return Resource.empty();
      }
      return Resource.success(
          answers.map((e) => e['answer'] as String).toList());
    } catch (e) {
      return Resource.error(
        'Не удалось получить answers из памяти телефона: ${e.toString()}',
        source: runtimeType.toString(),
        name: "getAll",
        args: [],
      );
    }
  }
}
