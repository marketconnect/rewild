import 'dart:async';

import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/advert_base.dart';

import 'package:rewild/domain/entities/advert_model.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/presentation/all_adverts_screen/all_adverts_screen_view_model.dart';
import 'package:rewild/presentation/bottom_navigation_screen/bottom_navigation_view_model.dart';

abstract class AdvertServiceAdvertApiClient {
  Future<Resource<List<AdvertInfoModel>>> getAdverts(String token);
  Future<Resource<Advert>> getAdvertInfo(String token, int id);
  Future<Resource<int>> getCompanyBudget(String token, int advertId);
}

abstract class AdvertServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
}

class AdvertService
    implements AllAdvertsScreenAdvertService, BottomNavigationAdvertService {
  final AdvertServiceAdvertApiClient advertApiClient;
  final AdvertServiceApiKeyDataProvider apiKeysDataProvider;
  StreamController<List<Advert>> activeAdvertsStreamController;

  AdvertService({
    required this.advertApiClient,
    required this.apiKeysDataProvider,
    required this.activeAdvertsStreamController,
  });

  @override
  Future<Resource<bool>> apiKeyExists() async {
    final resource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (resource is Error) {
      return Resource.error(resource.message!);
    }
    if (resource is Empty) {
      return Resource.success(false);
    }
    return Resource.success(true);
  }

  DateTime? budgetLastReq;
  DateTime? advertsLastReq;

  @override
  Future<Resource<int>> getBudget(int advertId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }
    // wait request time limit (1/sec)
    await _ready(budgetLastReq, const Duration(seconds: 1));
    final budgetResource = await advertApiClient.getCompanyBudget(
        tokenResource.data!.token, advertId);
    if (budgetResource is Error) {
      return Resource.error(budgetResource.message!);
    }
    budgetLastReq ??= DateTime.now();
    return budgetResource;
  }

  Future<void> _ready(DateTime? lastReq, Duration duration) async {
    if (lastReq == null) {
      return;
    }
    while (DateTime.now().difference(lastReq) < duration) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return;
  }

  @override
  Future<Resource<List<Advert>>> getActiveAdverts() async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.error("Токен не сохранен");
    }

    final advertsResource =
        await advertApiClient.getAdverts(tokenResource.data!.token);
    if (advertsResource is Error) {
      return Resource.error(advertsResource.message!);
    }

    List<Advert> res = [];
    if (advertsResource is Empty) {
      return Resource.error(
          'Токен "Продвижение" недействителен. Пожалуйста удалите его.');
    }
    for (var advert in advertsResource.data!) {
      if (advert.status != 9) {
        continue;
      }

      await _ready(advertsLastReq, const Duration(milliseconds: 300));

      final advInfoResource = await advertApiClient.getAdvertInfo(
          tokenResource.data!.token, advert.advertId);
      if (advInfoResource is Error) {
        return Resource.error(tokenResource.message!);
      }
      res.add(advInfoResource.data!);
    }

    return Resource.success(res);
  }

  @override
  Future<Resource<List<Advert>>> getAll() async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    final advertsResource =
        await advertApiClient.getAdverts(tokenResource.data!.token);
    if (advertsResource is Error) {
      return Resource.error(advertsResource.message!);
    }

    List<Advert> res = [];
    for (var advert in advertsResource.data!) {
      if (advert.status == 7 || advert.status == 8) {
        continue;
      }

      await _ready(advertsLastReq, const Duration(milliseconds: 300));

      final advInfoResource = await advertApiClient.getAdvertInfo(
          tokenResource.data!.token, advert.advertId);
      if (advInfoResource is Error) {
        return Resource.error(advInfoResource.message!);
      }
      res.add(advInfoResource.data!);
    }
    return Resource.success(res);
  }
}
