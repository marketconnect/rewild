import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';

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
    if (!context.mounted) {
      return;
    }
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

  Future<T?> fetch<T>(
      Future<Either<RewildError, T>> Function() callBack) async {
    final resource = await callBack();
    T t;
    resource.fold((l) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.message!),
        ));
      }
    }, (r) => t = r);
  }

  // @override
  // void dispose() {
  //   print('disposed $runtimeType');
  //   super.dispose();
  // }
}
