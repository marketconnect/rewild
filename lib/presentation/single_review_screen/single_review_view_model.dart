import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/review_model.dart';

abstract class SingleReviewCardOfProductService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

abstract class SingleReviewViewReviewService {
  Future<Either<RewildError, bool>> publishReview({
    required String id,
    required bool wasViewed,
    required bool wasRejected,
    required String answer,
  });
}

class SingleReviewViewModel extends ResourceChangeNotifier {
  final SingleReviewCardOfProductService singleReviewCardOfProductService;
  final SingleReviewViewReviewService reviewService;
  final ReviewModel? review;
  SingleReviewViewModel(this.review,
      {required super.context,
      required super.internetConnectionChecker,
      required this.reviewService,
      required this.singleReviewCardOfProductService}) {
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    if (review != null) {
      _cardImage = await fetch(() => singleReviewCardOfProductService
          .getImageForNmId(nmId: review!.productDetails.nmId));
    }
    notify();
  }

  String? _cardImage;

  String? get cardImage => _cardImage;

  String? _answer;
  void setAnswer(String value) {
    _answer = value;
    print(_answer);
    notify();
  }

  Future<void> publish() async {
    if (review == null || _answer == null || _answer!.isEmpty) {
      return;
    }

    await fetch(() => reviewService.publishReview(
          id: review!.id,
          answer: _answer!,
          wasRejected: false,
          wasViewed: true,
        ));
  }
}
