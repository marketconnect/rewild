import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/presentation/all_cards_filter_screen/all_cards_filter_screen_view_model.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';
import 'package:rewild/presentation/single_group_scrren/single_groups_screen_view_model.dart';

abstract class SellerServiceSellerDataProvider {
  Future<Resource<SellerModel>> get(int id);
  Future<Resource<int>> insert(SellerModel seller);
}

abstract class SellerServiceSelerApiClient {
  Future<Resource<SellerModel>> fetchSeller(int supplierId);
}

class SellerService
    implements
        SingleCardScreenSellerService,
        SingleGroupScreenSellerService,
        AllCardsFilterSellerService {
  final SellerServiceSellerDataProvider sellerDataProvider;
  final SellerServiceSelerApiClient sellerApiClient;
  SellerService(
      {required this.sellerDataProvider, required this.sellerApiClient});
  // list for sellers to get rid of unnecessary requests to WB
  List<SellerModel> sellersCache = [];

  @override
  Future<Resource<SellerModel>> get(int supplierId) async {
    // if the seller is already in cache
    final storedSeller =
        sellersCache.where((element) => element.supplierId == supplierId);
    if (storedSeller.isNotEmpty) {
      return Resource.success(storedSeller.first);
    } else {
      // if the seller is not in cache
      // try to get the seller from local db
      final localStoredSellerResource =
          await sellerDataProvider.get(supplierId);
      if (localStoredSellerResource is Error) {
        return Resource.error(localStoredSellerResource.message!);
      }

      // the seller is in db
      if (localStoredSellerResource is Success) {
        final seller = localStoredSellerResource.data!;
        sellersCache.add(seller);
        return Resource.success(seller);
      } else {
        // the seller is not in db and is not in cache
        // try to fetch the seller from WB
        final sellerResource = await sellerApiClient.fetchSeller(supplierId);
        // print("local`s seller: ${localStoredSellerResource.data!.name}");
        if (sellerResource is Error) {
          return Resource.error(sellerResource.message!);
        }
        final sellerFromWB = sellerResource.data!;

        final sellerModel = SellerModel(
            name: sellerFromWB.name,
            supplierId: supplierId,
            legalAddress: sellerFromWB.legalAddress,
            fineName: sellerFromWB.fineName,
            ogrn: sellerFromWB.ogrn,
            trademark: sellerFromWB.trademark);
        final insertResource = await sellerDataProvider.insert(sellerModel);
        if (insertResource is Error) {
          return Resource.error(insertResource.message!);
        }

        sellersCache.add(sellerModel);
        return Resource.success(sellerModel);
      }
    }
  }
}
