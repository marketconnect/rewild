import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';

import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/group_model.dart';
import 'package:flutter/material.dart';
import 'package:rewild/domain/entities/seller_model.dart';

abstract class SingleGroupScreenGroupsService {
  Future<Resource<GroupModel>> loadGroup(String name);
}

abstract class SingleGroupScreenViewModelCardsService {
  Future<Resource<List<CardOfProductModel>>> getAll(List<int> ids);
}

abstract class SingleGroupScreenSellerService {
  Future<Resource<SellerModel>> get(int supplierId);
}

class SingleGroupScreenViewModel extends ChangeNotifier {
  final SingleGroupScreenGroupsService groupService;
  final SingleGroupScreenViewModelCardsService cardsService;
  final SingleGroupScreenSellerService sellerService;
  final BuildContext context;
  final String name;
  String? _errMessage;
  String? get errMessage => _errMessage;

  SingleGroupScreenViewModel(
      {required this.name,
      required this.groupService,
      required this.cardsService,
      required this.sellerService,
      required this.context}) {
    _asyncInit();
  }

  void _asyncInit() async {
    final group = await _fetch(() => groupService.loadGroup(name));
    if (group == null) {
      return;
    }

    final cardsIds = group.cardsNmIds;

    final cards = await _fetch(() => cardsService.getAll(cardsIds));
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
      final seller = await _fetch(() => sellerService.get(card.supplierId!));
      if (seller == null) {
        continue;
      }
      if (!supplierIds.contains(seller.supplierId)) {
        seller.setColors(supplierIds.length);
      }
      card.setSeller(seller);
      supplierIds.add(seller.supplierId);
      card.calculate(
        yesterdayEndOfTheDay(),
        DateTime.now(),
      );
      _cards!.add(card);
    }

    group.calculateOrdersSum();
    stocksSum = group.stocksSum;
    ordersSum = group.ordersSum;

    ordersTotal = ordersSum;

    stocksTotal = stocksSum;
    _cards!.sort((a, b) => b.stocksSum.compareTo(a.stocksSum));

    for (final selId in supplierIds) {
      final cards = _cards!.where((card) => card.supplierId == selId);
      for (final card in cards) {
        if (card.ordersSum > 0) {
          addOrdersToDataMap(
              card.seller!, (card.ordersSum / ordersTotal) * 100);
        }

        addStocksToDataMap(card.seller!, (card.stocksSum / stocksTotal) * 100);
      }
    }

    notifyListeners();
  }

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
  int stocksSum = 0;
  int ordersSum = 0;

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
