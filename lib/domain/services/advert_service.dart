import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/rewild_error.dart';

import 'package:rewild/domain/entities/advert_base.dart';

import 'package:rewild/domain/entities/advert_model.dart';
import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:rewild/domain/entities/stream_advert_event.dart';
import 'package:rewild/presentation/all_adverts_words_screen/all_adverts_words_view_model.dart';

import 'package:rewild/presentation/all_adverts_stat_screen/all_adverts_stat_screen_view_model.dart';

import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';
import 'package:rewild/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild/presentation/single_auto_words_screen/single_auto_words_view_model.dart';
import 'package:rewild/presentation/single_search_words_screen/single_search_words_view_model.dart';

// API
abstract class AdvertServiceAdvertApiClient {
  Future<Either<RewildError, Map<int, List<int>>>> count(String token);
  Future<Either<RewildError, List<AdvertInfoModel>>> getAdverts(
      String token, List<int> ids);
  Future<Either<RewildError, Advert>> getCampaignInfo(String token, int id);
  Future<Either<RewildError, int>> getCompanyBudget(
      String token, int campaignId);
  Future<Either<RewildError, int>> balance(String token);
  Future<Either<RewildError, AdvertStatModel>> getAutoStat(
      String token, int campaignId);
  // Post
  Future<Either<RewildError, bool>> pauseAdvert(String token, int campaignId);
  Future<Either<RewildError, bool>> startAdvert(String token, int campaignId);
  Future<Either<RewildError, bool>> changeCpm(String token, int campaignId,
      int type, int cpm, int param, int? instrument);
}

// Api key
abstract class AdvertServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel?>> getApiKey(String type);
}

class AdvertService
    implements
        AllAdvertsStatScreenAdvertService,
        SingleAdvertStatsViewModelAdvertService,
        AllAdvertsWordsAdvertService,
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

  static final keyType = StringConstants.apiKeyTypes[ApiKeyType.promo] ?? "";
  @override
  Future<Either<RewildError, bool>> apiKeyExists() async {
    final result = await apiKeysDataProvider.getApiKey(keyType);
    if (result is Error) {
      return left(RewildError(result.message!,
          source: runtimeType.toString(), name: "apiKeyExists", args: []));
    }
    if (result is Empty) {
      return right(false);
    }
    return right(true);
  }

  @override
  Future<Either<RewildError, int>> getBallance() async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(), name: "getBallance", args: []);
    }
    if (tokenResource is Empty) {
      return right(null);
    }

    final balanceResource =
        await advertApiClient.balance(tokenResource.data!.token);

    if (balanceResource is Error) {
      return left(RewildError(balanceResource.message!,
          source: runtimeType.toString(), name: "getBallance", args: []);
    }
    return balanceResource;
  }

  @override
  Future<Either<RewildError, int>> getBudget(int campaignId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(),
          name: "getBudget",
          args: [campaignId]);
    }
    if (tokenResource is Empty) {
      return right(null);
    }

    final budgetResource = await advertApiClient.getCompanyBudget(
        tokenResource.data!.token, campaignId);

    if (budgetResource is Error) {
      return left(RewildError(budgetResource.message!,
          source: runtimeType.toString(),
          name: "getBudget",
          args: [campaignId]);
    }
    return budgetResource;
  }

  Future<Either<RewildError, List<AdvertInfoModel>>> _getAdverts(String token,
      [List<int>? types]) async {
    // get all adverts Ids
    final allAdvertsIdsResource = await advertApiClient.count(token);
    if (allAdvertsIdsResource is Error) {
      return left(RewildError(allAdvertsIdsResource.message!,
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }

    List<int> ids = [];
    final allAdvertsIdsMap = allAdvertsIdsResource.data!;
    if (types != null) {
      for (var type in allAdvertsIdsMap.keys) {
        if (types.contains(type)) {
          ids.addAll(allAdvertsIdsMap[type]!);
        }
      }
    } else {
      ids = allAdvertsIdsMap.values.expand((element) => element).toList();
    }

    final advertsResource = await advertApiClient.getAdverts(token, ids);

    if (advertsResource is Error) {
      return left(RewildError(advertsResource.message!,
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }
    return advertsResource;
  }

  @override
  Future<Either<RewildError, List<Advert>>> getAllAdverts() async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }
    if (tokenResource is Empty) {
      return left(RewildError("Токен не сохранен",
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }

    final advertsResource = await _getAdverts(tokenResource.data!.token);

    if (advertsResource is Error) {
      return left(RewildError(advertsResource.message!,
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }

    if (advertsResource is Empty) {
      return left(RewildError(
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

      final campaignInfoResource = await advertApiClient.getCampaignInfo(
          tokenResource.data!.token, advert.campaignId);

      if (campaignInfoResource is Error) {
        return left(RewildError(campaignInfoResource.message!,
            source: runtimeType.toString(), name: "getAllAdverts", args: []);
      }
      res.add(campaignInfoResource.data!);
    }

    return right(res);
  }

  @override
  Future<Either<RewildError, Advert>> advertInfo(int campaignId) async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(),
          name: "advertInfo",
          args: [campaignId]);
    }

    final advInfoResource = await advertApiClient.getCampaignInfo(
        tokenResource.data!.token, campaignId);

    if (advInfoResource is Error) {
      return left(RewildError(advInfoResource.message!,
          source: runtimeType.toString(),
          name: "advertInfo",
          args: [campaignId]);
    }

    return right(advInfoResource.data!);
  }

  @override
  Future<Either<RewildError, bool>> setCpm(
      {required int campaignId,
      required int type,
      required int cpm,
      required int param,
      int? instrument}) async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(),
          name: "setCpm",
          args: [campaignId, type, cpm, param, instrument]);
    }
    if (tokenResource is Empty) {
      return right(null);
    }

    final changeCpmResource = await advertApiClient.changeCpm(
        tokenResource.data!.token, campaignId, type, cpm, param, instrument);
    // setCpmLastReq = DateTime.now();
    if (changeCpmResource is Error) {
      return left(RewildError(changeCpmResource.message!,
          source: runtimeType.toString(),
          name: "setCpm",
          args: [campaignId, type, cpm, param, instrument]);
    }
    updatedAdvertStreamController
        .add(StreamAdvertEvent(campaignId: campaignId, cpm: cpm, status: null));
    return right(changeCpmResource.data!);
  }

  @override
  Future<Either<RewildError, List<Advert>>> getAll([List<int>? types]) async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(), name: "getAll", args: []);
    }
    if (tokenResource is Empty) {
      return right(null);
    }

    // request to API
    final advertsResource = await _getAdverts(tokenResource.data!.token, types);

    if (advertsResource is Error) {
      return left(RewildError(advertsResource.message!,
          source: runtimeType.toString(), name: "getAllAdverts", args: []);
    }
    List<Advert> res = [];
    if (advertsResource is Empty) {
      return right(res);
    }

    for (final advert in advertsResource.data!) {
      if (advert.status == 7 || advert.status == 8) {
        continue;
      }

      final advInfoResource = await advertApiClient.getCampaignInfo(
          tokenResource.data!.token, advert.campaignId);

      if (advInfoResource is Error) {
        return left(RewildError(advInfoResource.message!,
            source: runtimeType.toString(), name: "getAll", args: []);
      }

      res.add(advInfoResource.data!);
    }
    return right(res);
  }

  @override
  Future<Either<RewildError, bool>> startAdvert(int campaignId) async {
    final tokenResource = await _tryChangeAdvertStatus(
      campaignId,
      advertApiClient.startAdvert,
    );
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(),
          name: "startAdvert",
          args: [campaignId]);
    }
    if (tokenResource is Empty) {
      return right(false);
    }

    final advertInfoResource =
        await advertApiClient.getCampaignInfo(tokenResource.data!, campaignId);
    if (advertInfoResource is Error) {
      return left(RewildError(advertInfoResource.message!,
          source: runtimeType.toString(),
          name: "startAdvert",
          args: [campaignId]);
    }
    final advert = advertInfoResource.data!;
    if (advert.status == 9) {
      updatedAdvertStreamController
          .add(StreamAdvertEvent(campaignId: campaignId, cpm: null, status: 9));
      return right(true);
    }
    updatedAdvertStreamController.add(StreamAdvertEvent(
        campaignId: campaignId, cpm: null, status: advert.status));
    return right(false);
  }

  @override
  Future<Either<RewildError, bool>> stopAdvert(int campaignId) async {
    final tokenResource = await _tryChangeAdvertStatus(
      campaignId,
      advertApiClient.pauseAdvert,
    );
    if (tokenResource is Empty) {
      return right(false);
    }

    final advertInfoResource =
        await advertApiClient.getCampaignInfo(tokenResource.data!, campaignId);
    if (advertInfoResource is Error) {
      return left(RewildError(advertInfoResource.message!,
          source: runtimeType.toString(),
          name: "stopAdvert",
          args: [campaignId]);
    }
    final advert = advertInfoResource.data!;
    if (advert.status != 9) {
      updatedAdvertStreamController.add(StreamAdvertEvent(
          campaignId: campaignId, cpm: null, status: advert.status));
      return right(true);
    }
    updatedAdvertStreamController.add(StreamAdvertEvent(
        campaignId: campaignId, cpm: null, status: advert.status));
    return right(false);
  }

  Future<Either<RewildError, String>> _tryChangeAdvertStatus(int campaignId,
      Future<Either<RewildError, bool>> Function(String, int) func) async {
    final tokenResource = await apiKeysDataProvider.getApiKey(keyType);
    if (tokenResource is Error) {
      return left(RewildError(tokenResource.message!,
          source: runtimeType.toString(),
          name: "stopAdvert",
          args: [
            campaignId,
          ]);
    }
    if (tokenResource is Empty) {
      return right(null);
    }
    bool done = false;
    int cont = 0;
    while (!done) {
      if (cont >= 20) {
        break;
      }

      final resource = await func(tokenResource.data!.token, campaignId);

      if (resource is Error) {
        return left(RewildError(resource.message!,
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
      return right(tokenResource.data!.token);
    }
    return right(null);
  }
}
