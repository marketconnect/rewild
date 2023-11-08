import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/domain/entities/advert_auto_model.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/entities/advert_card_model.dart';
import 'package:rewild/domain/entities/advert_catalogue_model.dart';
import 'package:rewild/domain/entities/advert_recomendation_model.dart';
import 'package:rewild/domain/entities/advert_search_model.dart';
import 'package:rewild/domain/entities/advert_search_plus_catalogue_model.dart';

abstract class AllAdvertsScreenAdvertService {
  Future<Resource<List<Advert>>> getAll();
  Future<Resource<bool>> apiKeyExists();
  Future<Resource<int>> getBudget(int advertId);
}

abstract class AllAdvertsScreenCardOfProductService {
  Future<Resource<String>> getImageForNmId(int id);
}

class AllAdvertsScreenViewModel extends ResourceChangeNotifier {
  final AllAdvertsScreenAdvertService advertService;
  final AllAdvertsScreenCardOfProductService cardOfProductService;
  AllAdvertsScreenViewModel({
    required super.context,
    required super.internetConnectionChecker,
    required this.cardOfProductService,
    required this.advertService,
  }) {
    _asyncInit();
  }

  // adverts
  late List<Advert> _adverts = [];
  void setAdverts(List<Advert> value) {
    _adverts = value;
  }

  List<Advert> get adverts => _adverts;

  // api key
  bool _apiKeyExists = false;
  void setApiKeyExists(bool value) {
    _apiKeyExists = value;
  }

  bool get apiKeyExists => _apiKeyExists;

  // images
  Map<int, String> _image = {};
  void setImage(Map<int, String> value) {
    _image = value;
  }

  void addImage(int advId, String value) {
    _image[advId] = value;
  }

  String image(int advId) {
    return _image[advId] ?? "";
  }

  // cpm
  Map<int, String> _cpm = {};
  void setCpm(Map<int, String> value) {
    _cpm = value;
  }

  void addCpm(int advId, String value) {
    _cpm[advId] = value;
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

  void _asyncInit() async {
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

    List<int> advertIds = [];
    for (final advert in adverts) {
      advertIds.add(advert.advertId);
      int nmId = 0;
      String cpm = "";
      if (advert is AdvertCatalogueModel) {
        final params = advert.params!;
        for (final param in params) {
          if (param.nms != null) {
            nmId = param.nms!.map((e) => e.nm).first;
          }
          if (param.price != null) {
            cpm = param.price!.toString();
          }
        }
      } else if (advert is AdvertCardModel) {
        final params = advert.params!;

        for (final param in params) {
          if (param.nms != null) {
            nmId = param.nms!.map((e) => e.nm).first;
          }
          if (param.price != null) {
            cpm = param.price!.toString();
          }
        }
      } else if (advert is AdvertRecomendaionModel) {
        final params = advert.params!;

        for (final param in params) {
          if (param.nms != null) {
            nmId = param.nms!.map((e) => e.nm).first;
          }
          if (param.price != null) {
            cpm = param.price!.toString();
          }
        }
      } else if (advert is AdvertAutoModel) {
        final params = advert.autoParams!;
        if (params.nms != null) {
          nmId = params.nms!.map((e) => e).first;
        }
        if (params.cpm != null) {
          cpm = params.cpm!.toString();
        }
      } else if (advert is AdvertSearchModel) {
        final params = advert.params!;
        for (final param in params) {
          if (param.nms != null) {
            nmId = param.nms!.map((e) => e.nm).first;
          }
        }
        cpm = params.first.price!.toString();
      } else if (advert is AdvertSearchPlusCatalogueModel) {
        final params = advert.unitedParams!;
        for (final param in params) {
          if (param.nms != null) {
            nmId = param.nms!.map((e) => e).first;
          }
        }
        cpm =
            '${params.first.searchCPM!.toString()} + ${params.first.catalogCPM!.toString()}';
      }
      // catalog

      final image = await fetch(
        () => cardOfProductService.getImageForNmId(nmId),
      );
      if (image == null) {
        return;
      }
      addImage(advert.advertId, image);
      addCpm(advert.advertId, cpm);
    }
    adverts.sort((a, b) => b.status.compareTo(a.status));
    setAdverts(adverts);

    notify();
    for (final id in advertIds) {
      final budget = await fetch(() => advertService.getBudget(id));
      if (budget != null) {
        addBudget(id, budget);
        notify();
      }
    }
  }
}
