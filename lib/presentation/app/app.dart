import 'dart:async';

import 'package:fpdart/fpdart.dart' as fp;
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/theme/color_schemes.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppNavigation {
  Map<String, Widget Function(BuildContext)> get routes;
  Route<Object> onGenerateRoute(RouteSettings settings);
}

abstract class AppMessagesService {
  // State is used in the fpdart library also
  Future<fp.Either<RewildError, bool>> isNotEmpty();
}

class App extends StatefulWidget {
  final AppNavigation navigation;
  final AppMessagesService appMessagesService;
  final List<StreamController> streamControllers;
  const App({
    super.key,
    required this.navigation,
    required this.appMessagesService,
    required this.streamControllers,
  });

  @override
  State<App> createState() => _AppState();
}

// This widget is the root of the application.
class _AppState extends State<App> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  Future<void> dispose() async {
    // close every streamControllers
    for (final element in widget.streamControllers) {
      await element.close();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("app in resumed");
        final either = await widget.appMessagesService.isNotEmpty();
        final messagesIsNotEmpty = either.getOrElse((l) => false);
        if (either.isRight() && messagesIsNotEmpty) {
          if (navigatorKey.currentContext != null &&
              navigatorKey.currentContext!.mounted) {
            Navigator.of(navigatorKey.currentContext!).pushNamed(
                MainNavigationRouteNames.backgroundNotificationsScreen);
          }
        }
        break;

      case AppLifecycleState.inactive:
        debugPrint("app in inactive");

        break;
      case AppLifecycleState.paused:
        debugPrint("app in paused");

        break;
      case AppLifecycleState.detached:
        debugPrint("app in detached");

        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(
        Theme.of(context).colorScheme.surface);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);

    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          fontFamily: GoogleFonts.roboto().fontFamily),
      debugShowCheckedModeBanner: false,
      title: 'ReWild',
      routes: widget.navigation.routes,
      initialRoute: MainNavigationRouteNames.splashScreen,
      onGenerateRoute: widget.navigation.onGenerateRoute,
    );
  }
}
