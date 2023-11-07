import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_base.dart';

// card
abstract class BottomNavigationCardService {
  Future<Resource<void>> countAndSendInStream();
}

// advert
abstract class BottomNavigationAdvertService {
  Future<Resource<void>> sendActiveAdvertsToStream();
  Future<Resource<void>> apiKeyExistsSendInStream();
}

class BottomNavigationViewModel extends ResourceChangeNotifier {
  final BottomNavigationCardService cardService;
  final BottomNavigationAdvertService advertService;
  final Stream<int> cardsNumberStream;
  final Stream<List<Advert>> advertsStream;
  final Stream<bool> apiKeyExistsStream;

  BottomNavigationViewModel(
      {required this.cardService,
      required this.advertService,
      required this.cardsNumberStream,
      required this.advertsStream,
      required this.apiKeyExistsStream,
      required super.internetConnectionChecker,
      required super.context}) {
    _asyncInit();
  }

  void _asyncInit() async {
    await fetch(() => cardService.countAndSendInStream());

    // _cardsNum = cardsLen;

    await fetch(() => advertService.sendActiveAdvertsToStream());

    await fetch(() => advertService.apiKeyExistsSendInStream());

    notify();
  }
}
