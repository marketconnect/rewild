import 'package:rewild/core/utils/date_time_utils.dart';
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
    final dateFrom = getStartOfDay(date);
    final dateTo = getEndOfDay(date);
    final resource = await orderApiClient.get(skus, dateFrom, dateTo);

    return resource;
  }
}
