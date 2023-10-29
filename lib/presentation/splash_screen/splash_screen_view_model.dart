// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

abstract class SplashScreenViewModelAuthService {
  Future<Resource<String>> getToken();
  Future<Resource<bool>> isLogined();
}

abstract class SplashScreenViewModelUpdateService {
  Future<Resource<void>> fetchAllUserCardsFromServer(String token);
}

class SplashScreenViewModel extends ChangeNotifier {
  final BuildContext context;
  final SplashScreenViewModelUpdateService updateService;

  final SplashScreenViewModelAuthService authService;

  // Loading
  // bool _isLoading = false;
  // bool get isLoading => _isLoading;

  String? _token;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  SplashScreenViewModel({
    required this.context,
    required this.updateService,
    required this.authService,
  }) {
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    await auth();
  }

  Future auth() async {
    // _isLoading = true;
    // notifyListeners();

    final tokenResource = await authService.getToken();
    if (tokenResource is Error) {
      _errorMessage = tokenResource.message;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        _errorMessage!,
      )));
    }
    _token = tokenResource.data;
    await _checkAuth();
    Navigator.of(context)
        .pushReplacementNamed(MainNavigationRouteNames.bottomNavigationScreen);
    // _isLoading = false;
    // notifyListeners();
  }

  Future<void> _checkAuth() async {
    final isAuthResource = await authService.isLogined();
    if (isAuthResource is Error) {
      _errorMessage = isAuthResource.message;
    }
    if (isAuthResource is Success) {
      final isAuth = isAuthResource.data!;
      if (isAuth) {
        if (_token != null) {
          await updateService.fetchAllUserCardsFromServer(_token!);
        }
      }
    }
  }
}
