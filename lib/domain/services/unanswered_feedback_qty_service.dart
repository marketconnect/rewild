import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/feedback_qty_model.dart';
import 'package:rewild/presentation/all_products_feedback_screen/all_products_feedback_view_model.dart';

// questions api client
abstract class UnansweredFeedbackQtyServiceQuestionsApiClient {
  Future<Either<RewildError, int>> getCountUnansweredQuestions(
      {required String token});
}

// reviews api client
abstract class UnansweredFeedbackQtyServiceReviewsApiClient {
  Future<Either<RewildError, int>> getCountUnansweredReviews(
      {required String token});
}

// feedback qty data provider
abstract class UnansweredFeedbackQtyServiceFeedbackQtyDataProvider {
  Future<Either<RewildError, void>> saveUnansweredFeedbackQtyList(
      {required List<UnAnsweredFeedbacksQtyModel> feedbackList});
  Future<Either<RewildError, List<UnAnsweredFeedbacksQtyModel>>>
      getAllUnansweredFeedbackQty();
  Future<Either<RewildError, void>> deleteAllUnansweredFeedbackQty();
}

// class to provide qty of unanswered feedbacks that a user has not seen yet
class UnansweredFeedbackQtyService
    implements AllProductsFeedbackUnansweredFeedbackQtyService {
  final UnansweredFeedbackQtyServiceFeedbackQtyDataProvider
      feedbackQtyDataProvider;
  final UnansweredFeedbackQtyServiceReviewsApiClient reviewsApiClient;
  final UnansweredFeedbackQtyServiceQuestionsApiClient questionsApiClient;

  const UnansweredFeedbackQtyService(
      {required this.feedbackQtyDataProvider,
      required this.reviewsApiClient,
      required this.questionsApiClient});

  @override
  Future<Either<RewildError, List<UnAnsweredFeedbacksQtyModel>>>
      getAllUnansweredFeedbackQty() async {
    return feedbackQtyDataProvider.getAllUnansweredFeedbackQty();
  }

  @override
  Future<Either<RewildError, void>> saveUnansweredFeedbackQtyList({
    required String token,
    required List<UnAnsweredFeedbacksQtyModel> feedbacks,
  }) async {
    // quantity of unanswered questions
    final unansweredAllQuestionsQtyEither =
        await questionsApiClient.getCountUnansweredQuestions(token: token);
    final unansweredAllQuestionsQty = unansweredAllQuestionsQtyEither.fold(
      (l) => 0,
      (r) => r,
    );

    feedbacks.add(UnAnsweredFeedbacksQtyModel(
      nmId: 0,
      qty: unansweredAllQuestionsQty,
      type: UnAnsweredFeedbacksQtyModel.getType("allQuestions"),
    ));

    // quantity of unanswered reviews
    final unansweredReviewsQtyEither =
        await reviewsApiClient.getCountUnansweredReviews(token: token);
    final unansweredReviewsQty = unansweredReviewsQtyEither.fold(
      (l) => 0,
      (r) => r,
    );
    feedbacks.add(UnAnsweredFeedbacksQtyModel(
      nmId: 0,
      qty: unansweredReviewsQty,
      type: UnAnsweredFeedbacksQtyModel.getType("allReviews"),
    ));
    return await feedbackQtyDataProvider.saveUnansweredFeedbackQtyList(
        feedbackList: feedbacks);
  }
}
