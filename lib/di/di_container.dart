import 'dart:async';

import 'package:rewild/api_clients/advert_api_client.dart';
import 'package:rewild/api_clients/auth_service_api_client.dart';
import 'package:rewild/api_clients/commision_api_client.dart';
import 'package:rewild/api_clients/details_api_client.dart';

import 'package:rewild/api_clients/orders_history_api_client.dart';

import 'package:rewild/api_clients/product_card_service_api_client.dart';
import 'package:rewild/api_clients/questions_api_client.dart';
import 'package:rewild/api_clients/reviews_api_client.dart';
import 'package:rewild/api_clients/seller_api_client.dart';
import 'package:rewild/api_clients/initial_stocks_api_client.dart';
import 'package:rewild/api_clients/warehouse_api_client.dart';
import 'package:rewild/data_providers/advert_stat_data_provider/advert_stat_data_provider.dart';
import 'package:rewild/data_providers/answer_data_provider/answer_data_provider.dart';
import 'package:rewild/data_providers/background_message_data_provider/background_message_data_provider.dart';

import 'package:rewild/data_providers/card_of_product_data_provider/card_of_product_data_provider.dart';
import 'package:rewild/data_providers/commission_data_provider/commission_data_provider.dart';
import 'package:rewild/data_providers/filter_data_provider/filter_data_provider.dart';

import 'package:rewild/data_providers/group_data_provider/group_data_provider.dart';
import 'package:rewild/data_providers/initial_stocks_data_provider/initial_stocks_data_provider.dart';
import 'package:rewild/data_providers/keyword_data_provider/keyword_data_provider.dart';
import 'package:rewild/data_providers/last_update_day_data_provider.dart';
import 'package:rewild/data_providers/notificate_data_provider/notification_data_provider.dart';
import 'package:rewild/data_providers/orders_history_data_provider/orders_history_data_provider.dart';

import 'package:rewild/data_providers/secure_storage_data_provider.dart';
import 'package:rewild/data_providers/seller_data_provider/seller_data_provider.dart';
import 'package:rewild/data_providers/stock_data_provider.dart/stock_data_provider.dart';
import 'package:rewild/data_providers/supply_data_provider/supply_data_provider.dart';
import 'package:rewild/data_providers/warehouse_data_provider.dart';
import 'package:rewild/domain/entities/question_model.dart';

import 'package:rewild/domain/entities/stream_advert_event.dart';
import 'package:rewild/domain/entities/stream_notification_event.dart';
import 'package:rewild/domain/services/advert_service.dart';
import 'package:rewild/domain/services/all_cards_filter_service.dart';
import 'package:rewild/domain/services/answer_service.dart';
import 'package:rewild/domain/services/api_keys_service.dart';
import 'package:rewild/domain/services/auth_service.dart';
import 'package:rewild/domain/services/advert_stat_service.dart';
import 'package:rewild/domain/services/background_message_service.dart';
import 'package:rewild/domain/services/card_of_product_service.dart';
import 'package:rewild/domain/services/commission_service.dart';
import 'package:rewild/domain/services/group_service.dart';
import 'package:rewild/domain/services/init_stock_service.dart';
import 'package:rewild/domain/services/internet_connection_checke.dart';
import 'package:rewild/domain/services/keywords_service.dart';
import 'package:rewild/domain/services/notification_service.dart';

import 'package:rewild/domain/services/orders_history_service.dart';
import 'package:rewild/domain/services/question_service.dart';
import 'package:rewild/domain/services/review_service.dart';

import 'package:rewild/domain/services/seller_service.dart';
import 'package:rewild/domain/services/stock_service.dart';
import 'package:rewild/domain/services/supply_service.dart';
import 'package:rewild/domain/services/update_service.dart';

import 'package:rewild/domain/services/warehouse_service.dart';
import 'package:rewild/main.dart';
import 'package:rewild/presentation/add_group_screen/add_group_screen.dart';
import 'package:rewild/presentation/add_group_screen/add_group_screen_view_model.dart';
import 'package:rewild/presentation/all_products_reviews_screen/all_products_reviews_screen.dart';
import 'package:rewild/presentation/all_products_reviews_screen/all_products_reviews_view_model.dart';
import 'package:rewild/presentation/all_questions_screen/all_questions_screen.dart';
import 'package:rewild/presentation/all_questions_screen/all_questions_view_model.dart';
import 'package:rewild/presentation/first_start_splash_screen/first_start_splash_screen.dart';
import 'package:rewild/presentation/notification_advert_screen/notification_advert_screen.dart';
import 'package:rewild/presentation/notification_advert_screen/notification_advert_view_model.dart';
import 'package:rewild/presentation/all_adverts_words_screen/all_adverts_words_view_model.dart';
import 'package:rewild/presentation/all_adverts_stat_screen/all_adverts_stat_screen.dart';
import 'package:rewild/presentation/all_adverts_stat_screen/all_adverts_stat_screen_view_model.dart';
import 'package:rewild/presentation/all_adverts_words_screen/all_adverts_words_screen.dart';
import 'package:rewild/presentation/all_cards_filter_screen/all_cards_filter_screen.dart';
import 'package:rewild/presentation/all_cards_filter_screen/all_cards_filter_screen_view_model.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen.dart';
import 'package:rewild/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/all_groups_screen/all_groups_screen.dart';
import 'package:rewild/presentation/all_groups_screen/all_groups_view_model.dart';
import 'package:rewild/presentation/add_api_keys_screen/add_api_keys_screen.dart';
import 'package:rewild/presentation/add_api_keys_screen/add_api_keys_view_model.dart';

import 'package:rewild/presentation/app/app.dart';
import 'package:rewild/presentation/all_products_questions_screen/all_products_questions_view_model.dart';
import 'package:rewild/presentation/all_products_questions_screen/all_products_questions_screen.dart';
import 'package:rewild/presentation/single_auto_words_screen/single_auto_words_screen.dart';
import 'package:rewild/presentation/single_auto_words_screen/single_auto_words_view_model.dart';
import 'package:rewild/presentation/background_messages_screen/background_messages_screen.dart';
import 'package:rewild/presentation/background_messages_screen/background_messages_view_model.dart';

import 'package:rewild/presentation/notification_card_screen/notification_card_screen.dart';
import 'package:rewild/presentation/notification_card_screen/notification_card_view_model.dart';
import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_screen.dart';
import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';
import 'package:rewild/presentation/main_navigation_screen/main_navigation_screen.dart';
import 'package:rewild/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild/presentation/single_group_screen/single_group_screen.dart';
import 'package:rewild/presentation/single_group_screen/single_groups_screen_view_model.dart';
import 'package:rewild/presentation/my_web_view/my_web_view.dart';
import 'package:rewild/presentation/my_web_view/my_web_view_screen_view_model.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen.dart';
import 'package:rewild/presentation/single_card_screen/single_card_screen_view_model.dart';
import 'package:rewild/presentation/single_question_screen/single_question_view_model.dart';
import 'package:rewild/presentation/single_question_screen/single_question_screen.dart';
import 'package:rewild/presentation/single_search_words_screen/single_search_words_screen.dart';
import 'package:rewild/presentation/single_search_words_screen/single_search_words_view_model.dart';

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
        appMessagesService: _diContainer.makeBackgroundMessageService(),
        streamControllers: [
          _diContainer.apiKeyExistsStreamController,
          _diContainer.cardsNumberStreamController,
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

  // Advert (AdvertService ---> MainNavigationViewModel) (AdvertService ---> AllAdvertsStatScreenViewModel)
  final updatedAdvertStreamController =
      StreamController<StreamAdvertEvent>.broadcast();
  Stream<StreamAdvertEvent> get updatedAdvertStream =>
      updatedAdvertStreamController.stream;

  // Notification (NotificationService ---> ???)
  final updatedNotificationStreamController =
      StreamController<StreamNotificationEvent>.broadcast();
  Stream<StreamNotificationEvent> get updatedNotificationStream =>
      updatedNotificationStreamController.stream;

  // Factories ==================================================================
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

  QuestionsApiClient _makeQuestionsApiClient() => const QuestionsApiClient();

  ReviewApiClient _makeReviewApiClient() => const ReviewApiClient();
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
  AdvertStatDataProvider _makeAutoStatDataProvider() =>
      const AdvertStatDataProvider();

  // background messages
  BackgroundMessageDataProvider _makeBackgroundMessageDataProvider() =>
      const BackgroundMessageDataProvider();

  // notification
  NotificationDataProvider _makeNotificationDataProvider() =>
      const NotificationDataProvider();

  // keywords
  KeywordDataProvider _makeKeywordsDataProvider() =>
      const KeywordDataProvider();

  // Answers
  AnswerDataProvider _makeAnswerDataProvider() => const AnswerDataProvider();

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
        advertStatDataProvider: _makeAutoStatDataProvider(),
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

  // Advert
  AdvertService _makeAdvertService() => AdvertService(
      advertApiClient: _makeAdvertApiClient(),
      updatedAdvertStreamController: updatedAdvertStreamController,
      apiKeysDataProvider: _makeSecureDataProvider());

  QuestionService _makeQuestionService() => QuestionService(
      questionApiClient: _makeQuestionsApiClient(),
      apiKeysDataProvider: _makeSecureDataProvider());

  ReviewService _makeReviewService() => ReviewService(
        reviewApiClient: _makeReviewApiClient(),
        apiKeysDataProvider: _makeSecureDataProvider(),
      );

  // Auto stat
  AdvertStatService _makeAutoStatService() => AdvertStatService(
      advertApiClient: _makeAdvertApiClient(),
      apiKeysDataProvider: _makeSecureDataProvider(),
      autoStatDataProvider: _makeAutoStatDataProvider());

  // Notification
  NotificationService _makeNotificationService() => NotificationService(
        notificationDataProvider: _makeNotificationDataProvider(),
        updatedNotificationStreamController:
            updatedNotificationStreamController,
      );

  // Background message
  BackgroundMessageService makeBackgroundMessageService() =>
      BackgroundMessageService(
          backgroundMessageDataProvider: _makeBackgroundMessageDataProvider());

  // Keyword
  KeywordsService _makeKeywordsService() => KeywordsService(
      advertApiClient: _makeAdvertApiClient(),
      keywordsDataProvider: _makeKeywordsDataProvider(),
      apiKeysDataProvider: _makeSecureDataProvider());

  // Answer
  AnswerService _makeAnswerService() => AnswerService(
        answerDataProvider: _makeAnswerDataProvider(),
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
          notificationsService: _makeNotificationService(),
          streamNotification: updatedNotificationStream,
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
          notificationService: _makeNotificationService(),
          cardOfProductService: _makeCardOfProductService(),
          initialStocksService: _makeInitialStockService(),
          supplyService: _makeSupplyService(),
          streamNotification: updatedNotificationStream,
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
          warehouseService: _makeWarehouseService(),
          sellerService: _makeSellerService(),
          cardsService: _makeCardOfProductService());

  AllGroupsScreenViewModel _makeAllGroupsScreenViewModel(
          BuildContext context) =>
      AllGroupsScreenViewModel(
          context: context,
          updateService: _makeUpdateService(),
          internetConnectionChecker: _makeInternetConnectionChecker(),
          groupsProvider: _makeAllGroupsService());

  MainNavigationViewModel _makeBottomNavigationViewModel(
          BuildContext context) =>
      MainNavigationViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          updatedAdvertStream: updatedAdvertStream,
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

  AddApiKeysScreenViewModel _makeApiKeysScreenViewModel(BuildContext context) =>
      AddApiKeysScreenViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          apiKeysService: _makeApiKeysService());

  AllAdvertsStatScreenViewModel _makeAllAdvertsScreenViewModel(
          BuildContext context) =>
      AllAdvertsStatScreenViewModel(
        context: context,
        internetConnectionChecker: _makeInternetConnectionChecker(),
        cardOfProductService: _makeCardOfProductService(),
        updatedAdvertStream: updatedAdvertStream,
        advertService: _makeAdvertService(),
      );

  SingleAdvertStatsViewModel _makeAutoStatAdvertScreenViewModel(
          BuildContext context, int campaignId) =>
      SingleAdvertStatsViewModel(
        context: context,
        campaignId: campaignId,
        advertService: _makeAdvertService(),
        advertStatService: _makeAutoStatService(),
        notificationService: _makeNotificationService(),
        streamNotification: updatedNotificationStream,
        internetConnectionChecker: _makeInternetConnectionChecker(),
      );

  CardNotificationViewModel _makeCardNotificationSettingsViewModel(
          BuildContext context, NotificationCardState state) =>
      CardNotificationViewModel(state,
          notificationService: _makeNotificationService(),
          internetConnectionChecker: _makeInternetConnectionChecker(),
          context: context);

  SingleAutoWordsViewModel _makeAutoStatWordsViewModel(
          BuildContext context, int campaignId) =>
      SingleAutoWordsViewModel(campaignId,
          context: context,
          advertService: _makeAdvertService(),
          internetConnectionChecker: _makeInternetConnectionChecker(),
          keywordService: _makeKeywordsService());

  SingleSearchWordsViewModel _makeSearchStatWordsViewModel(
          BuildContext context, int campaignId) =>
      SingleSearchWordsViewModel(campaignId,
          context: context,
          advertService: _makeAdvertService(),
          internetConnectionChecker: _makeInternetConnectionChecker(),
          keywordService: _makeKeywordsService());

  AllAdvertsWordsViewModel _makeAdvertsToolsViewModel(BuildContext context) =>
      AllAdvertsWordsViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          cardOfProductService: _makeCardOfProductService(),
          advertService: _makeAdvertService());

  NotificationAdvertViewModel _makeAdvertNotificationViewModel(
          BuildContext context, NotificationAdvertState state) =>
      NotificationAdvertViewModel(state,
          context: context,
          notificationService: _makeNotificationService(),
          internetConnectionChecker: _makeInternetConnectionChecker());

  BackgroundMessagesViewModel _makeBackgroundNotificationsViewModel(
          BuildContext context) =>
      BackgroundMessagesViewModel(
          context: context,
          notificationService: _makeNotificationService(),
          internetConnectionChecker: _makeInternetConnectionChecker(),
          messageService: makeBackgroundMessageService());

  AllProductsQuestionsViewModel _makeQuestionsViewModel(BuildContext context) =>
      AllProductsQuestionsViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          cardOfProductService: _makeCardOfProductService(),
          questionService: _makeQuestionService());

  AllProductsReviewsViewModel _makeReviewsViewModel(BuildContext context) =>
      AllProductsReviewsViewModel(
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          cardOfProductService: _makeCardOfProductService(),
          reviewService: _makeReviewService());

  AllQuestionsViewModel _makeAllQuestionsViewModel(
          BuildContext context, int nmId) =>
      AllQuestionsViewModel(nmId,
          context: context,
          internetConnectionChecker: _makeInternetConnectionChecker(),
          answerService: _makeAnswerService(),
          questionService: _makeQuestionService());
  SingleQuestionViewModel _makeSingleQuestionViewModel(
          BuildContext context, QuestionModel question) =>
      SingleQuestionViewModel(
        question,
        context: context,
        answerService: _makeAnswerService(),
        questionService: _makeQuestionService(),
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
  Widget makeFirstTimeSplashScreen() {
    return ChangeNotifierProvider(
        create: (context) => _diContainer._makeSplashScreenViewModel(context),
        child: const FirstStartSplashScreen());
  }

  @override
  Widget makeBottomNavigationScreen() {
    return ChangeNotifierProvider(
        create: (context) =>
            _diContainer._makeBottomNavigationViewModel(context),
        child: const MainNavigationScreen());
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
        child: const AddApiKeysScreen());
  }

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
      child: const AllAdvertsStatScreen(),
    );
  }

  @override
  Widget makeSingleStatAdvertScreen(int id) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeAutoStatAdvertScreenViewModel(context, id),
      child: const SingleAdvertStatsScreen(),
    );
  }

  @override
  Widget makeAdvertsToolsScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeAdvertsToolsViewModel(context),
      child: const AllAdvertsWordsScreen(),
    );
  }

  @override
  Widget makeAutoStatsWordsScreen(int id) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeAutoStatWordsViewModel(context, id),
      child: const SingleAutoWordsScreen(),
    );
  }

  @override
  Widget makeSearchStatsWordsScreen(int id) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeSearchStatWordsViewModel(context, id),
      child: const SingleSearchWordsScreen(),
    );
  }

  @override
  Widget makeCardNotificationsSettingsScreen(NotificationCardState state) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeCardNotificationSettingsViewModel(context, state),
      child: const NotificationCardSettingsScreen(),
    );
  }

  @override
  Widget makeAdvertNotificationScreen(NotificationAdvertState state) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeAdvertNotificationViewModel(context, state),
      child: const NotificationAdvertSettingsScreen(),
    );
  }

  @override
  Widget makeBackgroundNotificationsScreen() {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeBackgroundNotificationsViewModel(context),
      child: const BackgroundMessagesScreen(),
    );
  }

  @override
  Widget makeAllProductsQuestionsScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeQuestionsViewModel(context),
      child: const AllProductsQuestionsScreen(),
    );
  }

  @override
  Widget makeAllProductsReviewsScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeReviewsViewModel(context),
      child: const AllProductsReviewsScreen(),
    );
  }

  @override
  Widget makeAllQuestionsScreen(int nmId) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeAllQuestionsViewModel(context, nmId),
      child: const AllQuestionsScreen(),
    );
  }

  @override
  Widget makeSingleQuestionScreen(QuestionModel question) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeSingleQuestionViewModel(context, question),
      child: const SingleQuestionScreen(),
    );
  }
}
