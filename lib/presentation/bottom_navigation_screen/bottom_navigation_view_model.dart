import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';

abstract class BottomNavigationCardService {
  Future<Resource<int>> count();
}

class BottomNavigationViewModel extends ResourceChangeNotifier {
  final BottomNavigationCardService cardService;

  BottomNavigationViewModel(
      {required this.cardService, required super.context}) {
    _asyncInit();
  }

  int _cardsNum = 0;
  int get cardsNum => _cardsNum;

  void _asyncInit() async {
    final cardsLen = await fetch(() => cardService.count());
    if (cardsLen == null) {
      return;
    }

    _cardsNum = cardsLen;
    notify();
  }
}
