import 'package:sqflite/sqflite.dart';

class AnswerDb {
  final String id;
  final String answer;
  final String type; // "question" or "review"

  AnswerDb({required this.id, required this.answer, required this.type});

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS answers (
        id TEXT,
        answer TEXT,
        type TEXT
      )
    ''');
  }
}
