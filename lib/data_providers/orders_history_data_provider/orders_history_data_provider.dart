import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/orders_history_model.dart';
import 'package:rewild/domain/services/orders_history_service.dart';

class OrdersHistoryDataProvider
    implements OrdersHistoryServiceOrdersHistoryDataProvider {
  const OrdersHistoryDataProvider();
  @override
  Future<Resource<OrdersHistoryModel>> get(
      int nmId, DateTime dateFrom, DateTime dateTo) async {
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
        return Resource.success(
            OrdersHistoryModel.fromMap(ordersHistory.first));
      }
      return Resource.empty();
    } catch (e) {
      return Resource.error(
          'Не удалось получить историю заказов для $nmId: $e');
    }
  }

  @override
  Future<Resource<int>> delete(int nmId) async {
    try {
      final db = await SqfliteService().database;
      final resId = await db.rawDelete(
        'DELETE FROM orders_history WHERE nmId = ?',
        [nmId],
      );
      return Resource.success(resId);
    } catch (e) {
      return Resource.error(
        'Не удалось удалить историю заказов для $nmId: $e',
      );
    }
  }

  @override
  Future<Resource<int>> insert(OrdersHistoryModel ordersHistory) async {
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
      return Resource.success(id);
    } catch (e) {
      return Resource.error(
          'Не удалось сохранить историю заказов для ${ordersHistory.nmId}: $e');
    }
  }
}
