import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_base.dart';

// card
abstract class BottomNavigationCardService {
  Future<Resource<int>> count();
}

// advert
abstract class BottomNavigationAdvertService {
  Future<Resource<List<Advert>>> getActive();
  Future<Resource<bool>> apiKeyExists();
}

class BottomNavigationViewModel extends ResourceChangeNotifier {
  final BottomNavigationCardService cardService;
  final BottomNavigationAdvertService advertService;

  BottomNavigationViewModel(
      {required this.cardService,
      required this.advertService,
      required super.internetConnectionChecker,
      required super.context}) {
    _asyncInit();
  }

  int _cardsNum = 0;
  void setCardsNum(int value) {
    _cardsNum = value;
  }

  int get cardsNum => _cardsNum;
  List<Advert> _adverts = [];
  void setAdverts(List<Advert> value) {
    _adverts = value;
  }

  List<Advert> get adverts => _adverts;

  bool _apiKeyExists = false;
  void setApiKeyExists(bool value) {
    _apiKeyExists = value;
  }

  bool get apiKeyExists => _apiKeyExists;

  Future<void> updateIsApiKeySaved() async {
    final isApiKeySaved = await fetch(() => advertService.apiKeyExists());
    if (isApiKeySaved == null) {
      return;
    }
    setApiKeyExists(isApiKeySaved);
  }

  Future<void> updateAdvertScreen() async {
    print("update advert");
    final fetchedActiveAdv = await fetch(() => advertService.getActive());
    if (fetchedActiveAdv == null) {
      return;
    }
    final isApiKeySaved = await fetch(() => advertService.apiKeyExists());
    if (isApiKeySaved == null) {
      return;
    }
    setApiKeyExists(isApiKeySaved);
    setAdverts(fetchedActiveAdv);
  }

  Future<void> updateCardsScreen() async {
    print("update cards");
    final cardsLen = await fetch(() => cardService.count());
    if (cardsLen == null) {
      return;
    }
    _cardsNum = cardsLen;
  }

  void _asyncInit() async {
    final cardsLen = await fetch(() => cardService.count());
    if (cardsLen == null) {
      return;
    }
    _cardsNum = cardsLen;
    final fetchedActiveAdv = await fetch(() => advertService.getActive());
    if (fetchedActiveAdv == null) {
      return;
    }
    final isApiKeySaved = await fetch(() => advertService.apiKeyExists());
    if (isApiKeySaved == null) {
      return;
    }
    setApiKeyExists(isApiKeySaved);
    setAdverts(fetchedActiveAdv);
    notify();
  }
}
