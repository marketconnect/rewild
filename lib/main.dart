import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rewild/di/di_container.dart';

abstract class AppFactory {
  Widget makeApp();
}

final appFactory = makeAppFactory();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final app = appFactory.makeApp();
  runApp(app);
}
