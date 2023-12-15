import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/orders_history_model.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';

abstract class OrdersHistoryServiceOrdersHistoryApiClient {
  Future<Either<RewildError, OrdersHistoryModel>> get({required  int nmId});
}

abstract class OrdersHistoryServiceOrdersHistoryDataProvider {
  Future<Either<RewildError, int>> insert(OrdersHistoryModel ordersHistory);
  Future<Either<RewildError, OrdersHistoryModel?>> get(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo});
  Future<Either<RewildError, int>> delete(int nmId);
}

class OrdersHistoryService implements SingleCardScreenOrdersHistoryService {
  final OrdersHistoryServiceOrdersHistoryApiClient ordersHistoryApiClient;
  final OrdersHistoryServiceOrdersHistoryDataProvider ordersHistoryDataProvider;

  OrdersHistoryService(
      {required this.ordersHistoryApiClient,
      required this.ordersHistoryDataProvider});

  @override
  Future<Either<RewildError, OrdersHistoryModel>> get(int nmId) async {
    // get from local db
    final now = DateTime.now();
    final ordersHistoryResource =
        await ordersHistoryDataProvider.get(nmId:  nmId,dateFrom:  yesterdayEndOfTheDay(),dateTo:  now);
    if (ordersHistoryResource is Error) {
      return left(RewildError(ordersHistoryResource.message!,
          source: runtimeType.toString(), name: 'get', args: [nmId]);
    }
    if (ordersHistoryResource is Success) {
      return ordersHistoryResource;
    }
    // not found in local db
    // get from WB
    final ordersHistoryFromServerResource =
        await ordersHistoryApiClient.get(nmId: nmId);
    if (ordersHistoryFromServerResource is Error) {
      return left(RewildError(ordersHistoryFromServerResource.message!,
          source: runtimeType.toString(), name: 'get', args: [nmId]);
    }
    if (ordersHistoryFromServerResource is Empty) {
      final emptyOrdersHistory = OrdersHistoryModel(
        nmId: nmId,
        qty: 0,
        highBuyout: false,
        updatetAt: now,
      );

      return right(emptyOrdersHistory);
    }
    // save to local db
    // but before delete all previous data
    // delete
    final deleteResource = await ordersHistoryDataProvider.delete(nmId);
    if (deleteResource is Error) {
      return left(RewildError(deleteResource.message!,
          source: runtimeType.toString(), name: 'get', args: [nmId]);
    }
    // save
    final saveResource = await ordersHistoryDataProvider
        .insert(ordersHistoryFromServerResource.data!);
    if (saveResource is Error) {
      return left(RewildError(saveResource.message!,
          source: runtimeType.toString(), name: 'get', args: [nmId]);
    }

    // return
    return right(ordersHistoryFromServerResource.data!);
  }
}
