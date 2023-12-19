import 'package:fpdart/fpdart.dart';
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
      {required String token,
      required int take,
      required int dateFrom,
      required int dateTo,
      required int skip,
      int? nmId});
  Future<Either<RewildError, List<QuestionModel>>> getAnsweredQuestions(
      {required String token,
      required int take,
      required int dateFrom,
      required int dateTo,
      required int skip,
      int? nmId});
  Future<Either<RewildError, bool>> handleQuestion(
      {required String token, required String id, required String answer});
}

// Api key
abstract class QuestionServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel?>> getApiKey({required String type});
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

  // Function to get api key
  @override
  Future<Either<RewildError, String?>> getApiKey() async {
    final result = await apiKeysDataProvider.getApiKey(type: keyType);
    return result.fold((l) => left(l), (r) {
      if (r == null) {
        return left(RewildError(
          "Api key not found",
          name: "getApiKey",
          source: runtimeType.toString(),
          args: [],
        ));
      }
      return right(r.token);
    });
  }

  // Function to get unanswered questions and answered questions by nmId
  @override
  Future<Either<RewildError, List<QuestionModel>>> getQuestions({
    int? nmId,
    required String token,
    required int take,
    required int skip,
    required int dateFrom,
    required int dateTo,
  }) async {
    List<QuestionModel> allQuestions = [];

    // Unanswered questions
    final unAnsweredEither = await questionApiClient.getUnansweredQuestions(
        token: token,
        take: take,
        dateFrom: dateFrom,
        dateTo: dateTo,
        skip: skip,
        nmId: nmId);

    if (unAnsweredEither.isRight()) {
      unAnsweredEither.fold((l) => left(l), (r) {
        allQuestions = r;
      });
    }

    // Answered questions
    final answeredEither = await questionApiClient.getAnsweredQuestions(
        token: token,
        take: take,
        dateFrom: dateFrom,
        dateTo: dateTo,
        skip: skip,
        nmId: nmId);
    if (answeredEither.isRight()) {
      answeredEither.fold((l) => left(l), (r) {
        allQuestions.addAll(r);
      });
    }

    return right(allQuestions);
  }

  // Function to publish question on wb server
  @override
  Future<Either<RewildError, bool>> publishQuestion(
      {required String token,
      required String id,
      required String answer}) async {
    final result = await questionApiClient.handleQuestion(
        token: token, id: id, answer: answer);

    return result.fold((l) => left(l), (r) {
      return right(r);
    });
  }
}
