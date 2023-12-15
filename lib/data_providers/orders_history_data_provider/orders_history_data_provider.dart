import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/orders_history_model.dart';
import 'package:rewild/domain/services/orders_history_service.dart';

class OrdersHistoryDataProvider
    implements OrdersHistoryServiceOrdersHistoryDataProvider {
  const OrdersHistoryDataProvider();
  @override
  Future<Either<RewildError, OrdersHistoryModel?>> get(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo}) async {
    try {
      final db = await SqfliteService().database;
      final ordersHistory = await db.rawQuery(
          'SELECT * FROM orders_history WHERE nmId = ? and updatetAt >= ? and updatetAt <= ?',
          [
            nmId,
            dateFrom.millisecondsSinceEpoch,
            dateTo.millisecondsSinceEpoch
          ]);
      if (ordersHistory.isNotEmpty) {
        return right(OrdersHistoryModel.fromMap(ordersHistory.first));
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
          'Не удалось получить историю заказов для $nmId: $e',
          source: runtimeType.toString(),
          name: "get",
          args: [nmId, dateFrom, dateTo]));
    }
  }

  @override
  Future<Either<RewildError, int>> delete(int nmId) async {
    try {
      final db = await SqfliteService().database;
      final resId = await db.rawDelete(
        'DELETE FROM orders_history WHERE nmId = ?',
        [nmId],
      );
      return right(resId);
    } catch (e) {
      return left(RewildError(
        'Не удалось удалить историю заказов для $nmId: $e',
        source: runtimeType.toString(),
        name: "delete",
        args: [nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, int>> insert(
      OrdersHistoryModel ordersHistory) async {
    try {
      final db = await SqfliteService().database;
      final id = await db.rawInsert('''
      INSERT INTO orders_history(
        nmId,
        qty,
        highBuyout,
        updatetAt
      ) VALUES(
        ?,?,?,?
      )''', [
        ordersHistory.nmId,
        ordersHistory.qty,
        ordersHistory.highBuyout,
        ordersHistory.updatetAt.millisecondsSinceEpoch,
      ]);
      return right(id);
    } catch (e) {
      return left(RewildError(
          'Не удалось сохранить историю заказов для ${ordersHistory.nmId}: $e',
          source: runtimeType.toString(),
          name: "insert",
          args: [ordersHistory]));
    }
  }
}
