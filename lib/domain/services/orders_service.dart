import 'package:rewild/core/utils/extensions/date_time.dart';
import 'package:rewild/core/utils/resource.dart';

abstract class OrderServiceOrderApiClient {
  Future<Resource<Map<int, int>>> get(
      List<int> skus, DateTime dateFrom, DateTime dateTo);
}

class OrderService {
  final OrderServiceOrderApiClient orderApiClient;
  const OrderService({required this.orderApiClient});

  Future<Resource<Map<int, int>>> get(
    List<int> skus,
    DateTime date,
  ) async {
    final dateFrom = date.getStartOfDay();
    final dateTo = date.getEndOfDay();
    final resource = await orderApiClient.get(skus, dateFrom, dateTo);

    return resource;
  }
}
