import 'dart:async';

import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/wb_api_helper.dart';
import 'package:rewild/domain/entities/advert_base.dart';

import 'package:rewild/domain/entities/advert_model.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:rewild/domain/entities/stream_advert_event.dart';
import 'package:rewild/presentation/all_adverts_tools_screen/all_adverts_tools_view_model.dart';

import 'package:rewild/presentation/all_adverts_stat_screen/all_adverts_stat_screen_view_model.dart';

import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';
import 'package:rewild/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild/presentation/single_auto_words_screen/single_auto_words_view_model.dart';
import 'package:rewild/presentation/single_search_words_screen%20copy/single_search_words_view_model.dart';

// API
abstract class AdvertServiceAdvertApiClient {
  Future<Resource<List<int>>> count(String token);
  Future<Resource<List<AdvertInfoModel>>> getAdverts(
      String token, List<int> ids);
  Future<Resource<Advert>> getCampaignInfo(String token, int id);
  Future<Resource<int>> getCompanyBudget(String token, int campaignId);
  Future<Resource<int>> balance(String token);
  Future<Resource<AdvertStatModel>> getAutoStat(String token, int campaignId);
  // Post
  Future<Resource<bool>> pauseAdvert(String token, int campaignId);
  Future<Resource<bool>> startAdvert(String token, int campaignId);
  Future<Resource<bool>> changeCpm(String token, int campaignId, int type,
      int cpm, int param, int? instrument);
}

// Api key
abstract class AdvertServiceApiKeyDataProvider {
  Future<Resource<ApiKeyModel>> getApiKey(String type);
}

class AdvertService
    implements
        AllAdvertsStatScreenAdvertService,
        SingleAdvertStatsViewModelAdvertService,
        AllAdvertsToolsAdvertService,
        SingleAutoWordsAdvertService,
        SingleSearchWordsAdvertService,
        MainNavigationAdvertService {
  final AdvertServiceAdvertApiClient advertApiClient;
  final AdvertServiceApiKeyDataProvider apiKeysDataProvider;
  final StreamController<StreamAdvertEvent> updatedAdvertStreamController;

  AdvertService(
      {required this.advertApiClient,
      required this.apiKeysDataProvider,
      required this.updatedAdvertStreamController});

  @override
  Future<Resource<bool>> apiKeyExists() async {
    final resource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (resource is Error) {
      return Resource.error(resource.message!,
          source: runtimeType.toString(), name: "apiKeyExists", args: []);
    }
    if (resource is Empty) {
      return Resource.success(false);
    }
    return Resource.success(true);
  }

  @override
  Future<Resource<int>> getBallance() async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(), name: "getBallance", args: []);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // wait
    final wbApi = WbApiHelper.getBalance;
    await wbApi.waitForNextRequest();

    final balanceResource =
        await advertApiClient.balance(tokenResource.data!.token);

    if (balanceResource is Error) {
      return Resource.error(balanceResource.message!,
          source: runtimeType.toString(), name: "getBallance", args: []);
    }
    return balanceResource;
  }

  @override
  Future<Resource<int>> getBudget(int campaignId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(),
          name: "getBudget",
          args: [campaignId]);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // request to API

    final wbApi = WbApiHelper.getCompanyBudget;

    await wbApi.waitForNextRequest();

    final budgetResource = await advertApiClient.getCompanyBudget(
        tokenResource.data!.token, campaignId);

    if (budgetResource is Error) {
      return Resource.error(budgetResource.message!,
          source: runtimeType.toString(),
          name: "getBudget",
          args: [campaignId]);
    }
    return budgetResource;
  }

  Future<Resource<List<AdvertInfoModel>>> _getAdverts(String token) async {
    // request to API
    // if (getCampaignsLastReq != null) {
    //   const wbApi = WbApiHelper.getCampaigns;
    //   await wbApi.ready(getCampaignInfoLastReq);
    // }

    final allAdvertsIdsResource = await advertApiClient.count(token);
    if (allAdvertsIdsResource is Error) {
      return Resource.error(allAdvertsIdsResource.message!,
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }
    final wbApi = WbApiHelper.getCampaigns;
    await wbApi.waitForNextRequest();
    final advertsResource =
        await advertApiClient.getAdverts(token, allAdvertsIdsResource.data!);

    if (advertsResource is Error) {
      return Resource.error(advertsResource.message!,
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }
    return advertsResource;
  }

  @override
  Future<Resource<List<Advert>>> getAllAdverts() async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }
    if (tokenResource is Empty) {
      return Resource.error("Токен не сохранен",
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }

    final advertsResource = await _getAdverts(tokenResource.data!.token);

    if (advertsResource is Error) {
      return Resource.error(advertsResource.message!,
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }

    if (advertsResource is Empty) {
      return Resource.error(
          'Токен "Продвижение" недействителен. Пожалуйста удалите его.',
          source: runtimeType.toString(),
          name: "getAllAdverts",
          args: []);
    }
    List<Advert> res = [];

    for (final advert in advertsResource.data!) {
      if (advert.status != 9 && advert.status != 11) {
        continue;
      }

      // requst to API
      // if (getCampaignInfoLastReq != null) {
      //   const wbApi = WbApiHelper.getCampaignInfo;
      //   await wbApi.ready(
      //     getCampaignInfoLastReq,
      //   );
      // }
      final wbApi = WbApiHelper.getCampaignInfo;
      await wbApi.waitForNextRequest();
      final campaignInfoResource = await advertApiClient.getCampaignInfo(
          tokenResource.data!.token, advert.campaignId);

      if (campaignInfoResource is Error) {
        return Resource.error(campaignInfoResource.message!,
            source: runtimeType.toString(), name: "getAllAdverts", args: []);
      }
      res.add(campaignInfoResource.data!);
    }

    return Resource.success(res);
  }

  @override
  Future<Resource<Advert>> advertInfo(int campaignId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(),
          name: "advertInfo",
          args: [campaignId]);
    }

    // request
    final wbApi = WbApiHelper.getCampaignInfo;

    await wbApi.waitForNextRequest();
    final advInfoResource = await advertApiClient.getCampaignInfo(
        tokenResource.data!.token, campaignId);

    if (advInfoResource is Error) {
      return Resource.error(advInfoResource.message!,
          source: runtimeType.toString(),
          name: "advertInfo",
          args: [campaignId]);
    }

    return Resource.success(advInfoResource.data!);
  }

  @override
  Future<Resource<bool>> setCpm(
      {required int campaignId,
      required int type,
      required int cpm,
      required int param,
      int? instrument}) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(),
          name: "setCpm",
          args: [campaignId, type, cpm, param, instrument]);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // request to API
    // if (setCpmLastReq != null) {
    //   const wbApi = WbApiHelper.setCpm;
    //   await wbApi.ready(setCpmLastReq);
    // }
    final wbApi = WbApiHelper.setCpm;
    await wbApi.waitForNextRequest();
    final changeCpmResource = await advertApiClient.changeCpm(
        tokenResource.data!.token, campaignId, type, cpm, param, instrument);
    // setCpmLastReq = DateTime.now();
    if (changeCpmResource is Error) {
      return Resource.error(changeCpmResource.message!,
          source: runtimeType.toString(),
          name: "setCpm",
          args: [campaignId, type, cpm, param, instrument]);
    }
    updatedAdvertStreamController
        .add(StreamAdvertEvent(campaignId: campaignId, cpm: cpm, status: null));
    return Resource.success(changeCpmResource.data!);
  }

  @override
  Future<Resource<List<AdvertInfoModel>>> getByType([int? type]) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(), name: "getByType", args: [type]);
    }
    if (tokenResource is Empty) {
      return Resource.error("Токен не сохранен",
          source: runtimeType.toString(), name: "getByType", args: []);
    }

    // request to API
    final advertsResource = await _getAdverts(tokenResource.data!.token);

    if (advertsResource is Error) {
      return Resource.error(advertsResource.message!,
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }

    if (advertsResource is Error) {
      return Resource.error(advertsResource.message!,
          source: runtimeType.toString(), name: "getByType", args: [type]);
    }

    List<AdvertInfoModel> res = [];
    if (advertsResource is Empty) {
      return Resource.success(res);
    }

    for (final advert in advertsResource.data!) {
      if (advert.status == 7 || advert.status == 8) {
        continue;
      }
      if (type != null && advert.type != type) {
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
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(), name: "getAll", args: []);
    }
    if (tokenResource is Empty) {
      return Resource.empty();
    }

    // request to API
    final advertsResource = await _getAdverts(tokenResource.data!.token);

    if (advertsResource is Error) {
      return Resource.error(advertsResource.message!,
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }
    List<Advert> res = [];
    if (advertsResource is Empty) {
      return Resource.success(res);
    }

    for (final advert in advertsResource.data!) {
      if (advert.status == 7 || advert.status == 8) {
        continue;
      }
      // const wbApi = WbApiHelper.getCampaignInfo;
      // await wbApi.ready(
      //   getCampaignInfoLastReq,
      // );

      // request
      final wbApi = WbApiHelper.getCampaignInfo;
      await wbApi.waitForNextRequest();
      final advInfoResource = await advertApiClient.getCampaignInfo(
          tokenResource.data!.token, advert.campaignId);

      if (advInfoResource is Error) {
        return Resource.error(advInfoResource.message!,
            source: runtimeType.toString(), name: "getAll", args: []);
      }

      res.add(advInfoResource.data!);
    }
    return Resource.success(res);
  }

  @override
  Future<Resource<bool>> startAdvert(int campaignId) async {
    final wbApiStart = WbApiHelper.startCampaign;

    final tokenResource = await _tryChangeAdvertStatus(
      campaignId,
      wbApiStart,
      advertApiClient.startAdvert,
    );
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(),
          name: "startAdvert",
          args: [campaignId]);
    }
    if (tokenResource is Empty) {
      return Resource.success(false);
    }

    final wbApiInfo = WbApiHelper.getCampaignInfo;

    await wbApiInfo.waitForNextRequest();
    final advertInfoResource =
        await advertApiClient.getCampaignInfo(tokenResource.data!, campaignId);
    if (advertInfoResource is Error) {
      return Resource.error(advertInfoResource.message!,
          source: runtimeType.toString(),
          name: "startAdvert",
          args: [campaignId]);
    }
    final advert = advertInfoResource.data!;
    if (advert.status == 9) {
      updatedAdvertStreamController
          .add(StreamAdvertEvent(campaignId: campaignId, cpm: null, status: 9));
      return Resource.success(true);
    }
    updatedAdvertStreamController.add(StreamAdvertEvent(
        campaignId: campaignId, cpm: null, status: advert.status));
    return Resource.success(false);
  }

  @override
  Future<Resource<bool>> stopAdvert(int campaignId) async {
    final wbApiPause = WbApiHelper.pauseCampaign;
    final tokenResource = await _tryChangeAdvertStatus(
      campaignId,
      wbApiPause,
      advertApiClient.pauseAdvert,
    );
    if (tokenResource is Empty) {
      return Resource.success(false);
    }
    // const wbApiInfo = WbApiHelper.getCampaignInfo;
    // await wbApiInfo.ready(
    //   getCampaignInfoLastReq,
    // );
    final wbApi = WbApiHelper.getCampaignInfo;
    await wbApi.waitForNextRequest();
    final advertInfoResource =
        await advertApiClient.getCampaignInfo(tokenResource.data!, campaignId);
    if (advertInfoResource is Error) {
      return Resource.error(advertInfoResource.message!,
          source: runtimeType.toString(),
          name: "stopAdvert",
          args: [campaignId]);
    }
    final advert = advertInfoResource.data!;
    if (advert.status != 9) {
      updatedAdvertStreamController.add(StreamAdvertEvent(
          campaignId: campaignId, cpm: null, status: advert.status));
      return Resource.success(true);
    }
    updatedAdvertStreamController.add(StreamAdvertEvent(
        campaignId: campaignId, cpm: null, status: advert.status));
    return Resource.success(false);
  }

  Future<Resource<String>> _tryChangeAdvertStatus(
      int campaignId,
      ApiConstants wbApi,
      Future<Resource<bool>> Function(String, int) func) async {
    final tokenResource = await apiKeysDataProvider.getApiKey('Продвижение');
    if (tokenResource is Error) {
      return Resource.error(tokenResource.message!,
          source: runtimeType.toString(),
          name: "stopAdvert",
          args: [
            campaignId,
          ]);
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
      // if (lastReqTime != null) {
      //   // TODO pause and start can have different durations
      //   const wbApi = WbApiHelper.startCampaign;
      //   await wbApi.ready(lastReqTime);
      // }

      await wbApi.waitForNextRequest();
      final resource = await func(tokenResource.data!.token, campaignId);

      if (resource is Error) {
        return Resource.error(resource.message!,
            source: runtimeType.toString(),
            name: "stopAdvert",
            args: [
              campaignId,
            ]);
      }
      done = resource.data!;
      cont++;
    }
    if (done) {
      return Resource.success(tokenResource.data!.token);
    }
    return Resource.empty();
  }
}
