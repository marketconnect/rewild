import 'package:rewild/core/utils/resource.dart';
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
  Future<Resource<bool>> update(List<Warehouse> warehouses) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      for (final warehouse in warehouses) {
        final ok =
            await prefs.setString(warehouse.id.toString(), warehouse.name);
        if (!ok) {
          return Resource.error(
              'Не удалось сохранить склад ${warehouse.id} ${warehouse.name} ');
        }
      }
      return Resource.success(true);
    } on Exception catch (e) {
      return Resource.error('Не удалось сохранить склады: $e');
    }
  }

  @override
  Future<Resource<String>> get(int id) async {
    try {
      final strId = id.toString();
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(strId) ?? '';
      if (name.isNotEmpty) {
        return Resource.success(name);
      }
      return Resource.empty();
    } on Exception catch (e) {
      return Resource.error('Не удалось сохранить склад $id:  $e');
    }
  }
}
