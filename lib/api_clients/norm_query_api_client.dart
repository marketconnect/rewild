import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:rewild/core/utils/rewild_error.dart';

class NormQueryApiClient {
  const NormQueryApiClient();

  static Future<Either<RewildError, String>> getNormQuery(
      String keyword) async {
    try {
      // URL with the query
      print('keyword: $keyword');
      var url = Uri.parse(
          'https://search.wb.ru/exactmatch/ru/common/v4/search?TestGroup=no_test&TestID=no_test&appType=1&curr=rub&dest=-1257786&query=$keyword&regions=80,38,83,4,64,33,68,70,30,40,86,75,69,1,31,66,110,48,22,71,114&resultset=filters&spp=35&suppressSpellcheck=false');

      // Make the GET request
      var response = await http.get(url);

      // Parse the JSON response
      if (response.statusCode == 200) {
        final resp = jsonDecode(utf8.decode(response.bodyBytes));
        if (resp['metadata'] == null) {
          return left(RewildError(
            "Ошибка при обращении к WB: 'Failed to load data'",
            source: "NormQueryApiClient",
            name: "getReq",
            args: [keyword],
          ));
        }
        return right(resp['metadata']['normquery'] ?? "");
      } else {
        return left(RewildError(
          "Ошибка при обращении к WB: 'Failed to load data'",
          source: "NormQueryApiClient",
          name: "getReq",
          args: [keyword],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Ошибка при обращении к WB: $e",
        source: "NormQueryApiClient",
        name: "getReq",
        args: [keyword],
      ));
    }
  }
}
