import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/question.dart';

abstract class QuestionsCardOfProductService {
  Future<Resource<String>> getImageForNmId(int id);
}

abstract class QuestionViewModelQuestionService {
  Future<Resource<List<Question>>> getQuestions();
  Future<Resource<bool>> apiKeyExists();
}

class QuestionsViewModel extends ResourceChangeNotifier {
  final QuestionViewModelQuestionService questionService;
  final QuestionsCardOfProductService cardOfProductService;

  QuestionsViewModel(
      {required super.context,
      required super.internetConnectionChecker,
      required this.cardOfProductService,
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
    final questions = await fetch(() => questionService.getQuestions());
    if (questions == null) {
      return;
    }
    for (final question in questions) {
      final nmId = question.productDetails.nmId;
      addQuestion(nmId, question);

      if (!_images.containsKey(nmId)) {
        final image = await fetch(
          () => cardOfProductService.getImageForNmId(nmId),
        );
        if (image == null) {
          continue;
        }
        print("image $image");
        addImage(nmId, image);
      }
    }
    notify();
  }

  // Images
  Map<int, String> _images = {};
  void setImages(Map<int, String> value) {
    _images = value;
  }

  void addImage(int nmId, String value) {
    _images[nmId] = value;
  }

  String getImage(int nmId) => _images[nmId] ?? '';

  // Questions
  Map<int, List<Question>> _questions = {};
  void setQuestions(Map<int, List<Question>> value) {
    _questions = value;
  }

  void addQuestion(int nmId, Question question) {
    if (_questions.containsKey(nmId)) {
      _questions[nmId]!.add(question);
    } else {
      _questions[nmId] = [question];
    }
  }

  Map<int, List<Question>> get questions => _questions;

  // new questions qty
  Map<int, int> _newQuestionsQty = {};
  void setNewQuestionsQty(Map<int, int> value) {
    _newQuestionsQty = value;
  }

  void addNewQuestionsQty(int nmId, int value) {
    if (_newQuestionsQty.containsKey(nmId)) {
      _newQuestionsQty[nmId] = _newQuestionsQty[nmId]! + value;
    } else {
      _newQuestionsQty[nmId] = value;
    }
  }

  int newQuestionsQty(int nmId) => _newQuestionsQty[nmId] ?? 0;

  // all questions qty
  Map<int, int> _allQuestionsQty = {};
  void setAllQuestionsQty(Map<int, int> value) {
    _allQuestionsQty = value;
  }

  void addAllQuestionsQty(int nmId, int value) {
    if (_allQuestionsQty.containsKey(nmId)) {
      _allQuestionsQty[nmId] = _allQuestionsQty[nmId]! + value;
    } else {
      _allQuestionsQty[nmId] = value;
    }
  }

  int allQuestionsQty(int nmId) => _allQuestionsQty[nmId] ?? 0;

  // ApiKeyExists
  bool _apiKeyExists = false;
  void setApiKeyExists(bool value) {
    _apiKeyExists = value;
    notify();
  }

  bool get apiKeyExists => _apiKeyExists;
}
