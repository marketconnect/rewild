import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/review_model.dart';

abstract class AllProductsReviewsCardOfProductService {
  Future<Resource<String>> getImageForNmId(int id);
}

abstract class AllProductsReviewsViewModelReviewService {
  Future<Resource<List<ReviewModel>>> getReviews({
    required int take,
    required int skip,
    int? nmId,
  });
  Future<Resource<bool>> apiKeyExists();
}

class AllProductsReviewsViewModel extends ResourceChangeNotifier {
  final AllProductsReviewsViewModelReviewService reviewService;
  final AllProductsReviewsCardOfProductService cardOfProductService;

  AllProductsReviewsViewModel(
      {required super.context,
      required super.internetConnectionChecker,
      required this.cardOfProductService,
      required this.reviewService}) {
    _asyncInit();
  }

  static const int takeAtOnce = 500;

  void _asyncInit() async {
    setLoading(true);
    // check api key
    final exists = await fetch(() => reviewService.apiKeyExists());
    if (exists == null) {
      return;
    }
    setApiKeyExists(exists);
    if (!exists) {
      return;
    }

    // get questions
    List<ReviewModel> allReviews = [];
    int n = 0;
    while (true) {
      final reviews = await fetch(() =>
          reviewService.getReviews(take: takeAtOnce, skip: takeAtOnce * n));
      if (reviews == null || reviews.length < takeAtOnce) {
        break;
      }
      setReviewQty(allReviews.length);
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
      final rating = review.productValuation;
      // Add reviews rates
      final createdAt = review.createdDate;
      if (createdAt
          .isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
        setBeforeWeekAgoReviewsRatings(nmId, rating);
      }
      if (createdAt
          .isBefore(DateTime.now().subtract(const Duration(days: 30)))) {
        setBeforeMonthAgoReviewsRatings(nmId, rating);
      }
      if (createdAt
          .isBefore(DateTime.now().subtract(const Duration(days: 90)))) {
        setBefore3MonthAgoReviewsRatings(nmId, rating);
      }

      incrementReview(nmId, review.productValuation);
      review.productValuation;

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

  int _reviewsQty = 0;
  void setReviewQty(int value) {
    _reviewsQty = value;
    notify();
  }

  int get reviewQty => _reviewsQty;

  // Images
  Map<int, String> _images = {};
  void setImages(Map<int, String> value) {
    _images = value;
  }

  void addImage(int nmId, String value) {
    _images[nmId] = value;
  }

  String getImage(int nmId) => _images[nmId] ?? '';

  // Reviews before week
  Map<int, int> _beforeWeekAgoReviewsRatings = {};
  Map<int, int> _beforeWeekAgoReviewsRatingsLength = {};
  void setBeforeWeekAgoReviewsRatings(int nmIi, int value) {
    if (_beforeWeekAgoReviewsRatings.containsKey(nmIi)) {
      _beforeWeekAgoReviewsRatings[nmIi] =
          _beforeWeekAgoReviewsRatings[nmIi]! + value;
      _beforeWeekAgoReviewsRatingsLength[nmIi] =
          _beforeWeekAgoReviewsRatingsLength[nmIi]! + 1;
    } else {
      _beforeWeekAgoReviewsRatings[nmIi] = value;
      _beforeWeekAgoReviewsRatingsLength[nmIi] = 1;
    }
  }

  double beforeWeekAgoReviewsRatings(int nmId) {
    final sum = _beforeWeekAgoReviewsRatings[nmId] ?? 0;
    final len = _beforeWeekAgoReviewsRatingsLength[nmId] ?? 0;
    if (len == 0) {
      return 0;
    }
    return sum / len;
  }

  // Reviews before month
  Map<int, int> _beforeMonthAgoReviewsRatings = {};
  Map<int, int> _beforeMonthAgoReviewsRatingsLength = {};
  void setBeforeMonthAgoReviewsRatings(int nmIi, int value) {
    if (_beforeMonthAgoReviewsRatings.containsKey(nmIi)) {
      _beforeMonthAgoReviewsRatings[nmIi] =
          _beforeMonthAgoReviewsRatings[nmIi]! + value;
      _beforeMonthAgoReviewsRatingsLength[nmIi] =
          _beforeMonthAgoReviewsRatingsLength[nmIi]! + 1;
    } else {
      _beforeMonthAgoReviewsRatings[nmIi] = value;
      _beforeMonthAgoReviewsRatingsLength[nmIi] = 1;
    }
  }

  double beforeMonthAgoReviewsRatings(int nmId) {
    final sum = _beforeMonthAgoReviewsRatings[nmId] ?? 0;
    final len = _beforeMonthAgoReviewsRatingsLength[nmId] ?? 0;
    if (len == 0) {
      return 0;
    }
    return sum / len;
  }

  // Reviews before 3 months
  Map<int, int> _before3MonthAgoReviewsRatings = {};
  Map<int, int> _before3MonthAgoReviewsRatingsLength = {};
  void setBefore3MonthAgoReviewsRatings(int nmIi, int value) {
    if (_before3MonthAgoReviewsRatings.containsKey(nmIi)) {
      _before3MonthAgoReviewsRatings[nmIi] =
          _before3MonthAgoReviewsRatings[nmIi]! + value;
      _before3MonthAgoReviewsRatingsLength[nmIi] =
          _before3MonthAgoReviewsRatingsLength[nmIi]! + 1;
    } else {
      _before3MonthAgoReviewsRatings[nmIi] = value;
      _before3MonthAgoReviewsRatingsLength[nmIi] = 1;
    }
  }

  double before3MonthAgoReviewsRatings(int nmId) {
    final sum = _before3MonthAgoReviewsRatings[nmId] ?? 0;
    final len = _before3MonthAgoReviewsRatingsLength[nmId] ?? 0;
    if (len == 0) {
      return 0;
    }
    return sum / len;
  }

  Map<int, Map<int, int>> _reviewsRatings = {};
  void setreviews(Map<int, Map<int, int>> value) {
    _reviewsRatings = value;
  }

  void incrementReview(int nmId, int key) {
    // last month reviews
    if (_reviewsRatings.containsKey(nmId)) {
      final rating = _reviewsRatings[nmId]!;
      if (rating.containsKey(key)) {
        rating[key] = rating[key]! + 1;
      } else {
        rating[key] = 1;
      }
    } else {
      final rating = {key: 1};
      _reviewsRatings[nmId] = rating;
    }
  }

  Map<int, Map<int, int>> get reviewsRatings => _reviewsRatings;

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

  // new reviews qty
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

  int newRewviewsQty(int nmId) => _newReviewsQty[nmId] ?? 0;

  // all questions qty
  Map<int, int> _allReviewsQty = {};
  void setAllQuestionsQty(Map<int, int> value) {
    _allReviewsQty = value;
  }

  void incrementAllReviewsQty(int nmId) {
    if (_allReviewsQty.containsKey(nmId)) {
      _allReviewsQty[nmId] = _allReviewsQty[nmId]! + 1;
    } else {
      _allReviewsQty[nmId] = 1;
    }
  }

  int allReviewsQty(int nmId) => _allReviewsQty[nmId] ?? 0;

  // ApiKeyExists
  bool _apiKeyExists = false;
  void setApiKeyExists(bool value) {
    _apiKeyExists = value;
    notify();
  }

  bool get apiKeyExists => _apiKeyExists;
}
