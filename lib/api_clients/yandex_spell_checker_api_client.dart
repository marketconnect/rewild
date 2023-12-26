import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/api_helpers/ya_speller_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/spell_result.dart';
import 'package:rewild/domain/services/spell_checker_service.dart';

class YandexSpellerApiClient
    implements SpellCheckerServiceSpellCheckerApiClient {
  const YandexSpellerApiClient();

  @override
  Future<Either<RewildError, List<SpellResult>>> checkText(
      {required String text}) async {
    try {
      final apiHelper = YandexSpellerApiHelper.checkText;
      final response = await apiHelper.get(null, {"text": text});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        List<SpellResult> spellResults = data
            .map((json) => SpellResult.fromJson(json as Map<String, dynamic>))
            .toList();

        return right(spellResults);
      } else {
        final errString =
            apiHelper.errResponse(statusCode: response.statusCode);
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "checkText",
          args: [text],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Ошибка при обращении к Yandex Speller API: $e",
        source: runtimeType.toString(),
        name: "checkText",
        args: [text],
      ));
    }
  }
}
