// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

abstract class SplashScreenViewModelAuthService {
  Future<Resource<String>> getToken();
  Future<Resource<bool>> isLogined();
}

abstract class SplashScreenViewModelUpdateService {
  Future<Resource<void>> fetchAllUserCardsFromServer(String token);
}

class SplashScreenViewModel extends ResourceChangeNotifier {
  final SplashScreenViewModelUpdateService updateService;

  final SplashScreenViewModelAuthService authService;

  String? _token;
  bool firstTime = true;
  SplashScreenViewModel({
    required super.context,
    required super.internetConnectionChecker,
    required this.updateService,
    required this.authService,
  }) {
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    await auth();
  }

  Future auth() async {
    final token = await fetch(() => authService.getToken());
    if (token == null) {
      return;
    }
    _token = token;
    await _checkAuth();
    if (context.mounted) {
      // final route = firstTime
      // ? MainNavigationRouteNames.firstStartSplashScreen
      // : MainNavigationRouteNames.mainNavigationScreen;
      Navigator.of(context)
          .pushReplacementNamed(MainNavigationRouteNames.mainNavigationScreen);
    }
  }

  Future<void> reload() async {
    if (context.mounted && !isConnected) {
      await _asyncInit();
    }
  }

  Future<void> _checkAuth() async {
    final isAuth = await fetch(() => authService.isLogined());
    if (isAuth == null) {
      return;
    }

    if (isAuth) {
      if (_token != null) {
        await fetch(() => updateService.fetchAllUserCardsFromServer(_token!));
      }
    }
  }
}
