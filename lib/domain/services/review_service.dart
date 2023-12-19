import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';

import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/review_model.dart';
import 'package:rewild/presentation/all_products_feedback_screen/all_products_feedback_view_model.dart';
import 'package:rewild/presentation/all_reviews_screen/all_reviews_view_model.dart';

// Api key
abstract class ReviewServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel?>> getApiKey({required String type});
}

// Api
abstract class ReviewServiceReviewApiClient {
  Future<Either<RewildError, List<ReviewModel>>> getUnansweredReviews(
      {required String token,
      required int take,
      required int dateFrom,
      required int dateTo,
      required int skip,
      int? nmId});

  Future<Either<RewildError, List<ReviewModel>>> getAnsweredReviews(
      {required String token,
      required int take,
      required int skip,
      required int dateFrom,
      required int dateTo,
      required int? nmId});

  Future<Either<RewildError, bool>> handleReview(
      {required String token,
      required String id,
      required bool wasViewed,
      required bool wasRejected,
      required String answer});
}

// data provider
abstract class ReviewServiceUnansweredFeedbackQtyDataProvider {
  Future<Either<RewildError, int>> getQtyOfNmId({required int nmId});
}

class ReviewService
    implements
        AllProductsFeedbackViewModelReviewService,
        AllReviewsViewModelReviewService {
  final ReviewServiceReviewApiClient reviewApiClient;
  final ReviewServiceApiKeyDataProvider apiKeysDataProvider;
  final ReviewServiceUnansweredFeedbackQtyDataProvider
      unansweredFeedbackQtyDataProvider;
  ReviewService({
    required this.apiKeysDataProvider,
    required this.reviewApiClient,
    required this.unansweredFeedbackQtyDataProvider,
  });

  static final keyType = StringConstants.apiKeyTypes[ApiKeyType.question] ?? "";

  @override
  Future<Either<RewildError, bool>> apiKeyExists() async {
    final either = await apiKeysDataProvider.getApiKey(type: keyType);
    return either.fold((l) => left(l), (r) {
      if (r == null) {
        return right(false);
      }
      return right(true);
    });
  }

  @override
  Future<Either<RewildError, Map<int, int>>> prevUnansweredReviewsQty(
      {required Set<int> nmIds}) async {
    Map<int, int> result = {};

    for (final nmId in nmIds) {
      final qtyEither =
          await unansweredFeedbackQtyDataProvider.getQtyOfNmId(nmId: nmId);
      if (qtyEither.isRight()) {
        result[nmId] = qtyEither.getOrElse((l) => 0);
      }
    }
    return Future.value(right(result));
  }

  @override
  Future<Either<RewildError, List<ReviewModel>>> getReviews({
    required int take,
    required int skip,
    required int dateFrom,
    required int dateTo,
    int? nmId,
  }) async {
    final tokenEither = await apiKeysDataProvider.getApiKey(type: keyType);
    return tokenEither.fold((l) => left(l), (apiKeyModel) async {
      if (apiKeyModel == null) {
        return left(RewildError(
          'Api key not found',
          source: runtimeType.toString(),
          name: 'getReviews',
          args: [],
        ));
      }
      final unAnsweredEther = await reviewApiClient.getUnansweredReviews(
        token: apiKeyModel.token,
        take: take,
        skip: skip,
        dateFrom: dateFrom,
        dateTo: dateTo,
        nmId: nmId,
      );
      return unAnsweredEther.fold((l) => left(l), (unAnsweredReviews) async {
        final answeredEither = await reviewApiClient.getAnsweredReviews(
          nmId: nmId,
          token: apiKeyModel.token,
          take: take,
          dateFrom: dateFrom,
          dateTo: dateTo,
          skip: skip,
        );
        return answeredEither.fold((l) => left(l), (answeredReviews) {
          return right([...unAnsweredReviews, ...answeredReviews]);
        });
      });
    });
  }

  Future<Either<RewildError, bool>> publishReview(
    String id,
    bool wasViewed,
    bool wasRejected,
    String answer,
  ) async {
    final tokenEither = await apiKeysDataProvider.getApiKey(type: keyType);
    return tokenEither.fold((l) => left(l), (apiKeyModel) async {
      if (apiKeyModel == null) {
        return left(RewildError(
          'Api key not found',
          source: runtimeType.toString(),
          name: 'publishReview',
          args: [],
        ));
      }

      final either = await reviewApiClient.handleReview(
        token: apiKeyModel.token,
        id: id,
        wasViewed: wasViewed,
        wasRejected: wasRejected,
        answer: answer,
      );
      return either.fold(
        (l) => left(l),
        (r) => right(r),
      );
    });
  }
}
