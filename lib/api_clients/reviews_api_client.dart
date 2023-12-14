import 'dart:convert';
import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/api_helpers/wb_review_seller_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/review_model.dart';
import 'package:rewild/domain/services/review_service.dart';

class ReviewApiClient implements ReviewServiceReviewApiClient {
  const ReviewApiClient();

  @override
  Future<Either<RewildError, List<ReviewModel>>> getUnansweredReviews(
      String token,
      int take, // Обязательный параметр take
      int skip, // Обязательный параметр skip
      [int? nmId]) async {
    try {
      final params = {
        'isAnswered': false.toString(),
        'take': take.toString(),
        'skip': skip.toString(),
        'order': 'dateAsc',
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
      String token,
      int take, // Обязательный параметр take
      int skip, // Обязательный параметр skip
      [int? nmId]) async {
    try {
      final params = {
        'isAnswered': true.toString(),
        'take': take.toString(),
        'skip': skip.toString(),
        'order': 'dateAsc',
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
  Future<Either<RewildError, bool>> handleReview(String token, String id,
      bool wasViewed, bool wasRejected, String answer) async {
    try {
      final body = {
        'id': id,
        'wasViewed': wasViewed.toString(),
        'wasRejected': wasRejected.toString(),
        'answer': answer,
      };

      final wbApi = WbReviewApiHelper.patchFeedbacks;
      final response = await wbApi.patch(token, body);

      if (response.statusCode == 200) {
        return right(true);
      } else {
        final errString = wbApi.errResponse(statusCode: response.statusCode);
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "handleFeedback",
          args: [token, id, wasViewed, wasRejected, answer],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Ошибка при обработке отзыва: $e",
        source: runtimeType.toString(),
        name: "handleFeedback",
        args: [token, id, wasViewed, wasRejected, answer],
      ));
    }
  }
}
