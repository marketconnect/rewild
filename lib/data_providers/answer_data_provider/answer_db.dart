import 'package:sqflite/sqflite.dart';

class AnswerDb {
  final String questionId;
  final String answer;

  AnswerDb({required this.questionId, required this.answer});

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS answers (
        questionId TEXT,
        answer TEXT
      )
      ''');
  }
}
