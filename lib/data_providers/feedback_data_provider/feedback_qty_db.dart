import 'package:rewild/domain/entities/feedback_qty_model.dart';
import 'package:sqflite/sqflite.dart';

class UnansweredFeedbackQtyDb extends UnAnsweredFeedbacksQtyModel {
  UnansweredFeedbackQtyDb({
    required super.nmId,
    required super.qty,
    required super.type,
  });

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS unanswered_feedback_qty (
        nmId INTEGER,
        qty INTEGER,
        type INTEGER,
        PRIMARY KEY (nmId, type) ON CONFLICT REPLACE
      )
    ''');
  }
}
