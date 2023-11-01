import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/filter_model.dart';
import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/presentation/all_cards_filter_screen/all_cards_filter_screen_view_model.dart';

abstract class AllCardsFilterServiceCardsOfProductDataProvider {
  Future<Resource<List<CardOfProductModel>>> getAll([List<int>? nmIds]);
}

abstract class AllCardsFilterServiceSellerDataProvider {
  Future<Resource<SellerModel>> get(int id);
}

class AllCardsFilterService implements AllCardsFilterAllCardsFilterService {
  final AllCardsFilterServiceCardsOfProductDataProvider
      cardsOfProductsDataProvider;

  final AllCardsFilterServiceSellerDataProvider sellerDataProvider;
  AllCardsFilterService(
      {required this.cardsOfProductsDataProvider,
      required this.sellerDataProvider});

  @override
  Future<Resource<FilterModel>> getCompletlyFilledFilter() async {
    // get cards
    final getCardsResource = await cardsOfProductsDataProvider.getAll();
    if (getCardsResource is Error) {
      return Resource.error(getCardsResource.message!);
    }

    final cards = getCardsResource.data!;

    Map<int, String> brands = {};
    Map<int, String> promos = {};
    Map<int, String> subjects = {};
    Map<int, String> suppliers = {};

    int promoId = 0;
    int brandId = 0;
    for (final card in cards) {
      // get brands
      if (card.brand != null) {
        // if brand not exists add it
        if (brands.values.where((e) => e == card.brand).toList().isEmpty) {
          brands[brandId] = card.brand!;

          brandId++;
        }
      }
      // get promo
      if (card.promoTextCard != null) {
        // if promo not exists add it
        if (promos.values
            .where((e) => e == card.promoTextCard)
            .toList()
            .isEmpty) {
          promos[promoId] = card.promoTextCard!;
          promoId++;
        }
      }

      // get subjects with empty values
      if (card.subjectId != null) {
        subjects[card.subjectId!] = "";
      }

      // get suppliers with empty values
      if (card.supplierId != null) {
        if (suppliers.keys
            .where((k) => k == card.supplierId)
            .toList()
            .isEmpty) {
          final getSupplierResource =
              await sellerDataProvider.get(card.supplierId!);
          if (getSupplierResource is Error) {
            return Resource.error(getSupplierResource.message!);
          }
          suppliers[card.supplierId!] = "";
        }
      }
    }

    return Resource.success(
      FilterModel(
        brands: brands,
        promos: promos,
        subjects: subjects,
        suppliers: suppliers,
      ),
    );
  }

  @override
  Future<Resource<void>> setFilter(FilterModel filter) {
    // TODO: implement setFilter
    throw UnimplementedError();
  }
}
