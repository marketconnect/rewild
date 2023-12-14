import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/filter_model.dart';
import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/presentation/all_cards_filter_screen/all_cards_filter_screen_view_model.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';

abstract class AllCardsFilterFilterDataProvider {
  Future<Either<RewildError, void>> insert(FilterModel filter);
  Future<Either<RewildError, void>> delete();
  Future<Either<RewildError, FilterModel>> get();
}

abstract class AllCardsFilterServiceCardsOfProductDataProvider {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]);
}

abstract class AllCardsFilterServiceSellerDataProvider {
  Future<Either<RewildError, SellerModel>> get(int id);
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
  Future<Either<RewildError, FilterModel>> getCompletlyFilledFilter() async {
    // get cards
    final getCardsResource = await cardsOfProductsDataProvider.getAll();
    if (getCardsResource is Error) {
      return left(RewildError(getCardsResource.message!,
          source: runtimeType.toString(),
          name: "getCompletlyFilledFilter",
          args: []);
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
            return left(RewildError(getSupplierResource.message!,
                source: runtimeType.toString(),
                name: "getCompletlyFilledFilter",
                args: []);
          }
          suppliers[card.supplierId!] = "";
        }
      }
    }

    return right(
      FilterModel(
          brands: brands,
          promos: promos,
          subjects: subjects,
          suppliers: suppliers,
          withSales: null,
          withStocks: null),
    );
  }

  @override
  Future<Either<RewildError, FilterModel>> getCurrentFilter() async {
    final filterResource = await filterDataProvider.get();
    if (filterResource is Empty) {
      return right(FilterModel(
        brands: {},
        promos: {},
        subjects: {},
        suppliers: {},
        withSales: null,
        withStocks: null,
      ));
    }
    return filterResource;
  }

  @override
  Future<Either<RewildError, void>> deleteFilter() async {
    final deleteFilterResource = await filterDataProvider.delete();
    if (deleteFilterResource is Error) {
      return left(RewildError(deleteFilterResource.message!,
          source: runtimeType.toString(), name: "deleteFilter", args: []);
    }

    return right(null);
  }

  @override
  Future<Either<RewildError, void>> setFilter(FilterModel filter) async {
    final values = await Future.wait(
        [filterDataProvider.delete(), filterDataProvider.insert(filter)]);

    // Advert Info
    final deleteFilterResource = values[0];
    final insertFilterResource = values[1];
    // delete previous filter
    // final deleteFilterResource = await filterDataProvider.delete();
    if (deleteFilterResource is Error) {
      return left(RewildError(deleteFilterResource.message!,
          source: runtimeType.toString(), name: "setFilter", args: [filter]);
    }
    // insert new
    // final insertFilterResource = await filterDataProvider.insert(filter);
    if (insertFilterResource is Error) {
      return left(RewildError(insertFilterResource.message!,
          source: runtimeType.toString(), name: "setFilter", args: [filter]);
    }
    return right(null);
  }
}
