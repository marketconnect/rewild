import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_base.dart';

// card
abstract class BottomNavigationCardService {
  Future<Resource<int>> count();
}

// advert
abstract class BottomNavigationAdvertService {
  Future<Resource<List<Advert>>> getActiveAdverts();
  Future<Resource<bool>> apiKeyExists();
  Future<Resource<int>> getBudget(int advertId);
  Future<Resource<bool>> stopAdvert(int advertId);
  Future<Resource<bool>> startAdvert(int advertId);
  Future<Resource<int>> getBallance(int advertId);
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
    final balance = await fetch(() => advertService.getBallance(0));
    if (balance == null) {
      return;
    }
    setBalance(balance);
    notify();

    final newAdverts = await fetch(() => advertService.getActiveAdverts());
    if (newAdverts == null) {
      return;
    }
    setAdverts(newAdverts);
    notify();
    final advertIds = _adverts.map((e) => e.advertId).toList();
    for (final id in advertIds) {
      final budget = await fetch(() => advertService.getBudget(id));
      if (budget != null) {
        addBudget(id, budget);
        notify();
      }
    }
  }

  Map<int, bool> _paused = {};
  Map<int, bool> get paused => _paused;
  void setPausedMap(Map<int, bool> value) {
    _paused = value;
  }

  void setPaused(int advId) {
    _paused[advId] = true;
    notify();
  }

  void unSetPaused(int advId) {
    _paused[advId] = false;
    notify();
  }

  Future<void> changeAdvertStatus(int advertId) async {
    final isPaused = paused[advertId] ?? false;

    if (!isPaused) {
      // now the advert is not paused
      // stop
      final adv = await fetch(() => advertService.stopAdvert(advertId));

      if (adv == null || !adv) {
        // could not stop
        unSetPaused(advertId); // still active
        return;
      }
      // done
      setPaused(advertId);
      return;
    } else {
      // now the advert is paused
      // start
      final adv = await fetch(() => advertService.startAdvert(advertId));

      if (adv == null || !adv) {
        // could not start
        setPaused(advertId); // still paused
        return;
      }

      // done
      unSetPaused(advertId); // now active
      return;
    }
  }

  // Future<bool> stopAdvert(int id) async {
  //   final adv = await fetch(() => advertService.stopAdvert(id));
  //   if (adv == null) {
  //     return false;
  //   }
  //   if (adv) {
  //     setPaused(id);
  //   } else {
  //     unSetPaused(id);
  //   }
  //   notify();
  //   return adv;
  // }

  // Future<bool> startAdvert(int id) async {
  //   final adv = await fetch(() => advertService.stopAdvert(id));
  //   if (adv == null) {
  //     return false;
  //   }
  //   if (adv) {
  //     unSetPaused(id);
  //   } else {
  //     setPaused(id);
  //   }
  //   return adv;
  // }

  // ApiKeyExists
  bool _apiKeyExists = false;
  void setApiKeyExists(bool value) {
    _apiKeyExists = value;
  }

  bool get apiKeyExists => _apiKeyExists;

  void _asyncInit() async {
    cardsNumberStream.listen((event) {
      setCardsNumber(event);
      notify();
    });
    apiKeyExistsStream.listen((event) {
      setApiKeyExists(event);
      notify();
    });

    advertsStream.listen((event) {
      setAdverts(event);
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
      final newAdverts = await fetch(() => advertService.getActiveAdverts());
      if (newAdverts == null) {
        return;
      }
    }

    notify();
  }
}
