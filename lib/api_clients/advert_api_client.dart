import 'dart:convert';

import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:http/http.dart' as http;
import 'package:rewild/domain/entities/advert_auto_model.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/entities/advert_card_model.dart';
import 'package:rewild/domain/entities/advert_catalogue_model.dart';

import 'package:rewild/domain/entities/advert_model.dart';
import 'package:rewild/domain/entities/advert_recomendation_model.dart';
import 'package:rewild/domain/entities/advert_search_model.dart';
import 'package:rewild/domain/entities/advert_search_plus_catalogue_model.dart';
import 'package:rewild/domain/entities/advert_stat.dart';
import 'package:rewild/domain/entities/auto_stat_word.dart';
import 'package:rewild/domain/services/advert_service.dart';
import 'package:rewild/domain/services/auto_stat_service.dart';

class AdvertApiClient
    implements AdvertServiceAdvertApiClient, AutoStatServiceAdvertApiClient {
  const AdvertApiClient();

  // max 10 requests per minute
  @override
  Future<Resource<bool>> setAutoSetExcluded(
      String token, int advertId, List<String> excludedKw) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };

      final params = {'id': advertId.toString()};
      final body = {
        'excluded': excludedKw,
      };

      final jsonString = json.encode(body);

      final uri =
          Uri.https('advert-api.wb.ru', "/adv/v1/auto/set-excluded", params);
      final response = await http.post(uri, headers: headers, body: jsonString);
      if (response.statusCode == 200) {
        return Resource.success(true);
      } else if (response.statusCode == 422) {
        // Size of bid is not changed
        return Resource.success(false);
      } else if (response.statusCode == 400) {
        return Resource.error("Incorrect campaign identifier");
      } else if (response.statusCode == 401) {
        return Resource.error("Empty authorization header");
      }
    } catch (e) {
      return Resource.error("Unknown error");
    }

    return Resource.error("Unknown error");
  }

  @override
  Future<Resource<AutoStatWord>> autoStatWords(
      String token, int advertId) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};
      final uri =
          Uri.https('advert-api.wb.ru', "/adv/v1/auto/stat-words", params);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        // Parse the JSON string into a Map
        Map<String, dynamic> jsonData =
            json.decode(utf8.decode(response.bodyBytes));
        final data = jsonData['words'];
        // Use the fromMap method
        AutoStatWord autoStatWord = AutoStatWord.fromMap(data);

        return Resource.success(autoStatWord);
      }
      if (response.statusCode == 400) {
        return Resource.error("Incorrect campaign identifier");
      } else if (response.statusCode == 401) {
        return Resource.error("Empty authorization header");
      }
    } catch (e) {
      return Resource.error("Unknown error $e");
    }
    return Resource.error("Unknown error");
  }

  // max 300 requests per minute
  @override
  Future<Resource<bool>> changeCpm(String token, int advertId, int type,
      int cpm, int param, int? instrument) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final body = {
        'advertId': advertId,
        'type': type,
        'cpm': cpm,
      };

      // param do not required for auto
      if (type != AdvertTypeConstants.auto) {
        body['param'] = param;
      }

      final jsonString = json.encode(body);

      final uri = Uri.https('advert-api.wb.ru', "/adv/v0/cpm");
      final response = await http.post(uri, headers: headers, body: jsonString);
      if (response.statusCode == 200) {
        return Resource.success(true);
      } else if (response.statusCode == 422) {
        // Size of bid is not changed
        return Resource.success(false);
      } else if (response.statusCode == 400) {
        return Resource.error("Incorrect campaign identifier");
      } else if (response.statusCode == 401) {
        return Resource.error("Empty authorization header");
      }
    } catch (e) {
      return Resource.error("Unknown error");
    }
    return Resource.error("Unknown error");
  }

  // max 300 requests per minute
  @override
  Future<Resource<bool>> pauseAdvert(String token, int advertId) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};

      final uri = Uri.https('advert-api.wb.ru', "/adv/v0/pause", params);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return Resource.success(true);
      } else if (response.statusCode == 422) {
        //Статус кампании не изменен
        return Resource.success(false);
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: Некорректный идентификатор РК",
        );
      } else if (response.statusCode == 401) {
        return Resource.error(
          "Ответ API WB: Пустой авторизационный заголовок",
        );
      }
    } catch (e) {
      return Resource.error("Неизвестная ошибка");
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  // max 300 requests per minute
  @override
  Future<Resource<bool>> startAdvert(String token, int advertId) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};

      final uri = Uri.https('advert-api.wb.ru', "/adv/v0/start", params);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return Resource.success(true);
      } else if (response.statusCode == 422) {
        //Статус кампании не изменен
        return Resource.success(false);
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: Некорректный идентификатор РК",
        );
      } else if (response.statusCode == 401) {
        return Resource.error(
          "Ответ API WB: Пустой авторизационный заголовок",
        );
      }
    } catch (e) {
      return Resource.error("Неизвестная ошибка");
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  @override
  Future<Resource<int>> getCompanyBudget(String token, int advertId) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};

      final uri = Uri.https('advert-api.wb.ru', "/adv/v1/budget", params);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) {
          return Resource.empty();
        }

        return Resource.success(data['total']);
      } else if (response.statusCode == 429) {
        return Resource.error(
          "Ответ API WB: too many requests with this user ID",
        );
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: кампания $advertId не принадлежит продавцу",
        );
      } else if (response.statusCode == 401) {
        return Resource.error(
          "Ответ API WB: Пустой авторизационный заголовок",
        );
      }
    } catch (e) {
      return Resource.error(e.toString());
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  @override
  Future<Resource<List<AdvertInfoModel>>> getAdverts(String token) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final uri = Uri.parse('https://advert-api.wb.ru/adv/v0/adverts');
      final response = await http.get(uri, headers: headers);

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
      } else if (response.statusCode == 429) {
        return Resource.error(
          "Ответ API WB: Кампании не найдены",
        );
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: Некорректный идентификатор РК",
        );
      } else if (response.statusCode == 401) {
        // "Ответ API WB: Пустой авторизационный заголовок",

        return Resource.empty();
      }
    } catch (e) {
      return Resource.error(
        "Ошибка при обращении к WB продвижение список кампаний: $e",
      );
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  @override
  Future<Resource<int>> balance(String token) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final uri = Uri.https("advert-api.wb.ru", "/adv/v1/balance");
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        final balance = stats['balance'];
        return Resource.success(balance);
      } else if (response.statusCode == 401) {
        return Resource.error(
          "Ответ API WB: Пустой авторизационный заголовок",
        );
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: Некорректный идентификатор продавца",
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка",
      );
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  Future<Resource<AdvertStatModel>> getSearchStat(
      String token, int advertId) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};
      final uri = Uri.https('advert-api.wb.ru', "/adv/v1/stat/words", params);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        final total = stats['stat'][0];
        return Resource.success(AdvertStatModel.fromJson(total, advertId));
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: кампания не найдена",
        );
      } else if (response.statusCode == 401) {
        return Resource.error(
          "Ответ API WB: Пустой авторизационный заголовок",
        );
      } else if (response.statusCode == 429) {
        return Resource.error(
          "Ответ API WB: too many requests with this user ID",
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка $e",
      );
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  @override
  Future<Resource<AdvertStatModel>> getAutoStat(
      String token, int advertId) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};
      final uri = Uri.https('advert-api.wb.ru', "/adv/v1/auto/stat", params);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        return Resource.success(AdvertStatModel.fromJson(stats, advertId));
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: кампания не найдена",
        );
      } else if (response.statusCode == 401) {
        return Resource.error(
          "Ответ API WB: Пустой авторизационный заголовок",
        );
      } else if (response.statusCode == 429) {
        return Resource.error(
          "Ответ API WB: too many requests with this user ID",
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка $e",
      );
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  @override
  Future<Resource<Advert>> getAdvertInfo(String token, int id) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };

      final params = {'id': id.toString()};

      final uri = Uri.https('advert-api.wb.ru', "/adv/v0/advert", params);

      final response = await http.get(uri, headers: headers);
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
              "Неизвестный тип объявления: $advType",
            );
        }
      } else if (response.statusCode == 204) {
        return Resource.error(
          "Ответ API WB: Кампания не найдена",
        );
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: Некорректное значение параметра param",
        );
      } else if (response.statusCode == 401) {
        return Resource.error(
          "Ответ API WB: Пустой авторизационный заголовок",
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка: $e",
      );
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  // STATIC METHODS ====================================================================== STATIC METHODS
  static Future<Resource<AdvertStatModel>> getFullStatInBackground(
      String token, int advertId) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};

      final uri = Uri.https('advert-api.wb.ru', "/adv/v1/fullstat", params);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        // final total = stats['stat'][0];
        return Resource.success(AdvertStatModel.fromJson(stats, advertId));
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: кампания не найдена",
        );
      } else if (response.statusCode == 401) {
        return Resource.error(
          "Ответ API WB: Пустой авторизационный заголовок",
        );
      } else if (response.statusCode == 429) {
        return Resource.error(
          "Ответ API WB: too many requests with this user ID",
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка $e",
      );
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  static Future<Resource<AdvertStatModel>> getSearchStatInBackground(
      String token, int advertId) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};
      final uri = Uri.https('advert-api.wb.ru', "/adv/v1/stat/words", params);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        final total = stats['stat'][0];
        return Resource.success(AdvertStatModel.fromJson(total, advertId));
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: кампания не найдена",
        );
      } else if (response.statusCode == 401) {
        return Resource.error(
          "Ответ API WB: Пустой авторизационный заголовок",
        );
      } else if (response.statusCode == 429) {
        return Resource.error(
          "Ответ API WB: too many requests with this user ID",
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка $e",
      );
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  static Future<Resource<List<AdvertInfoModel>>> getAdvertsInBackground(
      String token) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final uri = Uri.parse('https://advert-api.wb.ru/adv/v0/adverts');
      final response = await http.get(uri, headers: headers);

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
      } else if (response.statusCode == 429) {
        return Resource.error(
          "Ответ API WB: Кампании не найдены",
        );
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: Некорректный идентификатор РК",
        );
      } else if (response.statusCode == 401) {
        // "Ответ API WB: Пустой авторизационный заголовок",

        return Resource.empty();
      }
    } catch (e) {
      return Resource.error(
        "Ошибка при обращении к WB продвижение список кампаний: $e",
      );
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  static Future<Resource<AdvertStatModel>> getAutoStatInBackground(
      String token, int advertId) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};
      final uri = Uri.https('advert-api.wb.ru', "/adv/v1/auto/stat", params);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        return Resource.success(AdvertStatModel.fromJson(stats, advertId));
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: кампания не найдена",
        );
      } else if (response.statusCode == 401) {
        return Resource.error(
          "Ответ API WB: Пустой авторизационный заголовок",
        );
      } else if (response.statusCode == 429) {
        return Resource.error(
          "Ответ API WB: too many requests with this user ID",
        );
      }
    } catch (e) {
      return Resource.error(
        "Неизвестная ошибка $e",
      );
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }

  static Future<Resource<int>> getCompanyBudgetInBackground(
      String token, int advertId) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};

      final uri = Uri.https('advert-api.wb.ru', "/adv/v1/budget", params);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) {
          return Resource.empty();
        }

        return Resource.success(data['total']);
      } else if (response.statusCode == 429) {
        return Resource.error(
          "Ответ API WB: too many requests with this user ID",
        );
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Ответ API WB: кампания $advertId не принадлежит продавцу",
        );
      } else if (response.statusCode == 401) {
        return Resource.error(
          "Ответ API WB: Пустой авторизационный заголовок",
        );
      }
    } catch (e) {
      return Resource.error(e.toString());
    }
    return Resource.error(
      "Неизвестная ошибка",
    );
  }
}
