import 'dart:convert';

import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:http/http.dart' as http;
import 'package:rewild/core/utils/wb_api_helper.dart';
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

  Future<Resource<List<String>>> setSearchExcludedKeywords(
      String token, int campaignId, List<String> excludedKeywords) async {
    try {
      final params = {'id': campaignId.toString()};
      final body = {'excluded': excludedKeywords};

      final jsonString = json.encode(body);

      final wbApi = WbApiHelper.searchSetExcludedKeywords;

      final response = await http.post(wbApi.buildUri(params),
          headers: wbApi.headers(token), body: jsonString);

      if (response.statusCode == 200) {
        final List<String> responseList =
            List<String>.from(json.decode(response.body));
        return Resource.success(responseList);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(errString,
            source: runtimeType.toString(),
            name: "setSearchExcludedKeywords",
            args: [token, campaignId, ...excludedKeywords]);
      }
    } catch (e) {
      return Resource.error(
          "Ошибка при установке исключений для кампании в поиске: $e",
          source: runtimeType.toString(),
          name: "setSearchExcludedKeywords",
          args: [token, campaignId, ...excludedKeywords]);
    }
  }

  Future<Resource<List<String>>> setSearchPhraseKeywords(
      String token, int campaignId, List<String> phraseKeywords) async {
    try {
      final params = {'id': campaignId.toString()};
      final body = {'phrase': phraseKeywords};

      final jsonString = json.encode(body);

      final wbApi = WbApiHelper.searchSetPhraseKeywords;

      final response = await http.post(wbApi.buildUri(params),
          headers: wbApi.headers(token), body: jsonString);

      if (response.statusCode == 200) {
        final List<String> responseList =
            List<String>.from(json.decode(response.body));
        return Resource.success(responseList);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(errString,
            source: runtimeType.toString(),
            name: "setSearchPhraseKeywords",
            args: [token, campaignId, ...phraseKeywords]);
      }
    } catch (e) {
      return Resource.error("Ошибка при установке фраз для поиска: $e",
          source: runtimeType.toString(),
          name: "setSearchPhraseKeywords",
          args: [token, campaignId, ...phraseKeywords]);
    }
  }

  Future<Resource<List<String>>> setSearchStrongKeywords(
      String token, int campaignId, List<String> strongKeywords) async {
    try {
      final params = {'id': campaignId.toString()};
      final body = {'strong': strongKeywords};
      final jsonString = json.encode(body);

      final wbApi = WbApiHelper.searchSetPhraseKeywords;
      final response = await http.post(wbApi.buildUri(params),
          headers: wbApi.headers(token), body: jsonString);

      if (response.statusCode == 200) {
        final List<String> responseList =
            List<String>.from(json.decode(response.body));
        return Resource.success(responseList);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(errString,
            source: runtimeType.toString(),
            name: "setSearchStrongKeywords",
            args: [token, campaignId, ...strongKeywords]);
      }
    } catch (e) {
      return Resource.error(
          "Ошибка при установке точных совпадений для поиска: $e",
          source: runtimeType.toString(),
          name: "setSearchStrongKeywords",
          args: [token, campaignId, ...strongKeywords]);
    }
  }

  Future<Resource<List<String>>> setSearchPlusKeywords(
      String token, int campaignId, List<String> plusKeywords) async {
    try {
      final params = {'id': campaignId.toString()};
      final body = {'pluse': plusKeywords};

      final jsonString = json.encode(body);

      final wbApi = WbApiHelper.searchSetPlusKeywords;
      final response = await http.post(wbApi.buildUri(params),
          headers: wbApi.headers(token), body: jsonString);

      if (response.statusCode == 200) {
        final List<String> responseList =
            List<String>.from(json.decode(response.body));
        return Resource.success(responseList);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(errString,
            source: runtimeType.toString(),
            name: "setSearchPlusKeywords",
            args: [token, campaignId, ...plusKeywords]);
      }
    } catch (e) {
      return Resource.error("Ошибка при установке ключей для поиска: $e",
          source: runtimeType.toString(),
          name: "setSearchPlusKeywords",
          args: [token, campaignId, ...plusKeywords]);
    }
  }

  // max 10 requests per minute
  @override
  Future<Resource<bool>> setAutoSetExcluded(
      String token, int campaignId, List<String> excludedKw) async {
    try {
      final params = {'id': campaignId.toString()};
      final body = {
        'excluded': excludedKw,
      };

      final jsonString = json.encode(body);

      // final uri =
      //     Uri.https('advert-api.wb.ru', "/adv/v1/auto/set-excluded", params);

      final wbApi = WbApiHelper.autoSetExcludedKeywords;

      final response = await http.post(wbApi.buildUri(params),
          headers: wbApi.headers(token), body: jsonString);
      if (response.statusCode == 200) {
        return Resource.success(true);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "setAutoSetExcluded",
          args: [token, campaignId, ...excludedKw],
        );
      }
    } catch (e) {
      return Resource.error("Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "setAutoSetExcluded",
          args: [token, campaignId.toString(), ...excludedKw]);
    }
  }

  @override
  Future<Resource<bool>> changeCpm(String token, int campaignId, int type,
      int cpm, int param, int? instrument) async {
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

      final jsonString = json.encode(body);

      // final uri = Uri.https('advert-api.wb.ru', "/adv/v0/cpm");
      final wbApi = WbApiHelper.setCpm;
      final response = await http.post(wbApi.buildUri({}),
          headers: wbApi.headers(token), body: jsonString);
      if (response.statusCode == 200) {
        return Resource.success(true);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(errString,
            source: runtimeType.toString(),
            name: "changeCpm",
            args: [token, campaignId, type, cpm, param, instrument]);
      }
    } catch (e) {
      return Resource.error("Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "changeCpm",
          args: [token, campaignId, type, cpm, param, instrument]);
    }
  }

  @override
  Future<Resource<bool>> pauseAdvert(String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};

      // final uri = Uri.https('advert-api.wb.ru', "/adv/v0/pause", params);

      final wbApi = WbApiHelper.pauseCampaign;
      final response =
          await http.get(wbApi.buildUri(params), headers: wbApi.headers(token));
      if (response.statusCode == 200) {
        return Resource.success(true);
      } else if (response.statusCode == 422) {
        //Статус кампании не изменен
        return Resource.success(false);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "pauseAdvert",
          args: [token, campaignId],
        );
      }
    } catch (e) {
      return Resource.error("Неизвестная ошибка",
          source: runtimeType.toString(),
          name: "pauseAdvert",
          args: [token, campaignId]);
    }
  }

  // max 300 requests per minute
  @override
  Future<Resource<bool>> startAdvert(String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};

      // final uri = Uri.https('advert-api.wb.ru', "/adv/v0/start", params);

      final wbApi = WbApiHelper.startCampaign;
      final response =
          await http.get(wbApi.buildUri(params), headers: wbApi.headers(token));
      if (response.statusCode == 200) {
        return Resource.success(true);
      } else if (response.statusCode == 422) {
        //Статус кампании не изменен
        return Resource.success(false);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );

        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "startAdvert",
          args: [token, campaignId],
        );
      }
    } catch (e) {
      return Resource.error("Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "startAdvert",
          args: [token, campaignId]);
    }
  }

  @override
  Future<Resource<int>> getCompanyBudget(String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};

      final wbApi = WbApiHelper.getCompanyBudget;

      final response = await http.get(
        wbApi.buildUri(params),
        headers: wbApi.headers(token),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) {
          return Resource.empty();
        }

        return Resource.success(data['total']);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "getCompanyBudget",
          args: [token, campaignId],
        );
      }
    } catch (e) {
      return Resource.error("Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "getCompanyBudget",
          args: [token, campaignId]);
    }
  }

  @override
  Future<Resource<List<int>>> count(String token) async {
    try {
      final wbApi = WbApiHelper.getCampaigns;

      final response = await http.get(
        wbApi.buildUri({}),
        headers: wbApi.headers(token),
      );

      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));

        final adverts = stats['adverts'];
        if (adverts == null) {
          return Resource.success([]);
        }
        List<int> ids = [];
        for (final advert in adverts) {
          final advertList = advert['advert_list'];
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
        }
        return Resource.success(ids);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "count",
          args: [
            token,
          ],
        );
      }
    } catch (e) {
      return Resource.error("Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "count",
          args: [
            token,
          ]);
    }
  }

  @override
  Future<Resource<List<AdvertInfoModel>>> getAdverts(
      String token, List<int> ids) async {
    try {
      final body = ids;

      final jsonString = json.encode(body);

      final wbApi = WbApiHelper.getCampaignsInfo;
      final response = await http.post(wbApi.buildUri({}),
          headers: wbApi.headers(token), body: jsonString);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) {
          return Resource.empty();
        }
        if (data.length == 0) {
          return Resource.success([]);
        }

        return Resource.success(
          List<AdvertInfoModel>.from(
            data.map((x) => AdvertInfoModel.fromJson(x)),
          ),
        );
      } else if (response.statusCode == 204) {
        return Resource.success([]);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "getAdverts",
          args: [token],
        );
      }
    } catch (e) {
      return Resource.error(
        "Ошибка при обращении к WB продвижение список кампаний: $e",
        source: runtimeType.toString(),
        name: "getAdverts",
        args: [token],
      );
    }
  }

  @override
  Future<Resource<int>> balance(String token) async {
    try {
      // final uri = Uri.https("advert-api.wb.ru", "/adv/v1/balance");
      final wbApi = WbApiHelper.getBalance;
      final response = await http.get(
        wbApi.buildUri({}),
        headers: wbApi.headers(token),
      );
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        final balance = stats['balance'];
        return Resource.success(balance);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "balance",
          args: [token],
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "balance",
        args: [token],
      );
    }
  }

  @override
  Future<Resource<AutoCampaignStatWord>> autoStatWords(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};
      // final uri =
      //     Uri.https('advert-api.wb.ru', "/adv/v1/auto/stat-words", params);
      final wbApi = WbApiHelper.autoGetStatsWords;

      final response =
          await http.get(wbApi.buildUri(params), headers: wbApi.headers(token));
      if (response.statusCode == 200) {
        // Parse the JSON string into a Map
        Map<String, dynamic> jsonData =
            json.decode(utf8.decode(response.bodyBytes));
        final data = jsonData['words'];
        // Use the fromMap method
        AutoCampaignStatWord autoStatWord =
            AutoCampaignStatWord.fromMap(data, campaignId);

        return Resource.success(autoStatWord);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(errString,
            source: runtimeType.toString(),
            name: "autoStatWords",
            args: [token, campaignId]);
      }
    } catch (e) {
      return Resource.error("Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "autoStatWords",
          args: [token, campaignId]);
    }
  }

  @override
  Future<Resource<SearchCampaignStat>> getSearchStat(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};
      // final uri = Uri.https('advert-api.wb.ru', "/adv/v1/stat/words", params);
      final wbApi = WbApiHelper.searchGetStatsWords;
      final response = await http.get(
        wbApi.buildUri(params),
        headers: wbApi.headers(token),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData =
            json.decode(utf8.decode(response.bodyBytes));

        return Resource.success(
            SearchCampaignStat.fromJson(jsonData, campaignId));
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "getSearchStat",
          args: [token, campaignId],
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка $e",
        source: runtimeType.toString(),
        name: "getSearchStat",
        args: [token, campaignId],
      );
    }
  }

  @override
  Future<Resource<AdvertStatModel>> getAutoStat(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};

      final wbApi = WbApiHelper.autoGetStat;
      final response = await http.get(
        wbApi.buildUri(params),
        headers: wbApi.headers(token),
      );

      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        return Resource.success(AdvertStatModel.fromJson(stats, campaignId));
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "getAutoStat",
          args: [token, campaignId],
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка $e",
        source: runtimeType.toString(),
        name: "getAutoStat",
        args: [token, campaignId],
      );
    }
  }

  @override
  Future<Resource<Advert>> getCampaignInfo(String token, int id) async {
    try {
      final params = {'id': id.toString()};
      final wbApi = WbApiHelper.getCampaignInfo;

      final response = await http.get(
        wbApi.buildUri(params),
        headers: wbApi.headers(token),
      );

      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));

        final advType = stats['type'];

        switch (advType) {
          case AdvertTypeConstants.inCatalog:
            // catalog
            return Resource.success(AdvertCatalogueModel.fromJson(stats));

          case AdvertTypeConstants.inCard:
            // card
            return Resource.success(AdvertCardModel.fromJson(stats));
          case AdvertTypeConstants.inSearch:
            // search
            return Resource.success(AdvertSearchModel.fromJson(stats));
          case AdvertTypeConstants.inRecomendation:
            // recomendation
            return Resource.success(AdvertRecomendaionModel.fromJson(stats));
          case AdvertTypeConstants.auto:
            // auto
            return Resource.success(AdvertAutoModel.fromJson(stats));
          case AdvertTypeConstants.searchPlusCatalog:
            // search+catalogue
            return Resource.success(
                AdvertSearchPlusCatalogueModel.fromJson(stats));

          default:
            return Resource.error(
              "Неизвестный тип кампании: $advType",
              source: runtimeType.toString(),
              name: "getCampaignInfo",
              args: [token, id],
            );
        }
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(
          errString,
          source: runtimeType.toString(),
          name: "getCampaignInfo",
          args: [token, id],
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "getCampaignInfo",
        args: [token, id],
      );
    }
  }

  // STATIC METHODS ====================================================================== STATIC METHODS
  static Future<Resource<AdvertStatModel>> getFullStatInBackground(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};

      // final uri = Uri.https('advert-api.wb.ru', "/adv/v1/fullstat", params);
      final wbApi = WbApiHelper.getFullStat;

      final response = await http.get(
        wbApi.buildUri(params),
        headers: wbApi.headers(token),
      );
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));

        return Resource.success(AdvertStatModel.fromJson(stats, campaignId));
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );

        return Resource.error(
          errString,
          source: "AdvertApiClient",
          name: "getFullStatInBackground",
          args: [token, campaignId],
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка $e",
        source: "AdvertApiClient",
        name: "getFullStatInBackground",
        args: [token, campaignId],
      );
    }
  }

  static Future<Resource<AdvertStatModel>> getSearchStatInBackground(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};
      // final uri = Uri.https('advert-api.wb.ru', "/adv/v1/stat/words", params);

      final wbApi = WbApiHelper.searchGetStatsWords;
      final response = await http.get(
        wbApi.buildUri(params),
        headers: wbApi.headers(token),
      );
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        final total = stats['stat'][0];
        return Resource.success(AdvertStatModel.fromJson(total, campaignId));
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(
          errString,
          source: "AdvertApiClient",
          name: "getSearchStatInBackground",
          args: [token, campaignId],
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка $e",
        source: "AdvertApiClient",
        name: "getSearchStatInBackground",
        args: [token, campaignId],
      );
    }
  }

  static Future<Resource<List<AdvertInfoModel>>> getAdvertsInBackground(
      String token, List<int> ids) async {
    try {
      final body = ids;
      final jsonString = json.encode(body);

      final wbApi = WbApiHelper.getCampaignsInfo;
      final response = await http.post(wbApi.buildUri({}),
          headers: wbApi.headers(token), body: jsonString);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) {
          return Resource.empty();
        }
        if (data.length == 0) {
          return Resource.success([]);
        }

        return Resource.success(
          List<AdvertInfoModel>.from(
            data.map((x) => AdvertInfoModel.fromJson(x)),
          ),
        );
      } else if (response.statusCode == 204) {
        return Resource.success([]);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );

        return Resource.error(
          errString,
          source: "AdvertApiClient",
          name: "getAdvertsInBackground",
          args: [token],
        );
      }
    } catch (e) {
      return Resource.error(
        "Ошибка при обращении к WB продвижение список кампаний: $e",
        source: "AdvertApiClient",
        name: "getAdvertsInBackground",
        args: [token],
      );
    }
  }

  static Future<Resource<AdvertStatModel>> getAutoStatInBackground(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};

      final wbApi = WbApiHelper.autoGetStat;
      final response = await http.get(
        wbApi.buildUri(params),
        headers: wbApi.headers(token),
      );
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        return Resource.success(AdvertStatModel.fromJson(stats, campaignId));
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(
          errString,
          source: "AdvertApiClient",
          name: "getAutoStatInBackground",
          args: [token, campaignId],
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка $e",
        source: "AdvertApiClient",
        name: "getAutoStatInBackground",
        args: [token, campaignId],
      );
    }
  }

  static Future<Resource<int>> getCompanyBudgetInBackground(
      String token, int campaignId) async {
    try {
      final params = {'id': campaignId.toString()};
      final wbApi = WbApiHelper.getCompanyBudget;
      final response = await http.get(
        wbApi.buildUri(params),
        headers: wbApi.headers(token),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) {
          return Resource.empty();
        }

        return Resource.success(data['total']);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return Resource.error(
          errString,
          source: "AdvertApiClient",
          name: "getCompanyBudgetInBackground",
          args: [token, campaignId],
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка $e",
        source: "AdvertApiClient",
        name: "getCompanyBudgetInBackground",
        args: [token, campaignId],
      );
    }
  }
}
