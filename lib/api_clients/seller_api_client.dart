import 'dart:convert';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/seller_model.dart';

import 'package:http/http.dart' as http;
import 'package:rewild/domain/services/seller_service.dart';

class SellerApiClient implements SellerServiceSelerApiClient {
  const SellerApiClient();
  @override
  Future<Resource<SellerModel>> get(int supplierId) async {
    try {
      final uri = Uri.parse(
          'https://www.wildberries.ru/webapi/seller/data/short/$supplierId');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SellerModel resultSeller = SellerModel.fromJson(data);

        return Resource.success(resultSeller);
      } else if (response.statusCode == 429) {
        return Resource.error(
          "Слишком много запросов",
          source: runtimeType.toString(),
          name: "get",
          args: [supplierId],
        );
      } else if (response.statusCode == 400) {
        return Resource.error(
          "Некорректные данные",
          source: runtimeType.toString(),
          name: "get",
          args: [supplierId],
        );
      } else if (response.statusCode == 401) {
        return Resource.error(
          "Вы не авторизованы",
          source: runtimeType.toString(),
          name: "get",
          args: [supplierId],
        );
      }
    } on Exception catch (e) {
      return Resource.error(
        "Ошибка при обращении к WB: $e",
        source: runtimeType.toString(),
        name: "get",
        args: [supplierId],
      );
    }
    return Resource.error(
      "Неизвестная ошибка",
      source: runtimeType.toString(),
      name: "get",
      args: [supplierId],
    );
  }
}
