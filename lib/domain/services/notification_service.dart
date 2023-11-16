// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   // initialise the plugin of flutterlocalnotifications.
//   static final FlutterLocalNotificationsPlugin
//       _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   Future initialise() async {
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();
//     // const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('ic_launcher');
//     final DarwinInitializationSettings initializationSettingsDarwin =
//         DarwinInitializationSettings(
//             onDidReceiveLocalNotification: onDidReceiveLocalNotification);
//     const LinuxInitializationSettings initializationSettingsLinux =
//         LinuxInitializationSettings(defaultActionName: 'Open notification');

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//             android: initializationSettingsAndroid,
//             iOS: initializationSettingsDarwin,
//             linux: initializationSettingsLinux);
//     flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
//   }

//   void onDidReceiveLocalNotification(
//       int id, String? title, String? body, String? payload) async {
//     // display a dialog with the notification details, tap ok to go to another page
//     // showDialog(
//     //   context: context,
//     //   builder: (BuildContext context) => CupertinoAlertDialog(
//     //     title: Text(title),
//     //     content: Text(body),
//     //     actions: [
//     //       CupertinoDialogAction(
//     //         isDefaultAction: true,
//     //         child: Text('Ok'),
//     //         onPressed: () async {
//     //           Navigator.of(context, rootNavigator: true).pop();
//     //           await Navigator.push(
//     //             context,
//     //             MaterialPageRoute(
//     //               builder: (context) => SecondScreen(payload),
//     //             ),
//     //           );
//     //         },
//     //       )
//     //     ],
//     //   ),
//     // );
//   }
//   void onDidReceiveNotificationResponse(
//       NotificationResponse notificationResponse) async {
//     final String? payload = notificationResponse.payload;
//     if (notificationResponse.payload != null) {
//       debugPrint('notification payload: $payload');
//     }
//     // await Navigator.push(
//     //   context,
//     //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
//     // );
//   }

//   static Future instantNotification(String title, String body) async {
//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails('id', 'channel',
//             channelDescription: 'description',
//             importance: Importance.max,
//             priority: Priority.high,
//             ticker: 'ticker');

//     const NotificationDetails notificationDetails =
//         NotificationDetails(android: androidNotificationDetails);
//     await _flutterLocalNotificationsPlugin
//         .show(0, title, body, notificationDetails, payload: 'item x');
//   }

//   static Future imageNotification() async {
//     var bigPicture = const BigPictureStyleInformation(
//       DrawableResourceAndroidBitmap("ic_launcher"),
//       largeIcon: DrawableResourceAndroidBitmap("ic_launcher"),
//       contentTitle: "big image",
//       summaryText: "summaryText",
//       htmlFormatContent: true,
//       htmlFormatContentTitle: true,
//     );
//     AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails('id', 'channel',
//             channelDescription: 'description',
//             importance: Importance.max,
//             priority: Priority.high,
//             ticker: 'ticker',
//             styleInformation: bigPicture);
//     NotificationDetails notificationDetails =
//         NotificationDetails(android: androidNotificationDetails);
//     await _flutterLocalNotificationsPlugin.show(
//         0, 'plain image title', 'plain image body', notificationDetails,
//         payload: 'item x');
//   }

//   static Future stylishNotification(String title, String body) async {
//     AndroidNotificationDetails androidNotificationDetails =
//         const AndroidNotificationDetails('id', 'channel',
//             channelDescription: 'description',
//             importance: Importance.max,
//             priority: Priority.high,
//             ticker: 'ticker',
//             enableLights: true,
//             enableVibration: true,
//             styleInformation: MediaStyleInformation(
//               htmlFormatContent: true,
//               htmlFormatTitle: true,
//             ));
//     NotificationDetails notificationDetails =
//         NotificationDetails(android: androidNotificationDetails);
//     await _flutterLocalNotificationsPlugin
//         .show(0, title, body, notificationDetails, payload: 'item x');
//   }
// }
