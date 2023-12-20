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
  Future<Either<RewildError, List<QuestionModel>>> getUnansweredQuestions(
      {required String token,
      required int take,
      required int dateFrom,
      required int dateTo,
      required int skip,
      int? nmId});
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
  Future<Either<RewildError, List<ReviewModel>>> getUnansweredReviews(
      {required String token,
      required int take,
      required int skip,
      required int dateFrom,
      required int dateTo,
      int? nmId});
  Future<Either<RewildError, Map<int, int>>> prevUnansweredReviewsQty(
      {required Set<int> nmIds});
}

// Unanswered Feedback Qty
abstract class AllProductsFeedbackUnansweredFeedbackQtyService {
  Future<Either<RewildError, void>> saveUnansweredFeedbackQtyList({
    required String token,
    required List<UnAnsweredFeedbacksQtyModel> feedbacks,
  });
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

    // get current questions and reviews
    await Future.wait([_updateQuestions(), _updateReviews()]);
    await _updateSavedUnansweredFeedBacks();
    // set qty of unanswered reviews that user did not see yet

    for (final nmId in _unansweredReviewsQty.keys) {
      final current = _unansweredReviewsQty[nmId]!;
      final old = _savedNmIdUnansweredReviews[nmId] ?? 0;

      difReviews[nmId] = current - old;
    }
    for (final nmId in _unansweredQuestionsQty.keys) {
      final current = _unansweredQuestionsQty[nmId]!;
      final old = _savedNmIdUnansweredQuestions[nmId] ?? 0;

      difQuestions[nmId] = current - old;
    }
  }

  // Filter by period
  String _period = 'w';
  String get period => _period;
  Future<void> setPeriod(BuildContext context, String value) async {
    _period = value;
    final _ = await Future.wait([
      _updateReviews(),
      _updateQuestions(),
    ]);
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

  // saved unanswered reviews
  Map<int, int> _savedNmIdUnansweredReviews = {};
  void setSavedNmIdUnansweredReviews(Map<int, int> value) {
    _savedNmIdUnansweredReviews = value;
  }

  void setSavedNmIdUnansweredReview(int nmId, int qty) {
    _savedNmIdUnansweredReviews[nmId] = qty;
  }

  Future<void> _updateSavedUnansweredFeedBacks() async {
    final unanswered = await fetch(
        () => unansweredFeedbackQtyService.getAllUnansweredFeedbackQty());
    if (unanswered == null) {
      return;
    }
    for (final feedback in unanswered) {
      if (feedback.type == UnAnsweredFeedbacksQtyModel.getType("review")) {
        setSavedNmIdUnansweredReview(feedback.nmId, feedback.qty);
      } else {
        setSavedNmIdUnansweredQuestion(feedback.nmId, feedback.qty);
      }
    }

    notify();
  }

  // Variables for storing new feedbacks qty
  Map<int, int> difQuestions = {};
  int difQuestion(int nmId) => difQuestions[nmId] ?? 0;

  Map<int, int> difReviews = {};
  int difReview(int nmId) => difReviews[nmId] ?? 0;

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
  Map<int, int> _unansweredReviewsQty = {};
  void setUnansweredReviewsQty(Map<int, int> value) {
    _unansweredReviewsQty = value;
  }

  void _resetUnansweredReviewsQty() {
    _unansweredReviewsQty = {};
  }

  void incrementUnansweredReviewsQty(int nmId) {
    if (_unansweredReviewsQty.containsKey(nmId)) {
      _unansweredReviewsQty[nmId] = _unansweredReviewsQty[nmId]! + 1;
    } else {
      _unansweredReviewsQty[nmId] = 1;
    }
  }

  int unansweredReviewsQty(int nmId) => _unansweredReviewsQty[nmId] ?? 0;

  // Questions ================================================================== QUESTIONS
  // saved unanswered questions
  Map<int, int> _savedNmIdUnansweredQuestions = {};
  void setSavedNmIdUnansweredQuestions(Map<int, int> value) {
    _savedNmIdUnansweredQuestions = value;
  }

  void setSavedNmIdUnansweredQuestion(int nmId, int qty) {
    _savedNmIdUnansweredQuestions[nmId] = qty;
  }

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
    // get all last week unanswered feedbacks and add it to allUnansweredFeedbacksQtyList
    List<UnAnsweredFeedbacksQtyModel> allUnansweredFeedbacksQtyList = [];
    // get period
    final dateTo = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final dateFrom = dateTo - 60 * 60 * 24 * 7;

    // fetch unanswered questions and reviews from Api and store in allUnansweredFeedbacksQty
    final values = await Future.wait([
      _fetchAllUnansweredQuestionsForLatsWeek(
        dateFrom,
        dateTo,
      ),
      _fetchAllUnansweredReviewsForLastWeek(dateFrom, dateTo),
    ]);

    final allUnansweredQuestionsForLastWeek = values[0];
    final allUnansweredReviewsQty = values[1];
    for (final nmId in allUnansweredQuestionsForLastWeek.keys) {
      allUnansweredFeedbacksQtyList.add(UnAnsweredFeedbacksQtyModel(
        nmId: nmId,
        qty: allUnansweredQuestionsForLastWeek[nmId]!,
        type: UnAnsweredFeedbacksQtyModel.getType('question'),
      ));
    }

    for (final nmId in allUnansweredReviewsQty.keys) {
      allUnansweredFeedbacksQtyList.add(UnAnsweredFeedbacksQtyModel(
        nmId: nmId,
        qty: allUnansweredReviewsQty[nmId]!,
        type: UnAnsweredFeedbacksQtyModel.getType('review'),
      ));
    }

    await unansweredFeedbackQtyService.saveUnansweredFeedbackQtyList(
      token: _apiKey!,
      feedbacks: allUnansweredFeedbacksQtyList,
    );
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<Map<int, int>> _fetchAllUnansweredReviewsForLastWeek(
      int dateFrom, int dateTo) async {
    Map<int, int> allUnansweredReviewsQty = {};
    int n = 0;
    while (true) {
      final reviews = await fetch(() => reviewService.getUnansweredReviews(
          token: _apiKey!,
          take: NumericConstants.takeFeedbacksAtOnce,
          dateFrom: dateFrom,
          dateTo: dateTo,
          skip: NumericConstants.takeFeedbacksAtOnce * n));
      if (reviews == null) {
        break;
      }

      for (final review in reviews) {
        final nmId = review.productDetails.nmId;
        if (allUnansweredReviewsQty.containsKey(nmId)) {
          allUnansweredReviewsQty[nmId] = allUnansweredReviewsQty[nmId]! + 1;
        } else {
          allUnansweredReviewsQty[nmId] = 1;
        }
      }
      n++;

      if (reviews.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
    }
    return allUnansweredReviewsQty;
  }

  Future<Map<int, int>> _fetchAllUnansweredQuestionsForLatsWeek(
      int dateFrom, int dateTo) async {
    Map<int, int> allUnansweredQuestionsQty = {};
    int n = 0;
    while (true) {
      final questions = await fetch(() =>
          questionService.getUnansweredQuestions(
              token: _apiKey!,
              take: NumericConstants.takeFeedbacksAtOnce,
              dateFrom: dateFrom,
              dateTo: dateTo,
              skip: NumericConstants.takeFeedbacksAtOnce * n));
      if (questions == null) {
        break;
      }

      for (final question in questions) {
        final nmId = question.productDetails.nmId;
        if (allUnansweredQuestionsQty.containsKey(nmId)) {
          allUnansweredQuestionsQty[nmId] =
              allUnansweredQuestionsQty[nmId]! + 1;
        } else {
          allUnansweredQuestionsQty[nmId] = 1;
        }
      }
      n++;

      if (questions.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
    }
    return allUnansweredQuestionsQty;
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
      difReviews[nmId] = 0;
    } else {
      difQuestions[nmId] = 0;
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
