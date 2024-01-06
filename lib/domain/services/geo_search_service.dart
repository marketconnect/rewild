import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/presentation/geo_search_screen/geo_search_view_model.dart';

// Api client
abstract class GeoSearchServiceGeoSearchApiClient {
  Future<Either<RewildError, Map<int, int>>> getProductsNmIdIndexMap(
      {required String gNum, required String query, required List<int> nmIds});
}

class GeoSearchService implements GeoSearchViewModelGeoSearchService {
  final GeoSearchServiceGeoSearchApiClient geoSearchApiClient;
  // final GeoSearchServiceCardOfProductDataProvider cardsDataProvider;
  GeoSearchService({
    required this.geoSearchApiClient,
  });

  @override
  Future<Either<RewildError, Map<int, Map<String, int>>>>
      getProductsNmIdsGeoIndex(
          List<String> gNums, String query, List<int> nmIds) async {
    Map<int, Map<String, int>> nmIdGeoIndex = {};

    for (var gNum in gNums) {
      var nmIdIndexEither = await geoSearchApiClient.getProductsNmIdIndexMap(
          gNum: gNum, query: query, nmIds: nmIds);
      if (nmIdIndexEither.isRight()) {
        final nmIdsIndexes =
            nmIdIndexEither.fold((l) => throw UnimplementedError(), (r) => r);
        for (var nmId in nmIdsIndexes.keys) {
          if (!nmIdGeoIndex.containsKey(nmId)) {
            nmIdGeoIndex[nmId] = {};
          }
          nmIdGeoIndex[nmId]![gNum] = nmIdsIndexes[nmId]!;
        }
      }
      if (nmIdIndexEither.isLeft()) {
        return Left(
            nmIdIndexEither.fold((l) => l, (r) => throw UnimplementedError()));
      }
    }
    return Right(nmIdGeoIndex);
  }
}
