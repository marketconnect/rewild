import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/question_model.dart';
import 'package:rewild/domain/entities/spell_result.dart';

// card of product
abstract class SingleQuestionViewModelCardOfProductService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

// Answer
abstract class SingleQuestionViewModelAnswerService {
  Future<Either<RewildError, List<String>>> getAllQuestions();
}

// Question
abstract class SingleQuestionViewModelQuestionService {
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, bool>> publishQuestion(
      {required String token, required String id, required String answer});
}

// Spell checker
abstract class SingleQuestionViewModelSpellChecker {
  Future<Either<RewildError, List<SpellResult>>> checkText(
      {required String text});
}

class SingleQuestionViewModel extends ResourceChangeNotifier {
  final QuestionModel question;
  final SingleQuestionViewModelAnswerService answerService;
  final SingleQuestionViewModelQuestionService questionService;
  final SingleQuestionViewModelCardOfProductService cardOfProductService;
  final SingleQuestionViewModelSpellChecker spellChecker;
  SingleQuestionViewModel(this.question,
      {required super.context,
      required super.internetConnectionChecker,
      required this.questionService,
      required this.cardOfProductService,
      required this.spellChecker,
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
    final answers = await fetch(() => answerService.getAllQuestions());
    if (answers == null) {
      return;
    }
    _cardImage = await fetch(() => cardOfProductService.getImageForNmId(
        nmId: question.productDetails.nmId));
    setStoredAnswers(answers);
    if (question.answer != null) {
      setAnswer(question.answer!.text);
    }
    notify();
  }

  // Image
  String? _cardImage;

  String? get cardImage => _cardImage;

  // Api key
  String? _apiKey;
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  // reused answer text
  void setReusedAnswerText(String text) {
    question.setReusedAnswerText(text);
  }

  void resetReusedAnswerText() {
    question.clearReusedAnswerText();
  }

  // Saved answers
  List<String>? _storedAnswers;
  void setStoredAnswers(List<String> answers) {
    _storedAnswers = answers;
  }

  List<String>? get storedAnswers => _storedAnswers;

  // Spell checker
  List<SpellResult>? _spellResults;

  List<SpellResult> get spellResults => _spellResults ?? [];

  // Publish
  Future<void> publish() async {
    print('publish ${question.id} ${_answer} ${_apiKey}');
    if (_apiKey == null || _answer == null) {
      return;
    }

    final result = await fetch(() => questionService.publishQuestion(
        token: _apiKey!, id: question.id, answer: _answer!));
    if (result == null) {
      return;
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  String? _answer;
  String? get answer => _answer;
  void setAnswer(String value) {
    _answer = value;

    notify();
  }

  Future<List<SpellResult>> checkSpellText(String text) async {
    final spellResults = await fetch(() => spellChecker.checkText(text: text));
    if (spellResults == null) {
      return [];
    }
    return spellResults;
  }
}
