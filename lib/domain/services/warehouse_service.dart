import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/warehouse.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';

abstract class WarehouseServiceWarehouseProvider {
  Future<Resource<bool>> update(List<Warehouse> warehouses);
  Future<Resource<String>> get(int id);
}

abstract class WarehouseServiceWerehouseApiClient {
  Future<Resource<List<Warehouse>>> fetchAll();
}

class WarehouseService implements SingleCardScreenWarehouseService {
  final WarehouseServiceWarehouseProvider warehouseProvider;
  final WarehouseServiceWerehouseApiClient warehouseApiClient;
  const WarehouseService(
      {required this.warehouseProvider, required this.warehouseApiClient});

  @override
  Future<Resource<Warehouse>> getById(int id) async {
    final getResource = await warehouseProvider.get(id);
    if (getResource is Error) {
      return Resource.error(getResource.message!);
    }
    // warehouse exists
    if (getResource is Success) {
      final name = getResource.data!;
      Warehouse warehouse = Warehouse(
        id: id,
        name: name,
      );
      return Resource.success(warehouse);
    }
    // warehouse does`t exist
    final fetchedWarehusesResource = await warehouseApiClient.fetchAll();
    if (fetchedWarehusesResource is Error) {
      return Resource.error(fetchedWarehusesResource.message!);
    }
    final fetchedWarehouses = fetchedWarehusesResource.data!;
    final okResource = await warehouseProvider.update(fetchedWarehouses);
    if (okResource is Error) {
      return Resource.error(okResource.message!);
    }
    final againGetResource = await warehouseProvider.get(id);
    if (againGetResource is Error) {
      return Resource.error(againGetResource.message!);
    }
    // warehouse exists

    final name = againGetResource.data;
    Warehouse warehouse = Warehouse(
      id: id,
      name: name ?? "",
    );
    return Resource.success(warehouse);
  }
}
