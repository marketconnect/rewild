import 'package:flutter/material.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/seller_model.dart';

abstract class AllSellersCardsOfProductService {
  Future<Resource<List<CardOfProductModel>>> getAll([List<int>? nmIds]);
}

abstract class AllSellersSellersService {
  Future<Resource<SellerModel>> get(int supplierId);
}

class AllSellersScreenViewModel extends ChangeNotifier {
  AllSellersScreenViewModel(
      {required this.context,
      required this.cardsService,
      required this.sellersService}) {
    _asyncInit();
  }

  final BuildContext context;
  final AllSellersCardsOfProductService cardsService;
  final AllSellersSellersService sellersService;

  List<SellerModel> _sellers = [];
  void setSellers(List<SellerModel> sellers) {
    _sellers = sellers;
  }

  List<SellerModel> get sellers => _sellers;

  void _asyncInit() async {
    final allCards = await _fetch(() => cardsService.getAll());
    if (allCards == null) {
      return;
    }

    // get all sellers
    List<SellerModel> fetchedSellers = [];
    for (final card in allCards) {
      final supId = card.supplierId;
      if (supId == null) {
        continue;
      }
      if (fetchedSellers
          .where((element) => element.supplierId == supId)
          .isNotEmpty) {
        continue;
      }

      final seller = await _fetch(() => sellersService.get(supId));
      if (seller == null) {
        return;
      }
      fetchedSellers.add(seller);
    }
    setSellers(fetchedSellers);
    notify();
  }

  void notify() {
    if (context.mounted) {
      notifyListeners();
    }
  }

  Future<T?> _fetch<T>(Future<Resource<T>> Function() callBack) async {
    final resource = await callBack();
    if (resource is Error && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(resource.message!),
      ));
      notify();
      return null;
    }
    return resource.data;
  }
}
