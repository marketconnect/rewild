import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/search_adv_data.dart';
import 'package:rewild/presentation/geo_search_screen/geo_search_view_model.dart';

abstract class WebCatalogAdsServiceWebCatalogAdsApiClient {
  Future<Either<RewildError, List<SearchAdvData>>> getAdvData(
      String keyword, List<int> nmIds);
}

class WebCatalogAdsService implements GeoSearchViewModelWebCatalogAdsService {
  final WebCatalogAdsServiceWebCatalogAdsApiClient webCatalogAdsApiClient;

  WebCatalogAdsService({required this.webCatalogAdsApiClient});

  @override
  Future<Either<RewildError, List<SearchAdvData>>> getAdvData(
      String keyword, List<int> nmIds) async {
    // Call the API client to fetch advertisement data
    return await webCatalogAdsApiClient.getAdvData(keyword, nmIds);
  }
}
