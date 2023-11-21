// import 'package:flutter/material.dart';
// import 'package:rewild/core/utils/resource.dart';
// import 'package:rewild/domain/entities/card_of_product_model.dart';
// // import 'package:rewild/domain/entities/price_history_model.dart';

// // abstract class SingleSellerPriceHistoryService {
// //   Future<Resource<List<PriceHistoryModel>>> fetch(List<String> links);
// // }

// abstract class SingleSellerCardOfProductService {
//   Future<Resource<List<CardOfProductModel>>> getForSeller(int supplierId);
// }

// class SingleSellerViewModel extends ChangeNotifier {
//   final BuildContext context;
//   // final SingleSellerPriceHistoryService priceHistoryService;
//   final SingleSellerCardOfProductService cardOfProductService;
//   final int supplireId;

//   SingleSellerViewModel(
//       {required this.supplireId,
//       required this.context,
//       // required this.priceHistoryService,
//       required this.cardOfProductService}) {
//     _asyncInit();
//   }

//   bool _loading = true;
//   bool get loading => _loading;

//   List<CardOfProductModel> _allSellerCards = [];
//   void setAllSellerCards(List<CardOfProductModel> cards) {
//     _allSellerCards = List.from(cards);
//   }

//   List<CardOfProductModel> get allSellerCards => _allSellerCards;

//   void _asyncInit() async {
//     final cards =
//         await _fetch(() => cardOfProductService.getForSeller(supplireId));
//     if (cards == null) {
//       return;
//     }

//     // final linkList = cards.map((card) {
//     //   if (card.img == null) {
//     //     return '';
//     //   }
//     //   return '${card.img!.split('/images')[0]}/info/price-history.json';
//     // });
//     // final allPriceHistory =
//     //     await _fetch(() => priceHistoryService.fetch(linkList.toList()));

//     // if (allPriceHistory == null) {
//     //   return;
//     // }

//     // for (final i = 0; i < cards.length; i++) {
//     //   final prHistory = allPriceHistory
//     //       .where((priceHistory) => priceHistory.nmId == cards[i].nmId)
//     //       .toList();
//     //   cards[i].setPriceHistory(prHistory);
//     // }
//     setAllSellerCards(cards);
//     _loading = false;
//     if (context.mounted) {
//       notifyListeners();
//     }
//   }

//   // Define a method for fetch data and handling errors
//   Future<T?> _fetch<T>(Future<Resource<T>> Function() callBack) async {
//     final resource = await callBack();
//     if (resource is Error && context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text(resource.message!),
//       ));
//       return null;
//     }
//     return resource.data;
//   }
// }
