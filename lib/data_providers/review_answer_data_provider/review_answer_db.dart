import 'package:sqflite/sqflite.dart';

class ReviewAnswerDb {
  final String questionId;
  final String answer;

  ReviewAnswerDb({required this.questionId, required this.answer});

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS review_answers (
        questionId TEXT,
        answer TEXT
      )
      ''');
  }
}
