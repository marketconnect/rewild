import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/stocks_model.dart';
import 'package:rewild/domain/services/card_of_product_service.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';

abstract class StockServiceStocksDataProvider {
  Future<Resource<List<StocksModel>>> getAll();
  Future<Resource<List<StocksModel>>> get(int nmId);
}

class StockService
    implements
        CardOfProductServiceStockDataProvider,
        SingleCardScreenStockService {
  final StockServiceStocksDataProvider stocksDataProvider;

  StockService({required this.stocksDataProvider});

  @override
  Future<Resource<List<StocksModel>>> getAll() async {
    return stocksDataProvider.getAll();
  }

  @override
  Future<Resource<List<StocksModel>>> get(int nmId) async {
    return stocksDataProvider.get(nmId);
  }
}
