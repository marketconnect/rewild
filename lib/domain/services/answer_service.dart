import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/presentation/all_questions_screen/all_questions_view_model.dart';
import 'package:rewild/presentation/single_question_screen/single_question_view_model.dart';

abstract class AnswerServiceAnswerDataProvider {
  Future<Resource<bool>> delete(
    String questionId,
  );
  Future<Resource<bool>> insert(String questionId, String answer);
  Future<Resource<List<String>>> getAllQuestionsIds();
  Future<Resource<List<String>>> getAll();
}

class AnswerService
    implements
        AllQuestionsViewModelAnswerService,
        SingleQuestionViewModelAnswerService {
  final AnswerServiceAnswerDataProvider answerDataProvider;
  const AnswerService({required this.answerDataProvider});

  @override
  Future<Resource<bool>> delete(
    String questionId,
  ) async {
    return await answerDataProvider.delete(questionId);
  }

  @override
  Future<Resource<bool>> insert(String questionId, String answer) async {
    return await answerDataProvider.insert(questionId, answer);
  }

  @override
  Future<Resource<List<String>>> getAll() async {
    return await answerDataProvider.getAll();
  }

  @override
  Future<Resource<List<String>>> getAllQuestionsIds() async {
    final response = await answerDataProvider.getAllQuestionsIds();
    if (response is Empty) {
      return Resource.success([]);
    }
    return Resource.success(response.data!);
  }
}
