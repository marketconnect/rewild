import 'dart:convert';

import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';

import 'package:rewild/domain/entities/card_of_product_model.dart';

abstract class MyWebViewScreenViewModelUpdateService {
  Future<Resource<int>> insert(String token, List<CardOfProductModel> cards);
}

abstract class MyWebViewScreenViewModelTokenProvider {
  Future<Resource<String>> getToken();
}

class MyWebViewScreenViewModel extends ResourceChangeNotifier {
  MyWebViewScreenViewModel(
      {required this.updateService,
      required super.internetConnectionChecker,
      required this.tokenProvider,
      required super.context});
  final MyWebViewScreenViewModelUpdateService updateService;
  final MyWebViewScreenViewModelTokenProvider tokenProvider;
  bool isLoading = false;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  set errorMessage(String? errorMessage) {
    _errorMessage = errorMessage;
    notify();
  }

  Future<int> saveSiblingCards(String jsonString) async {
    isLoading = true;
    notify();
    final cardsListResource = _parseCards(jsonString);
    if (cardsListResource is Error) {
      errorMessage = cardsListResource.message;
      isLoading = false;
      notify();
      return 0;
    }

    final cardsList = cardsListResource.data!;

    // get token
    final tokenResource = await tokenProvider.getToken();
    if (tokenResource is Error) {
      errorMessage = tokenResource.message;

      isLoading = false;
      notify();
    }

    if (tokenResource is Success) {
      final token = tokenResource.data!;
      final resource = await updateService.insert(token, cardsList);
      if (resource is Success) {
        isLoading = false;
        notify();
        return resource.data!;
      }
    }

    return 0;
  }

  Resource<List<CardOfProductModel>> _parseCards(String jsonString) {
    try {
      List<dynamic> jsonList = json.decode(jsonString);
      List<CardOfProductModel> cards = [];

      for (var jsonObject in jsonList) {
        cards.add(
            CardOfProductModel(nmId: jsonObject['id'], img: jsonObject['img']));
      }

      return Resource.success(cards);
    } catch (e) {
      return Resource.error(e.toString());
    }
  }
}
