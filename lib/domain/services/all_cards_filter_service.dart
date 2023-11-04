import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/filter_model.dart';
import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/presentation/all_cards_filter_screen/all_cards_filter_screen_view_model.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';

abstract class AllCardsFilterFilterDataProvider {
  Future<Resource<void>> insert(FilterModel filter);
  Future<Resource<void>> delete();
  Future<Resource<FilterModel>> get();
}

abstract class AllCardsFilterServiceCardsOfProductDataProvider {
  Future<Resource<List<CardOfProductModel>>> getAll([List<int>? nmIds]);
}

abstract class AllCardsFilterServiceSellerDataProvider {
  Future<Resource<SellerModel>> get(int id);
}

class AllCardsFilterService
    implements
        AllCardsFilterAllCardsFilterService,
        AllCardsScreenFilterService {
  final AllCardsFilterServiceCardsOfProductDataProvider
      cardsOfProductsDataProvider;

  final AllCardsFilterServiceSellerDataProvider sellerDataProvider;

  final AllCardsFilterFilterDataProvider filterDataProvider;
  AllCardsFilterService(
      {required this.cardsOfProductsDataProvider,
      required this.filterDataProvider,
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
      if (card.brand != null && card.brand!.isNotEmpty) {
        // if brand not exists add it
        if (brands.values.where((e) => e == card.brand).toList().isEmpty) {
          brands[brandId] = card.brand!;

          brandId++;
        }
      }
      // get promo
      if (card.promoTextCard != null && card.promoTextCard!.isNotEmpty) {
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
  Future<Resource<FilterModel>> getCurrentFilter() async {
    final filterResource = await filterDataProvider.get();
    if (filterResource is Empty) {
      return Resource.success(FilterModel(
        brands: {},
        promos: {},
        subjects: {},
        suppliers: {},
      ));
    }
    return filterResource;
  }

  @override
  Future<Resource<void>> deleteFilter() async {
    final deleteFilterResource = await filterDataProvider.delete();
    if (deleteFilterResource is Error) {
      return Resource.error(deleteFilterResource.message!);
    }

    return Resource.empty();
  }

  @override
  Future<Resource<void>> setFilter(FilterModel filter) async {
    // delete previous filter
    final deleteFilterResource = await filterDataProvider.delete();
    if (deleteFilterResource is Error) {
      return Resource.error(deleteFilterResource.message!);
    }
    // insert new
    final insertFilterResource = await filterDataProvider.insert(filter);
    if (insertFilterResource is Error) {
      return Resource.error(insertFilterResource.message!);
    }
    return Resource.empty();
  }
}
