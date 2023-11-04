import 'dart:convert';

import 'package:rewild/core/utils/resource.dart';
import 'package:http/http.dart' as http;
import 'package:rewild/domain/entities/advert_model.dart';
import 'package:rewild/domain/services/advert_service.dart';

class AdvertApiClient implements AdvertServiceAdvertDataProvider {
  @override
  Future<Resource<List<Advert>>> getAdvert(String token) async {
    try {
      var headers = {'Authorization': token};
      var uri = Uri.parse('https://advert-api.wb.ru/adv/v0/adverts');
      var response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return Resource.success(
          List<Advert>.from(
            data.map((x) => Advert.fromJson(x)),
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
        return Resource.error(
          "Ответ API WB: Пустой авторизационный заголовок",
        );
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
}
