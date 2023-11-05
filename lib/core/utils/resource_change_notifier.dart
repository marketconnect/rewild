import 'package:flutter/material.dart';
import 'package:rewild/core/utils/resource.dart';

class ResourceChangeNotifier extends ChangeNotifier {
  final BuildContext context;

  late final Size _screenSize = MediaQuery.of(context).size;
  double get screenWidth => _screenSize.width;
  double get screenHeight => _screenSize.height;

  ResourceChangeNotifier({required this.context});
  late bool _loading = true;
  bool get loading => _loading;
  void notify() {
    if (context.mounted) {
      _loading = false;
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
