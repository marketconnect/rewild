import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/question_model.dart';
import 'package:rewild/domain/entities/review_model.dart';

// Images
abstract class AllProductsFeedbackCardOfProductService {
  Future<Resource<String>> getImageForNmId(int id);
}

// Questions
abstract class AllProductsFeedbackViewModelQuestionService {
  Future<Resource<List<QuestionModel>>> getQuestions();
  Future<Resource<bool>> apiKeyExists();
}

// Reviews
abstract class AllProductsFeedbackViewModelReviewService {
  Future<Resource<List<ReviewModel>>> getReviews({
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
    final exists = await fetch(() => questionService.apiKeyExists());
    if (exists == null) {
      return;
    }
    setApiKeyExists(exists);
    if (!exists) {
      return;
    }

    final _ = await Future.wait([_updateQuestions(), _updateReviews()]);
  }

  // Reviews ==================================================================== REVIEWS
  Future<void> _updateReviews() async {
    setLoading(true);
    // get questions
    List<ReviewModel> allReviews = [];
    int n = 0;
    while (true) {
      final reviews = await fetch(() => reviewService.getReviews(
          take: NumericConstants.takeFeedbacksAtOnce,
          skip: NumericConstants.takeFeedbacksAtOnce * n));
      if (reviews == null ||
          reviews.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
      // setReviewQty(allReviews.length);
      allReviews.addAll(reviews);
      n++;
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
          () => cardOfProductService.getImageForNmId(nmId),
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

    setLoading(false);
  }

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
  Future<void> _updateQuestions() async {
    // get questions
    final questions = await fetch(() => questionService.getQuestions());
    if (questions == null) {
      return;
    }
    for (final question in questions) {
      final nmId = question.productDetails.nmId;
      // All Questions Qty
      incrementAllQuestionsQty(nmId);

      // New Questions Qty
      if (question.state == "suppliersPortalSynch") {
        incrementNewQuestionsQty(nmId);
      }

      // Add Questions
      // addQuestion(
      //   nmId,
      // );

      // Image
      if (!_images.containsKey(nmId)) {
        final image = await fetch(
          () => cardOfProductService.getImageForNmId(nmId),
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
    notify();
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

  // Questions
  // Set<int> _questionsNmIds = {};
  // void setQuestions(Set<int> value) {
  //   _questionsNmIds = value;
  // }

  // void addQuestion(int nmId) {
  //   if (!_questionsNmIds.contains(nmId)) {
  //     _questionsNmIds.add(nmId);
  //   }
  // }

  // Set<int> get questions => _questionsNmIds;

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
  bool _apiKeyExists = false;
  void setApiKeyExists(bool value) {
    _apiKeyExists = value;
    notify();
  }

  bool get apiKeyExists => _apiKeyExists;
}
