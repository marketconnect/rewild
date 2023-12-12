import 'package:flutter/material.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/question_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

abstract class AllQuestionsViewModelQuestionService {
  Future<Resource<List<QuestionModel>>> getQuestions({
    int? nmId,
    required int take,
    required int skip,
  });
  Future<Resource<bool>> apiKeyExists();
}

abstract class AllQuestionsViewModelAnswerService {
  Future<Resource<bool>> insert(String questionId, String answer);
  Future<Resource<bool>> delete(
    String questionId,
  );

  Future<Resource<List<String>>> getAllQuestionsIds();
}

class AllQuestionsViewModel extends ResourceChangeNotifier {
  final AllQuestionsViewModelQuestionService questionService;
  final AllQuestionsViewModelAnswerService answerService;
  final int nmId;

  AllQuestionsViewModel(this.nmId,
      {required super.context,
      required super.internetConnectionChecker,
      required this.answerService,
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
    // get questions
    List<QuestionModel> allQuestions = [];
    int n = 0;
    while (true) {
      final questions = await fetch(() => questionService.getQuestions(
            nmId: nmId,
            take: NumericConstants.takeFeedbacksAtOnce,
            skip: NumericConstants.takeFeedbacksAtOnce * n,
          ));
      if (questions == null) {
        break;
      }
      allQuestions.addAll(questions);
      if (questions.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
      n++;
    }

    // Questions
    setQuestions(allQuestions);

    // Saved answers
    final answers = await fetch(() => answerService.getAllQuestionsIds());
    if (answers == null) {
      return;
    }

    setSavedAnswersQuestionsIds(answers);

    notify();
  }

  // ApiKeyExists
  bool _apiKeyExists = false;
  void setApiKeyExists(bool value) {
    _apiKeyExists = value;
    notify();
  }

  bool get apiKeyExists => _apiKeyExists;

  // Questions
  List<QuestionModel>? _questions;
  void setQuestions(List<QuestionModel> value) {
    _questions = value;
  }

  List<QuestionModel> get questions => _questions ?? [];

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

  void routeToSingleQuestionScreen(QuestionModel question) {
    if (_answerToReuseText != null) {
      question.setReusedAnswerText(_answerToReuseText!);

      _answerToReuseText = null;
    }
    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.singleQuestionScreen,
        arguments: question);
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
        questions.firstWhere((element) => element.id == questionId).answer;
    if (answer == null) {
      return false;
    }
    if (_savedAnswersQuestionsIds != null) {
      _savedAnswersQuestionsIds!.add(questionId);
    } else {
      _savedAnswersQuestionsIds = [questionId];
    }
    final answerText = answer.text;
    final ok = await fetch(() => answerService.insert(questionId, answerText));
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

    final ok = await fetch(() => answerService.delete(questionId));
    if (ok == null) {
      return false;
    }
    notify();
    return ok;
  }
}
