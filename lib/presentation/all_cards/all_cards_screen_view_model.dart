// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'dart:async';

import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';

import 'package:rewild/domain/entities/group_model.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/entities/size_model.dart';
import 'package:rewild/domain/entities/stocks_model.dart';
import 'package:rewild/domain/entities/supply_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:flutter/material.dart';
import 'package:rewild/core/utils/resource.dart';

// Token
abstract class AllCardsScreenTokenProvider {
  Future<Resource<String>> getToken();
}

// Cards
abstract class AllCardsScreenCardOfProductService {
  Future<Resource<List<CardOfProductModel>>> getAll(
      DateTime dateFrom, DateTime dateTo);
  Future<Resource<int>> delete(String token, List<int> nmIds);
}

// Groups
abstract class AllCardsScreenGroupsService {
  Future<Resource<List<GroupModel>>> getAll();
}

// Stocks
abstract class AllCardsScreenStocksService {
  Future<Resource<List<StocksModel>>> getAll();
}

// init stock
abstract class AllCardsScreenInitStockService {
  Future<Resource<List<InitialStockModel>>> getAll(
      [DateTime? dateFrom, DateTime? dateTo]);
}

// supply
abstract class AllCardsScreenSupplyService {
  Future<Resource<List<SupplyModel>>> getForOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo});
}

// Update
abstract class AllCardsScreenUpdateService {
  Future<Resource<void>> update();
}

class AllCardsScreenViewModel extends ChangeNotifier {
  final AllCardsScreenTokenProvider tokenProvider;
  final AllCardsScreenCardOfProductService cardsOfProductsService;
  final AllCardsScreenUpdateService updateService;
  final AllCardsScreenGroupsService groupsProvider;
  final AllCardsScreenStocksService stocksService;
  final AllCardsScreenInitStockService initStockService;
  final AllCardsScreenSupplyService supplyService;
  final BuildContext context;

// Constructor
  AllCardsScreenViewModel(
      {required this.context,
      required this.tokenProvider,
      required this.stocksService,
      required this.updateService,
      required this.groupsProvider,
      required this.initStockService,
      required this.supplyService,
      required this.cardsOfProductsService}) {
    asyncInit();
  }

  // async init ================================================================
  Future<void> asyncInit() async {
    await _update(false);
    _loading = false;

    notifyListeners();
    await p();
  }

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

  // Cards source
  List<CardOfProductModel> _productCards = [];

  List<CardOfProductModel> get productCards => _productCards;

  // Cards selecting
  bool _selectionInProcess = false;
  bool get selectionInProcess => _selectionInProcess;
  final List<int> _selectedNmIds = [];
  List<int> get selectedNmIds => _selectedNmIds;

  int get selectedLength => _selectedNmIds.length;

  // List of groups
  List<GroupModel> _groups = [];
  List<GroupModel> get groups => _groups;

  GroupModel? _selectedGroup;
  GroupModel? get selectedGroup => _selectedGroup;

  // Token =====================================================================
  Future<String> _getToken() async {
    final token = await _fetch(() => tokenProvider.getToken());
    if (token == null) {
      return "";
    }
    return token;
  }

  // update ====================================================================
  Future<void> _update([bool notify = true]) async {
    if (!_mounted) {
      return;
    }
    // update all cards in the local storage
    // final updateResource = await updateService.update();
    // if (updateResource is Error) {
    //   // ignore: use_build_context_synchronously
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(updateResource.message!),
    //   ));
    // }

    await _fetch(() => updateService.update());

    final dateFrom = yesterdayEndOfTheDay();
    final dateTo = DateTime.now();

    // get all cards from the local storage
    // final cardsOfProductsServiceResource =
    //     await cardsOfProductsService.getAll(dateFrom, dateTo);

    // if (cardsOfProductsServiceResource is Error) {
    //   // ignore: use_build_context_synchronously
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(cardsOfProductsServiceResource.message!),
    //   ));
    //   return;
    // }
    // final fetchedCardsOfProducts = cardsOfProductsServiceResource.data!;
    final fetchedCardsOfProducts =
        await _fetch(() => cardsOfProductsService.getAll(dateFrom, dateTo));
    if (fetchedCardsOfProducts == null) {
      return;
    }
    // Get stocks and initial stocks
    // stocks
    // final stocksResource = await stocksService.getAll();
    // if (stocksResource is Error) {
    //   // ignore: use_build_context_synchronously
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(stocksResource.message!),
    //   ));
    //   return;
    // }
    // final stocks = stocksResource.data!;
    final stocks = await _fetch(() => stocksService.getAll());
    if (stocks == null) {
      return;
    }
    // initial stocks
    // final initialStockResource = await initStockService.getAll();
    // if (initialStockResource is Error) {
    //   // ignore: use_build_context_synchronously
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(initialStockResource.message!),
    //   ));
    //   return;
    // }
    // final initialStocks = initialStockResource.data!;
    final initialStocks = await _fetch(() => initStockService.getAll());
    if (initialStocks == null) {
      return;
    }
    List<CardOfProductModel> oldCards = List.from(_productCards);

    if (fetchedCardsOfProducts.isNotEmpty) {
      _productCards.clear();
    }

    // supply
    // final supplyResource = await supplyService.getAll();
    // if (supplyResource is Error) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(supplyResource.message!),
    //   ));
    //   return;
    // }
    // final supplies = supplyResource.data!;

    // add and calculate supplies, stocks, initialStocks, sales for each card
    for (CardOfProductModel card in fetchedCardsOfProducts) {
      final cardStocks =
          stocks.where((stock) => stock.nmId == card.nmId).toList();

      final sizes = [SizeModel(stocks: cardStocks)];
      final cardWithStocks = card.copyWith(sizes: sizes);

      final initStocks =
          initialStocks.where((stock) => stock.nmId == card.nmId).toList();

      final newCard = cardWithStocks.copyWith(initialStocks: initStocks);

      // supplies
      // was supplied
      final supplyResource = await supplyService.getForOne(
        nmId: newCard.nmId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      if (supplyResource is Error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(supplyResource.message!),
        ));
        return;
      }
      if (supplyResource is Success) {
        final supplies = supplyResource.data!;
        newCard.setSupplies(supplies);
      }
      // newCard.calculateInitialStocksSum(dateFrom, dateTo);
      // newCard.calculateStocksSum();
      newCard.calculate(dateFrom, dateTo);
      final oldCard = oldCards.where((old) {
        return old.nmId == newCard.nmId;
      });

      // was ordered
      if (oldCard.isNotEmpty && newCard.ordersSum > oldCard.first.ordersSum) {
        newCard.setWasOrdered();
      } else {
        newCard.setWasNotOrdered();
      }

      // add card
      _productCards.add(newCard);
    }

    // sort cards
    _productCards.sort((a, b) => b.ordersSum.compareTo(a.ordersSum));
    // _productCards = fetchedCardsOfProducts;

    // get groups
    // final groupsResource = await groupsProvider.getAll();
    // if (groupsResource is Error) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(groupsResource.message!),
    //   ));
    //   return;
    // }
    // _groups = groupsResource.data!;
    final groupsResource = await _fetch(() => groupsProvider.getAll());
    if (groupsResource == null) {
      return;
    }
    _groups = groupsResource;

    _groups = _groups.where((group) => group.cards.isNotEmpty).toList();

    if (!notify) {
      return;
    }

    notifyListeners();
  }

  //
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

  // Listeners ==========================================================
  void onCardTap(int nmId) {
    // Not in selection mode
    if (_selectedNmIds.isEmpty) {
      Navigator.of(context).pushNamed(
        MainNavigationRouteNames.singleCardScreen,
        arguments: nmId,
      );
      return;
    }

    // In selection mode
    _select(nmId);
    notifyListeners();
  }

  void onCardLongPress(int index) {
    _select(index);
    notifyListeners();
  }

  Future<void> deleteCards() async {
    // get ids

    List<int> idsForDelete = [];
    for (final nmId in _selectedNmIds) {
      final deletedCard =
          _productCards.where((element) => element.nmId == nmId).first;
      _productCards.remove(deletedCard);
      idsForDelete.add(deletedCard.nmId);
    }

    // update screen
    onClearSelected();

    // delete from the local storage and from the server
    final token = await _getToken();
    // final deleteResource =
    //     await cardsOfProductsService.delete(token, idsForDelete);
    // if (deleteResource is Error) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(deleteResource.message!),
    //   ));
    //   return;
    // }
    await _fetch(() => cardsOfProductsService.delete(token, idsForDelete));
    //
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

  // Define a method for fetch data and handling errors
  Future<T?> _fetch<T>(Future<Resource<T>> Function() callBack) async {
    final resource = await callBack();
    if (resource is Error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(resource.message!),
      ));
      return null;
    }
    return resource.data;
  }
}
