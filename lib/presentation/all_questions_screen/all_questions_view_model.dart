import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/question.dart';

abstract class AllQuestionsViewModelQuestionService {
  Future<Resource<List<Question>>> getQuestions(int nmId);
  Future<Resource<bool>> apiKeyExists();
}

class AllQuestionsViewModel extends ResourceChangeNotifier {
  final AllQuestionsViewModelQuestionService questionService;
  final int nmId;

  AllQuestionsViewModel(this.nmId,
      {required super.context,
      required super.internetConnectionChecker,
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
    final questions = await fetch(() => questionService.getQuestions(nmId));
    if (questions == null) {
      return;
    }

    setQuestions(questions);

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
  List<Question>? _questions;
  void setQuestions(List<Question> value) {
    _questions = value;
  }

  List<Question> get questions => _questions ?? [];
}
