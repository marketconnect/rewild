import 'dart:async';

import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/theme/color_schemes.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppNavigation {
  Map<String, Widget Function(BuildContext)> get routes;
  Route<Object> onGenerateRoute(RouteSettings settings);
}

class App extends StatefulWidget {
  final AppNavigation navigation;
  final List<StreamController> streamControllers;
  const App({
    super.key,
    required this.navigation,
    required this.streamControllers,
  });

  @override
  State<App> createState() => _AppState();
}

// This widget is the root of the application.
class _AppState extends State<App> {
  @override
  Future<void> dispose() async {
    // close every streamControllers

    for (var element in widget.streamControllers) {
      await element.close();
    }
    super.dispose();
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
