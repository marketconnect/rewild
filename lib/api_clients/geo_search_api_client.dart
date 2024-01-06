import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/api_helpers/geo_search_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/services/geo_search_service.dart';

class GeoSearchApiClient implements GeoSearchServiceGeoSearchApiClient {
  const GeoSearchApiClient();
  @override
  Future<Either<RewildError, Map<int, int>>> getProductsNmIdIndexMap(
      {required String gNum,
      required String query,
      required List<int> nmIds}) async {
    var params = {
      'TestGroup': 'score_group_21',
      'TestID': '388',
      'appType': '1',
      'curr': 'rub',
      'dest': gNum,
      'query': query,
      'resultset': 'catalog',
      'sort': 'popular',
      'spp': '27',
      'suppressSpellcheck': 'false',
      'uclusters': '0'
    };
    try {
      var response = await GeoSearchApiHelper.search.get(null, params);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> products = data['data']['products'];

        Map<int, int> idToIndexMap = {};
        for (var i = 0; i < products.length; i++) {
          int productId = products[i]['id'];
          if (nmIds.contains(productId)) {
            idToIndexMap[productId] = i;
          }
        }
        return right(idToIndexMap);
      } else {
        return left(RewildError(
          GeoSearchApiHelper.search
              .errResponse(statusCode: response.statusCode),
          source: 'GeoApiClient',
          name: 'getProducts',
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Неизвестная ошибка: $e",
        source: 'GeoApiClient',
        name: 'getProducts',
        args: [],
      ));
    }

    // var uri =
    //     Uri.https('search.wb.ru', '/exactmatch/ru/male/v4/search', params);
    // var response = await http.get(uri);

    // if (response.statusCode == 200) {
    //   var data = jsonDecode(response.body);
    //   List<dynamic> products = data['data']['products'];

    //   Map<int, int> idToIndexMap = {};
    //   for (var i = 0; i < products.length; i++) {
    //     int productId = products[i]['id'];
    //     if (nmIds.contains(productId)) {
    //       idToIndexMap[productId] = i;
    //     }
    //   }
    //   return right(idToIndexMap);
    // } else {
    //   return left(RewildError(response.body,
    //       source: 'GeoApiClient', name: 'getProducts', args: []));
    // }
  }
}
