import 'dart:async';

import 'package:rewild/api_clients/advert_api_client.dart';
import 'package:rewild/api_clients/auth_service_api_client.dart';
import 'package:rewild/api_clients/commision_api_client.dart';
import 'package:rewild/api_clients/details_api_client.dart';

import 'package:rewild/api_clients/orders_history_api_client.dart';

import 'package:rewild/api_clients/product_card_service_api_client.dart';
import 'package:rewild/api_clients/seller_api_client.dart';
import 'package:rewild/api_clients/initial_stocks_api_client.dart';
import 'package:rewild/api_clients/warehouse_api_client.dart';
import 'package:rewild/data_providers/auto_stat_data_provider/auto_stat_data_provider.dart';

import 'package:rewild/data_providers/card_of_product_data_provider/card_of_product_data_provider.dart';
import 'package:rewild/data_providers/commission_data_provider/commission_data_provider.dart';
import 'package:rewild/data_providers/filter_data_provider/filter_data_provider.dart';

import 'package:rewild/data_providers/group_data_provider/group_data_provider.dart';
import 'package:rewild/data_providers/initial_stocks_data_provider/initial_stocks_data_provider.dart';
import 'package:rewild/data_providers/last_update_day_data_provider.dart';
import 'package:rewild/data_providers/notificate_data_provider/notificate_data_provider.dart';
import 'package:rewild/data_providers/orders_history_data_provider/orders_history_data_provider.dart';
import 'package:rewild/data_providers/pursued_data_provider/pursued_data_provider.dart';

import 'package:rewild/data_providers/secure_storage_data_provider.dart';
import 'package:rewild/data_providers/seller_data_provider/seller_data_provider.dart';
import 'package:rewild/data_providers/stock_data_provider.dart/stock_data_provider.dart';
import 'package:rewild/data_providers/supply_data_provider/supply_data_provider.dart';
import 'package:rewild/data_providers/warehouse_data_provider.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/domain/services/advert_service.dart';
import 'package:rewild/domain/services/all_cards_filter_service.dart';
import 'package:rewild/domain/services/api_keys_service.dart';
import 'package:rewild/domain/services/auth_service.dart';
import 'package:rewild/domain/services/auto_stat_service.dart';
import 'package:rewild/domain/services/card_of_product_service.dart';
import 'package:rewild/domain/services/commission_service.dart';
import 'package:rewild/domain/services/group_service.dart';
import 'package:rewild/domain/services/init_stock_service.dart';
import 'package:rewild/domain/services/internet_connection_checke.dart';
import 'package:rewild/domain/services/notificate_service.dart';

import 'package:rewild/domain/services/orders_history_service.dart';

import 'package:rewild/domain/services/seller_service.dart';
import 'package:rewild/domain/services/stock_service.dart';
import 'package:rewild/domain/services/supply_service.dart';
import 'package:rewild/domain/services/update_service.dart';

import 'package:rewild/domain/services/warehouse_service.dart';
import 'package:rewild/main.dart';
import 'package:rewild/presentation/add_group_screen/add_group_screen.dart';
import 'package:rewild/presentation/add_group_screen/add_group_screen_view_model.dart';
import 'package:rewild/presentation/all_adverts_screen/all_adverts_screen.dart';
import 'package:rewild/presentation/all_adverts_screen/all_adverts_screen_view_model.dart';
import 'package:rewild/presentation/all_cards_filter_screen/all_cards_filter_screen.dart';
import 'package:rewild/presentation/all_cards_filter_screen/all_cards_filter_screen_view_model.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/all_groups_screen/all_groups_screen.dart';
import 'package:rewild/presentation/all_groups_screen/all_groups_view_model.dart';
import 'package:rewild/presentation/api_keys_screen/api_keys_screen.dart';
import 'package:rewild/presentation/api_keys_screen/api_keys_view_model.dart';

import 'package:rewild/presentation/app/app.dart';
import 'package:rewild/presentation/auto_advert_screen/auto_advert_screen.dart';
import 'package:rewild/presentation/auto_advert_screen/auto_advert_view_model.dart';
import 'package:rewild/presentation/bottom_navigation_screen/bottom_navigation_screen.dart';
import 'package:rewild/presentation/bottom_navigation_screen/bottom_navigation_view_model.dart';
import 'package:rewild/presentation/single_group_screen/single_group_screen.dart';
import 'package:rewild/presentation/single_group_screen/single_groups_screen_view_model.dart';
import 'package:rewild/presentation/my_web_view/my_web_view.dart';
import 'package:rewild/presentation/my_web_view/my_web_view_screen_view_model.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';

import 'package:rewild/presentation/splash_screen/splash_screen.dart';
import 'package:rewild/presentation/splash_screen/splash_screen_view_model.dart';
import 'package:rewild/routes/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

AppFactory makeAppFactory() => _AppFactoryDefault();

class _AppFactoryDefault implements AppFactory {
  final _diContainer = _DIContainer();

  _AppFactoryDefault();
  @override
  Widget makeApp() {
    return App(
        navigation: _diContainer._makeAppNavigation(),
        streamControllers: [
          _diContainer.apiKeyExistsStreamController,
          _diContainer.cardsNumberStreamController,
          _diContainer.activeAdvertsStreamController
        ]);
  }
}

class _DIContainer {
  _DIContainer();

  // streams ===================================================================

  // Api Key Exist (AdvertService --> BottomNavigationViewModel)
  final apiKeyExistsStreamController = StreamController<bool>.broadcast();
  Stream<bool> get apiKeyExistsStream => apiKeyExistsStreamController.stream;

  // cards number (CardOfProductService --> BottomNavigationViewModel)
  final cardsNumberStreamController = StreamController<int>.broadcast();
  Stream<int> get cardsNumberStream => cardsNumberStreamController.stream;

  // Advert (AdvertService ---> BottomNavigationViewModel)
  final activeAdvertsStreamController =
      StreamController<List<Advert>>.broadcast();
  Stream<List<Advert>> get activeAdvertsStream =>
      activeAdvertsStreamController.stream;

  // Factorys ==================================================================
  ScreenFactory _makeScreenFactory() => ScreenFactoryDefault(this);
  AppNavigation _makeAppNavigation() => MainNavigation(_makeScreenFactory());

  // Api clients ===============================================================
  // auth
  AuthApiClient _makeAuthApiClient() => const AuthApiClient();

  // details
  DetailsApiClient _makeDetailsApiClient() => const DetailsApiClient();

  // seller
  SellerApiClient _makeSellerApiClient() => const SellerApiClient();

  // card
  CardOfProductApiClient _makeCardOfProductApiClient() =>
      const CardOfProductApiClient();

  // stock
  InitialStocksApiClient _makeStocksApiClient() =>
      const InitialStocksApiClient();

  // warehouse
  WarehouseApiClient _makeWarehouseApiClient() => const WarehouseApiClient();

  // commission
  CommissionApiClient _makeCommissionApiClient() => const CommissionApiClient();

  // orders history
  OrdersHistoryApiClient _makeOrdersHistoryApiClient() =>
      const OrdersHistoryApiClient();

  // advert
  AdvertApiClient _makeAdvertApiClient() => const AdvertApiClient();

  // Data providers ============================================================

  // secure storage
  SecureStorageProvider _makeSecureDataProvider() =>
      const SecureStorageProvider();

  // card
  CardOfProductDataProvider _makeCardOfProductDataProvider() =>
      const CardOfProductDataProvider();

  // initial stocks
  InitialStockDataProvider _makeInitialStockDataProvider() =>
      const InitialStockDataProvider();

  // Commission
  CommissionDataProvider _makeCommissionDataProvider() =>
      const CommissionDataProvider();

  // stocks
  StockDataProvider _makeStockDataProvider() => const StockDataProvider();

  // groups
  GroupDataProvider _makeGroupDataProvider() => const GroupDataProvider();

  // warehouse
  WarehouseDataProvider _makeWarehouseDataProvider() =>
      const WarehouseDataProvider();

  // supply
  SupplyDataProvider _makeSupplyDataProvider() => const SupplyDataProvider();

  // seller
  SellerDataProvider _makeSellerDataProvider() => const SellerDataProvider();

  // orders history
  OrdersHistoryDataProvider _makeOrdersHistoryDataProvider() =>
      const OrdersHistoryDataProvider();

  // last update
  LastUpdateDayDataProvider _makeLastUpdateDayDataProvider() =>
      const LastUpdateDayDataProvider();

  // filter
  FilterDataProvider _makeFilterDataProvider() => const FilterDataProvider();

  // auto stat
  AutoStatDataProvider _makeAutoStatDataProvider() =>
      const AutoStatDataProvider();

  // pursued
  PursuedDataProvider _makePursuedDataProvider() => const PursuedDataProvider();

  // notification
  NotificationDataProvider _makeNotificationDataProvider() =>
      const NotificationDataProvider();

  // Services ==================================================================

  // check internet connection
  InternetConnectionCheckerImpl _makeInternetConnectionChecker() =>
      const InternetConnectionCheckerImpl();

  // auth
  AuthServiceImpl _makeAuthService() => AuthServiceImpl(
      secureDataProvider: _makeSecureDataProvider(),
      authApiClient: _makeAuthApiClient());

  // Update service
  UpdateService _makeUpdateService() => UpdateService(
        cardOfProductApiClient: _makeCardOfProductApiClient(),
        detailsApiClient: _makeDetailsApiClient(),
        initialStockApiClient: _makeStocksApiClient(),
        supplyDataProvider: _makeSupplyDataProvider(),
        cardsNumberStreamController: cardsNumberStreamController,
        lastUpdateDayDataProvider: _makeLastUpdateDayDataProvider(),
        cardOfProductDataProvider: _makeCardOfProductDataProvider(),
        initialStockDataProvider: _makeInitialStockDataProvider(),
        stockDataProvider: _makeStockDataProvider(),
      );
  // card
  CardOfProductService _makeCardOfProductService() => CardOfProductService(
        warehouseApiClient: _makeWarehouseApiClient(),
        cardOfProductApiClient: _makeCardOfProductApiClient(),
        initStockDataProvider: _makeInitialStockDataProvider(),
        supplyDataProvider: _makeSupplyDataProvider(),
        stockDataprovider: _makeStockDataProvider(),
        warehouseDataprovider: _makeWarehouseDataProvider(),
        cardOfProductDataProvider: _makeCardOfProductDataProvider(),
      );

  // stocks
  StockService _makeStockService() => StockService(
        stocksDataProvider: _makeStockDataProvider(),
      );

  //  init stock
  InitialStockService _makeInitialStockService() => InitialStockService(
        initStockDataProvider: _makeInitialStockDataProvider(),
      );

  // warehouse
  WarehouseService _makeWarehouseService() => WarehouseService(
        warehouseApiClient: _makeWarehouseApiClient(),
        warehouseProvider: _makeWarehouseDataProvider(),
      );

  // groups
  GroupService _makeAllGroupsService() =>
      GroupService(groupDataProvider: _makeGroupDataProvider());

  // seller
  SellerService _makeSellerService() => SellerService(
        sellerApiClient: _makeSellerApiClient(),
        sellerDataProvider: _makeSellerDataProvider(),
      );

  // commission
  CommissionService _makeCommissionService() => CommissionService(
        commissionApiClient: _makeCommissionApiClient(),
        commissionDataProvider: _makeCommissionDataProvider(),
      );

  // supply
  SupplyService _makeSupplyService() => SupplyService(
        supplyDataProvider: _makeSupplyDataProvider(),
      );

  // orders history
  OrdersHistoryService _makeOrdersHistoryService() => OrdersHistoryService(
        ordersHistoryDataProvider: _makeOrdersHistoryDataProvider(),
        ordersHistoryApiClient: _makeOrdersHistoryApiClient(),
      );

  // filter
  AllCardsFilterService _makeAllCardsFilterService() => AllCardsFilterService(
        cardsOfProductsDataProvider: _makeCardOfProductDataProvider(),
        filterDataProvider: _makeFilterDataProvider(),
        sellerDataProvider: _makeSellerDataProvider(),
      );

  // Api keys
  ApiKeysService _makeApiKeysService() => ApiKeysService(
        apiKeysDataProvider: _makeSecureDataProvider(),
        apiKeyExistsStreamController: apiKeyExistsStreamController,
      );

  // advert
  AdvertService _makeAdvertService() => AdvertService(
      advertApiClient: _makeAdvertApiClient(),
      pursuitsDataProvider: _makePursuedDataProvider(),
      activeAdvertsStreamController: activeAdvertsStreamController,
      apiKeysDataProvider: _makeSecureDataProvider());

  // Auto stat
  AutoAdvertService _makeAutoStatService() => AutoAdvertService(
      advertApiClient: _makeAdvertApiClient(),
      apiKeysDataProvider: _makeSecureDataProvider(),
      autoStatDataProvider: _makeAutoStatDataProvider());

  // notification
  NotificationService _makeNotificationService() => NotificationService(
        notificationDataProvider: _makeNotificationDataProvider(),
      );

  // View models ===============================================================
  SplashScreenViewModel _makeSplashScreenViewModel(BuildContext context) =>
      SplashScreenViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          updateService: _makeUpdateService(),
          authService: _makeAuthService());

  AllCardsScreenViewModel _makeAllCardsScreenViewModel(context) =>
      AllCardsScreenViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          updateService: _makeUpdateService(),
          supplyService: _makeSupplyService(),
          groupsProvider: _makeAllGroupsService(),
          filterService: _makeAllCardsFilterService(),
          cardsOfProductsService: _makeCardOfProductService(),
          tokenProvider: _makeAuthService());

  MyWebViewScreenViewModel _makeMyWebViewScreenViewModel(context) =>
      MyWebViewScreenViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          updateService: _makeUpdateService(),
          tokenProvider: _makeAuthService());

  SingleCardScreenViewModel _makeSingleCardViewModel(
          BuildContext context, int id) =>
      SingleCardScreenViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          stockService: _makeStockService(),
          id: id,
          ordersHistoryService: _makeOrdersHistoryService(),
          commissionService: _makeCommissionService(),
          sellerService: _makeSellerService(),
          cardOfProductService: _makeCardOfProductService(),
          initialStocksService: _makeInitialStockService(),
          supplyService: _makeSupplyService(),
          warehouseService: _makeWarehouseService());

  AddGroupScreenViewModel _makeAddGroupScreenViewModel(
          BuildContext context, List<int> productsCardsIds) =>
      AddGroupScreenViewModel(
          context: context,
          groupsProvider: _makeAllGroupsService(),
          internetConnectionChecker: _makeInternetConnectionChecker(),
          productsCardsIds: productsCardsIds);

  SingleGroupScreenViewModel _makeSingleGroupScreenViewModel(
          BuildContext context, String name) =>
      SingleGroupScreenViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          name: name,
          groupService: _makeAllGroupsService(),
          sellerService: _makeSellerService(),
          cardsService: _makeCardOfProductService());

  AllGroupsScreenViewModel _makeAllGroupsScreenViewModel(
          BuildContext context) =>
      AllGroupsScreenViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          groupsProvider: _makeAllGroupsService());

  BottomNavigationViewModel _makeBottomNavigationViewModel(
          BuildContext context) =>
      BottomNavigationViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          advertsStream: activeAdvertsStream,
          cardsNumberStream: cardsNumberStream,
          apiKeyExistsStream: apiKeyExistsStream,
          advertService: _makeAdvertService(),
          cardService: _makeCardOfProductService());

  AllCardsFilterScreenViewModel _makeAllCardsFilterScreenViewModel(
          BuildContext context) =>
      AllCardsFilterScreenViewModel(
        context: context,
        internetConnectionChecker: _makeInternetConnectionChecker(),
        allCardsFilterService: _makeAllCardsFilterService(),
        commissionService: _makeCommissionService(),
        sellerService: _makeSellerService(),
      );

  ApiKeysScreenViewModel _makeApiKeysScreenViewModel(BuildContext context) =>
      ApiKeysScreenViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          apiKeysService: _makeApiKeysService());

  AllAdvertsScreenViewModel _makeAllAdvertsScreenViewModel(
          BuildContext context) =>
      AllAdvertsScreenViewModel(
        context: context,
        internetConnectionChecker: _makeInternetConnectionChecker(),
        cardOfProductService: _makeCardOfProductService(),
        advertService: _makeAdvertService(),
      );

  AutoAdvertViewModel _makeAutoStatAdvertScreenViewModel(
          BuildContext context, int advertId) =>
      AutoAdvertViewModel(
        context: context,
        advertId: advertId,
        advertService: _makeAdvertService(),
        autoStatService: _makeAutoStatService(),
        notificationService: _makeNotificationService(),
        internetConnectionChecker: _makeInternetConnectionChecker(),
      );
}

class ScreenFactoryDefault implements ScreenFactory {
  final _DIContainer _diContainer;

  // ignore: library_private_types_in_public_api
  const ScreenFactoryDefault(this._diContainer);

  @override
  Widget makeSplashScreen() {
    return ChangeNotifierProvider(
        create: (context) => _diContainer._makeSplashScreenViewModel(context),
        child: const SplashScreen());
  }

  @override
  Widget makeBottomNavigationScreen(int num) {
    return ChangeNotifierProvider(
        create: (context) =>
            _diContainer._makeBottomNavigationViewModel(context),
        child: const BottomNavigationScreen());
  }

  @override
  Widget makeAllCardsScreen() {
    return ChangeNotifierProvider(
        create: (context) => _diContainer._makeAllCardsScreenViewModel(context),
        child: const AllCardsScreen());
  }

  @override
  Widget makeSingleGroupScreen(String name) {
    return ChangeNotifierProvider(
        create: (context) =>
            _diContainer._makeSingleGroupScreenViewModel(context, name),
        child: const SingleGroupScreen());
  }

  @override
  Widget makeApiKeysScreen() {
    return ChangeNotifierProvider(
        create: (context) => _diContainer._makeApiKeysScreenViewModel(context),
        child: const ApiKeysScreen());
  }

  // @override
  // Widget makeSingleSellerScreen(int supplierID) {
  //   return ChangeNotifierProvider(
  //       create: (context) =>
  //           _diContainer._makeSingleSellerScreenViewModel(context, supplierID),
  //       child: const SingleSellerScreen());
  // }

  @override
  Widget makeMyWebViewScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeMyWebViewScreenViewModel(context),
      child: const MyWebViewScreen(),
    );
  }

  @override
  Widget makeSingleCardScreen(int id) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeSingleCardViewModel(context, id),
      child: const SingleCardScreen(),
    );
  }

  @override
  Widget makeAddGroupsScreen(List<int> productsCardsIds) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeAddGroupScreenViewModel(context, productsCardsIds),
      child: const AddGroupScreen(),
    );
  }

  @override
  Widget makeAllGroupsScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeAllGroupsScreenViewModel(context),
      child: const AllGroupsScreen(),
    );
  }

  @override
  Widget makeAllCardsFilterScreen() {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeAllCardsFilterScreenViewModel(context),
      child: const AllCardsFilterScreen(),
    );
  }

  @override
  Widget makeAllAdvertsScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeAllAdvertsScreenViewModel(context),
      child: const AllAdvertsScreen(),
    );
  }

  @override
  Widget makeAutoStatAdvertScreen(int id) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeAutoStatAdvertScreenViewModel(context, id),
      child: const AutoAdvertScreen(),
    );
  }
}
