import 'package:rewild/presentation/notification_advert_screen/notification_advert_view_model.dart';
import 'package:rewild/presentation/app/app.dart';
import 'package:flutter/material.dart';
import 'package:rewild/presentation/notification_card_screen/notification_card_view_model.dart';

import 'main_navigation_route_names.dart';

abstract class ScreenFactory {
  Widget makeAdvertNotificationScreen(NotificationAdvertState state);
  Widget makeAddGroupsScreen(List<int> cardsIds);
  Widget makeAllAdvertsScreen();
  Widget makeAllCardsFilterScreen();
  Widget makeAllCardsScreen();
  Widget makeAllGroupsScreen();
  Widget makeApiKeysScreen();
  Widget makeAutoStatsWordsScreen(int id);
  Widget makeBottomNavigationScreen(int num);
  Widget makeCardNotificationsSettingsScreen(NotificationCardState state);
  Widget makeSplashScreen();
  Widget makeMyWebViewScreen();
  Widget makeAdvertsToolsScreen();
  Widget makeSingleGroupScreen(String name);
  Widget makeSingleCardScreen(int id);
  Widget makeSingleStatAdvertScreen(int id);
  Widget makeBackgroundNotificationsScreen();
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
        // MainNavigationRouteNames.allCardsScreen: (_) =>
        //     screenFactory.makeAllCardsScreen(),
        // MainNavigationRouteNames.myWebViewScreen: (_) =>
        //     screenFactory.makeMyWebViewScreen(),
      };

  @override
  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRouteNames.backgroundNotificationsScreen:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                screenFactory.makeBackgroundNotificationsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            settings: settings);

      case MainNavigationRouteNames.myWebViewScreen:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                screenFactory.makeMyWebViewScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            settings: settings);
      case MainNavigationRouteNames.allCardsFilterScreen:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                screenFactory.makeAllCardsFilterScreen(),
            // transitionDuration: const Duration(seconds: 2),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            settings: settings);
      case MainNavigationRouteNames.allCardsScreen:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                screenFactory.makeAllCardsScreen(),
            // transitionDuration: const Duration(seconds: 2),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            settings: settings);
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
      case MainNavigationRouteNames.singleAdvertStatsScreen:
        final arguments = settings.arguments;
        final advertId = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeSingleStatAdvertScreen(advertId),
        );
      case MainNavigationRouteNames.allAdvertsToolsScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAdvertsToolsScreen(),
        );
      case MainNavigationRouteNames.cardNotificationsSettingsScreen:
        final arguments = settings.arguments;
        final state = arguments is NotificationCardState
            ? arguments
            : NotificationCardState.empty();

        return MaterialPageRoute(
          builder: (_) =>
              screenFactory.makeCardNotificationsSettingsScreen(state),
        );
      case MainNavigationRouteNames.allGroupsScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllGroupsScreen(),
        );

      case MainNavigationRouteNames.allAdvertsScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllAdvertsScreen(),
        );
      case MainNavigationRouteNames.autoStatWordsScreen:
        final arguments = settings.arguments;
        final advertId = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAutoStatsWordsScreen(advertId),
        );

      // case MainNavigationRouteNames.allCardsFilterScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => screenFactory.makeAllCardsFilterScreen(),
      //   );

      case MainNavigationRouteNames.advertNotificationScreen:
        final arguments = settings.arguments;
        final state = arguments is NotificationAdvertState
            ? arguments
            : NotificationAdvertState.empty();
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAdvertNotificationScreen(state),
        );

      default:
        const widget = Text('Navigation error!!!');
        return MaterialPageRoute(builder: (_) => widget);
    }
  }
}
