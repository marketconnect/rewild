import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/orders_history_model.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';

abstract class OrdersHistoryServiceOrdersHistoryApiClient {
  Future<Resource<OrdersHistoryModel>> get(int nmId);
}

abstract class OrdersHistoryServiceOrdersHistoryDataProvider {
  Future<Resource<int>> insert(OrdersHistoryModel ordersHistory);
  Future<Resource<OrdersHistoryModel>> get(
      int nmId, DateTime dateFrom, DateTime dateTo);
  Future<Resource<int>> delete(int nmId);
}

class OrdersHistoryService implements SingleCardScreenOrdersHistoryService {
  final OrdersHistoryServiceOrdersHistoryApiClient ordersHistoryApiClient;
  final OrdersHistoryServiceOrdersHistoryDataProvider ordersHistoryDataProvider;

  OrdersHistoryService(
      {required this.ordersHistoryApiClient,
      required this.ordersHistoryDataProvider});

  @override
  Future<Resource<OrdersHistoryModel>> get(int nmId) async {
    // get from local db
    final now = DateTime.now();
    final ordersHistoryResource =
        await ordersHistoryDataProvider.get(nmId, yesterdayEndOfTheDay(), now);
    if (ordersHistoryResource is Error) {
      return Resource.error(ordersHistoryResource.message!,
          source: runtimeType.toString(), name: 'get', args: [nmId]);
    }
    if (ordersHistoryResource is Success) {
      return ordersHistoryResource;
    }
    // not found in local db
    // get from WB
    final ordersHistoryFromServerResource =
        await ordersHistoryApiClient.get(nmId);
    if (ordersHistoryFromServerResource is Error) {
      return Resource.error(ordersHistoryFromServerResource.message!,
          source: runtimeType.toString(), name: 'get', args: [nmId]);
    }
    if (ordersHistoryFromServerResource is Empty) {
      final emptyOrdersHistory = OrdersHistoryModel(
        nmId: nmId,
        qty: 0,
        highBuyout: false,
        updatetAt: now,
      );

      return Resource.success(emptyOrdersHistory);
    }
    // save to local db
    // but before delete all previous data
    // delete
    final deleteResource = await ordersHistoryDataProvider.delete(nmId);
    if (deleteResource is Error) {
      return Resource.error(deleteResource.message!,
          source: runtimeType.toString(), name: 'get', args: [nmId]);
    }
    // save
    final saveResource = await ordersHistoryDataProvider
        .insert(ordersHistoryFromServerResource.data!);
    if (saveResource is Error) {
      return Resource.error(saveResource.message!,
          source: runtimeType.toString(), name: 'get', args: [nmId]);
    }

    // return
    return Resource.success(ordersHistoryFromServerResource.data!);
  }
}
