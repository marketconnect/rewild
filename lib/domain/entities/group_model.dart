import 'package:rewild/domain/entities/card_of_product_model.dart';

class GroupModel {
  int id;
  final String name;
  final int bgColor;
  final int fontColor;
  final List<int> cardsNmIds;
  List<CardOfProductModel> cards;
  void setCards(List<CardOfProductModel> cards) {
    this.cards = cards;
  }

  int stocksSum = 0;
  void calculateStocksSum() {
    stocksSum = 0;
    for (final card in cards) {
      for (final size in card.sizes) {
        for (final stock in size.stocks) {
          stocksSum += stock.qty;
        }
      }
    }
  }

  int initialStocksSum = 0;
  void calculateInitialStocksSum(DateTime dateFrom, DateTime dateTo) {
    initialStocksSum = 0;
    for (final card in cards) {
      for (final initialStock in card.initialStocks) {
        if (initialStock.date.isAfter(dateFrom) &&
            initialStock.date.isBefore(dateTo)) {
          initialStocksSum += initialStock.qty;
        }
      }
    }
  }

  int ordersSum = 0;
  void calculateOrdersSum() {
    ordersSum = initialStocksSum - stocksSum;
  }

  GroupModel(
      {this.id = 0,
      required this.name,
      required this.bgColor,
      required this.cardsNmIds,
      this.cards = const [],
      required this.fontColor});

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
        id: map['id'] as int,
        name: map['name'] as String,
        bgColor: map['bgColor'] as int,
        cardsNmIds: map['cardsNmIds'] as List<int>,
        fontColor: map['fontColor'] as int);
  }
}
