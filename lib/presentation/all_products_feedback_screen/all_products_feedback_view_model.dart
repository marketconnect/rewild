import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/nums.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/feedback_qty_model.dart';
import 'package:rewild/domain/entities/question_model.dart';
import 'package:rewild/domain/entities/review_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

// Images
abstract class AllProductsFeedbackCardOfProductService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

// Questions
abstract class AllProductsFeedbackViewModelQuestionService {
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, List<QuestionModel>>> getQuestions({
    int? nmId,
    required String token,
    required int take,
    required int skip,
    required int dateFrom,
    required int dateTo,
  });
}

// Reviews
abstract class AllProductsFeedbackViewModelReviewService {
  Future<Either<RewildError, List<ReviewModel>>> getReviews({
    required int take,
    required int skip,
    required int dateFrom,
    required int dateTo,
    int? nmId,
  });
}

// Unanswered Feedback Qty
abstract class AllProductsFeedbackUnansweredFeedbackQtyService {
  Future<Either<RewildError, void>> saveUnansweredFeedbackQtyList(
      {required String token,
      required List<UnAnsweredFeedbacksQtyModel> feedbacks});
  Future<Either<RewildError, List<UnAnsweredFeedbacksQtyModel>>>
      getAllUnansweredFeedbackQty();
}

class AllProductsFeedbackViewModel extends ResourceChangeNotifier {
  final AllProductsFeedbackViewModelQuestionService questionService;
  final AllProductsFeedbackCardOfProductService cardOfProductService;
  final AllProductsFeedbackViewModelReviewService reviewService;
  final AllProductsFeedbackUnansweredFeedbackQtyService
      unansweredFeedbackQtyService;
  AllProductsFeedbackViewModel(
      {required super.context,
      required super.internetConnectionChecker,
      required this.cardOfProductService,
      required this.unansweredFeedbackQtyService,
      required this.reviewService,
      required this.questionService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    // check api key

    final apiKey = await fetch(() => questionService.getApiKey());
    if (apiKey == null) {
      return;
    }
    setApiKey(apiKey);

    final _ = await Future.wait([_updateQuestions(), _updateReviews()]);
  }

  // Filter by period
  String _period = 'w';
  String get period => _period;
  Future<void> setPeriod(BuildContext context, String value) async {
    _period = value;
    await _updateReviews();
    await _updateQuestions();
    notify();
  }

  (int, int) dateFromDateTo() {
    final dateTo = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final dateFrom = _period == 'w'
        ? dateTo - 60 * 60 * 24 * 7
        : _period == 'm'
            ? dateTo - 60 * 60 * 24 * 30
            : unixTimestamp2019();
    return (dateFrom, dateTo);
  }

  // new feedback
  Map<int, int> _nmIdNew = {};
  void setNmIdNew(Map<int, int> value) {
    _nmIdNew = value;
  }

  void setNewReviewsQty(int nmId, int qty) {
    _nmIdNew[nmId] = qty;
  }

  int newReviewsQty(int nmId) {
    return _nmIdNew[nmId] ?? 0;
  }

  Future<void> _updateNews() async {
    final unanswered = await fetch(
        () => unansweredFeedbackQtyService.getAllUnansweredFeedbackQty());
    if (unanswered == null) {
      return;
    }
    for (final feedback in unanswered) {
      setNewReviewsQty(feedback.nmId, feedback.qty);
    }
    notify();
  }

  // Reviews ==================================================================== REVIEWS
  bool _isReviewsLoading = false;
  void setReviewsLoading(bool value) {
    _reviewsQty = 0;
    _isReviewsLoading = value;
    notify();
  }

  bool get isReviewsLoading => _isReviewsLoading;

  Future<void> _updateReviews() async {
    setReviewsLoading(true);
    _resetAllReviewsQty();
    _resetUnansweredReviewsQty();
    // get questions
    List<ReviewModel> allReviews = [];
    int n = 0;

    while (true) {
      final reviews = await fetch(() => reviewService.getReviews(
          take: NumericConstants.takeFeedbacksAtOnce,
          dateFrom: dateFromDateTo().$1,
          dateTo: dateFromDateTo().$2,
          skip: NumericConstants.takeFeedbacksAtOnce * n));
      if (reviews == null) {
        break;
      }
      // setReviewQty(allReviews.length);
      allReviews.addAll(reviews);
      n++;
      setReviewsQty(allReviews.length);
      if (reviews.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
    }

    for (final review in allReviews) {
      final nmId = review.productDetails.nmId;
      // All Reviews Qty
      incrementAllReviewsQty(nmId);

      // New Reviews Qty
      if (review.state == "none") {
        incrementUnansweredReviewsQty(nmId);
      }

      // incrementReview(nmId, review.productValuation);

      // Image
      if (!_images.containsKey(nmId)) {
        final image = await fetch(
          () => cardOfProductService.getImageForNmId(nmId: nmId),
        );
        if (image == null) {
          continue;
        }

        addImage(nmId, image);
      }

      // SupplierArticle
      if (!_supplierArticle.containsKey(nmId)) {
        final supplierArticle = review.productDetails.supplierArticle;
        addSupplierArticle(nmId, supplierArticle);
      }
    }

    setReviewsLoading(false);
  }

  int _reviewsQty = 0;
  void setReviewsQty(int value) {
    _reviewsQty = value;
    notify();
  }

  int get reviewQty => _reviewsQty;

  Map<int, int> _allReviewsQty = {};
  void setAllReviewsQty(Map<int, int> value) {
    _allReviewsQty = value;
  }

  void _resetAllReviewsQty() {
    _allReviewsQty = {};
  }

  Set<int> get reviews => _allReviewsQty.keys.toSet();

  void incrementAllReviewsQty(int nmId) {
    if (_allReviewsQty.containsKey(nmId)) {
      _allReviewsQty[nmId] = _allReviewsQty[nmId]! + 1;
    } else {
      _allReviewsQty[nmId] = 1;
    }
  }

  int allReviewsQty(int nmId) => _allReviewsQty[nmId] ?? 0;

  // unanswered reviews for each nmId
  Map<int, int> _newUnansweredReviewsQty = {};
  void setUnansweredReviewsQty(Map<int, int> value) {
    _newUnansweredReviewsQty = value;
  }

  void _resetUnansweredReviewsQty() {
    _newUnansweredReviewsQty = {};
  }

  void incrementUnansweredReviewsQty(int nmId) {
    if (_newUnansweredReviewsQty.containsKey(nmId)) {
      _newUnansweredReviewsQty[nmId] = _newUnansweredReviewsQty[nmId]! + 1;
    } else {
      _newUnansweredReviewsQty[nmId] = 1;
    }
  }

  int unansweredReviewsQty(int nmId) => _newUnansweredReviewsQty[nmId] ?? 0;

  // Questions ================================================================== QUESTIONS
  // new questions qty
  Map<int, int> _unansweredQuestionsQty = {};
  void setUnansweredQuestionsQty(Map<int, int> value) {
    _unansweredQuestionsQty = value;
  }

  void resetUnansweredQuestionsQty() {
    _unansweredQuestionsQty = {};
  }

  void incrementNewQuestionsQty(int nmId) {
    if (_unansweredQuestionsQty.containsKey(nmId)) {
      _unansweredQuestionsQty[nmId] = _unansweredQuestionsQty[nmId]! + 1;
    } else {
      _unansweredQuestionsQty[nmId] = 1;
    }
  }

  int unansweredQuestionsQty(int nmId) => _unansweredQuestionsQty[nmId] ?? 0;

  int _questionsQty = 0;
  void setQuestionsQty(int value) {
    _questionsQty = value;
    notify();
  }

  int get questionsQty => _questionsQty;

  // all questions qty
  Map<int, int> _allQuestionsQty = {};
  void setAllQuestionsQty(Map<int, int> value) {
    _allQuestionsQty = value;
  }

  void _resetAllQuestionsQty() {
    _allQuestionsQty = {};
  }

  Set<int> get questions => _allQuestionsQty.keys.toSet();

  void incrementAllQuestionsQty(int nmId) {
    if (_allQuestionsQty.containsKey(nmId)) {
      _allQuestionsQty[nmId] = _allQuestionsQty[nmId]! + 1;
    } else {
      _allQuestionsQty[nmId] = 1;
    }
  }

  int allQuestionsQty(int nmId) => _allQuestionsQty[nmId] ?? 0;
  bool _isQuestionsLoading = false;
  void setQuestionsLoading(bool value) {
    _questionsQty = 0;
    _isQuestionsLoading = value;
    notify();
  }

  bool get isQuestionsLoading => _isQuestionsLoading;
  Future<void> _updateQuestions() async {
    setQuestionsLoading(true);
    resetUnansweredQuestionsQty();
    _resetAllQuestionsQty();

    // get questions
    List<QuestionModel> allQuestions = [];
    int n = 0;
    if (_apiKey == null) {
      return;
    }
    while (true) {
      final questions = await fetch(() => questionService.getQuestions(
          token: _apiKey!,
          take: NumericConstants.takeFeedbacksAtOnce,
          dateFrom: dateFromDateTo().$1,
          dateTo: dateFromDateTo().$2,
          skip: NumericConstants.takeFeedbacksAtOnce * n));
      if (questions == null) {
        break;
      }

      allQuestions.addAll(questions);
      n++;
      setQuestionsQty(allQuestions.length);
      if (questions.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
    }
    for (final question in allQuestions) {
      final nmId = question.productDetails.nmId;
      // All Questions Qty
      incrementAllQuestionsQty(nmId);

      // New Questions Qty
      if (question.state == "suppliersPortalSynch") {
        incrementNewQuestionsQty(nmId);
      }

      // Image
      if (!_images.containsKey(nmId)) {
        final image = await fetch(
          () => cardOfProductService.getImageForNmId(nmId: nmId),
        );
        if (image == null) {
          continue;
        }

        addImage(nmId, image);
      }

      // SupplierArticle
      if (!_supplierArticle.containsKey(nmId)) {
        final supplierArticle = question.productDetails.supplierArticle;
        addSupplierArticle(nmId, supplierArticle);
      }
    }

    setQuestionsLoading(false);
  }

  Future<void> onClose() async {
    List<UnAnsweredFeedbacksQtyModel> allUnansweredFeedbacksQtyList = [];
    for (final nmId in _allQuestionsQty.keys) {
      final allUnansweredFeedbacksQty = _allQuestionsQty[nmId]!;
      allUnansweredFeedbacksQtyList.add(
        UnAnsweredFeedbacksQtyModel(
            nmId: nmId,
            qty: allUnansweredFeedbacksQty,
            type: UnAnsweredFeedbacksQtyModel.getType('question')),
      );
    }
    for (final nmId in _allReviewsQty.keys) {
      final allUnansweredFeedbacksQty = _allReviewsQty[nmId]!;
      allUnansweredFeedbacksQtyList.add(
        UnAnsweredFeedbacksQtyModel(
            nmId: nmId,
            qty: allUnansweredFeedbacksQty,
            type: UnAnsweredFeedbacksQtyModel.getType('review')),
      );
    }
    await unansweredFeedbackQtyService.saveUnansweredFeedbackQtyList(
        token: _apiKey!, feedbacks: allUnansweredFeedbacksQtyList);
    if (context.mounted) Navigator.of(context).pop();
  }

  // Images
  Map<int, String> _images = {};
  void setImages(Map<int, String> value) {
    _images = value;
  }

  void addImage(int nmId, String value) {
    _images[nmId] = value;
  }

  String getImage(int nmId) => _images[nmId] ?? '';

  // supplierArticles
  Map<int, String> _supplierArticle = {};
  void setSupplierArticle(Map<int, String> value) {
    _supplierArticle = value;
  }

  void addSupplierArticle(int nmId, String value) {
    if (_supplierArticle.containsKey(nmId)) {
      _supplierArticle[nmId] = value;
    } else {
      _supplierArticle[nmId] = value;
    }
  }

  String getSupplierArticle(int nmId) => _supplierArticle[nmId] ?? '';

  // ApiKeyExists
  String? _apiKey;
  void setApiKey(String value) {
    _apiKey = value;
    notify();
  }

  bool get apiKeyExists => _apiKey != null;

  void goTo(int nmId) {
    if (isReviews) {
      _newUnansweredReviewsQty.remove(nmId);
    } else {
      _unansweredQuestionsQty.remove(nmId);
    }
    if (context.mounted) {
      Navigator.of(context).pushNamed(
          isReviews
              ? MainNavigationRouteNames.allReviewsScreen
              : MainNavigationRouteNames.allQuestionsScreen,
          arguments: nmId);
    }
    notify();
  }

  bool isReviews = false;
  void setIsReviews(bool value) {
    isReviews = value;
    notify();
  }
}
