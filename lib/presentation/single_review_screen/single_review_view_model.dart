import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/review_model.dart';

abstract class SingleReviewCardOfProductService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

class SingleReviewViewModel extends ResourceChangeNotifier {
  final SingleReviewCardOfProductService singleReviewCardOfProductService;
  final ReviewModel? review;
  SingleReviewViewModel(this.review,
      {required super.context,
      required super.internetConnectionChecker,
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
}
