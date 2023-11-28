import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/entities/stream_advert_event.dart';

// card
abstract class MainNavigationCardService {
  Future<Resource<int>> count();
}

// advert
abstract class MainNavigationAdvertService {
  Future<Resource<List<Advert>>> getAllAdverts();
  Future<Resource<bool>> apiKeyExists();
  Future<Resource<int>> getBudget(int advertId);
  Future<Resource<bool>> stopAdvert(int advertId);
  Future<Resource<bool>> startAdvert(int advertId);
  Future<Resource<int>> getBallance();
}

class MainNavigationViewModel extends ResourceChangeNotifier {
  final MainNavigationCardService cardService;
  final MainNavigationAdvertService advertService;
  final Stream<int> cardsNumberStream;
  final Stream<StreamAdvertEvent> updatedAdvertStream;
  final Stream<bool> apiKeyExistsStream;

  MainNavigationViewModel(
      {required this.cardService,
      required this.advertService,
      required this.cardsNumberStream,
      required this.updatedAdvertStream,
      required this.apiKeyExistsStream,
      required super.internetConnectionChecker,
      required super.context}) {
    _asyncInit();
  }

  void _asyncInit() async {
    // Update in MainNavigationCardsWidget cards number
    cardsNumberStream.listen((event) {
      setCardsNumber(event);
      notify();
    });

    // Update in MainNavigationAdvertViewModel EmptyWidget or not
    apiKeyExistsStream.listen((event) {
      setApiKeyExists(event);
      notify();
    });

    // Update in MainNavigationAdvertScreen status of _AllAdvertsWidget
    updatedAdvertStream.listen((event) async {
      if (event.status != null) {
        final oldAdverts = _adverts.where((a) => a.advertId == event.advertId);
        if (oldAdverts.isEmpty) {
          return;
        }
        final newAdvert = oldAdverts.first.copyWith(status: event.status);
        updateAdvert(newAdvert);
      }

      notify();
    });

    final cardsQty = await fetch(() => cardService.count());
    if (cardsQty == null) {
      return;
    }
    setCardsNumber(cardsQty);
    final exists = await fetch(() => advertService.apiKeyExists());
    if (exists == null) {
      return;
    }
    setApiKeyExists(exists);

    if (apiKeyExists) {
      final newAdverts = await fetch(() => advertService.getAllAdverts());
      if (newAdverts == null) {
        return;
      }
    }

    notify();
  }

  // balance
  int? _balance;
  void setBalance(int? value) {
    _balance = value;
  }

  int? get balance => _balance;

  // cards num
  int _cardsNumber = 0;
  void setCardsNumber(int value) {
    _cardsNumber = value;
  }

  int get cardsNumber => _cardsNumber;

  // Adverts
  List<Advert> _adverts = [];
  void setAdverts(List<Advert> value) {
    _adverts = value;
    notify();
  }

  void updateAdvert(Advert advert) {
    _adverts.removeWhere((element) => element.advertId == advert.advertId);
    _adverts.insert(0, advert);
    notify();
  }

  List<Advert> get adverts => _adverts;

  // budget
  Map<int, int> _budget = {};
  void setBudget(Map<int, int> value) {
    _budget = value;
  }

  void addBudget(int advId, int value) {
    _budget[advId] = value;
  }

  Map<int, int> get budget => _budget;

  Future<void> updateAdverts() async {
    if (!apiKeyExists) {
      return;
    }
    final balance = await fetch(() => advertService.getBallance());
    if (balance == null) {
      return;
    }
    setBalance(balance);
    notify();

    final newAdverts = await fetch(() => advertService.getAllAdverts());
    if (newAdverts == null) {
      return;
    }
    setAdverts(newAdverts);

    for (final advert in _adverts) {
      final budget =
          await fetch(() => advertService.getBudget(advert.advertId));
      if (budget != null) {
        addBudget(advert.advertId, budget);
        notify();
      }
    }
  }

  Future<void> changeAdvertStatus(int advertId) async {
    final isPaused =
        adverts.firstWhere((adv) => adv.advertId == advertId).status ==
            AdvertStatusConstants.paused;

    if (!isPaused) {
      // now the advert is not paused
      // stop
      final _ = await fetch(() => advertService.stopAdvert(advertId));
      return;
    } else {
      // now the advert is paused
      // start
      final _ = await fetch(() => advertService.startAdvert(advertId));

      return;
    }
  }

  // ApiKeyExists
  bool _apiKeyExists = false;
  void setApiKeyExists(bool value) {
    _apiKeyExists = value;
  }

  bool get apiKeyExists => _apiKeyExists;
}