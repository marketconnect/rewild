import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';

import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/group_model.dart';
import 'package:flutter/material.dart';
import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/domain/entities/warehouse.dart';

abstract class SingleGroupScreenGroupsService {
  Future<Either<RewildError, GroupModel?>> loadGroup({required String name});
  Future<Either<RewildError, void>> delete(
      {required String groupName, required int nmId});
}

abstract class SingleGroupScreenViewModelCardsService {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]);
}

abstract class SingleGroupScreenSellerService {
  Future<Either<RewildError, SellerModel>> get({required int supplierId});
}

// warehouse
abstract class SingleGroupScreenWarehouseService {
  Future<Either<RewildError, Warehouse?>> getById({required int id});
}

class SingleGroupScreenViewModel extends ResourceChangeNotifier {
  final SingleGroupScreenGroupsService groupService;
  final SingleGroupScreenViewModelCardsService cardsService;
  final SingleGroupScreenSellerService sellerService;
  final SingleGroupScreenWarehouseService warehouseService;

  final String name;
  bool _isExpanded = false;
  void changeIsExpanded() {
    _isExpanded = !_isExpanded;
    notify();
  }

  bool get isExpanded => _isExpanded;

  SingleGroupScreenViewModel({
    required super.context,
    required super.internetConnectionChecker,
    required this.name,
    required this.groupService,
    required this.warehouseService,
    required this.cardsService,
    required this.sellerService,
  }) {
    _asyncInit();
  }

  void _asyncInit() async {
    setIsLoading(true);
    await _update();

    if (_cards == null) {
      return;
    }
    setIsLoading(false);
  }

  Future<void> _update() async {
    // group
    final group = await fetch(() => groupService.loadGroup(name: name));

    if (group == null) {
      return;
    }

    // cards
    final cardsIds = group.cardsNmIds;

    final cards = await fetch(() => cardsService.getAll(cardsIds));
    if (cards == null) {
      return;
    }

    group.setCards(cards);

    group.calculateStocksSum();

    group.calculateInitialStocksSum(
      yesterdayEndOfTheDay(),
      DateTime.now(),
    );

    Set<int> supplierIds = {};
    if (group.cards.isEmpty) {
      return;
    }

    _cards = [];
    for (final card in group.cards) {
      if (card.supplierId == null) {
        continue;
      }
      // seller
      final seller =
          await fetch(() => sellerService.get(supplierId: card.supplierId!));
      if (seller == null) {
        continue;
      }
      if (!supplierIds.contains(seller.supplierId)) {
        seller.setColors(supplierIds.length);
      }

      card.setSeller(seller);

      supplierIds.add(seller.supplierId);

      // //       for (final c in cards) {
      int stockQty = 0;
      for (final size in card.sizes) {
        final stock = size.stocks;
        for (final stock in stock) {
          final wh = stock.wh;
          String name = "";
          if (whIds.containsKey(wh)) {
            name = whIds[wh]!;
          } else {
            final warehouse =
                await fetch(() => warehouseService.getById(id: stock.wh));
            if (warehouse == null) {
              continue;
            }
            name = warehouse.name;
            whIds[wh] = name;
          }
          if (name.contains("клад продавца")) {
            continue;
          }
          stockQty += stock.qty;
        }
      }
      card.setStocksFbw(stockQty);
      stocksTotal += stockQty;

      card.calculate(
        yesterdayEndOfTheDay(),
        DateTime.now(),
      );

      _cards!.add(card);
    }

    group.calculateOrdersSum();

    ordersSum = group.ordersSum;

    ordersTotal = ordersSum;

    _cards!.sort((a, b) => b.stocksSum.compareTo(a.stocksSum));

    for (final selId in supplierIds) {
      final cards = _cards!.where((card) => card.supplierId == selId);
      for (final card in cards) {
        if (card.ordersSum > 0) {
          addOrdersToDataMap(
              card.seller!, (card.ordersSum / ordersTotal) * 100);
        }
        if (card.stocksFbw > 0) {
          addStocksToDataMap(
              card.seller!, (card.stocksFbw / stocksTotal) * 100);
        }
      }
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  Map<int, String> whIds = {};

  Map<int, Color> _sellerColorMap = {};
  void setSellerColorMap(Map<int, Color> map) {
    _sellerColorMap = map;
  }

  Map<int, Color> get sellerColorMap => _sellerColorMap;

  int ordersTotal = 0;
  int stocksTotal = 0;

  Map<SellerModel, double> _ordersDataMap = <SellerModel, double>{};
  void setOrdersDataMap(Map<SellerModel, double> ordersDataMap) {
    _ordersDataMap = ordersDataMap;
  }

  void addOrdersToDataMap(SellerModel name, double value) {
    if (_ordersDataMap[name] != null) {
      _ordersDataMap[name] = _ordersDataMap[name]! + value;
    } else {
      _ordersDataMap[name] = value;
    }
  }

  Map<SellerModel, double> get ordersDataMap => _ordersDataMap;

  Map<SellerModel, double> _stocksDataMap = <SellerModel, double>{};
  void setStocksDataMap(Map<SellerModel, double> stocksDataMap) {
    _stocksDataMap = stocksDataMap;
  }

  void addStocksToDataMap(SellerModel name, double value) {
    if (_stocksDataMap[name] != null) {
      _stocksDataMap[name] = _stocksDataMap[name]! + value;
    } else {
      _stocksDataMap[name] = value;
    }
  }

  Map<SellerModel, double> get stocksDataMap => _stocksDataMap;

  List<Color> _colorsList = <Color>[];
  void setColorsList(List<Color> colorsList) {
    _colorsList = colorsList;
  }

  List<Color> get colorsList => _colorsList;

  List<CardOfProductModel>? _cards;
  List<CardOfProductModel>? get cards => _cards;
  // int stocksSum = 0;
  int ordersSum = 0;

  Future<void> deleteCardFromGroup(int nmId) async {
    final _ =
        await fetch(() => groupService.delete(groupName: name, nmId: nmId));
    if (cards == null) {
      return;
    }
    // it was last card
    if (cards!.length == 1) {
      if (context.mounted) Navigator.of(context).pop();
      return;
    }
    await _update();
    notify();
  }
}
