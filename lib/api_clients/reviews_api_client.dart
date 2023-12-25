import 'dart:convert';
import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/api_helpers/wb_review_seller_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/review_model.dart';
import 'package:rewild/domain/services/review_service.dart';
import 'package:rewild/domain/services/unanswered_feedback_qty_service.dart';

class ReviewApiClient
    implements
        ReviewServiceReviewApiClient,
        UnansweredFeedbackQtyServiceReviewsApiClient {
  const ReviewApiClient();

  @override
  Future<Either<RewildError, int>> getCountUnansweredReviews(
      {required String token}) async {
    try {
      final wbApi = WbReviewApiHelper.countUnansweredFeedbacks;
      final response = await wbApi.get(
        token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int countUnanswered = responseData['data']['countUnanswered'];
        return right(countUnanswered); // Use 'right' for successful result
      } else {
        final errString = wbApi.errResponse(statusCode: response.statusCode);
        return left(RewildError(errString,
            source: runtimeType.toString(),
            name: "getCountUnansweredQuestions",
            args: [token])); // Use 'left' for error
      }
    } catch (e) {
      return left(RewildError("Error: $e",
          source: runtimeType.toString(),
          name: "getCountUnansweredQuestions",
          args: [token]));
    }
  }

  static Future<Either<RewildError, int>> getCountUnansweredReviewsInBackground(
      {required String token}) async {
    try {
      final wbApi = WbReviewApiHelper.countUnansweredFeedbacks;
      final response = await wbApi.get(
        token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int countUnanswered = responseData['data']['countUnanswered'];
        return right(countUnanswered); // Use 'right' for successful result
      } else {
        final errString = wbApi.errResponse(statusCode: response.statusCode);
        return left(RewildError(errString,
            source: 'getCountUnansweredReviewsInBackground',
            name: "getCountUnansweredReviews",
            args: [token])); // Use 'left' for error
      }
    } catch (e) {
      return left(RewildError("Error: $e",
          source: "getCountUnansweredReviewsInBackground",
          name: "getCountUnansweredReviews",
          args: [token]));
    }
  }

  @override
  Future<Either<RewildError, List<ReviewModel>>> getUnansweredReviews(
      {required String token,
      required int take,
      required int skip,
      required int dateFrom,
      required int dateTo,
      int? nmId}) async {
    try {
      print('dateFrom $dateFrom dateTo $dateTo');
      final params = {
        'isAnswered': false.toString(),
        'take': take.toString(),
        'skip': skip.toString(),
        'dateFrom': dateFrom.toString(),
        'dateTo': dateTo.toString(),
        'order': 'dateDesc',
      };

      if (nmId != null) {
        params['nmId'] = nmId.toString();
      }

      final wbApi = WbReviewApiHelper.getFeedbacks;
      final response = await wbApi.get(token, params);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        final List<ReviewModel> reviews = [];
        final responseReviews = (responseData['data']['feedbacks']);

        for (final review in responseReviews) {
          reviews.add(ReviewModel.fromJson(review));
        }
        return right(reviews);
      } else {
        final errString = wbApi.errResponse(statusCode: response.statusCode);
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "getUnAnsweredReviews",
          args: [token, take, skip, nmId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Ошибка при получении списка отзывов: $e",
        source: runtimeType.toString(),
        name: "getFeedbacks",
        args: [token, take, skip, nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<ReviewModel>>> getAnsweredReviews(
      {required String token,
      required int take,
      required int skip,
      required int dateFrom,
      required int dateTo,
      int? nmId}) async {
    try {
      final params = {
        'isAnswered': true.toString(),
        'take': take.toString(),
        'skip': skip.toString(),
        'dateFrom': dateFrom.toString(),
        'dateTo': dateTo.toString(),
        'order': 'dateDesc',
      };
      if (nmId != null) {
        params['nmId'] = nmId.toString();
      }

      final wbApi = WbReviewApiHelper.getFeedbacks;
      final response = await wbApi.get(token, params);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        final List<ReviewModel> reviews = [];
        final responseReviews = (responseData['data']['feedbacks']);

        for (final review in responseReviews) {
          reviews.add(ReviewModel.fromJson(review));
        }
        return right(reviews);
      } else {
        final errString = wbApi.errResponse(statusCode: response.statusCode);
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "getAnsweredReviews",
          args: [token, take, skip, nmId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Ошибка при получении списка отзывов: $e",
        source: runtimeType.toString(),
        name: "getFeedbacks",
        args: [token, take, skip, nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> handleReview(
      {required String token,
      required String id,
      required bool wasViewed,
      required bool wasRejected,
      required String answer}) async {
    try {
      final body = {
        'id': id,
        'text': answer,
      };

      print('handleReview $id $wasViewed $wasRejected $answer');
      final wbApi = WbReviewApiHelper.patchFeedbacks;
      final response = await wbApi.patch(token, body);

      if (response.statusCode == 200) {
        return right(true);
      } else {
        print(response.body);
        final errString = wbApi.errResponse(statusCode: response.statusCode);
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "handleReview",
          args: [token, id, wasViewed, wasRejected, answer],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Ошибка при обработке отзыва: $e",
        source: runtimeType.toString(),
        name: "handleReview",
        args: [token, id, wasViewed, wasRejected, answer],
      ));
    }
  }
}
