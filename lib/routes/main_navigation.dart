import 'package:rewild/presentation/app/app.dart';
import 'package:flutter/material.dart';

import 'main_navigation_route_names.dart';

abstract class ScreenFactory {
  Widget makeSplashScreen();
  Widget makeBottomNavigationScreen(int num);
  Widget makeMyWebViewScreen();
  Widget makeApiKeysScreen();
  Widget makeAllCardsScreen();
  Widget makeAllCardsFilterScreen();
  Widget makeAllGroupsScreen();
  // Widget makeAllSellersScreen();
  Widget makeSingleGroupScreen(String name);
  Widget makeSingleCardScreen(int id);
  // Widget makeSingleSellerScreen(int supplierId);
  Widget makeAddGroupsScreen(List<int> cardsIds);
  Widget makeAllAdvertsScreen();
}

class MainNavigation implements AppNavigation {
  final ScreenFactory screenFactory;

  const MainNavigation(this.screenFactory);
  @override
  Map<String, Widget Function(BuildContext)> get routes => {
        MainNavigationRouteNames.splashScreen: (_) =>
            screenFactory.makeSplashScreen(),
        // MainNavigationRouteNames.bottomNavigationScreen: () =>
        //     screenFactory.makeBottomNavigationScreen(num),
        MainNavigationRouteNames.allCardsScreen: (_) =>
            screenFactory.makeAllCardsScreen(),
        MainNavigationRouteNames.myWebViewScreen: (_) =>
            screenFactory.makeMyWebViewScreen(),
      };

  @override
  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRouteNames.singleCardScreen:
        final arguments = settings.arguments;
        final cardId = arguments is int ? arguments : 0;
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                screenFactory.makeSingleCardScreen(cardId),
            // transitionDuration: const Duration(seconds: 2),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            settings: settings);
      case MainNavigationRouteNames.addGroupsScreen:
        final arguments = settings.arguments;
        final productsCardsIds = arguments is List<int> ? arguments : <int>[];
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAddGroupsScreen(productsCardsIds),
        );

      case MainNavigationRouteNames.bottomNavigationScreen:
        final arguments = settings.arguments;
        final num = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeBottomNavigationScreen(num),
        );

      case MainNavigationRouteNames.singleGroupScreen:
        final arguments = settings.arguments;
        final groupName = arguments is String ? arguments : "";
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeSingleGroupScreen(groupName),
        );

      case MainNavigationRouteNames.apiKeysScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeApiKeysScreen(),
        );

      // case MainNavigationRouteNames.singleSellerScreen:
      //   final arguments = settings.arguments;
      //   final supplierId = arguments is int ? arguments : 0;
      //   return MaterialPageRoute(
      //     builder: (_) => screenFactory.makeSingleSellerScreen(supplierId),
      //   );

      case MainNavigationRouteNames.allGroupsScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllGroupsScreen(),
        );

      case MainNavigationRouteNames.allAdvertsScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllAdvertsScreen(),
        );
      // case MainNavigationRouteNames.allSellersScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => screenFactory.makeAllSellersScreen(),
      //   );

      case MainNavigationRouteNames.allCardsFilterScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllCardsFilterScreen(),
        );

      default:
        const widget = Text('Navigation error!!!');
        return MaterialPageRoute(builder: (_) => widget);
    }
  }
}
