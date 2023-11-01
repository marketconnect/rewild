import 'package:flutter/material.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/commission_model.dart';
import 'package:rewild/domain/entities/filter_model.dart';
import 'package:rewild/domain/entities/seller_model.dart';

// filter
abstract class AllCardsFilterAllCardsFilterService {
  Future<Resource<FilterModel>> getCompletlyFilledFilter();
  Future<Resource<void>> setFilter(FilterModel filter);
}

// Commission
abstract class AllCardsFilterCommissionService {
  Future<Resource<CommissionModel>> get(int id);
}

// Supplier
abstract class AllCardsFilterSellerService {
  Future<Resource<SellerModel>> get(int supplierId);
}

class AllCardsFilterScreenViewModel extends ChangeNotifier {
  final AllCardsFilterAllCardsFilterService allCardsFilterService;
  final AllCardsFilterCommissionService commissionService;
  final AllCardsFilterSellerService sellerService;
  final BuildContext context;
  AllCardsFilterScreenViewModel(
      {required this.context,
      required this.allCardsFilterService,
      required this.sellerService,
      required this.commissionService}) {
    _asyncInit();
  }

  // Input filter
  FilterModel? _completlyFilledfilter;
  FilterModel? get completlyFilledfilter => _completlyFilledfilter;

  // Output filter
  FilterModel _outputfilter = FilterModel(
    brands: {},
    subjects: {},
    promos: {},
    suppliers: {},
  );

  int counter = 0;

  FilterModel? get outputfilter => _outputfilter;
  void setFilter(FilterModel filter) {
    _outputfilter = filter;
    final brandsLength = _outputfilter.brands ?? {};
    final promoLength = _outputfilter.promos ?? {};
    final suppliersLength = _outputfilter.suppliers ?? {};
    final subjectsLength = _outputfilter.subjects ?? {};
    counter = brandsLength.length +
        promoLength.length +
        subjectsLength.length +
        suppliersLength.length;
    notifyListeners();
  }

  void _asyncInit() async {
    final filter =
        await _fetch(() => allCardsFilterService.getCompletlyFilledFilter());
    if (filter == null) {
      return;
    }

    // subject
    if (filter.subjects != null) {
      for (final subjId in filter.subjects!.keys) {
        final subj = await _fetch(
          () => commissionService.get(subjId),
        );
        if (subj == null) {
          return;
        }
        filter.subjects![subjId] = subj.subject;
      }
    }

    if (filter.suppliers != null) {
      for (final suppId in filter.suppliers!.keys) {
        final seller = await _fetch(
          () => sellerService.get(suppId),
        );
        if (seller == null) {
          return;
        }
        filter.suppliers![suppId] = seller.name;
      }
    }

    _completlyFilledfilter = filter;

    notifyListeners();
  }

  void clear() {
    final newFilter = FilterModel(
      brands: {},
      subjects: {},
      promos: {},
      suppliers: {},
    );
    setFilter(newFilter);
  }

  // Subjects
  void setAllSubjects() {
    if (completlyFilledfilter == null ||
        completlyFilledfilter!.subjects == null) {
      return;
    }
    Map<int, String> allSubjects = Map.from(completlyFilledfilter!.subjects!);
    FilterModel newFilter = outputfilter!.copyWith(subjects: allSubjects);
    setFilter(newFilter);
  }

  void clearSubjects() {
    FilterModel newFilter = outputfilter!.copyWith(subjects: {});
    setFilter(newFilter);
  }

  void setSubject(int subject) {
    final subj = completlyFilledfilter!.subjects![subject];
    Map<int, String> prevSubjects = outputfilter!.subjects ?? {};
    FilterModel newFilter =
        outputfilter!.copyWith(subjects: prevSubjects..[subject] = subj!);
    setFilter(newFilter);
  }

  void unSetSubject(int subject) {
    Map<int, String>? prevSubjects = outputfilter!.subjects;
    if (prevSubjects == null) {
      return;
    }
    prevSubjects.remove(subject);
    FilterModel newFilter = outputfilter!.copyWith(subjects: prevSubjects);
    setFilter(newFilter);
  }

  // Brand
  void setAllBrands() {
    if (completlyFilledfilter == null ||
        completlyFilledfilter!.brands == null) {
      return;
    }
    Map<int, String> allBrands = Map.from(completlyFilledfilter!.brands!);
    FilterModel newFilter = outputfilter!.copyWith(brands: allBrands);
    setFilter(newFilter);
  }

  void clearBrands() {
    FilterModel newFilter = outputfilter!.copyWith(brands: {});
    setFilter(newFilter);
  }

  void setBrand(int brand) {
    final br = completlyFilledfilter!.brands![brand];
    Map<int, String> prevBrands = outputfilter!.brands ?? {};
    FilterModel newFilter =
        outputfilter!.copyWith(brands: prevBrands..[brand] = br!);
    setFilter(newFilter);
  }

  void unSetBrand(int brand) {
    Map<int, String>? prevBrands = outputfilter!.brands;
    if (prevBrands == null) {
      return;
    }
    prevBrands.remove(brand);
    FilterModel newFilter = outputfilter!.copyWith(brands: prevBrands);
    setFilter(newFilter);
  }

  // Supplier
  void setAllSuppliers() {
    if (completlyFilledfilter == null ||
        completlyFilledfilter!.suppliers == null) {
      return;
    }
    Map<int, String> allSuppliers = Map.from(completlyFilledfilter!.suppliers!);
    FilterModel newFilter = outputfilter!.copyWith(suppliers: allSuppliers);
    setFilter(newFilter);
  }

  void setSupplier(int supplier) {
    final supp = completlyFilledfilter!.suppliers![supplier];
    Map<int, String> prevSuppliers = outputfilter!.suppliers ?? {};
    FilterModel newFilter =
        outputfilter!.copyWith(suppliers: prevSuppliers..[supplier] = supp!);
    setFilter(newFilter);
  }

  void clearSuppliers() {
    FilterModel newFilter = outputfilter!.copyWith(suppliers: {});
    setFilter(newFilter);
  }

  void unSetSupplier(int supplier) {
    Map<int, String>? prevSuppliers = outputfilter!.suppliers;
    if (prevSuppliers == null) {
      return;
    }
    prevSuppliers.remove(supplier);
    FilterModel newFilter = outputfilter!.copyWith(suppliers: prevSuppliers);
    setFilter(newFilter);
  }

  // Promo
  void setAllPromos() {
    if (completlyFilledfilter == null ||
        completlyFilledfilter!.promos == null) {
      return;
    }
    Map<int, String> allPromos = Map.from(completlyFilledfilter!.promos!);
    FilterModel newFilter = outputfilter!.copyWith(promos: allPromos);
    setFilter(newFilter);
  }

  void setPromo(int promo) {
    final prom = completlyFilledfilter!.promos![promo];
    Map<int, String> prevPromos = outputfilter!.promos ?? {};
    FilterModel newFilter =
        outputfilter!.copyWith(promos: prevPromos..[promo] = prom!);
    setFilter(newFilter);
  }

  void clearPromos() {
    FilterModel newFilter = outputfilter!.copyWith(promos: {});
    setFilter(newFilter);
  }

  void unSetPromo(int promo) {
    Map<int, String>? prevPromos = outputfilter!.promos;
    if (prevPromos == null) {
      return;
    }
    prevPromos.remove(promo);
    FilterModel newFilter = outputfilter!.copyWith(promos: prevPromos);
    setFilter(newFilter);
  }

  // Define a method for fetch data and handling errors
  Future<T?> _fetch<T>(Future<Resource<T>> Function() callBack) async {
    final resource = await callBack();
    if (resource is Error && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(resource.message!),
      ));
      return null;
    }
    return resource.data;
  }
}
