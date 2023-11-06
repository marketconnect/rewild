import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_base.dart';

abstract class BottomNavigationCardService {
  Future<Resource<int>> count();
}

abstract class BottomNavigationAdvertService {
  Future<Resource<List<Advert>>> getActive();
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
  int get cardsNum => _cardsNum;
  List<Advert> _adverts = [];
  void setAdverts(List<Advert> value) {
    _adverts = value;
  }

  List<Advert> get adverts => _adverts;

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
    setAdverts(fetchedActiveAdv);
    notify();
  }
}
