import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/presentation/all_questions_screen/all_questions_view_model.dart';
import 'package:rewild/presentation/all_reviews_screen/all_reviews_view_model.dart';
import 'package:rewild/presentation/single_question_screen/single_question_view_model.dart';

abstract class AnswerServiceAnswerDataProvider {
  Future<Either<RewildError, bool>> delete({required String questionId});
  Future<Either<RewildError, bool>> insert(
      {required String questionId, required String answer});
  Future<Either<RewildError, List<String>>> getAllQuestionsIds();
  Future<Either<RewildError, List<String>>> getAll();
}

class AnswerService
    implements
        AllQuestionsViewModelAnswerService,
        AllReviewsViewModelAnswerService,
        SingleQuestionViewModelAnswerService {
  final AnswerServiceAnswerDataProvider answerDataProvider;
  const AnswerService({required this.answerDataProvider});

  @override
  Future<Either<RewildError, bool>> delete({
    required String questionId,
  }) async {
    return await answerDataProvider.delete(questionId: questionId);
  }

  @override
  Future<Either<RewildError, bool>> insert(
      {required String questionId, required String answer}) async {
    return await answerDataProvider.insert(
        questionId: questionId, answer: answer);
  }

  @override
  Future<Either<RewildError, List<String>>> getAll() async {
    return await answerDataProvider.getAll();
  }

  @override
  Future<Either<RewildError, List<String>>> getAllQuestionsIds() async {
    return await answerDataProvider.getAllQuestionsIds();
  }
}
