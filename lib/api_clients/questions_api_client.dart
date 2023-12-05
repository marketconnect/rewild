import 'dart:convert';
import 'dart:async';

import 'package:rewild/core/utils/api/wb_questions_api.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/question.dart';
import 'package:rewild/domain/services/question_service.dart';

class QuestionsApiClient implements QuestionServiceQuestionApiClient {
  const QuestionsApiClient();

  Future<Resource<int>> getCountUnansweredQuestions(String token) async {
    try {
      final wbApiHelper = WbQuestionsApiHelper.getUnansweredQuestionsCount;
      final response = await wbApiHelper.get(token);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final countUnanswered = responseData['data']['countUnanswered'] ?? 0;
        return Resource.success(countUnanswered);
      } else {
        final errString =
            wbApiHelper.errResponse(statusCode: response.statusCode);
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "getCountUnansweredQuestions",
          args: [token],
        );
      }
    } catch (e) {
      return Resource.error(
        "Ошибка при получении количества неотвеченных вопросов: $e",
        source: runtimeType.toString(),
        name: "getCountUnansweredQuestions",
        args: [token],
      );
    }
  }

  @override
  Future<Resource<List<Question>>> getUnansweredQuestions(String token) async {
    try {
      final params = {
        'isAnswered': false.toString(),
        'take': 100.toString(),
        'skip': 0.toString(),
        'order': 'dateAsc',
      };

      final wbApiHelper = WbQuestionsApiHelper.getQuestionsList;
      final response = await wbApiHelper.get(token, params);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        final List<Question> questions = [];
        final responseQuestions = (responseData['data']['questions']);
        for (var question in responseQuestions) {
          questions.add(Question.fromJson(question));
        }
        return Resource.success(questions);
      } else {
        final errString =
            wbApiHelper.errResponse(statusCode: response.statusCode);
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "getUnansweredQuestions",
          args: [
            token,
          ],
        );
      }
    } catch (e) {
      return Resource.error(
        "Ошибка при получении списка вопросов: $e",
        source: runtimeType.toString(),
        name: "getUnansweredQuestions",
        args: [
          token,
        ],
      );
    }
  }

  @override
  Future<Resource<List<Question>>> getAnsweredQuestions(String token) async {
    try {
      final params = {
        'isAnswered': true.toString(),
        'take': 100.toString(),
        'skip': 0.toString(),
        'order': 'dateAsc',
      };

      final wbApiHelper = WbQuestionsApiHelper.getQuestionsList;
      final response = await wbApiHelper.get(token, params);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        final List<Question> questions = [];
        final responseQuestions = (responseData['data']['questions']);
        for (var question in responseQuestions) {
          questions.add(Question.fromJson(question));
        }
        return Resource.success(questions);
      } else {
        final errString =
            wbApiHelper.errResponse(statusCode: response.statusCode);
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "getAnsweredQuestions",
          args: [
            token,
          ],
        );
      }
    } catch (e) {
      return Resource.error(
        "Ошибка при получении списка вопросов: $e",
        source: runtimeType.toString(),
        name: "getAnsweredQuestions",
        args: [
          token,
        ],
      );
    }
  }

  Future<Resource<bool>> handleQuestion(String token, String id, bool wasViewed,
      bool wasRejected, String answer) async {
    try {
      final body = {
        'id': id,
        'wasViewed': wasViewed.toString(),
        'wasRejected': wasRejected.toString(),
        'answer': answer,
      };

      final wbApiHelper = WbQuestionsApiHelper.patchQuestions;
      final response = await wbApiHelper.patch(token, body);

      if (response.statusCode == 200) {
        return Resource.success(true);
      } else {
        final errString =
            wbApiHelper.errResponse(statusCode: response.statusCode);
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "handleQuestion",
          args: [token, id, wasViewed, wasRejected, answer],
        );
      }
    } catch (e) {
      return Resource.error(
        "Ошибка при обработке вопроса: $e",
        source: runtimeType.toString(),
        name: "handleQuestion",
        args: [token, id, wasViewed, wasRejected, answer],
      );
    }
  }

  // Future<Resource<bool>> hasNewFeedbacksAndQuestions(String token) async {
  //   try {
  //     final wbApi = WbQuestionsApiHelper.getNewFeedbacksQuestions;
  //     final response = await wbApi.get(token);

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       final hasNewQuestions =
  //           responseData['data']['hasNewQuestions'] ?? false;
  //       final hasNewFeedbacks =
  //           responseData['data']['hasNewFeedbacks'] ?? false;
  //       return Resource.success(hasNewQuestions || hasNewFeedbacks);
  //     } else {
  //       final errString = wbApi.errResponse(statusCode: response.statusCode);
  //       return Resource.error(
  //         errString,
  //         source: runtimeType.toString(),
  //         name: "hasNewFeedbacksAndQuestions",
  //         args: [token],
  //       );
  //     }
  //   } catch (e) {
  //     return Resource.error(
  //       "Ошибка при проверке наличия новых отзывов и вопросов: $e",
  //       source: runtimeType.toString(),
  //       name: "hasNewFeedbacksAndQuestions",
  //       args: [token],
  //     );
  //   }
  // }

  // Future<Resource<List<String>>> getFrequentlyAskedProducts(
  //     String token, int size) async {
  //   try {
  //     final params = {'size': size.toString()};
  //     final wbApi = WbQuestionsApiHelper.getFrequentlyAskedProducts;
  //     final response = await wbApi.get(token, params);

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       final List<String> products =
  //           List<String>.from(responseData['data']['products']);
  //       return Resource.success(products);
  //     } else {
  //       final errString = wbApi.errResponse(statusCode: response.statusCode);
  //       return Resource.error(
  //         errString,
  //         source: runtimeType.toString(),
  //         name: "getFrequentlyAskedProducts",
  //         args: [token, size],
  //       );
  //     }
  //   } catch (e) {
  //     return Resource.error(
  //       "Ошибка при получении часто задаваемых товаров: $e",
  //       source: runtimeType.toString(),
  //       name: "getFrequentlyAskedProducts",
  //       args: [token, size],
  //     );
  //   }
  // }
}
