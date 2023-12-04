// onPopInvoked
import 'package:flutter/material.dart';

import 'package:rewild/routes/main_navigation_route_names.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 1 millisecond and then navigate to another screen
    Future.delayed(const Duration(milliseconds: 1), () {
      Navigator.of(context).pushNamed(MainNavigationRouteNames.splashScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF18191d),
    );
  }
}
