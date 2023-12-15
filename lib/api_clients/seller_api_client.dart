import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/api_helpers/seller_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/seller_model.dart';

import 'package:http/http.dart' as http;
import 'package:rewild/domain/services/seller_service.dart';

class SellerApiClient implements SellerServiceSelerApiClient {
  const SellerApiClient();
  @override
  Future<Either<RewildError, SellerModel>> get(
      {required int supplierId}) async {
    try {
      final uri = Uri.parse(
          'https://www.wildberries.ru/webapi/seller/data/short/$supplierId');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SellerModel resultSeller = SellerModel.fromJson(data);

        return right(resultSeller);
      } else {
        final wbApiHelper = SellerApiHelper.get;
        final errString = wbApiHelper.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "get",
          args: [supplierId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Ошибка при обращении к WB: $e",
        source: runtimeType.toString(),
        name: "get",
        args: [supplierId],
      ));
    }
  }
}
