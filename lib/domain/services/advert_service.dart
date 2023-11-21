import 'dart:async';

import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/advert_base.dart';

import 'package:rewild/domain/entities/advert_model.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:rewild/presentation/adverts_tools_screen/adverts_tools_view_model.dart';

import 'package:rewild/presentation/all_adverts_screen/all_adverts_screen_view_model.dart';
import 'package:rewild/presentation/auto_stats_words_screen/auto_stats_words_view_model.dart';
import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';
import 'package:rewild/presentation/bottom_navigation_screen/bottom_navigation_view_model.dart';

// API
abstract class AdvertServiceAdvertApiClient {
  Future<Resource<List<AdvertInfoModel>>> getAdverts(String token);
  Future<Resource<Advert>> getAdvertInfo(String token, int id);
  Future<Resource<int>> getCompanyBudget(String token, int advertId);
  Future<Resource<int>> balance(String token);
  Future<Resource<AdvertStatModel>> getAutoStat(String token, int advertId);
  // Post
  Future<Resource<bool>> pauseAdvert(String token, int advertId);
  Future<Resource<bool>> startAdvert(String token, int advertId);
  Future<Resource<bool>> changeCpm(String token, int advertId, int type,
      int cpm, int param, int? instrument);
  Future<Resource<bool>> setAutoSetExcluded(
      String token, int advertId, List<String> excludedKw);
}

// Api key
abstract class AdvertServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
}

class AdvertService
    implements
        AllAdvertsScreenAdvertService,
        SingleAdvertStatsViewModelAdvertService,
        AutoStatsWordsAdvertService,
        AdvertsToolsAdvertService,
        BottomNavigationAdvertService {
  final AdvertServiceAdvertApiClient advertApiClient;
  final AdvertServiceApiKeyDataProvider apiKeysDataProvider;

  AdvertService({
    required this.advertApiClient,
    required this.apiKeysDataProvider,
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

  DateTime? advertsLastReq;
  DateTime? changeCpmLastReq;
  DateTime? advertLastReq;
  DateTime? budgetLastReq;
  DateTime? pauseLastReq;
  DateTime? startLastReq;
  DateTime? balanceLastReq;
  DateTime? autoExcludedLastReq;

  @override
  Future<Resource<int>> getBallance(int advertId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    if (balanceLastReq != null) {
      await _ready(balanceLastReq, APIConstants.balanceDurationBetweenReqInMs);
    }
    final balanceResource =
        await advertApiClient.balance(tokenResource.data!.token);
    balanceLastReq = DateTime.now();
    if (balanceResource is Error) {
      return Resource.error(balanceResource.message!);
    }
    return balanceResource;
  }

  @override
  Future<Resource<int>> getBudget(int advertId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // request to API

    if (budgetLastReq != null) {
      await _ready(budgetLastReq, APIConstants.budgetDurationBetweenReqInMs);
    }

    final budgetResource = await advertApiClient.getCompanyBudget(
        tokenResource.data!.token, advertId);
    budgetLastReq = DateTime.now();

    if (budgetResource is Error) {
      return Resource.error(budgetResource.message!);
    }
    return budgetResource;
  }

  @override
  Future<Resource<List<Advert>>> getAllAdverts() async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.error("Токен не сохранен");
    }

    // request to API
    if (advertsLastReq != null) {
      await _ready(advertsLastReq, APIConstants.advertsDurationBetweenReqInMs);
    }

    final advertsResource =
        await advertApiClient.getAdverts(tokenResource.data!.token);
    advertsLastReq = DateTime.now();

    if (advertsResource is Error) {
      return Resource.error(advertsResource.message!);
    }

    if (advertsResource is Empty) {
      return Resource.error(
          'Токен "Продвижение" недействителен. Пожалуйста удалите его.');
    }
    List<Advert> res = [];

    for (var advert in advertsResource.data!) {
      if (advert.status != 9 && advert.status != 11) {
        continue;
      }

      // requst to API
      if (advertLastReq != null) {
        await _ready(advertLastReq, APIConstants.advertDurationBetweenReqInMs);
      }

      final advInfoResource = await advertApiClient.getAdvertInfo(
          tokenResource.data!.token, advert.advertId);
      advertLastReq = DateTime.now();

      if (advInfoResource is Error) {
        return Resource.error(advInfoResource.message!);
      }
      res.add(advInfoResource.data!);
    }

    return Resource.success(res);
  }

  @override
  Future<Resource<Advert>> advertInfo(int advertId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }

    // request
    final advInfoResource = await advertApiClient.getAdvertInfo(
        tokenResource.data!.token, advertId);
    advertLastReq = DateTime.now();
    if (advInfoResource is Error) {
      return Resource.error(advInfoResource.message!);
    }

    return Resource.success(advInfoResource.data!);
  }

  @override
  Future<Resource<bool>> setAutoExcluded(
      int advertId, List<String> excluded) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // request to API
    if (autoExcludedLastReq != null) {
      await _ready(autoExcludedLastReq,
          APIConstants.autoSetExcludedDurationBetweenReqInMs);
    }

    final autoExcludedResource = await advertApiClient.setAutoSetExcluded(
        tokenResource.data!.token, advertId, excluded);
    autoExcludedLastReq = DateTime.now();
    if (autoExcludedResource is Error) {
      return Resource.error(autoExcludedResource.message!);
    }
    return Resource.success(autoExcludedResource.data!);
  }

  @override
  Future<Resource<bool>> setCpm(
      {required int advertId,
      required int type,
      required int cpm,
      required int param,
      int? instrument}) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // request to API
    if (changeCpmLastReq != null) {
      await _ready(changeCpmLastReq, APIConstants.cpmDurationBetweenReqInMs);
    }
    final changeCpmResource = await advertApiClient.changeCpm(
        tokenResource.data!.token, advertId, type, cpm, param, instrument);
    changeCpmLastReq = DateTime.now();
    if (changeCpmResource is Error) {
      return Resource.error(changeCpmResource.message!);
    }
    return Resource.success(changeCpmResource.data!);
  }

  @override
  Future<Resource<List<AdvertInfoModel>>> getByType(int type) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // request to API

    if (advertsLastReq != null) {
      await _ready(advertsLastReq, APIConstants.advertsDurationBetweenReqInMs);
    }

    final advertsResource =
        await advertApiClient.getAdverts(tokenResource.data!.token);
    advertsLastReq = DateTime.now();
    if (advertsResource is Error) {
      return Resource.error(advertsResource.message!);
    }

    List<AdvertInfoModel> res = [];
    if (advertsResource is Empty) {
      return Resource.success(res);
    }

    for (var advert in advertsResource.data!) {
      if (advert.status == 7 || advert.status == 8) {
        continue;
      }
      if (advert.type != type) {
        continue;
      }
      res.add(advert);
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

    // request to API

    if (advertsLastReq != null) {
      await _ready(advertsLastReq, APIConstants.advertsDurationBetweenReqInMs);
    }

    final advertsResource =
        await advertApiClient.getAdverts(tokenResource.data!.token);
    advertsLastReq = DateTime.now();
    if (advertsResource is Error) {
      return Resource.error(advertsResource.message!);
    }

    List<Advert> res = [];
    if (advertsResource is Empty) {
      return Resource.success(res);
    }

    for (var advert in advertsResource.data!) {
      if (advert.status == 7 || advert.status == 8) {
        continue;
      }

      await _ready(advertLastReq, APIConstants.advertDurationBetweenReqInMs);

      // request
      final advInfoResource = await advertApiClient.getAdvertInfo(
          tokenResource.data!.token, advert.advertId);
      advertLastReq = DateTime.now();
      if (advInfoResource is Error) {
        return Resource.error(advInfoResource.message!);
      }
      res.add(advInfoResource.data!);
    }
    return Resource.success(res);
  }

  @override
  Future<Resource<bool>> startAdvert(int advertId) async {
    final tokenResource = await _tryChangeAdvertStatus(
      advertId,
      pauseLastReq,
      APIConstants.startDurationBetweenReqInMs,
      advertApiClient.startAdvert,
    );
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.success(false);
    }
    await _ready(advertLastReq, APIConstants.advertDurationBetweenReqInMs);
    final advertInfoResource =
        await advertApiClient.getAdvertInfo(tokenResource.data!, advertId);
    if (advertInfoResource is Error) {
      return Resource.error(advertInfoResource.message!);
    }
    final advert = advertInfoResource.data!;
    if (advert.status == 9) {
      return Resource.success(true);
    }
    return Resource.success(false);
  }

  @override
  Future<Resource<bool>> stopAdvert(int advertId) async {
    final tokenResource = await _tryChangeAdvertStatus(
      advertId,
      pauseLastReq,
      APIConstants.pauseDurationBetweenReqInMs,
      advertApiClient.pauseAdvert,
    );
    if (tokenResource is Empty) {
      return Resource.success(false);
    }
    await _ready(advertLastReq, APIConstants.advertDurationBetweenReqInMs);
    final advertInfoResource =
        await advertApiClient.getAdvertInfo(tokenResource.data!, advertId);
    if (advertInfoResource is Error) {
      return Resource.error(advertInfoResource.message!);
    }
    final advert = advertInfoResource.data!;
    if (advert.status != 9) {
      return Resource.success(true);
    }
    return Resource.success(false);
  }

  Future<Resource<String>> _tryChangeAdvertStatus(
      int advertId,
      DateTime? lastReqTime,
      Duration duration,
      Future<Resource<bool>> Function(String, int) func) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }
    bool done = false;
    int cont = 0;
    while (!done) {
      if (cont >= 20) {
        break;
      }
      if (lastReqTime != null) {
        await _ready(lastReqTime, duration);
      }
      final resource = await func(tokenResource.data!.token, advertId);
      lastReqTime = DateTime.now();
      if (resource is Error) {
        return Resource.error(resource.message!);
      }
      done = resource.data!;
      cont++;
    }
    if (done) {
      return Resource.success(tokenResource.data!.token);
    }
    return Resource.empty();
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
}
