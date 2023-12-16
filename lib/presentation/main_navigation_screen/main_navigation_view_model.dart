import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_base.dart';

import 'package:rewild/domain/entities/stream_advert_event.dart';

// card
abstract class MainNavigationCardService {
  Future<Either<RewildError, int>> count();
}

// question
abstract class MainNavigationQuestionService {
  Future<Either<RewildError, String?>> getApiKey();
}

// advert
abstract class MainNavigationAdvertService {
  Future<Either<RewildError, List<Advert>>> getAllAdverts(
      {required String token});
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, int>> getBudget(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> checkAdvertIsActive(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> stopAdvert(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> startAdvert(
      {required String token, required int campaignId});
  Future<Either<RewildError, int?>> getBallance({required String token});
}

class MainNavigationViewModel extends ResourceChangeNotifier {
  final MainNavigationCardService cardService;
  final MainNavigationAdvertService advertService;
  final MainNavigationQuestionService questionService;

  final Stream<int> cardsNumberStream;
  final Stream<StreamAdvertEvent> updatedAdvertStream;
  final Stream<Map<ApiKeyType, String>> apiKeyExistsStream;

  MainNavigationViewModel(
      {required this.cardService,
      required this.advertService,
      required this.questionService,
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
    // TODO - Update in FeedbackScreen
    apiKeyExistsStream.listen((event) {
      if (event[ApiKeyType.promo] != null) {
        setAdvertApiKey(event[ApiKeyType.promo]!);
      } else if (event[ApiKeyType.question] != null) {
        setFeedbackApiKey(event[ApiKeyType.question]!);
      }
      notify();
    });

    // Update in MainNavigationAdvertScreen status of _AllAdvertsWidget
    updatedAdvertStream.listen((event) async {
      if (event.status != null) {
        final oldAdverts =
            _adverts.where((a) => a.campaignId == event.campaignId);
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
    // Api keys exist
    // Advert
    final advertApiKey = await fetch(() => advertService.getApiKey());
    if (advertApiKey == null) {
      return;
    }
    setAdvertApiKey(advertApiKey);

    final newAdverts =
        await fetch(() => advertService.getAllAdverts(token: _advertApiKey!));
    if (newAdverts == null) {
      return;
    }
    // Question
    final questionApiKey = await fetch(() => questionService.getApiKey());
    if (questionApiKey == null) {
      return;
    }
    setFeedbackApiKey(questionApiKey);

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
    _adverts.removeWhere((element) => element.campaignId == advert.campaignId);
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
    if (_advertApiKey == null) {
      return;
    }
    final balance =
        await fetch(() => advertService.getBallance(token: _advertApiKey!));
    if (balance == null) {
      return;
    }
    setBalance(balance);
    notify();

    final newAdverts =
        await fetch(() => advertService.getAllAdverts(token: _advertApiKey!));
    if (newAdverts == null) {
      return;
    }
    setAdverts(newAdverts);

    for (final advert in _adverts) {
      final budget = await fetch(() => advertService.getBudget(
          token: _advertApiKey!, campaignId: advert.campaignId));
      if (budget != null) {
        addBudget(advert.campaignId, budget);
        notify();
      }
    }
  }

  Future<void> changeAdvertStatus(int campaignId) async {
    final isPaused =
        adverts.firstWhere((adv) => adv.campaignId == campaignId).status ==
            AdvertStatusConstants.paused;
    if (_advertApiKey == null) {
      return;
    }

    if (!isPaused) {
      // now the advert is not paused
      // stop
      final _ = await fetch(() => advertService.stopAdvert(
          token: _advertApiKey!, campaignId: campaignId));
      return;
    } else {
      // now the advert is paused
      // start
      final _ = await fetch(() => advertService.startAdvert(
          token: _advertApiKey!, campaignId: campaignId));

      return;
    }
  }

  // ApiKeysExists
  String? _advertApiKey;
  void setAdvertApiKey(String value) {
    _advertApiKey = value;
  }

  bool get advertApiKeyExists => _advertApiKey != null;

  String? _feedbackApiKey;
  void setFeedbackApiKey(String value) {
    _feedbackApiKey = value;
  }

  bool get feedbackApiKeyExists => _feedbackApiKey != null;
}
