import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';

import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/commission_model.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/entities/orders_history_model.dart';
import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/domain/entities/stocks_model.dart';
import 'package:rewild/domain/entities/supply_model.dart';

import 'package:rewild/domain/entities/warehouse.dart';
import 'package:flutter/material.dart';

// card
abstract class SingleCardScreenCardOfProductService {
  Future<Resource<CardOfProductModel?>> getOne(int nmId);
}

// warehouse
abstract class SingleCardScreenWarehouseService {
  Future<Resource<Warehouse?>> getById(int id);
}

// initial stock
abstract class SingleCardScreenInitialStockService {
  Future<Resource<List<InitialStockModel>>> get(int nmId,
      [DateTime? dateFrom, DateTime? dateTo]);
}

// stock
abstract class SingleCardScreenStockService {
  Future<Resource<List<StocksModel>>> get(int nmId);
}

// seller
abstract class SingleCardScreenSellerService {
  Future<Resource<SellerModel>> get(int supplierId);
}

// commission
abstract class SingleCardScreenCommissionService {
  Future<Resource<CommissionModel>> get(int id);
}

// orders history
abstract class SingleCardScreenOrdersHistoryService {
  Future<Resource<OrdersHistoryModel>> get(int nmId);
}

// supply
abstract class SingleCardScreenSupplyService {
  Future<Resource<List<SupplyModel>>> getForOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo});
}

class SingleCardScreenViewModel extends ChangeNotifier {
  final BuildContext context;
  final SingleCardScreenCardOfProductService cardOfProductService;
  final SingleCardScreenSellerService sellerService;
  final SingleCardScreenCommissionService commissionService;
  final SingleCardScreenInitialStockService initialStocksService;
  final SingleCardScreenWarehouseService warehouseService;
  final SingleCardScreenStockService stockService;
  final SingleCardScreenSupplyService supplyService;
  final SingleCardScreenOrdersHistoryService ordersHistoryService;

  final int id;

  SingleCardScreenViewModel(
      {required this.id,
      required this.context,
      required this.initialStocksService,
      required this.stockService,
      required this.sellerService,
      required this.commissionService,
      required this.cardOfProductService,
      required this.ordersHistoryService,
      required this.supplyService,
      required this.warehouseService}) {
    asyncInit();
  }

  final List<String> listTilesNames = [
    'Общая информация',
    'Карточка',
    'Остатки по складам',
    'Заказы по складам',
  ];
  String getTitle(int index) {
    return listTilesNames[index];
  }

  // Uri
  Uri? websiteUri;
  // Name
  String _name = '';
  String get name => _name;

  // Seller name
  String _sellerName = '-';
  String get sellerName => _sellerName;

  // Brand
  String _brand = '-';
  String get brand => _brand;

  // Trademark
  String _tradeMark = '-';
  String get tradeMark => _tradeMark;

  // category
  String _category = '-';
  String get category => _category;

  // subject Id
  int _subjectId = 0;
  int get subjectId => _subjectId;

  // subject
  String _subject = '-';
  String get subject => _subject;

  // commission
  int? _commission;
  int? get commission => _commission;

  // total oders qty
  int? _totalOrdersQty;
  int? get totalOrdersQty => _totalOrdersQty;

  // is high buyout
  bool _isHighBuyout = false;
  bool get isHighBuyout => _isHighBuyout;

  // Image
  String _img = '';
  String get img => _img;

  // Feedback
  int _feedbacks = 0;
  int get feedbacks => _feedbacks;
  // Review rating
  double _reviewRating = 0;
  double get reviewRating => _reviewRating;

  // Warehouses
  Map<String, int> _warehouses = {};
  void setWarehouses(Map<String, int> warehouses) {
    _warehouses = warehouses;
  }

  void addWarehouse(String name, int qty) {
    if (_warehouses[name] == null) {
      _warehouses[name] = qty;

      return;
    }
    final sumQty = _warehouses[name]! + qty;
    _warehouses[name] = sumQty;
  }

  Map<String, int> get warehouses => _warehouses;

  // Stocks sum
  int _stocksSum = 0;
  int get stocksSum => _stocksSum;

  // Initial  Stocks
  Map<String, int> _initialStocks = {};
  Map<String, int> get initialStocks => _initialStocks;
  void setInitialStocks(Map<String, int> initialStocks) {
    _initialStocks = initialStocks;
  }

  void addInitialStock(String name, int qty) {
    if (_initialStocks[name] == null) {
      _initialStocks[name] = qty;
      return;
    }
    final sumQty = _initialStocks[name]! + qty;
    _initialStocks[name] = sumQty;
  }

  // Supplies
  Map<String, int> _supplies = {};
  Map<String, int> get supplies => _supplies;
  void setSupplies(Map<String, int> supplies) {
    _supplies = supplies;
  }

  void addSupply(String name, int qty) {
    if (_supplies[name] == null) {
      _supplies[name] = qty;
      return;
    }
    final sumQty = _supplies[name]! + qty;
    _supplies[name] = sumQty;
  }

  int _initStocksSum = 0;
  int get initStocksSum => _initStocksSum;

  int _supplySum = 0;
  int get supplySum => _supplySum;

  // Sales
  Map<String, int> _orders = {};
  void setOrders(Map<String, int> orders) {
    _orders = orders;
  }

  void addOrder(String name, int qty) {
    _orders[name] = qty;
  }

  Map<String, int> get orders => _orders;

  // Null
  bool _isNull = true;
  bool get isNull => _isNull;

  // Async init ================================================================
  Future<void> asyncInit() async {
    // Set Uri
    websiteUri =
        Uri.parse('https://www.wildberries.ru/catalog/$id/detail.aspx');

    // Get card
    final cardOfProduct = await _fetch(() => cardOfProductService.getOne(id));
    if (cardOfProduct == null) {
      return;
    }
    print("isNull false");

    _isNull = false;

    // name, img, feedbacks, reviewRating
    _name = cardOfProduct.name;
    _img = cardOfProduct.img!.replaceFirst("/tm/", "/big/");
    _feedbacks = cardOfProduct.feedbacks ?? 0;
    _reviewRating = cardOfProduct.reviewRating ?? 0;

    // Seller
    if (_sellerName == "-") {
      if (cardOfProduct.supplierId != null) {
        final seller =
            await _fetch(() => sellerService.get(cardOfProduct.supplierId!));
        if (seller == null) {
          return;
        }
        _tradeMark = seller.trademark ?? '-';
        _sellerName = seller.name;
      }
    }
    print("isNull false1");
    // Commission, category, subject
    if (_subjectId == 0) {
      _subjectId = cardOfProduct.subjectId ?? 0;
    }
    if (_commission == null && _subjectId != 0) {
      final commissionResource =
          await _fetch(() => commissionService.get(_subjectId));
      if (commissionResource == null) {
        return;
      }
      _commission = commissionResource.commission;
      _category = commissionResource.category;
      _subject = commissionResource.subject;
    }

    // brand
    _brand = cardOfProduct.brand ?? '-';
    print("isNull false2");
    // get stocks
    final stocks = await _fetch(() => stockService.get(id));
    if (stocks == null) {
      return;
    }

    //  add stocks
    for (final stock in stocks) {
      final resource = await warehouseService.getById(stock.wh);
      final resouwarehouse = resource.data;
      if (resouwarehouse == null) {
        return;
      }
      addWarehouse(resouwarehouse.name, stock.qty);
    }
    print("isNull false3");
    // get supplies
    final supplies = await _fetch(() => supplyService.getForOne(
            nmId: id,
            dateFrom: yesterdayEndOfTheDay(),
            dateTo: DateTime.now())) ??
        [];

    print("isNull false3.5");

    // get initial stocks
    final initialStocks = await _fetch(() => initialStocksService.get(id));
    if (initialStocks == null) {
      return;
    }
    print("isNull false4");
    // add initial stocks and orders
    for (final initStock in initialStocks) {
      final wh = initStock.wh;
      final warehouse = await _fetch(() => warehouseService.getById(wh));
      if (warehouse == null) {
        return;
      }

      addInitialStock(warehouse.name, initStock.qty);

      // orders
      final stock = warehouses[warehouse.name] ?? 0;
      final iSt = _initialStocks[warehouse.name] ?? 0;
      int supplyQty = 0;
      final supply = supplies.where((element) =>
          element.nmId == id &&
          element.wh == wh &&
          element.sizeOptionId == initStock.sizeOptionId);
      if (supply.isNotEmpty) {
        supplyQty = supply.first.qty;
      }
      addSupply(warehouse.name, supplyQty);
      final qty = iSt + supplyQty - stock;
      addOrder(warehouse.name, qty);
      _stocksSum += stock;
    }

    _initStocksSum = _initialStocks.values.isNotEmpty
        ? _initialStocks.values.reduce((value, element) => value + element)
        : 0;
    _supplySum = _supplies.values.isNotEmpty
        ? _supplies.values.reduce((value, element) => value + element)
        : 0;
    final ordersHistory = await _fetch(() => ordersHistoryService.get(id));
    if (ordersHistory == null) {
      return;
    }

    _totalOrdersQty = ordersHistory.qty;
    print("isNull false5");
    // is high buyout
    _isHighBuyout = ordersHistory.highBuyout;

    notifyListeners();
  }

  // Define a method for fetch data and handling errors
  Future<T?> _fetch<T>(Future<Resource<T>> Function() callBack) async {
    final resource = await callBack();
    if (resource is Error) {
      print('ERRRRRRR${resource.message}');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(resource.message!),
      ));
      return null;
    }
    print('Data ${resource.data}');
    return resource.data;
  }
}
