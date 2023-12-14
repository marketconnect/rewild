import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/question_model.dart';
import 'package:rewild/presentation/all_products_feedback_screen/all_products_feedback_view_model.dart';
import 'package:rewild/presentation/all_questions_screen/all_questions_view_model.dart';
import 'package:rewild/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild/presentation/single_question_screen/single_question_view_model.dart';

abstract class QuestionServiceQuestionApiClient {
  Future<Either<RewildError, List<QuestionModel>>> getUnansweredQuestions(
      String token,
      int take, // Обязательный параметр take
      int skip, // Обязательный параметр skip
      [int? nmId]);
  Future<Either<RewildError, List<QuestionModel>>> getAnsweredQuestions(
      String token,
      int take, // Обязательный параметр take
      int skip, // Обязательный параметр skip
      [int? nmId]);
  Future<Either<RewildError, bool>> handleQuestion(
      String token, String id, String answer);
}

// Api key
abstract class QuestionServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel>> getApiKey(String type);
}

class QuestionService
    implements
        AllProductsFeedbackViewModelQuestionService,
        MainNavigationQuestionService,
        SingleQuestionViewModelQuestionService,
        AllQuestionsViewModelQuestionService {
  final QuestionServiceQuestionApiClient questionApiClient;
  final QuestionServiceApiKeyDataProvider apiKeysDataProvider;
  QuestionService(
      {required this.apiKeysDataProvider, required this.questionApiClient});

  static final keyType = StringConstants.apiKeyTypes[ApiKeyType.question] ?? "";

  @override
  Future<Either<RewildError, bool>> apiKeyExists() async {
    final resource = await apiKeysDataProvider.getApiKey(keyType);
    if (resource is Error) {
      return left(RewildError(resource.message!,
          source: runtimeType.toString(), name: "apiKeyExists", args: []);
    }
    if (resource is Empty) {
      return right(false);
    }
    return right(true);
  }

  @override
  Future<Either<RewildError, List<QuestionModel>>> getQuestions({
    int? nmId,
    required int take,
    required int skip,
  }) async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(), name: "getBallance", args: []);
    }
    if (tokenResource is Empty) {
      return right(null);
    }

    // Unanswered questions
    final resourceUnAnswered = await questionApiClient.getUnansweredQuestions(
        tokenResource.data!.token, take, skip, nmId);
    if (resourceUnAnswered is Error) {
      return left(RewildError(resourceUnAnswered.message!,
          source: runtimeType.toString(), name: "getQuestions", args: []);
    }
    if (resourceUnAnswered is Empty) {
      return right(null);
    }
    final unAnsweredQuestions = resourceUnAnswered.data!;
    // Answered questions
    final resourceAnswered = await questionApiClient.getAnsweredQuestions(
        tokenResource.data!.token, take, skip, nmId);
    if (resourceAnswered is Error) {
      return left(RewildError(resourceAnswered.message!,
          source: runtimeType.toString(), name: "getQuestions", args: []);
    }
    if (resourceAnswered is Empty) {
      return right(unAnsweredQuestions);
    }

    final answeredQuestions = resourceAnswered.data!;

    return right([...unAnsweredQuestions, ...answeredQuestions]);
  }

  @override
  Future<Either<RewildError, bool>> publishQuestion(
      String id, String answer) async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(), name: "getBallance", args: []);
    }
    if (tokenResource is Empty) {
      return right(null);
    }

    final resource = await questionApiClient.handleQuestion(
        tokenResource.data!.token, id, answer);
    if (resource is Error) {
      return left(RewildError(resource.message!,
          source: runtimeType.toString(), name: "publishQuestion", args: []);
    }

    return right(true);
  }
}
