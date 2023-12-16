import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/question_model.dart';

abstract class SingleQuestionViewModelAnswerService {
  Future<Either<RewildError, List<String>>> getAll();
}

abstract class SingleQuestionViewModelQuestionService {
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, bool>> publishQuestion(
      {required String token, required String id, required String answer});
}

class SingleQuestionViewModel extends ResourceChangeNotifier {
  final QuestionModel question;
  final SingleQuestionViewModelAnswerService answerService;
  final SingleQuestionViewModelQuestionService questionService;
  SingleQuestionViewModel(this.question,
      {required super.context,
      required super.internetConnectionChecker,
      required this.questionService,
      required this.answerService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    final apiKey = await fetch(() => questionService.getApiKey());
    if (apiKey == null) {
      return;
    }
    setApiKey(apiKey);
    // Saved answers
    final answers = await fetch(() => answerService.getAll());
    if (answers == null) {
      return;
    }
    setStoredAnswers(answers);
    notify();
  }

  // Api key
  String? _apiKey;
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  void setReusedAnswerText(String text) {
    question.setReusedAnswerText(text);
  }

  void resetReusedAnswerText() {
    question.clearReusedAnswerText();
  }

  List<String>? _storedAnswers;
  void setStoredAnswers(List<String> answers) {
    _storedAnswers = answers;
  }

  List<String>? get storedAnswers => _storedAnswers;

  Future<void> publish(String text) async {
    if (_apiKey == null) {
      return;
    }
    final result = await fetch(() => questionService.publishQuestion(
        token: _apiKey!, id: question.id, answer: text));
    if (result == null) {
      return;
    }
    if (context.mounted) Navigator.of(context).pop();
  }
}
