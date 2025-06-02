// // import 'dart:developer';
// // import 'dart:typed_data';
// //
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// //
// // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// //   await Firebase.initializeApp();
// //   print(message.notification?.title);
// //
// //   log('Handling a background message ${message.messageId}');
// // }
// //
// // final navigatorKey = GlobalKey<NavigatorState>();
// //
// // AndroidNotificationChannel channel =  AndroidNotificationChannel(
// //   'your channel id', // id
// //   'High Importance Notifications', // title
// // 'This channel is used for important notifications.',
// // );
// // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// // FlutterLocalNotificationsPlugin();
// // AppLifecycleState appLifecycleState = AppLifecycleState.detached;
// // String token = "";
// //
// // Future<String> getToken() async {
// //   token = (await FirebaseMessaging.instance.getToken())!;
// //   print(token);
// //   return token;
// // }
// //
// // Future<void> onSelectNotification(String payload) async {
// //   if (payload != null) {
// //     debugPrint('notification payload: $payload');
// //   }
// // }
// //
// // /// For main.dart
// // mainFunctionForNotification() async {
// //   FirebaseMessaging messaging = FirebaseMessaging.instance;
// //
// //   // Request permissions
// //   await messaging.requestPermission();
// //   FlutterLocalNotificationsPlugin ?flutterLocalNotificationsPlugin;
// //   await flutterLocalNotificationsPlugin
// //      !.resolvePlatformSpecificImplementation<
// //       AndroidFlutterLocalNotificationsPlugin>()
// //       ?.createNotificationChannel(channel);
// //   if (appLifecycleState == AppLifecycleState.inactive ||
// //       appLifecycleState == AppLifecycleState.paused ||
// //       appLifecycleState == AppLifecycleState.detached) {
// //     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
// //   }
// //   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
// //     alert: true,
// //     badge: true,
// //     sound: true,
// //   );
// // }
// //
// // /// For Splash screen
// // appNotificationDialogFunctions() async {
// //
// //   getToken();
// //   var initializationSettingsAndroid =
// //   const AndroidInitializationSettings('@mipmap/launcher_icon');
// //   var initializationSettings =
// //   InitializationSettings(android: initializationSettingsAndroid);
// //   await flutterLocalNotificationsPlugin.initialize(
// //     initializationSettings,
// //   );
// //   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
// //     RemoteNotification? notification = message.notification;
// //     AndroidNotification? android = message.notification?.android;
// //
// //     if (notification != null && android != null) {
// //       // Create the notification channel if it hasn't been created yet
// //       await flutterLocalNotificationsPlugin
// //           .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
// //           ?.createNotificationChannel(channel);
// //
// //       await flutterLocalNotificationsPlugin.show(
// //         notification.hashCode,
// //         notification.title,
// //         notification.body,
// //         NotificationDetails(
// //           android: AndroidNotificationDetails(
// //             channel.id,
// //             channel.name,
// //           channel.description,
// //             importance: Importance.high,
// //             priority: Priority.high,
// //             icon: '@mipmap/ic_launcher',
// //             // additionalFlags: Int32List.fromList([AndroidNotificationChannel.FLAG_IMMUTABLE]), // Use FLAG_IMMUTABLE
// //
// //           ),
// //         ),
// //       );
// //     }
// //   });
// //
// //
// //
// //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
// //     var notification = message.notification;
// //     var android = message.notification?.android;
// //     if (notification != null && android != null) {
// //       showDialog(
// //           context: navigatorKey.currentContext!,
// //           builder: (_) {
// //             return MaterialApp(
// //               home: AlertDialog(
// //                 title: Text(notification.title! ),
// //                 content: SingleChildScrollView(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(notification.body!),
// //                       Row(
// //                         children: [
// //                           Text(notification.title! ),
// //                           Text(notification.body!),
// //                         ],
// //                       )
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             );
// //           });
// //     }
// //   });
// //   FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage ?message) {
// //     if (message != null) {
// //       RemoteNotification notification = message.notification!;
// //       AndroidNotification? android = message.notification?.android;
// //       if (notification != null && android != null) {
// //         showDialog(
// //           context: navigatorKey.currentContext!,
// //           builder: (_) {
// //             return AlertDialog(
// //               title: Text(notification.title!),
// //               content: SingleChildScrollView(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [Text(notification.body!)],
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       }
// //     }
// //   });
// // }
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// final navigatorKey = GlobalKey<NavigatorState>();
//
// Future<void> setupFCM() async {
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//
//     if (notification != null && android != null) {
//       // Create the notification channel if it hasn't been created yet
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(channel);
//
//       await flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel.id,
//             channel.name,
//               channelDescription: channel.description,
//             importance: Importance.high,
//             priority: Priority.high,
//             icon: '@mipmap/ic_launcher',
//             // Add the following line
//           ),
//         ),
//       );
//
//     }
//   });
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//     debugPrint("-*-*-*--*-*-");
//     if (notification != null && android != null) {
//       showDialog(
//           context: navigatorKey.currentContext!,
//           builder: (_) {
//             return AlertDialog(
//               title: Text(notification.title!),
//               content: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [Text(notification.body!)],
//                 ),
//               ),
//             );
//           });
//     }
//   });
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     var notification = message.notification;
//     var android = message.notification?.android;
//     if (notification != null && android != null) {
//       showDialog(
//           context: navigatorKey.currentContext!,
//           builder: (_) {
//             return MaterialApp(
//               home: AlertDialog(
//                 title: Text(notification.title! ),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(notification.body!),
//                       Row(
//                         children: [
//                           Text(notification.title! ),
//                           Text(notification.body!),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           });
//     }
//   });
//   FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage ?message) {
//     if (message != null) {
//       RemoteNotification notification = message.notification!;
//       AndroidNotification? android = message.notification?.android;
//       if (notification != null && android != null) {
//         showDialog(
//           context: navigatorKey.currentContext!,
//           builder: (_) {
//             return AlertDialog(
//               title: Text(notification.title!),
//               content: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [Text(notification.body!)],
//                 ),
//               ),
//             );
//           },
//         );
//       }
//     }
//   });
// }