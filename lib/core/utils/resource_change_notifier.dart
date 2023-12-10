import 'package:flutter/material.dart';
import 'package:rewild/core/utils/resource.dart';

import 'package:rewild/widgets/alert_widget.dart';

abstract class InternetConnectionChecker {
  Future<bool> checkInternetConnection();
}

class ResourceChangeNotifier extends ChangeNotifier {
  final BuildContext context;
  final InternetConnectionChecker internetConnectionChecker;

  late final Size _screenSize = MediaQuery.of(context).size;
  double get screenWidth => _screenSize.width;
  double get screenHeight => _screenSize.height;
  ResourceChangeNotifier(
      {required this.context, required this.internetConnectionChecker}) {
    _asyncInit();
  }

  bool isConnected = false;

  void _asyncInit() async {
    isConnected = await internetConnectionChecker.checkInternetConnection();
    if (!context.mounted) {
      return;
    }
    if (!isConnected) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AlertWidget(
              errorType: ErrorType.network,
            ),
          ));
    }
  }

  bool _external = false;
  late bool _loading = true;
  void setLoading(bool value) {
    _external = true;
    _loading = value;
    notifyListeners();
  }

  bool get loading => _loading;

  void notify() {
    if (context.mounted) {
      if (!_external) {
        _loading = false;
      }
      notifyListeners();
    }
  }

  Future<T?> fetch<T>(Future<Resource<T>> Function() callBack) async {
    final resource = await callBack();
    if (resource is Error && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(resource.message!),
      ));
      notify();
      return null;
    }
    return resource.data;
  }
}
