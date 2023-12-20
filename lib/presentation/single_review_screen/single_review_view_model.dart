import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/review_model.dart';

class SingleReviewViewModel extends ResourceChangeNotifier {
  final ReviewModel? review;
  SingleReviewViewModel(this.review,
      {required super.context, required super.internetConnectionChecker});
}
