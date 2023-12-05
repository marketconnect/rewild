import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/question.dart';
import 'package:rewild/presentation/questions_screen/question_view_model.dart';

abstract class QuestionServiceQuestionApiClient {
  Future<Resource<List<Question>>> getUnansweredQuestions(String token);
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

    final resource = await questionApiClient
        .getUnansweredQuestions(tokenResource.data!.token);
    if (resource is Error) {
      return Resource.error(resource.message!,
          source: runtimeType.toString(), name: "getQuestions", args: []);
    }
    if (resource is Empty) {
      return Resource.empty();
    }
    return Resource.success(resource.data!);
  }
}
