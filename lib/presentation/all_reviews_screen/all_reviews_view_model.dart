import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/nums.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/review_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

// Reviews service
abstract class AllReviewsViewModelReviewService {
  Future<Either<RewildError, bool>> apiKeyExists();
  Future<Either<RewildError, List<ReviewModel>>> getReviews({
    required int take,
    required int skip,
    required int dateFrom,
    required int dateTo,
    int? nmId,
  });
}

// Answers service
abstract class AllReviewsViewModelAnswerService {
  Future<Either<RewildError, bool>> insert(
      {required String questionId, required String answer});
  Future<Either<RewildError, bool>> delete({
    required String questionId,
  });

  Future<Either<RewildError, List<String>>> getAllQuestionsIds();
}

class AllReviewsViewModel extends ResourceChangeNotifier {
  final AllReviewsViewModelReviewService reviewService;
  final AllReviewsViewModelAnswerService answerService;
  final int nmId;

  AllReviewsViewModel(this.nmId,
      {required super.context,
      required super.internetConnectionChecker,
      required this.answerService,
      required this.reviewService}) {
    _asyncInit();
  }

  void _asyncInit() async {
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
    // await _firstLoad();
    int n = 0;
    while (true) {
      final reviews = await fetch(() => reviewService.getReviews(
            nmId: nmId,
            take: NumericConstants.takeFeedbacksAtOnce,
            skip: NumericConstants.takeFeedbacksAtOnce * n,
            dateFrom: unixTimestamp2019(),
            dateTo: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          ));
      if (reviews == null) {
        break;
      }
      allReviews.addAll(reviews);
      if (reviews.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
      n++;
    }

    // Questions
    setReviews(allReviews);

    // Saved answers
    final answers = await fetch(() => answerService.getAllQuestionsIds());
    if (answers == null) {
      return;
    }

    setSavedAnswersQuestionsIds(answers);

    notify();
  }

  // PAGINATION
  // final int _limit = NumericConstants.takeReviewsAtOnce;
  // int get limit => _limit;

  // bool _isFirstLoadRunning = false;
  // void setFirstLoadRunning(bool value) {
  //   _isFirstLoadRunning = value;
  //   notify();
  // }

  // bool get isFirstLoadRunning => _isFirstLoadRunning;

  // int _page = 0;
  // void setPage(int value) {
  //   _page = value;
  //   notify();
  // }

  // Future<void> _firstLoad() async {
  //   setFirstLoadRunning(true);
  //   final reviews = await fetch(() => reviewService.getReviews(
  //         nmId: nmId,
  //         take: NumericConstants.takeFeedbacksAtOnce,
  //         dateFrom: unixTimestamp2019(),
  //         dateTo: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  //         skip: 0,
  //       ));
  //   if (reviews == null) {
  //     setFirstLoadRunning(false);
  //     return;
  //   }
  //   setReviews(reviews);

  //   setFirstLoadRunning(false);
  // }

  // ApiKeyExists
  bool _apiKeyExists = false;
  void setApiKeyExists(bool value) {
    _apiKeyExists = value;
    notify();
  }

  bool get apiKeyExists => _apiKeyExists;

  // Questions
  List<ReviewModel>? _reviews;
  void setReviews(List<ReviewModel> value) {
    _reviews = value;
  }

  List<ReviewModel> get reviews => _reviews ?? [];

  // Answer to reuse
  String? _answerToReuseQuestionId;
  String get answerToReuseQuestionId => _answerToReuseQuestionId ?? "";

  String? _answerToReuseText;
  void setAnswerToReuse(String value, String questionId) {
    _answerToReuseQuestionId = questionId;

    _answerToReuseText = value;
  }

  void clearAnswerToReuse() {
    _answerToReuseQuestionId = "";
    _answerToReuseText = null;
  }

  void routeToSingleReviewScreen(ReviewModel review) {
    if (_answerToReuseText != null) {
      review.setReusedAnswerText(_answerToReuseText!);

      _answerToReuseText = null;
    }
    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.singleQuestionScreen,
        arguments: review);
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  void setSearchQuery(String query) {
    _searchQuery = query;

    notify();
  }

  void clearSearchQuery() {
    _searchQuery = "";
    notify();
  }

  List<String>? _savedAnswersQuestionsIds;
  void setSavedAnswersQuestionsIds(List<String> savedAnswersQuestionsIds) {
    _savedAnswersQuestionsIds = savedAnswersQuestionsIds;
  }

  bool isAnswerSaved(String questionId) =>
      _savedAnswersQuestionsIds != null &&
      _savedAnswersQuestionsIds!.contains(questionId);

  // save answer in db
  Future<bool> saveAnswer(String questionId) async {
    final answer =
        reviews.firstWhere((element) => element.id == questionId).answer;
    if (answer == null) {
      return false;
    }
    if (_savedAnswersQuestionsIds != null) {
      _savedAnswersQuestionsIds!.add(questionId);
    } else {
      _savedAnswersQuestionsIds = [questionId];
    }
    final answerText = answer.text;
    final ok = await fetch(
        () => answerService.insert(questionId: questionId, answer: answerText));
    if (ok == null) {
      return false;
    }
    notify();
    return ok;
  }

  // Delete answer from db
  Future<bool> deleteAnswer(String questionId) async {
    if (_savedAnswersQuestionsIds != null) {
      _savedAnswersQuestionsIds!.remove(questionId);
    }

    final ok = await fetch(() => answerService.delete(questionId: questionId));
    if (ok == null) {
      return false;
    }
    notify();
    return ok;
  }
}
