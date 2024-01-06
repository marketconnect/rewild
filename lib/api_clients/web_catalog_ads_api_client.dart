import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/api_helpers/web_catalog_ads_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/search_adv_data.dart';
import 'package:rewild/domain/services/web_catalog_ads_service.dart';

class WebCatalogAdsApiClient
    implements WebCatalogAdsServiceWebCatalogAdsApiClient {
  const WebCatalogAdsApiClient();
  Future<Either<RewildError, List<SearchAdvData>>> getAdvData(
      String keyword, List<int> nmIds) async {
    final params = {
      "TestGroup": "no_test",
      "TestID": "no_test",
      "appType": "1",
      "curr": "rub",
      "dest": "-1257786",
      "regions":
          "80,38,4,64,83,33,68,70,69,30,86,75,40,1,66,110,22,31,48,71,114",
      "resultset": "catalog",
      "sort": "popular",
      "spp": "0",
      "suppressSpellcheck": "false",
      "keyword": keyword
    };

    try {
      final wbApiHelper = WebCatalogAdsApiHelper.searchAds;

      var response = await wbApiHelper.get(null, params);
      if (response.statusCode == 200) {
        var advDict = jsonDecode(response.body);
        var pages = advDict['pages'] ?? [];
        if (pages.isEmpty || !pages[0].containsKey('positions')) {
          return right([]);
        }

        var positions = pages[0]['positions'];
        var adverts = advDict['adverts'] ?? [];

        print(nmIds);
        List<SearchAdvData> result = [];
        for (var i = 0; i < adverts.length && i < positions.length; i++) {
          if (!nmIds.contains(adverts[i]['id'])) {
            continue;
          }
          print("here --- ${adverts[i]['id']}");
          result.add(SearchAdvData.fromJson({
            'id': adverts[i]['id'],
            'cpm': adverts[i]['cpm'],
            'subject': adverts[i]['subject'],
            'pos': positions[i],
            'order': i,
          }));
        }
        return right(result);
      } else {
        final errString = wbApiHelper.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "getAdvData",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError("Неизвестная ошибка: $e",
          source: runtimeType.toString(), name: "getAdvData", args: []));
    }
  }
}
