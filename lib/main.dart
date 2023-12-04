import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
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
        try {
          await BackgroundService.fetchAll();
        } catch (e) {
          throw Exception(e);
        }
        break;
      case everyDayAtFirstHourAfterMidNight:
        try {
          await BackgroundService.updateInitialStocks();
        } catch (e) {
          throw Exception(e);
        }
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

  // Notifications
  AwesomeNotifications()
      .initialize('resource://drawable/res_notification_app_icon', [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'ReWild',
      defaultColor: const Color(0xFF9D50DD),
      importance: NotificationImportance.High,
      channelShowBadge: true,
      channelDescription: 'description',
      enableLights: true,
    ),
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

  // BackgroundService.initial();

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

  // to solve the cached_network_image Handshake problem
  HttpOverrides.global = MyHttpOverrides();

  final app = appFactory.makeApp();
  runApp(app);
}

// to solve the cached_network_image Handshake problem
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}


 // calculate stocks
  //  