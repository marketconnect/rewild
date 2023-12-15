import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/api_helpers/orders_history_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/orders_history_model.dart';

import 'package:rewild/domain/services/orders_history_service.dart';

class OrdersHistoryApiClient
    implements OrdersHistoryServiceOrdersHistoryApiClient {
  const OrdersHistoryApiClient();

  @override
  Future<Either<RewildError, OrdersHistoryModel>> get(
      {required int nmId}) async {
    try {
      // final uri = Uri.parse(
      //     'https://product-order-qnt.wildberries.ru/v2/by-nm/?nm=$nmId');
      final params = {'nm': nmId.toString()};
      final wbApiHelper = WbOrdersHistoryApiHelper.get;
      final response = await wbApiHelper.get(null, params);
      if (response.statusCode == 200) {
        final bodyList = jsonDecode(response.body);

        if (bodyList.length == 0) {
          return right(OrdersHistoryModel.empty());
        }
        final json = jsonDecode(response.body)[0];
        // Mapping
        final qty = json['qnt'] ?? 0;
        final highBuyout = json['highBuyout'] ?? false;
        final updatetAt = DateTime.now();

        return right(OrdersHistoryModel(
          nmId: nmId,
          qty: qty,
          highBuyout: highBuyout,
          updatetAt: updatetAt,
        ));
      } else {
        final errString = wbApiHelper.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "get",
          args: [nmId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "Ошибка при получении списка отзывов: $e",
        source: runtimeType.toString(),
        name: "get",
        args: [nmId],
      ));
    }
  }
}
