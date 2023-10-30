import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/presentation/single_card/single_card_screen_view_model.dart';

abstract class InitStockServiceInitStockDataProvider {
  Future<Resource<List<InitialStockModel>>> getAll(
      DateTime dateFrom, DateTime dateTo);

  Future<Resource<List<InitialStockModel>>> get(
      int nmId, DateTime dateFrom, DateTime dateTo);
}

class InitialStockService
    implements
        // AllCardsScreenInitStockService,
        SingleCardScreenInitialStockService {
  final InitStockServiceInitStockDataProvider initStockDataProvider;

  InitialStockService({required this.initStockDataProvider});

  // Future<Resource<List<InitialStockModel>>> getAll(
  //     [DateTime? dateFrom, DateTime? dateTo]) async {
  //   if (dateFrom == null || dateTo == null) {
  //     dateFrom = yesterdayEndOfTheDay();
  //     dateTo = DateTime.now();
  //   }
  //   return initStockDataProvider.getAll(dateFrom, dateTo);
  // }

  @override
  Future<Resource<List<InitialStockModel>>> get(int nmId,
      [DateTime? dateFrom, DateTime? dateTo]) async {
    if (dateFrom == null || dateTo == null) {
      dateFrom = yesterdayEndOfTheDay();
      dateTo = DateTime.now();
    }
    return initStockDataProvider.get(nmId, dateFrom, dateTo);
  }
}
