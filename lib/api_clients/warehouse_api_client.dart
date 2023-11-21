import 'dart:convert';

import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/warehouse.dart';
import 'package:rewild/domain/services/card_of_product_service.dart';
import 'package:rewild/domain/services/warehouse_service.dart';
import 'package:http/http.dart' as http;

class WarehouseApiClient
    implements
        CardOfProductServiceWarehouseApiCient,
        WarehouseServiceWerehouseApiClient {
  const WarehouseApiClient();
  @override
  Future<Resource<List<Warehouse>>> fetchAll() async {
    final params = {
      'latitude': '55.753737',
      'longitude': '37.6201',
    };

    final uri =
        Uri.parse('https://www.wildberries.ru/webapi/spa/product/deliveryinfo')
            .replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final warehouses = data['value']['times'];
      List<Warehouse> resultWarehousesList = [];

      for (final warehouse in warehouses) {
        Warehouse w = Warehouse.fromJson(warehouse);
        resultWarehousesList.add(w);
      }

      return Resource.success(resultWarehousesList);
    } else if (response.statusCode == 429) {
      return Resource.error("Слишком много запросов");
    } else if (response.statusCode == 400) {
      return Resource.error("Некорректные данные");
    } else if (response.statusCode == 401) {
      return Resource.error("Вы не авторизованы");
    } else {
      return Resource.error("Неизвестная ошибка");
    }
  }
}
