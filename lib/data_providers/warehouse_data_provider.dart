import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/warehouse.dart';
import 'package:rewild/domain/services/card_of_product_service.dart';
import 'package:rewild/domain/services/warehouse_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarehouseDataProvider
    implements
        CardOfProductServiceWarehouseDataProvider,
        WarehouseServiceWarehouseProvider {
  const WarehouseDataProvider();
  @override
  Future<Either<RewildError, bool>> update(List<Warehouse> warehouses) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      for (final warehouse in warehouses) {
        final ok =
            await prefs.setString(warehouse.id.toString(), warehouse.name);
        if (!ok) {
          return left(RewildError(
              'Не удалось сохранить склад ${warehouse.id} ${warehouse.name} ',
              source: runtimeType.toString(),
              name: "update",
              args: [warehouse]);
        }
      }
      return right(true);
    } on Exception catch (e) {
      return left(RewildError('Не удалось сохранить склады: $e',
          source: runtimeType.toString(), name: "update", args: [warehouses]);
    }
  }

  @override
  Future<Either<RewildError, String>> get(int id) async {
    try {
      final strId = id.toString();
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(strId) ?? '';
      if (name.isNotEmpty) {
        return right(name);
      }
      return right(null);
    } on Exception catch (e) {
      return left(RewildError('Не удалось сохранить склад $id:  $e',
          source: runtimeType.toString(), name: "get", args: [id]);
    }
  }
}
