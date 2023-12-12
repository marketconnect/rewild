import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/question_model.dart';

abstract class AllProductsQuestionsCardOfProductService {
  Future<Resource<String>> getImageForNmId(int id);
}

abstract class AllProductsQuestionViewModelQuestionService {
  Future<Resource<List<QuestionModel>>> getQuestions();
  Future<Resource<bool>> apiKeyExists();
}

class AllProductsQuestionsViewModel extends ResourceChangeNotifier {
  final AllProductsQuestionViewModelQuestionService questionService;
  final AllProductsQuestionsCardOfProductService cardOfProductService;

  AllProductsQuestionsViewModel(
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
      // All Questions Qty
      incrementAllQuestionsQty(nmId);

      // New Questions Qty
      if (question.state == "suppliersPortalSynch") {
        incrementNewQuestionsQty(nmId);
      }

      // Add Questions
      addQuestion(nmId, question);

      // Image
      if (!_images.containsKey(nmId)) {
        final image = await fetch(
          () => cardOfProductService.getImageForNmId(nmId),
        );
        if (image == null) {
          continue;
        }

        addImage(nmId, image);
      }

      // SupplierArticle
      if (!_supplierArticle.containsKey(nmId)) {
        final supplierArticle = question.productDetails.supplierArticle;
        addSupplierArticle(nmId, supplierArticle);
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
  Map<int, List<QuestionModel>> _questions = {};
  void setQuestions(Map<int, List<QuestionModel>> value) {
    _questions = value;
  }

  void addQuestion(int nmId, QuestionModel question) {
    if (_questions.containsKey(nmId)) {
      _questions[nmId]!.add(question);
    } else {
      _questions[nmId] = [question];
    }
  }

  Map<int, List<QuestionModel>> get questions => _questions;

  // supplierArticles
  Map<int, String> _supplierArticle = {};
  void setSupplierArticle(Map<int, String> value) {
    _supplierArticle = value;
  }

  void addSupplierArticle(int nmId, String value) {
    if (_supplierArticle.containsKey(nmId)) {
      _supplierArticle[nmId] = value;
    } else {
      _supplierArticle[nmId] = value;
    }
  }

  String getSupplierArticle(int nmId) => _supplierArticle[nmId] ?? '';

  // new questions qty
  Map<int, int> _newQuestionsQty = {};
  void setNewQuestionsQty(Map<int, int> value) {
    _newQuestionsQty = value;
  }

  void incrementNewQuestionsQty(int nmId) {
    if (_newQuestionsQty.containsKey(nmId)) {
      _newQuestionsQty[nmId] = _newQuestionsQty[nmId]! + 1;
    } else {
      _newQuestionsQty[nmId] = 1;
    }
  }

  int newQuestionsQty(int nmId) => _newQuestionsQty[nmId] ?? 0;

  // all questions qty
  Map<int, int> _allQuestionsQty = {};
  void setAllQuestionsQty(Map<int, int> value) {
    _allQuestionsQty = value;
  }

  void incrementAllQuestionsQty(int nmId) {
    if (_allQuestionsQty.containsKey(nmId)) {
      _allQuestionsQty[nmId] = _allQuestionsQty[nmId]! + 1;
    } else {
      _allQuestionsQty[nmId] = 1;
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
