import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/search_adv_data.dart';

// Web Catalog Ads
abstract class GeoSearchViewModelWebCatalogAdsService {
  Future<Either<RewildError, List<SearchAdvData>>> getAdvData(
      String keyword, List<int> nmIds);
}

// Geo search
abstract class GeoSearchViewModelGeoSearchService {
  Future<Either<RewildError, Map<int, Map<String, int>>>>
      getProductsNmIdsGeoIndex(
          List<String> gNums, String query, List<int> nmIds);
}

// Card of product
abstract class GeoSearchViewModelCardOfProductService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
  Future<Either<RewildError, List<int>>> getAllNmIds();
}

class GeoSearchViewModel extends ResourceChangeNotifier {
  final GeoSearchViewModelGeoSearchService geoSearchService;
  final GeoSearchViewModelCardOfProductService cardOfProductService;
  final GeoSearchViewModelWebCatalogAdsService webCatalogAdsService;

  GeoSearchViewModel({
    required this.geoSearchService,
    required super.context,
    required super.internetConnectionChecker,
    required this.webCatalogAdsService,
    required this.cardOfProductService,
  });

  // Adjusted to new return type of getProducts
  Map<int, Map<String, int>> _productsByGeo = {};
  Map<int, String> _images = {};
  List<SearchAdvData> _searchAdvData = [];
  bool _isLoading = false;

  // Method now takes List<String> gNums
  Future<void> searchProducts(List<String> gNums, String query) async {
    _isLoading = true;
    notify();
    // NmIds
    final nmIdsEither = await cardOfProductService.getAllNmIds();
    if (nmIdsEither.isLeft()) {
      return;
    }
    final nmIds = nmIdsEither.fold((l) => throw UnimplementedError(), (r) => r);
    // Search results
    final productsEither =
        await geoSearchService.getProductsNmIdsGeoIndex(gNums, query, nmIds);
    if (productsEither.isRight()) {
      _productsByGeo =
          productsEither.fold((l) => throw UnimplementedError(), (r) => r);
    }

    // Web Catalog Ads
    final webCatalogAdsDataEither =
        await webCatalogAdsService.getAdvData(query, nmIds);
    if (webCatalogAdsDataEither.isRight()) {
      _searchAdvData = webCatalogAdsDataEither.fold(
          (l) => throw UnimplementedError(), (r) => r);
    }

    _isLoading = false;
    notify();
    await _loadImages();
  }

  Future<void> _loadImages() async {
    // get all unique nmIds from _productsByGeo and _searchAdvData
    final nmIds = [
      ..._productsByGeo.keys,
      ..._searchAdvData.map((e) => e.id),
    ];
    final uniqueNmIds = nmIds.toSet();
    // Iterate through all nmIds
    for (var nmId in uniqueNmIds) {
      final imageEither =
          await cardOfProductService.getImageForNmId(nmId: nmId);
      imageEither.match(
        (l) => {/* handle error */},
        (imageUrl) {
          _images[nmId] = imageUrl;
          notify();
        },
      );
    }
  }

  Map<int, Map<String, int>> get productsByGeo => _productsByGeo;
  List<SearchAdvData> get searchAdvData => _searchAdvData;
  String imageForProduct(int nmId) => _images[nmId] ?? '';
  bool get isLoading => _isLoading;
}
