import 'package:flutter/material.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/question_model.dart';

abstract class SingleQuestionViewModelAnswerService {
  Future<Either<RewildError, List<String>>> getAll();
}

abstract class SingleQuestionViewModelQuestionService {
  Future<Either<RewildError, bool>> publishQuestion(String id, String answer);
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
    // Saved answers
    final answers = await fetch(() => answerService.getAll());
    if (answers == null) {
      return;
    }
    setStoredAnswers(answers);
    notify();
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
    final result =
        await fetch(() => questionService.publishQuestion(question.id, text));
    if (result == null) {
      return;
    }
    if (context.mounted) Navigator.of(context).pop();
  }
}
