import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/question.dart';

abstract class QuestionServiceQuestionApiClient {
  Future<Resource<List<Question>>> getUnansweredQuestions(String token);
}

class QuestionService {
  final QuestionServiceQuestionApiClient questionApiClient;

  QuestionService({required this.questionApiClient});
}
