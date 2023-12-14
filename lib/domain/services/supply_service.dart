import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/supply_model.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';

abstract class SupplyServiceSupplyDataProvider {
  Future<Either<RewildError, List<SupplyModel>>> get(int nmId);
  Future<Either<RewildError, List<SupplyModel>>> getForOne(
    int nmId,
  );
}

class SupplyService
    implements AllCardsScreenSupplyService, SingleCardScreenSupplyService {
  final SupplyServiceSupplyDataProvider supplyDataProvider;

  SupplyService({required this.supplyDataProvider});

  @override
  Future<Either<RewildError, List<SupplyModel>>> getForOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo}) async {
    return supplyDataProvider.getForOne(nmId);
  }

  // Future<Either<RewildError,List<SupplyModel>>> getAll() async {
  //   return supplyDataProvider.getAll();
  // }
}
