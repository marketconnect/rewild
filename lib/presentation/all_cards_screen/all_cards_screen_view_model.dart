import 'dart:async';

import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';

import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/filter_model.dart';

import 'package:rewild/domain/entities/group_model.dart';

import 'package:rewild/domain/entities/supply_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:flutter/material.dart';
import 'package:rewild/core/utils/resource.dart';

abstract class AllCardsScreenTokenProvider {
  Future<Resource<String>> getToken();
}

abstract class AllCardsScreenCardOfProductService {
  Future<Resource<List<CardOfProductModel>>> getAll();
  Future<Resource<int>> delete(String token, List<int> nmIds);
}

abstract class AllCardsScreenFilterService {
  Future<Resource<FilterModel>> getCurrentFilter();
  Future<Resource<void>> deleteFilter();
}

abstract class AllCardsScreenGroupsService {
  Future<Resource<List<GroupModel>>> getAll();
}

abstract class AllCardsScreenSupplyService {
  Future<Resource<List<SupplyModel>>> getForOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo});
}

abstract class AllCardsScreenUpdateService {
  Future<Resource<void>> update();
}

class AllCardsScreenViewModel extends ChangeNotifier {
  final AllCardsScreenTokenProvider tokenProvider;
  final AllCardsScreenCardOfProductService cardsOfProductsService;
  final AllCardsScreenUpdateService updateService;
  final AllCardsScreenGroupsService groupsProvider;
  final AllCardsScreenFilterService filterService;
  // final AllCardsScreenStocksService stocksService;
  // final AllCardsScreenInitStockService initStockService;
  final AllCardsScreenSupplyService supplyService;
  final BuildContext context;

  AllCardsScreenViewModel(
      {required this.context,
      required this.tokenProvider,
      // required this.stocksService,
      required this.updateService,
      required this.groupsProvider,
      required this.filterService,
      required this.supplyService,
      required this.cardsOfProductsService}) {
    asyncInit();
  }

  Future<void> asyncInit() async {
    _groups.insert(
        0,
        GroupModel(
            name: "Все",
            bgColor: const Color(0xFF6750A4).value,
            cardsNmIds: [],
            fontColor: const Color(0xFFFFFFFF).value));

    _filter = await _fetch(() => filterService.getCurrentFilter());
    if (_filter == null) {
      return;
    }

    await _update(false);
    _loading = false;

    if (context.mounted) notifyListeners();
    await p();
  }

  // filter
  FilterModel? _filter;
  FilterModel? get filter => _filter;

  bool filterIsEmpty() {
    if (_filter == null) {
      return true;
    }

    if (_filter!.subjects != null && _filter!.subjects!.isNotEmpty ||
        _filter!.brands != null && _filter!.brands!.isNotEmpty ||
        _filter!.suppliers != null && _filter!.suppliers!.isNotEmpty ||
        _filter!.promos != null && _filter!.promos!.isNotEmpty) {
      return false;
    }
    return true;
  }

  Future<void> resetFilter() async {
    await _fetch(() => filterService.deleteFilter());
    await _update();
  }

  bool _loading = true;
  bool get loading => _loading;

  Future<void> setMounted(bool mounted) async {
    if (context.mounted) await _update();
  }

  List<CardOfProductModel> _productCards = [];
  void setProductCards(List<CardOfProductModel> productCards) {
    _productCards = productCards;
  }

  List<CardOfProductModel> get productCards => _productCards;

  bool _selectionInProcess = false;
  bool get selectionInProcess => _selectionInProcess;
  final List<int> _selectedNmIds = [];
  List<int> get selectedNmIds => _selectedNmIds;

  int get selectedLength => _selectedNmIds.length;

  List<GroupModel> _groups = [];
  void setGroups(List<GroupModel> groups) {
    _groups = groups;
  }

  List<GroupModel> get groups => _groups;

  GroupModel? _selectedGroup;
  GroupModel? get selectedGroup => _selectedGroup;

  Future<String> _getToken() async {
    final token = await _fetch(() => tokenProvider.getToken());
    if (token == null) {
      return "";
    }
    return token;
  }

  Future<void> _update([bool notify = true]) async {
    if (!context.mounted) {
      return;
    }

    // Update
    await _fetch(() => updateService.update());

    // get cards
    final fetchedCardsOfProducts =
        await _fetch(() => cardsOfProductsService.getAll());
    if (fetchedCardsOfProducts == null) {
      return;
    }

    List<CardOfProductModel> oldCards = List.from(_productCards);

    // reassign productCards
    if (fetchedCardsOfProducts.isNotEmpty) {
      _productCards.clear();
    }

    final dateFrom = yesterdayEndOfTheDay();
    final dateTo = DateTime.now();

    // calculate stocks, initial stocks, supplies, was ordered field
    for (CardOfProductModel card in fetchedCardsOfProducts) {
      card.calculate(dateFrom, dateTo);
      final oldCard = oldCards.where((old) {
        return old.nmId == card.nmId;
      });

      if (oldCard.isNotEmpty && card.ordersSum > oldCard.first.ordersSum) {
        card.setWasOrdered();
      } else {
        card.setWasNotOrdered();
      }

      _productCards.add(card);
    }

    // sort by orders sum
    _productCards.sort((a, b) => b.ordersSum.compareTo(a.ordersSum));

    final fetchedGroups = await _fetch(() => groupsProvider.getAll());
    if (fetchedGroups == null) {
      return;
    }

    // append groups
    for (final g in fetchedGroups) {
      if (_groups.where((element) => element.name == g.name).isEmpty) {
        _groups.add(g);
      }
      final cardsWithGroup =
          _productCards.where((card) => g.cardsNmIds.contains(card.nmId));
      for (final card in cardsWithGroup) {
        card.setGroup(g);
      }
    }

    if (!notify) {
      return;
    }

    if (context.mounted) notifyListeners();
  }

  Future<void> p() async {
    const timeDuration = TimeConstants.updatePeriod;

    Timer.periodic(timeDuration, (Timer t) async {
      if (!context.mounted) {
        return;
      }

      await _update();

      debugPrint('hi! ${DateTime.now()}');
    });
  }

  void onCardTap(int nmId) {
    if (_selectedNmIds.isEmpty) {
      Navigator.of(context).pushNamed(
        MainNavigationRouteNames.singleCardScreen,
        arguments: nmId,
      );
      return;
    }

    _select(nmId);
    notifyListeners();
  }

  void onCardLongPress(int index) {
    _select(index);
    notifyListeners();
  }

  Future<void> deleteCards() async {
    List<int> idsForDelete = [];
    for (final nmId in _selectedNmIds) {
      final deletedCardList =
          _productCards.where((element) => element.nmId == nmId);
      if (deletedCardList.isEmpty) {
        continue;
      }
      final deletedCard = deletedCardList.first;
      _productCards.remove(deletedCard);
      idsForDelete.add(deletedCard.nmId);
    }

    onClearSelected();

    final token = await _getToken();

    await _fetch(() => cardsOfProductsService.delete(token, idsForDelete));

    _update();
  }

  void onClearSelected() {
    _selectedNmIds.clear();
    _selectionInProcess = false;
    notifyListeners();
  }

  void combine() {
    Navigator.of(context).pushReplacementNamed(
      MainNavigationRouteNames.addGroupsScreen,
      arguments: _selectedNmIds,
    );
  }

  void _select(int nmId) {
    bool found = _selectedNmIds.contains(nmId);
    if (found) {
      _selectedNmIds.remove(nmId);
    } else {
      _selectedNmIds.add(nmId);
    }
    if (_selectedNmIds.isNotEmpty) {
      _selectionInProcess = true;
    } else {
      _selectionInProcess = false;
    }
  }

  void selectGroup(int index) {
    if (index == 0) {
      _selectedGroup = null;
    } else {
      _selectedGroup = _groups[index];
    }
    notifyListeners();
  }

  bool filterCard(CardOfProductModel card) {
    print("FILTER");
    if (_filter == null) {
      return true;
    }

    // check subject
    if (_filter!.subjects != null && _filter!.subjects!.isNotEmpty) {
      final found = _filter!.subjects!.keys.contains(card.subjectId);
      print('${_filter!.subjects!.keys} -- ${card.subjectId}');
      if (!found) {
        return false;
      }
    }
    // check supplier
    if (_filter!.suppliers != null && _filter!.suppliers!.isNotEmpty) {
      final found = _filter!.suppliers!.keys.contains(card.supplierId);
      if (!found) {
        return false;
      }
    }
    // check brand
    if (_filter!.brands != null && _filter!.brands!.isNotEmpty) {
      final found = _filter!.brands!.values.contains(card.brand);
      if (!found) {
        return false;
      }
    }
    // check promo
    if (_filter!.promos != null && _filter!.promos!.isNotEmpty) {
      final found = _filter!.promos!.values.contains(card.promoTextCard);
      if (!found) {
        return false;
      }
    }
    return true;
  }

  Future<T?> _fetch<T>(Future<Resource<T>> Function() callBack) async {
    final resource = await callBack();
    if (resource is Error && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(resource.message!),
      ));
      notifyListeners();
      return null;
    }
    return resource.data;
  }
}
