import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/presentation/all_cards_filter_screen/all_cards_filter_screen_view_model.dart';

import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';
import 'package:rewild/presentation/single_group_screen/single_groups_screen_view_model.dart';

abstract class SellerServiceSellerDataProvider {
  Future<Either<RewildError, SellerModel?>> get({required int supplierId}) ;
  Future<Either<RewildError, int>> insert({required SellerModel seller});
}

abstract class SellerServiceSelerApiClient {
  Future<Either<RewildError, SellerModel>> get({required int supplierId});
}

class SellerService
    implements
        SingleCardScreenSellerService,
        SingleGroupScreenSellerService,
        // AllSellersSellersService,
        AllCardsFilterSellerService {
  final SellerServiceSellerDataProvider sellerDataProvider;
  final SellerServiceSelerApiClient sellerApiClient;
  SellerService(
      {required this.sellerDataProvider, required this.sellerApiClient});
  // list for sellers to get rid of unnecessary requests to WB
  List<SellerModel> sellersCache = [];

  @override
  Future<Either<RewildError, SellerModel>> get(int supplierId) async {
    // if the seller is already in cache
    final storedSeller =
        sellersCache.where((element) => element.supplierId == supplierId);
    if (storedSeller.isNotEmpty) {
      return right(storedSeller.first);
    } else {
      // if the seller is not in cache
      // try to get the seller from local db
      final localStoredSellerResource =
          await sellerDataProvider.get(supplierId);
      if (localStoredSellerResource is Error) {
        return left(RewildError(localStoredSellerResource.message!,
            source: runtimeType.toString(), name: 'get', args: [supplierId]);
      }

      // the seller is in db
      if (localStoredSellerResource is Success) {
        final seller = localStoredSellerResource.data!;
        sellersCache.add(seller);
        return right(seller);
      } else {
        // the seller is not in db and is not in cache
        // try to fetch the seller from WB
        final sellerResource = await sellerApiClient.get(supplierId);
        // print("local`s seller: ${localStoredSellerResource.data!.name}");
        if (sellerResource is Error) {
          return left(RewildError(sellerResource.message!,
              source: runtimeType.toString(), name: 'get', args: [supplierId]);
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
          return left(RewildError(insertResource.message!,
              source: runtimeType.toString(), name: 'get', args: [supplierId]);
        }

        sellersCache.add(sellerModel);
        return right(sellerModel);
      }
    }
  }
}
