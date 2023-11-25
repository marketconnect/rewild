import 'package:flutter/material.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';

import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:rewild/domain/entities/commission_model.dart';
import 'package:rewild/domain/entities/initial_stock_model.dart';
import 'package:rewild/domain/entities/orders_history_model.dart';
import 'package:rewild/domain/entities/seller_model.dart';
import 'package:rewild/domain/entities/stocks_model.dart';
import 'package:rewild/domain/entities/supply_model.dart';

import 'package:rewild/domain/entities/warehouse.dart';
import 'package:rewild/presentation/notification_card_screen/notification_card_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

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

class SingleCardScreenViewModel extends ResourceChangeNotifier {
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
      {required super.context,
      required super.internetConnectionChecker,
      required this.id,
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

  // Async init ================================================================
  Future<void> asyncInit() async {
    // Set Uri
    websiteUri =
        Uri.parse('https://www.wildberries.ru/catalog/$id/detail.aspx');

    // Get card
    final cardOfProduct = await fetch(() => cardOfProductService.getOne(id));
    if (cardOfProduct == null) {
      return;
    }

    _isNull = false;

    // name, img, feedbacks, reviewRating
    _name = cardOfProduct.name;
    _img = cardOfProduct.img!.replaceFirst("/tm/", "/big/");
    _feedbacks = cardOfProduct.feedbacks ?? 0;
    _reviewRating = cardOfProduct.reviewRating ?? 0;
    _price = cardOfProduct.basicPriceU ?? 0;
    _pics = cardOfProduct.pics ?? 0;
    _promo = cardOfProduct.promoTextCard ?? '';

    // Seller
    if (_sellerName == "-") {
      if (cardOfProduct.supplierId != null) {
        final seller =
            await fetch(() => sellerService.get(cardOfProduct.supplierId!));
        if (seller == null) {
          return;
        }
        _tradeMark = seller.trademark ?? '-';
        _sellerName = seller.name;
        // region
        final ogrn = seller.ogrn;
        _region = (ogrn != null && ogrn.length > 3)
            ? "${RegionsNumsConstants.regions[ogrn.substring(3, 5)]}"
            : "-";
      }
    }

    // Commission, category, subject
    if (_subjectId == 0) {
      _subjectId = cardOfProduct.subjectId ?? 0;
    }
    if (_commission == null && _subjectId != 0) {
      final commissionResource =
          await fetch(() => commissionService.get(_subjectId));
      if (commissionResource == null) {
        return;
      }
      _commission = commissionResource.commission;
      _category = commissionResource.category;
      _subject = commissionResource.subject;
    }

    // brand
    _brand = cardOfProduct.brand ?? '-';
    // get stocks
    final stocks = await fetch(() => stockService.get(id));
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
      _notificationScreenWarehouses[resouwarehouse] = stock.qty;
      addWarehouse(resouwarehouse.name, stock.qty);
    }
    // get supplies
    final supplies = await fetch(() => supplyService.getForOne(
            nmId: id,
            dateFrom: yesterdayEndOfTheDay(),
            dateTo: DateTime.now())) ??
        [];

    // get initial stocks
    final initialStocks = await fetch(() => initialStocksService.get(id));
    if (initialStocks == null) {
      return;
    }
    // add initial stocks and orders
    for (final initStock in initialStocks) {
      final wh = initStock.wh;
      final warehouse = await fetch(() => warehouseService.getById(wh));
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
    final ordersHistory = await fetch(() => ordersHistoryService.get(id));
    if (ordersHistory == null) {
      return;
    }

    _totalOrdersQty = ordersHistory.qty;
    // is high buyout
    _isHighBuyout = ordersHistory.highBuyout;

    notify();
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

  // stet for notification screen

  String _promo = '';

  // price
  int _price = 0;

  // pics
  int _pics = 0;

  Map<Warehouse, int> _notificationScreenWarehouses = {};
  // review rating
  double _reviewRating = 0;
  double get reviewRating => _reviewRating;

  //
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

  // region
  String _region = '-';
  String get region => _region;
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

  void notificationsScreen() {
    final state = NotificationCardState(
      nmId: id,
      price: _price,
      promo: _promo,
      name: _name,
      pics: _pics,
      reviewRating: _reviewRating,
      warehouses: _notificationScreenWarehouses,
    );

    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.cardNotificationsSettingsScreen,
        arguments: state);
  }
}
