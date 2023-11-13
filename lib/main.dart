import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rewild/di/di_container.dart';
import 'package:rewild/domain/services/background_service.dart';
import 'package:workmanager/workmanager.dart';

const fetchBackground = "fetchBackground";
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        await BackgroundService.fetchAll();
        break;
    }
    return Future.value(true);
  });
}

abstract class AppFactory {
  Widget makeApp();
}

final appFactory = makeAppFactory();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Workmanager().initialize(
    callbackDispatcher,
    // isInDebugMode: true,
  );
  await Workmanager().registerPeriodicTask(
    "1",
    fetchBackground,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );

  final app = appFactory.makeApp();
  runApp(app);
}
