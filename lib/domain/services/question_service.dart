import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/question.dart';
import 'package:rewild/presentation/questions_screen/questions_view_model.dart';

abstract class QuestionServiceQuestionApiClient {
  Future<Resource<List<Question>>> getUnansweredQuestions(String token);
  Future<Resource<List<Question>>> getAnsweredQuestions(String token);
}

// Api key
abstract class QuestionServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
}

class QuestionService implements QuestionViewModelQuestionService {
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
  Future<Resource<List<Question>>> getQuestions() async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(), name: "getBallance", args: []);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // Unanswered questions
    final resourceUnAnswered = await questionApiClient
        .getUnansweredQuestions(tokenResource.data!.token);
    if (resourceUnAnswered is Error) {
      return Resource.error(resourceUnAnswered.message!,
          source: runtimeType.toString(), name: "getQuestions", args: []);
    }
    if (resourceUnAnswered is Empty) {
      return Resource.empty();
    }
    final unAnsweredQuestions = resourceUnAnswered.data!;
    // Answered questions
    final resourceAnswered =
        await questionApiClient.getAnsweredQuestions(tokenResource.data!.token);
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
}
