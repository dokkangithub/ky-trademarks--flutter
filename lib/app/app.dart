
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../presentation/Controllar/GetBrandBySearchProvider.dart';
import '../presentation/Controllar/GetBrandDetailsProvider.dart';
import '../presentation/Controllar/GetBrandProvider.dart';
import '../presentation/Controllar/GetCompanyProvider.dart';
import '../presentation/Controllar/GetSuccessPartners.dart';
import '../presentation/Controllar/LoginProvider.dart';
import '../presentation/Controllar/RequestProvider.dart';
import '../presentation/Controllar/ReservationProvider.dart';
import '../presentation/Controllar/notificationModel/notificationProvider.dart';
import '../presentation/Controllar/userProvider.dart';
import '../presentation/Controllar/Issues/GetIssuesProvider.dart';
import '../presentation/Controllar/Issues/GetIssueDetailsProvider.dart';
import '../presentation/Controllar/Issues/GetIssuesSummaryProvider.dart';
import '../presentation/Controllar/Issues/SearchIssuesProvider.dart';
import '../presentation/Screens/login/Login.dart';
import '../resources/Route_Manager.dart';
import '../resources/Theme_Manager.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    // Handle the notification
  }
   @override
  void initState() {
     super.initState();
     // var initializationSettingsAndroid =
     // AndroidInitializationSettings('@mipmap/launcher_icon');
     // var initializationSettings =
     // InitializationSettings(android: initializationSettingsAndroid);
     // flutterLocalNotificationsPlugin.initialize(
     //     initializationSettings,
     //     // onSelectNotification: onSelectNotification
     // );
     // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
     //   'your_channel_id',
     //   'your_channel_name',
     //   channelDescription:  'your_channel_description',
     //   importance: Importance.max,
     //   priority: Priority.high,
     //   ticker: 'ticker',
     //   // Remove FLAG_IMMUTABLE from here (it's not valid here)
     // );
     //
     // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
     //   RemoteNotification? notification = message.notification;
     //   AndroidNotification? android = message.notification?.android;
     //
     //   if (notification != null && android != null) {
     //     // Create the notification channel if it hasn't been created yet
     //     await flutterLocalNotificationsPlugin
     //         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
     //         ?.createNotificationChannel(channel);
     //
     //     await flutterLocalNotificationsPlugin.show(
     //       notification.hashCode,
     //       notification.title,
     //       notification.body,
     //       NotificationDetails(
     //         android: AndroidNotificationDetails(
     //           channel.id,
     //           channel.name,
     //              channelDescription:  channel.description,
     //           importance: Importance.high,
     //           priority: Priority.high,
     //           icon: '@mipmap/ic_launcher',
     //           // Add the following line
     //         ),
     //       ),
     //     );
     //
     //   }
     // });
     // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
     //   RemoteNotification? notification = message.notification;
     //   AndroidNotification? android = message.notification?.android;
     //   debugPrint("-*-*-*--*-*-");
     //   if (notification != null && android != null) {
     //     showDialog(
     //         context: navigatorKey.currentContext!,
     //         builder: (_) {
     //           return AlertDialog(
     //             title: Text(notification.title!),
     //             content: SingleChildScrollView(
     //               child: Column(
     //                 crossAxisAlignment: CrossAxisAlignment.start,
     //                 children: [Text(notification.body!)],
     //               ),
     //             ),
     //           );
     //         });
     //   }
     // });
     // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
     //   var notification = message.notification;
     //   var android = message.notification?.android;
     //   if (notification != null && android != null) {
     //     showDialog(
     //         context: navigatorKey.currentContext!,
     //         builder: (_) {
     //           return MaterialApp(
     //             home: AlertDialog(
     //               title: Text(notification.title! ),
     //               content: SingleChildScrollView(
     //                 child: Column(
     //                   crossAxisAlignment: CrossAxisAlignment.start,
     //                   children: [
     //                     Text(notification.body!),
     //                     Row(
     //                       children: [
     //                         Text(notification.title! ),
     //                         Text(notification.body!),
     //                       ],
     //                     )
     //                   ],
     //                 ),
     //               ),
     //             ),
     //           );
     //         });
     //   }
     // });
     // FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage ?message) {
     //   if (message != null) {
     //     RemoteNotification notification = message.notification!;
     //     AndroidNotification? android = message.notification?.android;
     //     if (notification != null && android != null) {
     //       showDialog(
     //         context: navigatorKey.currentContext!,
     //         builder: (_) {
     //           return AlertDialog(
     //             title: Text(notification.title!),
     //             content: SingleChildScrollView(
     //               child: Column(
     //                 crossAxisAlignment: CrossAxisAlignment.start,
     //                 children: [Text(notification.body!)],
     //               ),
     //             ),
     //           );
     //         },
     //       );
     //     }
     //   }
     // });
    getToken();

  }
  String token="";
  getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
      LoginScreen.token=await  FirebaseMessaging.instance.getToken();
      print("TOKEN"+token);
  }
  @override
  Widget build(BuildContext context) {
    return
      MultiProvider(
        providers: [
          ListenableProvider<GetBrandProvider>(
              create: (_) => GetBrandProvider()),
          ListenableProvider<LoginProvider>(create: (_) => LoginProvider()),
          ListenableProvider<GetBrandDetailsProvider>(
              create: (_) => GetBrandDetailsProvider()),
          ListenableProvider<GetBrandBySearchProvider>(
              create: (_) => GetBrandBySearchProvider()),
          ListenableProvider<ReservationProvider>(
              create: (_) => ReservationProvider()),
          ListenableProvider<RequestProvider>(
              create: (_) => RequestProvider()),
          ListenableProvider<GetSuccessPartners>(
              create: (_) => GetSuccessPartners()),
          ListenableProvider<NotificationProvider>(
              create: (_) => NotificationProvider()),
          ListenableProvider<GetUserProvider>(
              create: (_) => GetUserProvider()),
          ListenableProvider<GetCompanyProvider>(
              create: (_) => GetCompanyProvider()),
          ListenableProvider<GetIssuesProvider>(
              create: (_) => GetIssuesProvider()),
          ListenableProvider<GetIssueDetailsProvider>(
              create: (_) => GetIssueDetailsProvider()),
          ListenableProvider<GetIssuesSummaryProvider>(
              create: (_) => GetIssuesSummaryProvider()),
          ListenableProvider<SearchIssuesProvider>(
              create: (_) => SearchIssuesProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateRoute: RouteGenerator.getRoute,
          initialRoute: Routes.splashRoute,
          theme: getApplicationTheme(),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          navigatorKey: navigatorKey,
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
        ),
      );



   }
}
