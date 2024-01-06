import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/review_model.dart';
import 'package:rewild/domain/entities/spell_result.dart';

// Card of product
abstract class SingleReviewCardOfProductService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

// Review
abstract class SingleReviewViewReviewService {
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, bool>> publishReview({
    required String token,
    required String id,
    required bool wasViewed,
    required bool wasRejected,
    required String answer,
  });
  Future<Either<RewildError, List<ReviewModel>>> getReviews({
    required String token,
    required int take,
    required int skip,
    required int dateFrom,
    required int dateTo,
    int? nmId,
  });
}

// Answer
abstract class SingleReviewViewModelAnswerService {
  Future<Either<RewildError, List<String>>> getAllReviews();
}

// Spell checker
abstract class SingleReviewViewModelSpellChecker {
  Future<Either<RewildError, List<SpellResult>>> checkText(
      {required String text});
}

class SingleReviewViewModel extends ResourceChangeNotifier {
  final SingleReviewCardOfProductService singleReviewCardOfProductService;
  final SingleReviewViewReviewService reviewService;
  final SingleReviewViewModelSpellChecker spellChecker;
  final SingleReviewViewModelAnswerService answerService;
  final ReviewModel? review;
  SingleReviewViewModel(this.review,
      {required super.context,
      required super.internetConnectionChecker,
      required this.reviewService,
      required this.spellChecker,
      required this.answerService,
      required this.singleReviewCardOfProductService}) {
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    final apiKey = await fetch(() => reviewService.getApiKey());
    if (apiKey == null) {
      return;
    }
    setApiKey(apiKey);
    if (review != null) {
      _cardImage = await fetch(() => singleReviewCardOfProductService
          .getImageForNmId(nmId: review!.productDetails.nmId));
    }
    // Saved answers
    final answers = await fetch(() => answerService.getAllReviews());
    if (answers == null) {
      return;
    }
    setStoredAnswers(answers);

    notify();
  }

  String? _cardImage;

  String? get cardImage => _cardImage;

// Api key
  String? _apiKey;
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  String? _answer;
  String? get answer => _answer;
  void setAnswer(String value) {
    _answer = value;

    notify();
  }

  // Spell checker
  List<SpellResult>? _spellResults;

  List<SpellResult> get spellResults => _spellResults ?? [];
  // Saved answers
  List<String>? _storedAnswers;
  void setStoredAnswers(List<String> answers) {
    _storedAnswers = answers;
  }

  List<String>? get storedAnswers => _storedAnswers;

  bool _isAnswered = false;
  bool get isAnswered => _isAnswered;
  void setIsAnswered() {
    _isAnswered = true;
    notify();
  }

  Future<void> publish() async {
    if (_apiKey == null ||
        review == null ||
        _answer == null ||
        _answer!.isEmpty) {
      return;
    }

    final resultEither = await fetch(() => reviewService.publishReview(
          token: _apiKey!,
          id: review!.id,
          answer: _answer!,
          wasRejected: false,
          wasViewed: true,
        ));

    if (resultEither == null) {
      return;
    }
    setIsAnswered();
  }

  Future<List<SpellResult>> checkSpellText(String text) async {
    final spellResults = await fetch(() => spellChecker.checkText(text: text));
    if (spellResults == null) {
      return [];
    }
    return spellResults;
  }
}
