import 'dart:convert';

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
import 'package:rewild/domain/services/advert_service.dart';

class AdvertApiClient implements AdvertServiceAdvertApiClient {
  const AdvertApiClient();

  // max 300 requests per minute
  @override
  Future<Resource<bool>> pauseAdvert(String token, int advertId) async {
    try {
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};

      var uri = Uri.https('advert-api.wb.ru', "/adv/v0/pause", params);
      var response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        print("pause 200");
        return Resource.success(true);
      } else if (response.statusCode == 422) {
        print("pause 422");
        //Статус кампании не изменен
        return Resource.success(false);
      } else if (response.statusCode == 400) {
        print("pause 400");
        return Resource.error(
          "Ответ API WB: Некорректный идентификатор РК",
        );
      } else if (response.statusCode == 401) {
        print("pause 401");
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
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};

      var uri = Uri.https('advert-api.wb.ru', "/adv/v0/start", params);
      var response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        print("start: 200");
        return Resource.success(true);
      } else if (response.statusCode == 422) {
        print("start: 422");
        //Статус кампании не изменен
        return Resource.success(false);
      } else if (response.statusCode == 400) {
        print("start: 400");
        return Resource.error(
          "Ответ API WB: Некорректный идентификатор РК",
        );
      } else if (response.statusCode == 401) {
        print("start: 401");
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
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      final params = {'id': advertId.toString()};

      var uri = Uri.https('advert-api.wb.ru', "/adv/v1/budget", params);
      var response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
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
          "Ответ API WB: кампания не принадлежит продавцу",
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
    print("getAdverts");
    try {
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      var uri = Uri.parse('https://advert-api.wb.ru/adv/v0/adverts');
      var response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print("getAdverts 200");
        var data = jsonDecode(utf8.decode(response.bodyBytes));
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
        print("getAdverts 429");
        return Resource.error(
          "Ответ API WB: Кампании не найдены",
        );
      } else if (response.statusCode == 400) {
        print("getAdverts 400");
        return Resource.error(
          "Ответ API WB: Некорректный идентификатор РК",
        );
      } else if (response.statusCode == 401) {
        print("getAdverts 401");
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
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };
      var uri = Uri.https("advert-api.wb.ru", "/adv/v1/balance");
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

  @override
  Future<Resource<Advert>> getAdvertInfo(String token, int id) async {
    try {
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };

      final params = {'id': id.toString()};

      var uri = Uri.https('advert-api.wb.ru', "/adv/v0/advert", params);

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));

        final advType = stats['type'];

        switch (advType) {
          case 4:
            // catalog
            return Resource.success(AdvertCatalogueModel.fromJson(stats));

          case 5:
            // card
            return Resource.success(AdvertCardModel.fromJson(stats));
          case 6:
            // search
            return Resource.success(AdvertSearchModel.fromJson(stats));
          case 7:
            // recomendation
            return Resource.success(AdvertRecomendaionModel.fromJson(stats));
          case 8:
            // auto
            return Resource.success(AdvertAutoModel.fromJson(stats));
          case 9:
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
}
