import 'dart:convert';

import 'package:rewild/domain/entities/group_model.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/entities/price_history_model.dart';
import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/domain/entities/size_model.dart';
import 'package:rewild/domain/entities/supply_model.dart';

class CardOfProductModel {
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

  final List<PriceHistoryModel> priceHistory;

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
    this.priceHistory = const [],
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
    List<PriceHistoryModel>? priceHistory,
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
      priceHistory: priceHistory ?? this.priceHistory,
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
    for (final size in sizes) {
      for (final stock in size.stocks) {
        // Calculate stocks sum
        final stockQty = stock.qty;

        _stocksSum += stockQty;
        // something wrong with initial stocks
        final initialStock = initialStocksList.where((element) {
          return element.nmId == stock.nmId &&
              element.wh == stock.wh &&
              element.sizeOptionId == stock.sizeOptionId;
        });

        if (initialStock.isEmpty) {
          _ordersSum += stockQty;
          continue;
        }

        // calculate supply
        int supplyQty = 0;
        int ordersBeforeSupply = 0;
        final sup = supplies.where((s) =>
            s.nmId == stock.nmId &&
            s.sizeOptionId == stock.sizeOptionId &&
            s.wh == stock.wh);
        if (sup.isNotEmpty) {
          supplyQty = sup.first.qty;
          ordersBeforeSupply = initialStocks.first.qty - sup.first.lastStocks;
          _supplySum += supplyQty;
        }

        // orders sum is
        _ordersSum += (initialStock.first.qty + supplyQty) -
            stockQty +
            ordersBeforeSupply;
      }
    }
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
}
