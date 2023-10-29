import 'package:flutter/material.dart';
import 'package:rewild/core/utils/resource.dart';

abstract class BottomNavigationCardService {
  Future<Resource<int>> count();
}

class BottomNavigationViewModel extends ChangeNotifier {
  final BottomNavigationCardService cardService;
  final BuildContext context;

  BottomNavigationViewModel(
      {required this.cardService, required this.context}) {
    _asyncInit();
  }

  int _cardsNum = 0;
  int get cardsNum => _cardsNum;

  void _asyncInit() async {
    final cardsResource = await cardService.count();
    if (cardsResource is Error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(cardsResource.message!),
      ));
      return;
    }
    _cardsNum = cardsResource.data!;
    notifyListeners();
  }
}
