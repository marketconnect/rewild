import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/price_history_model.dart';

abstract class PriceHistoryDataProvider {
  Future<Resource<void>> insert(List<PriceHistoryModel> priceHistoryList);
  Future<Resource<List<PriceHistoryModel>>> fetch(List<int> nmId);
  Future<Resource<void>> delete(List<int> nmId);
}

class PriceHistoryService {
  final PriceHistoryDataProvider priceHistoryDataProvider;

  PriceHistoryService({required this.priceHistoryDataProvider});

  Future<Resource<List<PriceHistoryModel>>> fetch(
      List<int> supplierIdList) async {
    // get stored price history
    final priceHistoryListResource =
        await priceHistoryDataProvider.fetch(supplierIdList);

    if (priceHistoryListResource is Error) {
      return Resource.error(priceHistoryListResource.message!);
    }
    final priceHistoryList = priceHistoryListResource.data!;
    return Resource.success(priceHistoryList);
  }
}
