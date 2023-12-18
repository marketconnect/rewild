import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/feedback_qty_model.dart';
import 'package:rewild/domain/services/unanswered_feedback_qty_service.dart';
import 'package:sqflite/sqflite.dart';

class UnansweredFeedbackQtyDataProvider
    implements UnansweredFeedbackQtyServiceFeedbackQtyDataProvider {
  const UnansweredFeedbackQtyDataProvider();

  @override
  Future<Either<RewildError, void>> saveUnansweredFeedbackQtyList(
      {required List<UnAnsweredFeedbacksQtyModel> feedbackList}) async {
    try {
      final db = await SqfliteService().database;
      final Batch batch = db.batch();

      for (var feedback in feedbackList) {
        batch.rawInsert(
          '''
          INSERT OR REPLACE INTO unanswered_feedback_qty (nmId, qty, type) 
          VALUES (?, ?, ?)
        ''',
          [feedback.nmId, feedback.qty, feedback.type],
        );
      }

      await batch.commit();
      return right(null);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(),
          name: "saveUnansweredFeedbackQtyList",
          args: [feedbackList]));
    }
  }

  @override
  Future<Either<RewildError, List<UnAnsweredFeedbacksQtyModel>>>
      getAllUnansweredFeedbackQty() async {
    try {
      final db = await SqfliteService().database;
      final List<Map<String, dynamic>> maps =
          await db.rawQuery('SELECT * FROM unanswered_feedback_qty');

      return right(
          maps.map((e) => UnAnsweredFeedbacksQtyModel.fromMap(e)).toList());
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "getAllFeedback", args: []));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAllUnansweredFeedbackQty() async {
    try {
      final db = await SqfliteService().database;
      await db.rawDelete('DELETE FROM unanswered_feedback_qty');
      return right(null);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: runtimeType.toString(), name: "deleteAllFeedback", args: []));
    }
  }

  static Future<Either<RewildError, int>> getQtyOfType(int type) async {
    try {
      final db = await SqfliteService().database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
          'SELECT * FROM unanswered_feedback_qty WHERE type = ?', [type]);
      return right(maps[0]['qty']);
    } catch (e) {
      return left(RewildError(e.toString(),
          source: 'FeedbackQtyDataProvider',
          name: "getQtyOfType",
          args: [type]));
    }
  }
}
