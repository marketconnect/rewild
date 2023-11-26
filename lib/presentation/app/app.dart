import 'dart:async';

import 'package:rewild/core/utils/resource.dart';
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
  Future<Resource<bool>> isNotEmpty();
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
        final resource = await widget.appMessagesService.isNotEmpty();
        if (resource is Success && resource.data!) {
          Navigator.of(context).pushNamed(
              MainNavigationRouteNames.backgroundNotificationsScreen);
        }

        break;
      case AppLifecycleState.inactive:
        debugPrint("app in inactive");
        // mountedCallback!(false);
        break;
      case AppLifecycleState.paused:
        debugPrint("app in paused");
        // mountedCallback!(false);
        break;
      case AppLifecycleState.detached:
        debugPrint("app in detached");
        // mountedCallback!(false);
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
