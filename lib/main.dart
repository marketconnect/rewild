import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rewild/di/di_container.dart';
import 'package:rewild/domain/services/background_service.dart';
import 'package:workmanager/workmanager.dart';

const everyFifteen = "everyFifteen";
const everyDayAtFirstHourAfterMidNight =
    "fetchEveryDayAtFirstHourAfterMidNight";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case everyFifteen:
        await BackgroundService.fetchAll();
        break;
      case everyDayAtFirstHourAfterMidNight:
        await BackgroundService.updateInitialStocks();
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
    everyFifteen,
    everyFifteen,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );

  DateTime now = DateTime.now();
  // to get rid of simultaneous requests at the same time
  final minutes = now.minute > 15 ? now.minute : now.minute + 15;

  DateTime firstHourAfterMidNight =
      DateTime(now.year, now.month, now.day + 1, 0, minutes);

  final initialDelay = firstHourAfterMidNight.difference(now);

  await Workmanager().registerPeriodicTask(
    everyDayAtFirstHourAfterMidNight,
    everyDayAtFirstHourAfterMidNight,
    frequency: const Duration(days: 1),
    initialDelay: initialDelay,
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );

  final app = appFactory.makeApp();
  runApp(app);
}
