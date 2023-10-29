import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/supply_model.dart';
import 'package:rewild/presentation/all_cards/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/single_card/single_card_screen_view_model.dart';

abstract class SupplyServiceSupplyDataProvider {
  Future<Resource<List<SupplyModel>>> get(int nmId);
  Future<Resource<List<SupplyModel>>> getForOne(
    int nmId,
  );
}

class SupplyService
    implements AllCardsScreenSupplyService, SingleCardScreenSupplyService {
  final SupplyServiceSupplyDataProvider supplyDataProvider;

  SupplyService({required this.supplyDataProvider});

  @override
  Future<Resource<List<SupplyModel>>> getForOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo}) async {
    return supplyDataProvider.getForOne(nmId);
  }

  // Future<Resource<List<SupplyModel>>> getAll() async {
  //   return supplyDataProvider.getAll();
  // }
}
