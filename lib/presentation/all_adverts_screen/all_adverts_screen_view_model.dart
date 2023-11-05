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
}

abstract class AllAdvertsScreenCardOfProductService {
  Future<Resource<String>> getImagesForNmIds(int id);
}

class AllAdvertsScreenViewModel extends ResourceChangeNotifier {
  final AllAdvertsScreenAdvertService advertService;
  final AllAdvertsScreenCardOfProductService cardOfProductService;
  AllAdvertsScreenViewModel({
    required super.context,
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
  void setImages(int advId, String value) {
    _image[advId] = value;
  }

  String image(int advId) {
    return _image[advId] ?? "";
  }

  // cpm
  Map<int, String> _cpm = {};
  void setCpm(int advId, String value) {
    _cpm[advId] = value;
  }

  String cpm(int advId) {
    return _cpm[advId] ?? "";
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
    final adverts = await fetch(() => advertService.getAll());
    if (adverts == null) {
      return;
    }

    for (final advert in adverts) {
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
            '${params.first.catalogCPM!.toString()} + ${params.first.searchCPM!.toString()}';
      }
      // catalog

      final image = await fetch(
        () => cardOfProductService.getImagesForNmIds(nmId),
      );
      if (image == null) {
        return;
      }
      setImages(advert.advertId, image);
      setCpm(advert.advertId, cpm);
    }

    setAdverts(adverts);
    notify();
  }
}
