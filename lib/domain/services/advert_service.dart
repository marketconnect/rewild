import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/rewild_error.dart';

import 'package:rewild/domain/entities/advert_base.dart';

import 'package:rewild/domain/entities/api_key_model.dart';
import 'package:rewild/domain/entities/stream_advert_event.dart';
import 'package:rewild/presentation/all_adverts_words_screen/all_adverts_words_view_model.dart';

import 'package:rewild/presentation/all_adverts_stat_screen/all_adverts_stat_screen_view_model.dart';

import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';
import 'package:rewild/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild/presentation/single_auto_words_screen/single_auto_words_view_model.dart';
import 'package:rewild/presentation/single_search_words_screen/single_search_words_view_model.dart';

// API
abstract class AdvertServiceAdvertApiClient {
  Future<Either<RewildError, Map<(int aType, int aStatus), List<int>>>> count(
      {required String token});
  Future<Either<RewildError, List<Advert>>> getAdverts(
      {required String token, required List<int> ids, int? status, int? type});
  // Future<Either<RewildError, List<Advert>>> getCampaignsInfo(
  //     {required String token,
  //     required List<int> ids,
  //     int? status,
  //     int? type});
  Future<Either<RewildError, int>> getCompanyBudget(
      {required String token, required int campaignId});
  Future<Either<RewildError, int>> balance({required String token});
  // Future<Either<RewildError, AdvertStatModel>> getAutoStat(
  //     {required String token, required int campaignId});
  // Post
  Future<Either<RewildError, bool>> pauseAdvert(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> startAdvert(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> changeCpm(
      {required String token,
      required int campaignId,
      required int type,
      required int cpm,
      required int param,
      int? instrument});
}

// Api key
abstract class AdvertServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel?>> getApiKey({required String type});
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

  // Function to get token string
  @override
  Future<Either<RewildError, String?>> getApiKey() async {
    final tokenResult = await apiKeysDataProvider.getApiKey(type: keyType);

    return tokenResult.fold((l) => left(l), (r) async {
      if (r == null) {
        return right(null);
      }
      return right(r.token);
    });
  }

  // Function to get ballance with token
  @override
  Future<Either<RewildError, int?>> getBallance({required String token}) async {
    final balanceResult = await advertApiClient.balance(token: token);

    return balanceResult.fold((l) => left(l), (r) {
      return right(r);
    });
  }

  // Function to get budget of a campaign by id
  @override
  Future<Either<RewildError, int>> getBudget(
      {required String token, required int campaignId}) async {
    final result = await advertApiClient.getCompanyBudget(
        token: token, campaignId: campaignId);
    return result;
  }

  // Function to get ids of all adverts filtered by types or not
  Future<Either<RewildError, List<int>>> _getAllCompaniesIdsFiltered(
      {required String token, List<int>? types, List<int>? statuses}) async {
    // get ids of all adverts grouped by type and status
    final result = await advertApiClient.count(token: token);

    // since wb count endpoints do not provide any filtering
    // and wb /adv/v1/promotion/adverts privides filtering by type and status
    // but only one type and one status at a time that leads to making a lot of requests
    // the filtering implemented in this code
    return result.fold((l) => left(l), (r) {
      if (types == null && statuses == null) {
        return right(r.entries.expand((element) => element.value).toList());
      }

      if (types != null && statuses == null) {
        return right(r.entries
            .where((element) => types.contains(element.key.$1))
            .expand((element) => element.value)
            .toList());
      }

      if (types == null && statuses != null) {
        return right(r.entries
            .where((element) => statuses.contains(element.key.$2))
            .expand((element) => element.value)
            .toList());
      }

      // types != null && statuses != null
      return right(r.entries
          .where((element) =>
              types!.contains(element.key.$1) &&
              statuses!.contains(element.key.$2))
          .expand((element) => element.value)
          .toList());
    });
  }

  // Function to get all adverts filtered by types or not
  Future<Either<RewildError, List<Advert>>> _getAdvertInfoModels(
      {required String token, List<int>? types, List<int>? statuses}) async {
    // get ids of all adverts filtered by types and statuses
    final allAdvertsIdsResult = await _getAllCompaniesIdsFiltered(
        token: token, types: types, statuses: statuses);

    // get all the filtered adverts as the AdvertInfoModels
    return allAdvertsIdsResult.fold((l) => left(l), (r) async {
      final advertsResult =
          await advertApiClient.getAdverts(token: token, ids: r);
      return advertsResult;
    });
  }

  @override
  Future<Either<RewildError, Advert>> getAdvert(
      {required String token, required int campaignId}) async {
    final advInfoResult =
        await advertApiClient.getAdverts(token: token, ids: [campaignId]);
    return advInfoResult.fold((l) => left(l), (r) {
      return right(r.first);
    });
  }

  @override
  Future<Either<RewildError, bool>> setCpm(
      {required String token,
      required int campaignId,
      required int type,
      required int cpm,
      required int param,
      int? instrument}) async {
    final changeCpmResult = await advertApiClient.changeCpm(
        token: token,
        campaignId: campaignId,
        type: type,
        cpm: cpm,
        param: param,
        instrument: instrument);

    return changeCpmResult.fold((l) => left(l), (r) {
      updatedAdvertStreamController.add(
          StreamAdvertEvent(campaignId: campaignId, cpm: cpm, status: null));
      return right(r);
    });
  }

  @override
  Future<Either<RewildError, List<Advert>>> getAllAdverts(
      {required String token}) async {
    // get ids of all adverts filtered by statuses (paused and active)
    final allAdvertsIdsResult = await _getAllCompaniesIdsFiltered(
        token: token, statuses: AdvertStatusConstants.useable);

    // get Advert for all the filtered by statuses (paused and active) ids
    return allAdvertsIdsResult.fold((l) => left(l), (r) async {
      return await advertApiClient.getAdverts(token: token, ids: r);
    });
  }

  @override
  Future<Either<RewildError, List<Advert>>> getAll(
      {required String token, List<int>? types}) async {
    // get ids of all adverts filtered by types if types is not null
    final allAdvertsIdsResult =
        await _getAllCompaniesIdsFiltered(token: token, types: types);

    // get Advert for all the filtered by types ids
    return allAdvertsIdsResult.fold((l) => left(l), (r) async {
      return await advertApiClient.getAdverts(token: token, ids: r);
    });
  }

  @override
  Future<Either<RewildError, bool>> checkAdvertIsActive(
      {required String token, required int campaignId}) async {
    final getAdvertsResult =
        await advertApiClient.getAdverts(token: token, ids: [campaignId]);

    return getAdvertsResult.fold((l) => left(l), (r) {
      final status = r.first.status;

      updatedAdvertStreamController.add(
          StreamAdvertEvent(campaignId: campaignId, cpm: null, status: status));
      return right(status == AdvertStatusConstants.active);
    });
  }

  @override
  Future<Either<RewildError, bool>> startAdvert(
      {required String token, required int campaignId}) async {
    final result = await _tryChangeAdvertStatus(
      token: token,
      campaignId: campaignId,
      func: advertApiClient.startAdvert,
    );

    return result;
  }

  @override
  Future<Either<RewildError, bool>> stopAdvert(
      {required String token, required int campaignId}) async {
    final result = await _tryChangeAdvertStatus(
      token: token,
      campaignId: campaignId,
      func: advertApiClient.pauseAdvert,
    );

    return result;
  }

  Future<Either<RewildError, bool>> _tryChangeAdvertStatus(
      {required String token,
      required int campaignId,
      required Future<Either<RewildError, bool>> Function(
              {required String token, required int campaignId})
          func}) async {
    bool done = false;
    int cont = 0;
    while (!done) {
      if (cont >= 20) {
        break;
      }
      // try to change the status of the advert
      final result = await func(token: token, campaignId: campaignId);
      result.fold((l) => left(l), (r) {
        // if the status changed
        done = r;
        cont++;
      });
    }
    return right(done);
  }
}
