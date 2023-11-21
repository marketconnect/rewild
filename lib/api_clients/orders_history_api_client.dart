import 'dart:convert';

import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/orders_history_model.dart';
import 'package:http/http.dart' as http;
import 'package:rewild/domain/services/orders_history_service.dart';

class OrdersHistoryApiClient
    implements OrdersHistoryServiceOrdersHistoryApiClient {
  const OrdersHistoryApiClient();

  @override
  Future<Resource<OrdersHistoryModel>> fetch(int nmId) async {
    try {
      final uri = Uri.parse(
          'https://product-order-qnt.wildberries.ru/v2/by-nm/?nm=$nmId');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final bodyList = jsonDecode(response.body);

        if (bodyList.length == 0) {
          return Resource.empty();
        }
        final json = jsonDecode(response.body)[0];
        // Mapping
        final qty = json['qnt'] ?? 0;
        final highBuyout = json['highBuyout'] ?? false;
        final updatetAt = DateTime.now();

        return Resource.success(OrdersHistoryModel(
          nmId: nmId,
          qty: qty,
          highBuyout: highBuyout,
          updatetAt: updatetAt,
        ));
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
