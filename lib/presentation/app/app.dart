import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/theme/color_schemes.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';

abstract class AppNavigation {
  Map<String, Widget Function(BuildContext)> get routes;
  Route<Object> onGenerateRoute(RouteSettings settings);
}

class App extends StatelessWidget {
  final AppNavigation navigation;
  const App({
    super.key,
    required this.navigation,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(
        Theme.of(context).colorScheme.surface);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          fontFamily: 'Poppins'),
      debugShowCheckedModeBanner: false,
      title: 'ReWild',
      routes: navigation.routes,
      initialRoute: MainNavigationRouteNames.splashScreen,
      onGenerateRoute: navigation.onGenerateRoute,
    );
  }
}
