import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/services/orders_service.dart';
import 'package:rewild/pb/message.pb.dart';
import 'package:rewild/pb/service.pbgrpc.dart';

class OrdersApiClient implements OrderServiceOrderApiClient {
  const OrdersApiClient();

  @override
  Future<Resource<Map<int, int>>> get(
      List<int> skus, DateTime dateFrom, DateTime dateTo) async {
    final channel = ClientChannel(
      APIConstants.apiHost,
      port: APIConstants.apiPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectTimeout: Duration(seconds: 5),
        connectionTimeout: Duration(seconds: 5),
      ),
    );

    try {
      if (skus.isEmpty) {
        return Resource.error(
          "Некорректные данные",
        );
      }

      final stub = OrderServiceClient(channel);
      final request = GetOrdersFromToReq(
        from: Int64(dateFrom.millisecondsSinceEpoch),
        to: Int64(dateTo.millisecondsSinceEpoch),
        skus: skus.map((e) => Int64(e)).toList(),
      );
      final response = await stub.getOrdersFromTo(
        request,
      );

      Map<int, int> orders = {};
      final ordersFromServer = response.orders;

      for (final order in ordersFromServer) {
        orders[order.sku.toInt()] = order.qty.toInt();
      }
      return Resource.success(orders);
    } catch (e) {
      if (e is GrpcError) {
        if (e.code == StatusCode.internal) {
          return Resource.error(
            "Ошибка сервера",
          );
        } else if (e.code == StatusCode.unavailable) {
          return Resource.error(
            ErrorsConstants.unavailable,
          );
        }
      }
      return Resource.error(
        "Неизвестная ошибка во время получения данных об остатках с сервера: $e",
      );
    } finally {
      await channel.shutdown();
    }
  }
}
