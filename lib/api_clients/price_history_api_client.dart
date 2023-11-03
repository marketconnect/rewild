import 'dart:convert';

import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/price_history_model.dart';
import 'package:http/http.dart' as http;

class PriceHistoryApiClient {
  const PriceHistoryApiClient();

  @override
  Future<Resource<List<PriceHistoryModel>>> fetch(String link) async {
    try {
      final nmId = int.tryParse(
          link.split('/info/price-history.json')[0].split('/').last);
      if (nmId == null) {
        return Resource.error(
          "Некорректные данные: $nmId.",
        );
      }

      var uri = Uri.parse(link);

      List<PriceHistoryModel> priceHistoryList = [];
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        final bodyList = jsonDecode(response.body);

        if (bodyList.length == 0) {
          return Resource.empty();
        }
        var json = jsonDecode(response.body)[0];
        // Mapping

        for (final priceHisstory in json) {
          priceHistoryList.add(PriceHistoryModel(
              nmId: nmId,
              dt: priceHisstory['dt'] ?? 0,
              price: priceHisstory['price'] ?? 0,
              updateAt: DateTime.now().millisecondsSinceEpoch));
        }
        return Resource.success(priceHistoryList);
      }
    } catch (e) {
      return Resource.error(
        "Ошибка при обращении к WB product-order: $e",
      );
    }
    return Resource.error(
      "Неизвестная ошибка при обращении к WB product-order",
    );
  }
}
