import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/review_model.dart';
import 'package:rewild/presentation/all_products_feedback_screen/all_products_feedback_view_model.dart';
import 'package:rewild/presentation/all_reviews_screen/all_reviews_view_model.dart';

abstract class ReviewServiceReviewApiClient {
  Future<Resource<List<ReviewModel>>> getUnansweredReviews(
      String token,
      int take, // Обязательный параметр take
      int skip, // Обязательный параметр skip
      [int? nmId]);

  Future<Resource<List<ReviewModel>>> getAnsweredReviews(
      String token,
      int take, // Обязательный параметр take
      int skip, // Обязательный параметр skip
      [int? nmId]);

  Future<Resource<bool>> handleReview(
      String token, String id, bool wasViewed, bool wasRejected, String answer);
}

// Api key
abstract class ReviewServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
}

class ReviewService
    implements
        AllProductsFeedbackViewModelReviewService,
        AllReviewsViewModelReviewService {
  final ReviewServiceReviewApiClient reviewApiClient;
  final ReviewServiceApiKeyDataProvider apiKeysDataProvider;

  ReviewService({
    required this.apiKeysDataProvider,
    required this.reviewApiClient,
  });

  static final keyType = StringConstants.apiKeyTypes[ApiKeyType.question] ?? "";

  // @override
  Future<Resource<bool>> apiKeyExists() async {
    final resource = await apiKeysDataProvider.getApiKey(keyType);
    if (resource is Error) {
      return Resource.error(
        resource.message!,
        source: runtimeType.toString(),
        name: "apiKeyExists",
        args: [],
      );
    }
    if (resource is Empty) {
      return Resource.success(false);
    }
    return Resource.success(true);
  }

  @override
  Future<Resource<List<ReviewModel>>> getReviews({
    required int take,
    required int skip,
    int? nmId,
  }) async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return Resource.error(
        tokenResource.message!,
        source: runtimeType.toString(),
        name: "getReviews",
        args: [],
      );
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // Unanswered reviews
    final resourceUnAnswered = await reviewApiClient.getUnansweredReviews(
      tokenResource.data!.token,
      take,
      skip,
      nmId,
    );
    if (resourceUnAnswered is Error) {
      return Resource.error(
        resourceUnAnswered.message!,
        source: runtimeType.toString(),
        name: "getReviews",
        args: [],
      );
    }
    if (resourceUnAnswered is Empty) {
      return Resource.empty();
    }
    final unAnsweredReviews = resourceUnAnswered.data!;

    // Answered reviews
    final resourceAnswered = await reviewApiClient.getAnsweredReviews(
      tokenResource.data!.token,
      take,
      skip,
      nmId,
    );
    if (resourceAnswered is Error) {
      return Resource.error(
        resourceAnswered.message!,
        source: runtimeType.toString(),
        name: "getReviews",
        args: [],
      );
    }
    if (resourceAnswered is Empty) {
      return Resource.success(unAnsweredReviews);
    }
    final answeredReviews = resourceAnswered.data!;

    return Resource.success([...unAnsweredReviews, ...answeredReviews]);
  }

  Future<Resource<bool>> publishReview(
    String id,
    bool wasViewed,
    bool wasRejected,
    String answer,
  ) async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return Resource.error(
        tokenResource.message!,
        source: runtimeType.toString(),
        name: "publishReview",
        args: [],
      );
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    final resource = await reviewApiClient.handleReview(
      tokenResource.data!.token,
      id,
      wasViewed,
      wasRejected,
      answer,
    );
    if (resource is Error) {
      return Resource.error(
        resource.message!,
        source: runtimeType.toString(),
        name: "publishReview",
        args: [],
      );
    }

    return Resource.success(true);
  }
}
