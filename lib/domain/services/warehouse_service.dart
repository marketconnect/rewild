import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/warehouse.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';
import 'package:rewild/presentation/single_group_screen/single_groups_screen_view_model.dart';

abstract class WarehouseServiceWarehouseProvider {
  Future<Either<RewildError, bool>> update({required List<Warehouse> warehouses});
  Future<Either<RewildError, String?>> get({required int id}) ;
}

abstract class WarehouseServiceWerehouseApiClient {
  Future<Either<RewildError, List<Warehouse>>> getAll();
}

class WarehouseService
    implements
        SingleCardScreenWarehouseService,
        SingleGroupScreenWarehouseService {
  final WarehouseServiceWarehouseProvider warehouseProvider;
  final WarehouseServiceWerehouseApiClient warehouseApiClient;
  const WarehouseService(
      {required this.warehouseProvider, required this.warehouseApiClient});

  @override
  Future<Either<RewildError, Warehouse>> getById(int id) async {
    final getResource = await warehouseProvider.get(id);
    if (getResource is Error) {
      return left(RewildError(getResource.message!,
          source: runtimeType.toString(), name: "getById", args: [id]);
    }
    // warehouse exists
    if (getResource is Success) {
      final name = getResource.data!;
      Warehouse warehouse = Warehouse(
        id: id,
        name: name,
      );
      return right(warehouse);
    }
    // warehouse does`t exist
    final fetchedWarehusesResource = await warehouseApiClient.getAll();
    if (fetchedWarehusesResource is Error) {
      return left(RewildError(fetchedWarehusesResource.message!,
          source: runtimeType.toString(), name: "getById", args: [id]);
    }
    final fetchedWarehouses = fetchedWarehusesResource.data!;
    final okResource = await warehouseProvider.update(fetchedWarehouses);
    if (okResource is Error) {
      return left(RewildError(okResource.message!,
          source: runtimeType.toString(), name: "getById", args: [id]);
    }
    final againGetResource = await warehouseProvider.get(id);
    if (againGetResource is Error) {
      return left(RewildError(againGetResource.message!,
          source: runtimeType.toString(), name: "getById", args: [id]);
    }
    // warehouse exists

    final name = againGetResource.data;
    Warehouse warehouse = Warehouse(
      id: id,
      name: name ?? "",
    );
    return right(warehouse);
  }
}
