import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/question_model.dart';
import 'package:rewild/presentation/all_products_feedback_screen/all_products_feedback_view_model.dart';
import 'package:rewild/presentation/all_questions_screen/all_questions_view_model.dart';
import 'package:rewild/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild/presentation/single_question_screen/single_question_view_model.dart';

abstract class QuestionServiceQuestionApiClient {
  Future<Resource<List<QuestionModel>>> getUnansweredQuestions(
      String token,
      int take, // Обязательный параметр take
      int skip, // Обязательный параметр skip
      [int? nmId]);
  Future<Resource<List<QuestionModel>>> getAnsweredQuestions(
      String token,
      int take, // Обязательный параметр take
      int skip, // Обязательный параметр skip
      [int? nmId]);
  Future<Resource<bool>> handleQuestion(String token, String id, String answer);
}

// Api key
abstract class QuestionServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
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
  Future<Resource<bool>> apiKeyExists() async {
    final resource = await apiKeysDataProvider.getApiKey(keyType);
    if (resource is Error) {
      return Resource.error(resource.message!,
          source: runtimeType.toString(), name: "apiKeyExists", args: []);
    }
    if (resource is Empty) {
      return Resource.success(false);
    }
    return Resource.success(true);
  }

  @override
  Future<Resource<List<QuestionModel>>> getQuestions({
    int? nmId,
    required int take,
    required int skip,
  }) async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(), name: "getBallance", args: []);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // Unanswered questions
    final resourceUnAnswered = await questionApiClient.getUnansweredQuestions(
        tokenResource.data!.token, take, skip, nmId);
    if (resourceUnAnswered is Error) {
      return Resource.error(resourceUnAnswered.message!,
          source: runtimeType.toString(), name: "getQuestions", args: []);
    }
    if (resourceUnAnswered is Empty) {
      return Resource.empty();
    }
    final unAnsweredQuestions = resourceUnAnswered.data!;
    // Answered questions
    final resourceAnswered = await questionApiClient.getAnsweredQuestions(
        tokenResource.data!.token, take, skip, nmId);
    if (resourceAnswered is Error) {
      return Resource.error(resourceAnswered.message!,
          source: runtimeType.toString(), name: "getQuestions", args: []);
    }
    if (resourceAnswered is Empty) {
      return Resource.success(unAnsweredQuestions);
    }

    final answeredQuestions = resourceAnswered.data!;

    return Resource.success([...unAnsweredQuestions, ...answeredQuestions]);
  }

  @override
  Future<Resource<bool>> publishQuestion(String id, String answer) async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(), name: "getBallance", args: []);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    final resource = await questionApiClient.handleQuestion(
        tokenResource.data!.token, id, answer);
    if (resource is Error) {
      return Resource.error(resource.message!,
          source: runtimeType.toString(), name: "publishQuestion", args: []);
    }

    return Resource.success(true);
  }
}
