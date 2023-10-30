import 'dart:async';

import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';

import 'package:rewild/domain/entities/card_of_product_model.dart';

import 'package:rewild/domain/entities/group_model.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';

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

abstract class AllCardsScreenGroupsService {
  Future<Resource<List<GroupModel>>> getAll();
}

// abstract class AllCardsScreenStocksService {
//   Future<Resource<List<StocksModel>>> getAll();
// }

// abstract class AllCardsScreenInitStockService {
//   Future<Resource<List<InitialStockModel>>> getAll(
//       [DateTime? dateFrom, DateTime? dateTo]);
// }

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
      // required this.initStockService,
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

    await _update(false);
    _loading = false;

    notifyListeners();
    await p();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _loading = true;
  bool get loading => _loading;
  bool _mounted = true;

  Future<void> setMounted(bool mounted) async {
    _mounted = mounted;
    if (!_mounted) {
      return;
    }
    await _update();
  }

  @override
  void dispose() {
    super.dispose();
    _mounted = false;
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
    if (!_mounted) {
      return;
    }

    _errorMessage = null;

    // Update
    await _fetch(() => updateService.update());

    // get cards
    final fetchedCardsOfProducts =
        await _fetch(() => cardsOfProductsService.getAll());
    if (fetchedCardsOfProducts == null) {
      return;
    }

    // get stocks
    // final stocks = await _fetch(() => stocksService.getAll());
    // if (stocks == null) {
    //   return;
    // }

    // final initialStocks = await _fetch(() => initStockService.getAll());
    // if (initialStocks == null) {
    //   return;
    // }
    List<CardOfProductModel> oldCards = List.from(_productCards);

    if (fetchedCardsOfProducts.isNotEmpty) {
      _productCards.clear();
    }
    final dateFrom = yesterdayEndOfTheDay();
    final dateTo = DateTime.now();

    for (CardOfProductModel card in fetchedCardsOfProducts) {
      // final cardStocks =
      //     stocks.where((stock) => stock.nmId == card.nmId).toList();

      // final sizes = [SizeModel(stocks: cardStocks)];
      // final cardWithStocks = card.copyWith(sizes: sizes);

      // final initStocks =
      //     initialStocks.where((stock) => stock.nmId == card.nmId).toList();

      // final newCard = cardWithStocks.copyWith(initialStocks: initStocks);
      // final dateFrom = yesterdayEndOfTheDay();
      // final dateTo = DateTime.now();
      // final supplies = await _fetch(() => supplyService.getForOne(
      //       nmId: newCard.nmId,
      //       dateFrom: dateFrom,
      //       dateTo: dateTo,
      //     ));
      // if (supplies != null) {
      //   newCard.setSupplies(supplies);
      // }

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

    _productCards.sort((a, b) => b.ordersSum.compareTo(a.ordersSum));

    final fetchedGroups = await _fetch(() => groupsProvider.getAll());
    if (fetchedGroups == null) {
      return;
    }

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

    notifyListeners();
  }

  Future<void> p() async {
    const timeDuration = TimeConstants.updatePeriod;

    Timer.periodic(timeDuration, (Timer t) async {
      if (!_mounted) {
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
      final deletedCard =
          _productCards.where((element) => element.nmId == nmId).first;
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

  Future<T?> _fetch<T>(Future<Resource<T>> Function() callBack) async {
    final resource = await callBack();
    if (resource is Error) {
      _errorMessage = resource.message;
      notifyListeners();
      return null;
    }
    return resource.data;
  }
}
