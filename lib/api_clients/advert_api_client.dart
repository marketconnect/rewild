import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/constants/constants.dart';

import 'package:rewild/core/utils/api_helpers/wb_advert_seller_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/advert_auto_model.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/entities/advert_card_model.dart';
import 'package:rewild/domain/entities/advert_catalogue_model.dart';

import 'package:rewild/domain/entities/advert_model.dart';
import 'package:rewild/domain/entities/advert_recomendation_model.dart';
import 'package:rewild/domain/entities/advert_search_model.dart';
import 'package:rewild/domain/entities/advert_search_plus_catalogue_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:rewild/domain/entities/auto_campaign_stat.dart';
import 'package:rewild/domain/entities/search_campaign_stat.dart';
import 'package:rewild/domain/services/advert_service.dart';
import 'package:rewild/domain/services/advert_stat_service.dart';
import 'package:rewild/domain/services/keywords_service.dart';

class AdvertApiClient
    implements
        AdvertServiceAdvertApiClient,
        AdvertStatServiceAdvertApiClient,
        KeywordsServiceAdvertApiClient {
  const AdvertApiClient();

  @override
  Future<Either<RewildError, bool>> setSearchExcludedKeywords(
      String token, int campaignId, List<String> excludedKeywords) async {
    try {
      final params = {'id': campaignId.toString()};
      final body = {'excluded': excludedKeywords};

      final wbApi = WbAdvertApiHelper.searchSetExcludedKeywords;
      final response = await wbApi.post(token, body, params);

      if (response.statusCode == 200) {
        return right(true);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(errString,
            source: runtimeType.toString(),
            name: "setSearchExcludedKeywords",
            args: [token, campaignId, ...excludedKeywords]));
      }
    } catch (e) {
      return left(RewildError(
          "Ошибка при установке исключений для кампании в поиске: $e",
          source: runtimeType.toString(),
          name: "setSearchExcludedKeywords",
          args: [token, campaignId, ...excludedKeywords]));
    }
  }

  Future<Either<RewildError, List<String>>> setSearchPhraseKeywords(
      String token, int campaignId, List<String> phraseKeywords) async {
    try {
      final params = {'id': campaignId.toString()};
      final body = {'phrase': phraseKeywords};

      final wbApi = WbAdvertApiHelper.searchSetPhraseKeywords;

      final response = await wbApi.post(token, body, params);

      if (response.statusCode == 200) {
        final List<String> responseList =
            List<String>.from(json.decode(response.body));
        return right(responseList);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(errString,
            source: runtimeType.toString(),
            name: "setSearchPhraseKeywords",
            args: [token, campaignId, ...phraseKeywords]));
      }
    } catch (e) {
      return left(RewildError("Ошибка при установке фраз для поиска: $e",
          source: runtimeType.toString(),
          name: "setSearchPhraseKeywords",
          args: [token, campaignId, ...phraseKeywords]));
    }
  }

  Future<Either<RewildError, List<String>>> setSearchStrongKeywords(
      String token, int campaignId, List<String> strongKeywords) async {
    try {
      final params = {'id': campaignId.toString()};
      final body = {'strong': strongKeywords};

      final wbApi = WbAdvertApiHelper.searchSetPhraseKeywords;
      final response = await wbApi.post(token, body, params);

      if (response.statusCode == 200) {
        final List<String> responseList =
            List<String>.from(json.decode(response.body));
        return right(responseList);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(errString,
            source: runtimeType.toString(),
            name: "setSearchStrongKeywords",
            args: [token, campaignId, ...strongKeywords]));
      }
    } catch (e) {
      return left(RewildError(
          "Ошибка при установке точных совпадений для поиска: $e",
          source: runtimeType.toString(),
          name: "setSearchStrongKeywords",
          args: [token, campaignId, ...strongKeywords]));
    }
  }

  Future<Either<RewildError, List<String>>> setSearchPlusKeywords(
      String token, int campaignId, List<String> plusKeywords) async {
    try {
      final params = {'id': campaignId.toString()};
      final body = {'pluse': plusKeywords};

      final wbApi = WbAdvertApiHelper.searchSetPlusKeywords;
      final response = await wbApi.post(token, body, params);

      if (response.statusCode == 200) {
        final List<String> responseList =
            List<String>.from(json.decode(response.body));
        return right(responseList);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(errString,
            source: runtimeType.toString(),
            name: "setSearchPlusKeywords",
            args: [token, campaignId, ...plusKeywords]));
      }
    } catch (e) {
      return left(RewildError("Ошибка при установке ключей для поиска: $e",
          source: runtimeType.toString(),
          name: "setSearchPlusKeywords",
          args: [token, campaignId, ...plusKeywords]));
    }
  }

  @override
  Future<Either<RewildError, bool>> setAutoSetExcluded(
      String token, int campaignId, List<String> excludedKw) async {
    try {
      final params = {'id': campaignId.toString()};
      final body = {
        'excluded': excludedKw,
      };

      final wbApi = WbAdvertApiHelper.autoSetExcludedKeywords;

      final response = await wbApi.post(token, body, params);
      if (response.statusCode == 200) {
        return right(true);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "setAutoSetExcluded",
          args: [token, campaignId, ...excludedKw],
        ));
      }
    } catch (e) {
      return left(RewildError("Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "setAutoSetExcluded",
          args: [token, campaignId.toString(), ...excludedKw]));
    }
  }

  @override
  Future<Either<RewildError, bool>> changeCpm(String token, int campaignId,
      int type, int cpm, int param, int? instrument) async {
    try {
      final body = {
        'advertId': campaignId,
        'type': type,
        'cpm': cpm,
      };

      // param do not required for auto
      if (type != AdvertTypeConstants.auto) {
        body['param'] = param;
      }

      if (instrument != null) {
        body['instrument'] = instrument;
      }

      final wbApi = WbAdvertApiHelper.setCpm;
      final response = await wbApi.post(token, body);
      if (response.statusCode == 200) {
        return right(true);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(errString,
            source: runtimeType.toString(),
            name: "changeCpm",
            args: [token, campaignId, type, cpm, param, instrument]));
      }
    } catch (e) {
      return left(RewildError("Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "changeCpm",
          args: [token, campaignId, type, cpm, param, instrument]));
    }
  }

  @override
  Future<Either<RewildError, bool>> pauseAdvert(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};

      // final uri = Uri.https('advert-api.wb.ru', "/adv/v0/pause", params);

      final wbApi = WbAdvertApiHelper.pauseCampaign;
      final response = await wbApi.get(token, params);
      if (response.statusCode == 200) {
        return right(true);
      } else if (response.statusCode == 422) {
        //Статус кампании не изменен
        return right(false);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "pauseAdvert",
          args: [token, campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError("Неизвестная ошибка",
          source: runtimeType.toString(),
          name: "pauseAdvert",
          args: [token, campaignId]));
    }
  }

  // max 300 requests per minute
  @override
  Future<Either<RewildError, bool>> startAdvert(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};

      // final uri = Uri.https('advert-api.wb.ru', "/adv/v0/start", params);

      final wbApi = WbAdvertApiHelper.startCampaign;
      final response = await wbApi.get(token, params);
      if (response.statusCode == 200) {
        return right(true);
      } else if (response.statusCode == 422) {
        //Статус кампании не изменен
        return right(false);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );

        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "startAdvert",
          args: [token, campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError("Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "startAdvert",
          args: [token, campaignId]));
    }
  }

  @override
  Future<Either<RewildError, int>> getCompanyBudget(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};

      final wbApi = WbAdvertApiHelper.getCompanyBudget;

      final response = await wbApi.get(
        token,
        params,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) {
          return right(0);
        }

        return right(data['total']);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "getCompanyBudget",
          args: [token, campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError("Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "getCompanyBudget",
          args: [token, campaignId]));
    }
  }

  @override
  Future<Either<RewildError, Map<(int aType, int aStatus), List<int>>>> count(
      String token) async {
    try {
      final wbApi = WbAdvertApiHelper.getCampaigns;

      final response = await wbApi.get(
        token,
      );

      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));

        final adverts = stats['adverts'];
        if (adverts == null) {
          return right({});
        }
        Map<(int, int), List<int>> typeIds = {};
        for (final advert in adverts) {
          List<int> ids = [];
          final advertList = advert['advert_list'];
          final type = advert['type'];
          final status = advert['status'];
          if (advertList == null) {
            continue;
          }
          for (final a in advertList) {
            final id = a['advertId'];
            if (id == null) {
              continue;
            }
            ids.add(id);
          }
          if (typeIds.containsKey(type)) {
            typeIds[type]!.addAll(ids);
          } else {
            typeIds[(type, status)] = ids;
          }
        }

        return right(typeIds);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "count",
          args: [
            token,
          ],
        ));
      }
    } catch (e) {
      return left(RewildError("Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "count",
          args: [
            token,
          ]));
    }
  }

  @override
  Future<Either<RewildError, List<AdvertInfoModel>>> getAdverts(
      String token, List<int> ids) async {
    try {
      final body = ids;
      final wbApi = WbAdvertApiHelper.getCampaignsInfo;
      final response = await wbApi.post(token, body);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null || data.length == 0) {
          return right([]);
        }

        return right(
          List<AdvertInfoModel>.from(
            data.map((x) => AdvertInfoModel.fromJson(x)),
          ),
        );
      } else if (response.statusCode == 204) {
        return right([]);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "getAdverts",
          args: [token],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Ошибка при обращении к WB продвижение список кампаний: $e",
        source: runtimeType.toString(),
        name: "getAdverts",
        args: [token],
      ));
    }
  }

  @override
  Future<Either<RewildError, int>> balance(String token) async {
    try {
      final wbApi = WbAdvertApiHelper.getBalance;
      final response = await wbApi.get(
        token,
      );
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        final balance = stats['balance'];
        return right(balance);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "balance",
          args: [token],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "balance",
        args: [token],
      ));
    }
  }

  @override
  Future<Either<RewildError, AutoCampaignStatWord>> autoStatWords(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};
      // final uri =
      //     Uri.https('advert-api.wb.ru', "/adv/v1/auto/stat-words", params);
      final wbApi = WbAdvertApiHelper.autoGetStatsWords;

      final response = await wbApi.get(token, params);
      if (response.statusCode == 200) {
        // Parse the JSON string into a Map
        Map<String, dynamic> jsonData =
            json.decode(utf8.decode(response.bodyBytes));
        final data = jsonData['words'];
        // Use the fromMap method
        AutoCampaignStatWord autoStatWord =
            AutoCampaignStatWord.fromMap(data, campaignId);

        return right(autoStatWord);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(errString,
            source: runtimeType.toString(),
            name: "autoStatWords",
            args: [token, campaignId]));
      }
    } catch (e) {
      return left(RewildError("Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "autoStatWords",
          args: [token, campaignId]));
    }
  }

  @override
  Future<Either<RewildError, SearchCampaignStat>> getSearchStat(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};
      // final uri = Uri.https('advert-api.wb.ru', "/adv/v1/stat/words", params);
      final wbApi = WbAdvertApiHelper.searchGetStatsWords;
      final response = await wbApi.get(
        token,
        params,
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData =
            json.decode(utf8.decode(response.bodyBytes));

        return right(SearchCampaignStat.fromJson(jsonData, campaignId));
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "getSearchStat",
          args: [token, campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Неизвестная ошибка $e",
        source: runtimeType.toString(),
        name: "getSearchStat",
        args: [token, campaignId],
      ));
    }
  }

  @override
  Future<Either<RewildError, AdvertStatModel>> getAutoStat(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};

      final wbApi = WbAdvertApiHelper.autoGetStat;
      final response = await wbApi.get(
        token,
        params,
      );

      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        return right(AdvertStatModel.fromJson(stats, campaignId));
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "getAutoStat",
          args: [token, campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Неизвестная ошибка $e",
        source: runtimeType.toString(),
        name: "getAutoStat",
        args: [token, campaignId],
      ));
    }
  }

  @override
  Future<Either<RewildError, Advert>> getCampaignInfo(
      String token, int id) async {
    try {
      final params = {'id': id.toString()};
      final wbApi = WbAdvertApiHelper.getCampaignInfo;

      final response = await wbApi.get(
        token,
        params,
      );

      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));

        final advType = stats['type'];

        switch (advType) {
          case AdvertTypeConstants.inCatalog:
            // catalog
            return right(AdvertCatalogueModel.fromJson(stats));

          case AdvertTypeConstants.inCard:
            // card
            return right(AdvertCardModel.fromJson(stats));
          case AdvertTypeConstants.inSearch:
            // search
            return right(AdvertSearchModel.fromJson(stats));
          case AdvertTypeConstants.inRecomendation:
            // recomendation
            return right(AdvertRecomendaionModel.fromJson(stats));
          case AdvertTypeConstants.auto:
            // auto
            return right(AdvertAutoModel.fromJson(stats));
          case AdvertTypeConstants.searchPlusCatalog:
            // search+catalogue
            return right(AdvertSearchPlusCatalogueModel.fromJson(stats));

          default:
            return left(RewildError(
              "Неизвестный тип кампании: $advType",
              source: runtimeType.toString(),
              name: "getCampaignInfo",
              args: [token, id],
            ));
        }
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "getCampaignInfo",
          args: [token, id],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "getCampaignInfo",
        args: [token, id],
      ));
    }
  }

  // STATIC METHODS ====================================================================== STATIC METHODS
  static Future<Either<RewildError, AdvertStatModel>> getFullStatInBackground(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};

      final wbApi = WbAdvertApiHelper.getFullStat;

      final response = await wbApi.get(
        token,
        params,
      );
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        // print(' params: $params response.body: ${response.body}');
        return right(AdvertStatModel.fromJson(stats, campaignId));
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );

        return left(RewildError(
          errString,
          source: "AdvertApiClient",
          name: "getFullStatInBackground",
          args: [token, campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Неизвестная ошибка $e",
        source: "AdvertApiClient",
        name: "getFullStatInBackground",
        args: [token, campaignId],
      ));
    }
  }

  static Future<Either<RewildError, AdvertStatModel>> getSearchStatInBackground(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};
      // final uri = Uri.https('advert-api.wb.ru', "/adv/v1/stat/words", params);

      final wbApi = WbAdvertApiHelper.searchGetStatsWords;
      final response = await wbApi.get(
        token,
        params,
      );
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        final total = stats['stat'][0];
        return right(AdvertStatModel.fromJson(total, campaignId));
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: "AdvertApiClient",
          name: "getSearchStatInBackground",
          args: [token, campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Неизвестная ошибка $e",
        source: "AdvertApiClient",
        name: "getSearchStatInBackground",
        args: [token, campaignId],
      ));
    }
  }

  static Future<Either<RewildError, Map<int, List<int>>>> countInBackground(
      String token) async {
    try {
      final wbApi = WbAdvertApiHelper.getCampaigns;

      final response = await wbApi.get(
        token,
      );

      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));

        final adverts = stats['adverts'];
        if (adverts == null) {
          return right({});
        }
        Map<int, List<int>> typeIds = {};
        for (final advert in adverts) {
          List<int> ids = [];
          final advertList = advert['advert_list'];
          final type = advert['type'];
          if (advertList == null) {
            continue;
          }
          for (final a in advertList) {
            final id = a['advertId'];
            if (id == null) {
              continue;
            }
            ids.add(id);
          }
          if (typeIds.containsKey(type)) {
            typeIds[type]!.addAll(ids);
          } else {
            typeIds[type] = ids;
          }
        }

        return right(typeIds);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: 'countInBackground',
          name: "count",
          args: [
            token,
          ],
        ));
      }
    } catch (e) {
      return left(RewildError("Неизвестная ошибка: $e",
          source: 'countInBackground',
          name: "count",
          args: [
            token,
          ]));
    }
  }

  static Future<Either<RewildError, List<AdvertInfoModel>>>
      getAdvertsInBackground(String token, List<int> ids) async {
    try {
      final body = ids;

      final wbApi = WbAdvertApiHelper.getCampaignsInfo;
      final response = await wbApi.post(token, body);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null || data.length == 0) {
          return right([]);
        }

        return right(
          List<AdvertInfoModel>.from(
            data.map((x) => AdvertInfoModel.fromJson(x)),
          ),
        );
      } else if (response.statusCode == 204) {
        return right([]);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );

        return left(RewildError(
          errString,
          source: "AdvertApiClient",
          name: "getAdvertsInBackground",
          args: [token],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Ошибка при обращении к WB продвижение список кампаний: $e",
        source: "AdvertApiClient",
        name: "getAdvertsInBackground",
        args: [token],
      ));
    }
  }

  static Future<Either<RewildError, AdvertStatModel>> getAutoStatInBackground(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};

      final wbApi = WbAdvertApiHelper.autoGetStat;
      final response = await wbApi.get(
        token,
        params,
      );
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        return right(AdvertStatModel.fromJson(stats, campaignId));
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: "AdvertApiClient",
          name: "getAutoStatInBackground",
          args: [token, campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Неизвестная ошибка $e",
        source: "AdvertApiClient",
        name: "getAutoStatInBackground",
        args: [token, campaignId],
      ));
    }
  }

  static Future<Either<RewildError, int>> getCompanyBudgetInBackground(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};
      final wbApi = WbAdvertApiHelper.getCompanyBudget;
      final response = await wbApi.get(
        token,
        params,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) {
          return right(0);
        }

        return right(data['total']);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: "AdvertApiClient",
          name: "getCompanyBudgetInBackground",
          args: [token, campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Неизвестная ошибка $e",
        source: "AdvertApiClient",
        name: "getCompanyBudgetInBackground",
        args: [token, campaignId],
      ));
    }
  }
}
