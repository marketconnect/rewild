import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/api_helpers/warehouses_api_helper.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/warehouse.dart';
import 'package:rewild/domain/services/card_of_product_service.dart';
import 'package:rewild/domain/services/warehouse_service.dart';

class WarehouseApiClient
    implements
        CardOfProductServiceWarehouseApiCient,
        WarehouseServiceWerehouseApiClient {
  const WarehouseApiClient();
  @override
  Future<Either<RewildError, List<Warehouse>>> getAll() async {
    try {
      final params = {
        'latitude': '55.753737',
        'longitude': '37.6201',
      };
      final wbApiHelper = WbWarehousesHistoryApiHelper.get;
      final response = await wbApiHelper.get(null, params);
      // final uri =
      //     Uri.parse('https://www.wildberries.ru/webapi/spa/product/deliveryinfo')
      //         .replace(queryParameters: params);
      // final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final warehouses = data['value']['times'];
        List<Warehouse> resultWarehousesList = [];

        for (final warehouse in warehouses) {
          Warehouse w = Warehouse.fromJson(warehouse);
          resultWarehousesList.add(w);
        }

        return right(resultWarehousesList);
      } else {
        final errString = wbApiHelper.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          errString,
          source: runtimeType.toString(),
          name: "getAll",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        "$e",
        source: runtimeType.toString(),
        name: "getAll",
        args: [],
      ));
    }
  }
}
