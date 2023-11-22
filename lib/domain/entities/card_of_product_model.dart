import 'dart:convert';

import 'package:rewild/core/constants.dart';

import 'package:rewild/domain/entities/background_notifier.dart';
import 'package:rewild/domain/entities/group_model.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/entities/notification.dart';

import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/domain/entities/size_model.dart';
import 'package:rewild/domain/entities/supply_model.dart';
import 'package:rewild/domain/services/notification_content.dart';

class CardOfProductModel extends BackgroundNotifier {
  int nmId = 0;

  String name;

  String? img;

  int? sellerId;

  String? tradeMark;

  int? subjectId;

  int? subjectParentId;

  String? brand;

  int? supplierId;

  int? basicPriceU;

  int? pics;

  int? rating;

  double? reviewRating;

  int? feedbacks;

  String? promoTextCard;

  int? createdAt;

  final List<SizeModel> sizes;

  final List<InitialStockModel> initialStocks;

  List<InitialStockModel> initialStocksList(
      DateTime dateFrom, DateTime dateTo) {
    return initialStocks.where((element) {
      return element.date.isAfter(dateFrom) && element.date.isBefore(dateTo);
    }).toList();
  }

  List<GroupModel> groups = [];
  void setGroup(GroupModel g) {
    groups = List.from(groups);
    groups.add(g);
  }

  SellerModel? seller;
  void setSeller(SellerModel s) {
    seller = s;
  }

  CardOfProductModel({
    required this.nmId,
    this.name = "",
    this.img = "",
    this.sellerId = 0,
    this.tradeMark = "",
    this.subjectId = 0,
    this.subjectParentId = 0,
    this.brand = "",
    this.supplierId = 0,
    this.basicPriceU = 0,
    this.pics = 0,
    this.rating = 0,
    this.reviewRating = 0,
    this.feedbacks = 0,
    this.createdAt = 0,
    this.promoTextCard = "",
    this.sizes = const [],
    this.initialStocks = const [],
    this.groups = const [],
    this.seller,
  });

  CardOfProductModel copyWith({
    int? nmId,
    String? name,
    String? img,
    int? sellerId,
    String? tradeMark,
    int? subjectId,
    int? subjectParentId,
    String? brand,
    int? supplierId,
    int? basicPriceU,
    int? pics,
    int? rating,
    double? reviewRating,
    int? feedbacks,
    int? createdAt,
    String? promoTextCard,
    List<SizeModel>? sizes,
    List<InitialStockModel>? initialStocks,
  }) {
    return CardOfProductModel(
      nmId: nmId ?? this.nmId,
      name: name ?? this.name,
      img: img ?? this.img,
      sellerId: sellerId ?? this.sellerId,
      tradeMark: tradeMark ?? this.tradeMark,
      subjectId: subjectId ?? this.subjectId,
      subjectParentId: subjectParentId ?? this.subjectParentId,
      brand: brand ?? this.brand,
      supplierId: supplierId ?? this.supplierId,
      basicPriceU: basicPriceU ?? this.basicPriceU,
      pics: pics ?? this.pics,
      rating: rating ?? this.rating,
      reviewRating: reviewRating ?? this.reviewRating,
      feedbacks: feedbacks ?? this.feedbacks,
      promoTextCard: promoTextCard ?? this.promoTextCard,
      sizes: sizes ?? this.sizes,
      createdAt: createdAt ?? this.createdAt,
      initialStocks: initialStocks ?? this.initialStocks,
      groups: groups,
      seller: seller,
    );
  }

  List<SupplyModel> supplies = [];
  void setSupplies(List<SupplyModel> s) {
    supplies = s;
  }

  // int _initialStocksSum = 0;
  int _stocksSum = 0;
  int get stocksSum => _stocksSum;
  int _ordersSum = 0;
  int get ordersSum => _ordersSum;
  int _supplySum = 0;
  int get supplySum => _supplySum;
  void calculate(DateTime dateFrom, DateTime dateTo) {
    // ordersSum = initialStocksSum - stocksSum;
    List<InitialStockModel> initialStocksList = initialStocks.where((element) {
      return element.date.isAfter(dateFrom) && element.date.isBefore(dateTo);
    }).toList();
    List<int> whIds = [];
    for (final size in sizes) {
      for (final stock in size.stocks) {
        whIds.add(stock.wh);
        // Calculate stocks sum
        final stockQty = stock.qty;

        _stocksSum += stockQty;
        // something wrong with initial stocks
        final initialStock = initialStocksList.where((element) {
          return element.nmId == stock.nmId &&
              element.wh == stock.wh &&
              element.sizeOptionId == stock.sizeOptionId;
        });

        //
        final initStockQty = initialStock.isEmpty ? 0 : initialStock.first.qty;

        // calculate supply
        int supplyQty = 0;
        int ordersBeforeSupply = 0;
        final sup = supplies.where((s) =>
            s.nmId == stock.nmId &&
            s.sizeOptionId == stock.sizeOptionId &&
            s.wh == stock.wh);
        if (sup.isNotEmpty) {
          supplyQty = sup.first.qty;
          ordersBeforeSupply = initStockQty - sup.first.lastStocks;
          _supplySum += supplyQty;
        }
        // orders sum is
        _ordersSum +=
            (initStockQty + supplyQty) - stockQty + ordersBeforeSupply;
      }
      final soldInitStocks = initialStocks
          .where((initStock) => !whIds.contains(initStock.wh))
          .map((e) => e.qty);
      if (soldInitStocks.isNotEmpty) {
        _ordersSum +=
            soldInitStocks.reduce((value, element) => value + element);
      }
    }
  }

  int _calculateAllStocks([int? sizeId]) {
    int allStocksSum = 0;
    for (final size in sizes) {
      if (sizeId != null && sizeId != size.optionId) {
        continue;
      }
      for (final stock in size.stocks) {
        final stockQty = stock.qty;
        allStocksSum += stockQty;
      }
    }
    return allStocksSum;
  }

  int _calculateAllStocksForWh(int wh, [int? sizeId]) {
    int stocksSum = 0;
    for (final size in sizes) {
      if (sizeId == null && sizeId != size.optionId) {
        continue;
      }
      for (final stock in size.stocks) {
        final stockWh = stock.wh;
        if (wh != stockWh) {
          continue;
        }
        final stockQty = stock.qty;
        stocksSum += stockQty;
      }
    }
    return stocksSum;
  }

  bool wasOrdered = false;
  void setWasOrdered() {
    wasOrdered = true;
  }

  void setWasNotOrdered() {
    wasOrdered = false;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nmId': nmId,
      'name': name,
      'img': img,
      'sellerId': sellerId,
      'tradeMark': tradeMark,
      'subjectId': subjectId,
      'subjectParentId': subjectParentId,
      'brand': brand,
      'supplierId': supplierId,
      'createdAt': createdAt,
      'basicPriceU': basicPriceU,
      'pics': pics,
      'rating': rating,
      'reviewRating': reviewRating,
      'feedbacks': feedbacks,
      'promoTextCard': promoTextCard,
    };
  }

  factory CardOfProductModel.fromMap(Map<String, dynamic> map) {
    return CardOfProductModel(
      nmId: map['nmId'] as int,
      name: map['name'] as String,
      img: map['img'] != null ? map['img'] as String : null,
      sellerId: map['sellerId'] != null ? map['sellerId'] as int : null,
      tradeMark: map['tradeMark'] != null ? map['tradeMark'] as String : null,
      subjectId: map['subjectId'] != null ? map['subjectId'] as int : null,
      createdAt: map['createdAt'] != null ? map['createdAt'] as int : null,
      subjectParentId:
          map['subjectParentId'] != null ? map['subjectParentId'] as int : null,
      brand: map['brand'] != null ? map['brand'] as String : null,
      supplierId: map['supplierId'] != null ? map['supplierId'] as int : null,
      basicPriceU:
          map['basicPriceU'] != null ? map['basicPriceU'] as int : null,
      pics: map['pics'] != null ? map['pics'] as int : null,
      rating: map['rating'] != null ? map['rating'] as int : null,
      reviewRating:
          map['reviewRating'] != null ? map['reviewRating'] as double : null,
      feedbacks: map['feedbacks'] != null ? map['feedbacks'] as int : null,
      promoTextCard:
          map['promoTextCard'] != null ? map['promoTextCard'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CardOfProductModel.fromJson(String source) =>
      CardOfProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CardOfProductModel(nmId: $nmId, name: $name, img: $img, sellerId: $sellerId, tradeMark: $tradeMark, subjectId: $subjectId, subjectParentId: $subjectParentId, brand: $brand, supplierId: $supplierId, basicPriceU: $basicPriceU, pics: $pics, rating: $rating, reviewRating: $reviewRating, feedbacks: $feedbacks, promoTextCard: $promoTextCard)';
  }

  @override
  bool operator ==(covariant CardOfProductModel other) {
    if (identical(this, other)) return true;

    return other.nmId == nmId &&
        other.name == name &&
        other.img == img &&
        other.sellerId == sellerId &&
        other.tradeMark == tradeMark &&
        other.subjectId == subjectId &&
        other.subjectParentId == subjectParentId &&
        other.brand == brand &&
        other.supplierId == supplierId &&
        other.basicPriceU == basicPriceU &&
        other.pics == pics &&
        other.rating == rating &&
        other.reviewRating == reviewRating &&
        other.feedbacks == feedbacks &&
        other.promoTextCard == promoTextCard;
  }

  @override
  int get hashCode {
    return nmId.hashCode ^
        name.hashCode ^
        img.hashCode ^
        sellerId.hashCode ^
        tradeMark.hashCode ^
        subjectId.hashCode ^
        subjectParentId.hashCode ^
        brand.hashCode ^
        supplierId.hashCode ^
        basicPriceU.hashCode ^
        pics.hashCode ^
        rating.hashCode ^
        reviewRating.hashCode ^
        feedbacks.hashCode ^
        promoTextCard.hashCode;
  }

  @override
  List<NotificationContent> notifications(
      List<NotificationModel> notifications) {
    List<NotificationContent> result = [];
    for (final notification in notifications) {
      print('candition: ${notification.condition}');
      switch (notification.condition) {
        case NotificationConditionConstants.nameChanged:
          _checkNameCondition(notification, result);
          break;
        case NotificationConditionConstants.picsChanged:
          _checkPicsCondition(notification, result);
          break;
        case NotificationConditionConstants.priceChanged:
          _checkPriceCondition(notification, result);
          break;
        case NotificationConditionConstants.promoChanged:
          _checkPromoCondition(notification, result);
          break;
        case NotificationConditionConstants.reviewRatingChanged:
          _checkReviewRatingCondition(notification, result);
          break;
        case NotificationConditionConstants.stocksLessThan:
          _checkStocksLessThanCondition(notification, result);
          break;

        case NotificationConditionConstants.sizeStocksLessThan:
          _checkSizeStocksLessCondition(notification, result);
          break;
        case NotificationConditionConstants.stocksInWhLessThan:
          _checkStocksInWhLessThanCondition(notification, result);
          break;
        case NotificationConditionConstants.sizeStocksInWhLessThan:
          _checkSizeInWhStocksLessThanCondition(notification, result);
          break;
        case NotificationConditionConstants.stocksMoreThan:
          _checkStocksMoreThanCondition(notification, result);
          break;
        default:
          break;
      }
    }
    return result;
  }

  void _checkNameCondition(
      NotificationModel notification, List<NotificationContent> result) {
    if (notification.value != name) {
      result.add(NotificationContent(
        id: nmId,
        title: "Изменено наименование карточки $nmId",
        body: "Новое наименование: $name",
        condition: NotificationConditionConstants.nameChanged,
        newValue: name,
      ));
    }
  }

  void _checkPicsCondition(
      NotificationModel notification, List<NotificationContent> result) {
    final nPics = int.tryParse(notification.value) ?? 0;
    if (nPics != pics) {
      result.add(NotificationContent(
        id: nmId,
        title: "Изменено кол-во картинок карточки $nmId",
        body: "Новое кол-во картинок: $pics, было $nPics",
        condition: NotificationConditionConstants.picsChanged,
        newValue: pics.toString(),
      ));
    }
  }

  void _checkPriceCondition(
      NotificationModel notification, List<NotificationContent> result) {
    final nPrice = int.tryParse(notification.value) ?? 0;

    print("check price condition $basicPriceU ");
    if (nPrice != basicPriceU) {
      result.add(NotificationContent(
        id: nmId,
        title: "Изменена цена товара $nmId",
        body: "Новая цена: $basicPriceU, было $nPrice",
        condition: NotificationConditionConstants.priceChanged,
        newValue: basicPriceU.toString(),
      ));
    }
  }

  void _checkPromoCondition(
      NotificationModel notification, List<NotificationContent> result) {
    if (notification.value != promoTextCard) {
      result.add(NotificationContent(
        id: nmId,
        title: "Изменена акция карточки $nmId",
        body: "Новая акция: $promoTextCard",
        condition: NotificationConditionConstants.promoChanged,
        newValue: promoTextCard,
      ));
    }
  }

  void _checkReviewRatingCondition(
      NotificationModel notification, List<NotificationContent> result) {
    final nReviewRating = int.tryParse(notification.value) ?? 0;
    print("In Card entity check review rating condition $reviewRating ");
    if (nReviewRating != reviewRating) {
      result.add(NotificationContent(
        id: nmId,
        title: "Изменен рейтинг карточки $nmId",
        body: "Новый рейтинг: $reviewRating, был $nReviewRating",
        condition: NotificationConditionConstants.reviewRatingChanged,
        newValue: reviewRating.toString(),
      ));
    }
  }

  void _checkStocksLessThanCondition(
      NotificationModel notification, List<NotificationContent> result) {
    final stocksQty = _calculateAllStocks();
    final nStocks = int.tryParse(notification.value) ?? 0;
    final stocksDif = nStocks - stocksQty;
    print("check stocks less than condition $stocksQty ");
    if (stocksDif > 0) {
      result.add(NotificationContent(
        id: nmId,
        title: "Изменено кол-во остатков на складах $nmId",
        body: "Новое кол-во на всех складах: $stocksQty меньше, чем $nStocks",
        condition: NotificationConditionConstants.stocksLessThan,
        newValue: stocksQty.toString(),
      ));
    }
  }

  void _checkStocksMoreThanCondition(
      NotificationModel notification, List<NotificationContent> result) {
    final stocksQty = _calculateAllStocks();
    final nStocks = int.tryParse(notification.value) ?? 0;
    final stocksDif = nStocks - stocksQty;
    if (stocksDif < 0) {
      result.add(NotificationContent(
        id: nmId,
        title: "Изменено кол-во остатков на складах $nmId",
        body: "Новое кол-во на всех складах: $stocksQty больше, чем $nStocks",
        condition: NotificationConditionConstants.stocksMoreThan,
        newValue: stocksQty.toString(),
      ));
    }
  }

  void _checkStocksInWhLessThanCondition(
      NotificationModel notification, List<NotificationContent> result) {
    final wh = notification.wh ?? 0;
    final nStocks = int.tryParse(notification.value) ?? 0;
    final stocksSum = _calculateAllStocksForWh(wh);
    final stocksDif = stocksSum - nStocks;
    if (stocksDif < 0) {
      result.add(NotificationContent(
        id: nmId,
        title: "Изменено кол-во остатков на складе $nmId",
        body: "Новое кол-во на складе: $stocksSum меньше, чем $nStocks",
        condition: NotificationConditionConstants.stocksInWhLessThan,
        newValue: stocksSum.toString(),
      ));
    }
  }

  void _checkSizeStocksLessCondition(
      NotificationModel notification, List<NotificationContent> result) {
    final nSize = notification.sizeId ?? 0;
    final nStocks = int.tryParse(notification.value) ?? 0;
    final stocksSum = _calculateAllStocks(nSize);
    final stocksDif = stocksSum - nStocks;
    if (stocksDif < 0) {
      result.add(NotificationContent(
        id: nmId,
        title: "Изменено кол-во остатков на складе $nmId  для размера $nSize",
        body: "Новое кол-во на складе: $stocksSum меньше, чем $nStocks",
        condition: NotificationConditionConstants.sizeStocksLessThan,
        newValue: stocksSum.toString(),
      ));
    }
  }

  void _checkSizeInWhStocksLessThanCondition(
      NotificationModel notification, List<NotificationContent> result) {
    final nSize = notification.sizeId ?? 0;
    final nStocks = int.tryParse(notification.value) ?? 0;
    final wh = notification.wh ?? 0;
    final stocksSumForWh = _calculateAllStocksForWh(wh, nSize);
    final stocksDif = stocksSumForWh - nStocks;
    if (stocksDif < 0) {
      result.add(NotificationContent(
        id: nmId,
        title: "Изменено кол-во остатков на складе $nmId  для размера $nSize",
        body: "Новое кол-во на складе: $stocksSum меньше, чем $nStocks",
        condition: NotificationConditionConstants.sizeStocksInWhLessThan,
        newValue: stocksSum.toString(),
      ));
    }
  }
}
