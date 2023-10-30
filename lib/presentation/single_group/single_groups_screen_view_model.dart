// ignore_for_file: use_build_context_synchronously, prefer_final_fields

import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/sqflite_service.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/group_model.dart';
import 'package:flutter/material.dart';

abstract class SingleGroupScreenGroupsService {
  Future<Resource<GroupModel>> loadGroup(String name);
}

abstract class SingleGroupScreenViewModelCardsService {
  Future<Resource<List<CardOfProductModel>>> getAll(List<int> ids);
}

class SingleGroupScreenViewModel extends ChangeNotifier {
  final SingleGroupScreenGroupsService groupService;
  final SingleGroupScreenViewModelCardsService cardsService;
  final BuildContext context;
  final String name;

  SingleGroupScreenViewModel(
      {required this.name,
      required this.groupService,
      required this.cardsService,
      required this.context}) {
    _asyncInit();
  }

  void _asyncInit() async {
    // TODO Move to separate method
    SqfliteService.printTableContent("groups");
    final groupsResource = await groupService.loadGroup(name);
    if (groupsResource is Error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(groupsResource.message!),
      ));
    }
    final group = groupsResource.data!;
    final cardsIds = group.cardsNmIds;

    // TODO Move to separate method
    final cardsResource = await cardsService.getAll(cardsIds);
    if (cardsResource is Error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(cardsResource.message!),
      ));
    }
    final cards = cardsResource.data!;

    group.setCards(cards);

    // _name = group.name;
    group.calculateStocksSum();
    group.calculateInitialStocksSum(
      yesterdayEndOfTheDay(),
      DateTime.now(),
    );
    for (final card in group.cards) {
      card.setColors(group.cards.indexOf(card));
      card.calculate(
        yesterdayEndOfTheDay(),
        DateTime.now(),
      );
    }
    group.calculateOrdersSum();
    stocksSum = group.stocksSum;
    ordersSum = group.ordersSum;
    _cards = group.cards;
    _cards ??= [];

    ordersTotal = ordersSum;

    stocksTotal = stocksSum;
    _cards!.sort((a, b) => b.stocksSum.compareTo(a.stocksSum));

    for (final card in _cards!) {
      if (card.ordersSum > 0) {
        _ordersDataMap[card.nmId.toString()] =
            (card.ordersSum / ordersTotal) * 100;
      }

      _stocksDataMap[card.name] = (card.stocksSum / stocksTotal) * 100;

      if (card.backgroundColor == null) {
        _colorsList.add(Colors.red);
        continue;
      }
      print(
          'card.stocksSum ${card.stocksSum} card.backgroundColor ${card.backgroundColor}');
      _colorsList.add(card.backgroundColor!);
    }
    notifyListeners();
  }

  // String _name = "";
  // String get name => _name;

  int ordersTotal = 0;
  int stocksTotal = 0;

  Map<String, double> _ordersDataMap = <String, double>{};
  Map<String, double> get ordersDataMap => _ordersDataMap;

  Map<String, double> _stocksDataMap = <String, double>{};
  Map<String, double> get stocksDataMap => _stocksDataMap;

  List<Color> _colorsList = <Color>[];
  List<Color> get colorsList => _colorsList;

  List<CardOfProductModel>? _cards;
  List<CardOfProductModel>? get cards => _cards;
  int stocksSum = 0;
  int ordersSum = 0;
}
