import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
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
  });
}

// Reviews
abstract class AllProductsFeedbackViewModelReviewService {
  Future<Either<RewildError, List<ReviewModel>>> getReviews({
    required int take,
    required int skip,
    int? nmId,
  });
}

class AllProductsFeedbackViewModel extends ResourceChangeNotifier {
  final AllProductsFeedbackViewModelQuestionService questionService;
  final AllProductsFeedbackCardOfProductService cardOfProductService;
  final AllProductsFeedbackViewModelReviewService reviewService;

  AllProductsFeedbackViewModel(
      {required super.context,
      required super.internetConnectionChecker,
      required this.cardOfProductService,
      required this.reviewService,
      required this.questionService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    // check api key
    // final exists = await fetch(() => questionService.apiKeyExists());
    // if (exists == null) {
    //   return;
    // }
    final apiKey = await fetch(() => questionService.getApiKey());
    if (apiKey == null) {
      return;
    }
    setApiKey(apiKey);

    final _ = await Future.wait([_updateQuestions(), _updateReviews()]);
  }

  // Reviews ==================================================================== REVIEWS
  bool _isReviewsLoading = false;
  void setReviewsLoading(bool value) {
    _isReviewsLoading = value;
    notify();
  }

  bool get isReviewsLoading => _isReviewsLoading;

  Future<void> _updateReviews() async {
    setReviewsLoading(true);
    // get questions
    List<ReviewModel> allReviews = [];
    int n = 0;
    while (true) {
      final reviews = await fetch(() => reviewService.getReviews(
          take: NumericConstants.takeFeedbacksAtOnce,
          skip: NumericConstants.takeFeedbacksAtOnce * n));
      if (reviews == null) {
        break;
      }
      // setReviewQty(allReviews.length);
      allReviews.addAll(reviews);
      n++;
      setReviewQty(allReviews.length);
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
        incrementNewReviewsQty(nmId);
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
  void setReviewQty(int value) {
    _reviewsQty = value;
    notify();
  }

  int get reviewQty => _reviewsQty;

  Map<int, int> _allReviewsQty = {};
  void setAllReviewsQty(Map<int, int> value) {
    _allReviewsQty = value;
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

  // new reviews for each nmId
  Map<int, int> _newReviewsQty = {};
  void setNewReviewsQty(Map<int, int> value) {
    _newReviewsQty = value;
  }

  void incrementNewReviewsQty(int nmId) {
    if (_newReviewsQty.containsKey(nmId)) {
      _newReviewsQty[nmId] = _newReviewsQty[nmId]! + 1;
    } else {
      _newReviewsQty[nmId] = 1;
    }
  }

  int newReviewsQty(int nmId) => _newReviewsQty[nmId] ?? 0;

  // Questions ================================================================== QUESTIONS
  bool _isQuestionsLoading = false;
  void setQuestionsLoading(bool value) {
    _isQuestionsLoading = value;
    notify();
  }

  bool get isQuestionsLoading => _isQuestionsLoading;
  Future<void> _updateQuestions() async {
    setQuestionsLoading(true);
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

  // new questions qty
  Map<int, int> _newQuestionsQty = {};
  void setNewQuestionsQty(Map<int, int> value) {
    _newQuestionsQty = value;
  }

  void incrementNewQuestionsQty(int nmId) {
    if (_newQuestionsQty.containsKey(nmId)) {
      _newQuestionsQty[nmId] = _newQuestionsQty[nmId]! + 1;
    } else {
      _newQuestionsQty[nmId] = 1;
    }
  }

  int newQuestionsQty(int nmId) => _newQuestionsQty[nmId] ?? 0;

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

  Set<int> get questions => _allQuestionsQty.keys.toSet();

  void incrementAllQuestionsQty(int nmId) {
    if (_allQuestionsQty.containsKey(nmId)) {
      _allQuestionsQty[nmId] = _allQuestionsQty[nmId]! + 1;
    } else {
      _allQuestionsQty[nmId] = 1;
    }
  }

  int allQuestionsQty(int nmId) => _allQuestionsQty[nmId] ?? 0;

  // ApiKeyExists
  String? _apiKey;
  void setApiKey(String value) {
    _apiKey = value;
    notify();
  }

  bool get apiKeyExists => _apiKey != null;

  void goTo(int nmId) {
    if (isReviews) {
      _newReviewsQty.remove(nmId);
    } else {
      _newQuestionsQty.remove(nmId);
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
