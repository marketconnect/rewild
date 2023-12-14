import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/advert_auto_model.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/entities/advert_card_model.dart';
import 'package:rewild/domain/entities/advert_catalogue_model.dart';
import 'package:rewild/domain/entities/advert_recomendation_model.dart';
import 'package:rewild/domain/entities/advert_search_model.dart';
import 'package:rewild/domain/entities/advert_search_plus_catalogue_model.dart';
import 'package:rewild/domain/entities/stream_advert_event.dart';

abstract class AllAdvertsStatScreenAdvertService {
  Future<Either<RewildError, List<Advert>>> getAll();
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, int>> getBudget(String apiKey, int campaignId);
}

abstract class AllAdvertsStatScreenCardOfProductService {
  Future<Either<RewildError, String>> getImageForNmId(int id);
}

class AllAdvertsStatScreenViewModel extends ResourceChangeNotifier {
  final AllAdvertsStatScreenAdvertService advertService;
  final AllAdvertsStatScreenCardOfProductService cardOfProductService;
  final Stream<StreamAdvertEvent> updatedAdvertStream;
  AllAdvertsStatScreenViewModel({
    required super.context,
    required super.internetConnectionChecker,
    required this.cardOfProductService,
    required this.updatedAdvertStream,
    required this.advertService,
  }) {
    _asyncInit();
  }

  void _asyncInit() async {
    SqfliteService.printTableContent('background_messages');
    SqfliteService.printTableContent('notifications');

    // Update status and cpm of cards
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
      if (event.cpm != null) {
        // TODO:
        // to update cpm of search+catalog need to update cpm of search and
        // cpm of catalog. But with only one value from the stream it is not possible.
        // So we need to update all
        if (adverts.isNotEmpty) {
          if (adverts
                  .firstWhere((a) => a.campaignId == event.campaignId)
                  .type ==
              AdvertTypeConstants.searchPlusCatalog) {
            await _update();
            return;
          }
        }

        updateCpm(event.campaignId, event.cpm.toString());
      }

      notify();
    });

    await _update();
  }

  Future _update() async {
    final resource = await advertService.apiKeyExists();
    if (resource is Error) {
      return;
    }

    setApiKeyExists(resource.data!);
    if (!apiKeyExists) {
      return;
    }
    if (!isConnected) {
      return;
    }
    final adverts = await fetch(() => advertService.getAll());
    if (adverts == null) {
      return;
    }

    List<int> campaignIds = [];
    for (final advert in adverts) {
      campaignIds.add(advert.campaignId);
      List<int> nmIds = [];
      String cpm = "";
      if (advert is AdvertCatalogueModel) {
        final params = advert.params!;
        for (final param in params) {
          if (param.nms != null) {
            final nms = param.nms!;
            final n = nms.length > 3 ? 3 : nms.length;

            nmIds = nms.map((e) => e.nm).toList().sublist(0, n);
          }
          if (param.price != null) {
            cpm = param.price!.toString();
          }
        }
      } else if (advert is AdvertCardModel) {
        final params = advert.params!;

        for (final param in params) {
          if (param.nms != null) {
            final nms = param.nms!;
            final n = nms.length > 3 ? 3 : nms.length;
            nmIds = nms.map((e) => e.nm).toList().sublist(0, n);
          }
          if (param.price != null) {
            cpm = param.price!.toString();
          }
        }
      } else if (advert is AdvertRecomendaionModel) {
        final params = advert.params!;

        for (final param in params) {
          if (param.nms != null) {
            final nms = param.nms!;
            final n = nms.length > 3 ? 3 : nms.length;
            nmIds = nms.map((e) => e.nm).toList().sublist(0, n);
          }
          if (param.price != null) {
            cpm = param.price!.toString();
          }
        }
      } else if (advert is AdvertAutoModel) {
        final params = advert.autoParams!;
        if (params.nms != null) {
          final nms = params.nms!;
          final n = nms.length > 3 ? 3 : nms.length;
          nmIds = nms.map((e) => e).toList().sublist(0, n);
        }
        if (params.cpm != null) {
          cpm = params.cpm!.toString();
        }
      } else if (advert is AdvertSearchModel) {
        final params = advert.params!;
        for (final param in params) {
          if (param.nms != null) {
            final nms = param.nms!;
            final n = nms.length > 3 ? 3 : nms.length;
            nmIds = nms.map((e) => e.nm).toList().sublist(0, n);
          }
        }
        cpm = params.first.price!.toString();
      } else if (advert is AdvertSearchPlusCatalogueModel) {
        final params = advert.unitedParams!;
        for (final param in params) {
          if (param.nms != null) {
            final nms = param.nms!;
            final n = nms.length > 3 ? 3 : nms.length;
            nmIds = nms.map((e) => e).toList().sublist(0, n);
          }
        }
        cpm =
            '${params.first.searchCPM!.toString()} + ${params.first.catalogCPM!.toString()}';
      }

      List<String> images = [];
      for (final nmId in nmIds) {
        final image = await fetch(
          () => cardOfProductService.getImageForNmId(nmId),
        );
        if (image == null) {
          continue;
        }
        images.add(image);
      }
      // final image = await fetch(
      //   () => cardOfProductService.getImageForNmId(nmIds),
      // );
      if (images.isEmpty) {
        return;
      }
      addImage(advert.campaignId, images);
      addCpm(advert.campaignId, cpm);
    }
    adverts.sort((a, b) => b.status.compareTo(a.status));
    setAdverts(adverts);

    notify();
    for (final id in campaignIds) {
      final budget = await fetch(() => advertService.getBudget(id));
      if (budget != null) {
        addBudget(id, budget);
        notify();
      }
    }
  }

  // adverts
  late List<Advert> _adverts = [];
  void setAdverts(List<Advert> value) {
    _adverts = value;
  }

  void updateAdvert(Advert advert) {
    _adverts.removeWhere((element) => element.campaignId == advert.campaignId);
    _adverts.insert(0, advert);
    notify();
  }

  List<Advert> get adverts => _adverts;

  // api key
  bool _apiKeyExists = false;
  void setApiKeyExists(bool value) {
    _apiKeyExists = value;
  }

  bool get apiKeyExists => _apiKeyExists;

  // images
  Map<int, List<String>> _image = {};
  void setImage(Map<int, List<String>> value) {
    _image = value;
  }

  void addImage(int advId, List<String> value) {
    _image[advId] = value;
  }

  List<String> images(int advId) {
    return _image[advId] ?? [];
  }

  // cpm
  Map<int, String> _cpm = {};
  void setCpm(Map<int, String> value) {
    _cpm = value;
  }

  void addCpm(int advId, String value) {
    _cpm[advId] = value;
  }

  void updateCpm(int advId, String value) {
    _cpm[advId] = value;
    notify();
  }

  String cpm(int advId) {
    return _cpm[advId] ?? "";
  }

  // budget
  Map<int, int> _budget = {};
  void setBudget(Map<int, int> value) {
    _budget = value;
  }

  void addBudget(int advId, int value) {
    _budget[advId] = value;
  }

  int? budget(int advId) {
    return _budget[advId];
  }
}
