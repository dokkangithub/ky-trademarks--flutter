import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';
import 'package:oktoast/oktoast.dart';
import 'app/app.dart';
import 'core/Services_locator.dart';
import 'firebase_options.dart';
import 'notification.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Only initialize if not already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  debugPrint('Handling a background message ${message.messageId}');

  // Initialize FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@android:drawable/ic_dialog_info');
  final DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint("Notification clicked: ${response.payload}");
    },
  );

  // Define the notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  // Create the notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Display the notification
  if (message.notification != null) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@android:drawable/ic_dialog_info',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: message.data['data'],
      );
    }
  }
}

final navigatorKey = GlobalKey<NavigatorState>();

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
AppLifecycleState appLifecycleState = AppLifecycleState.detached;
const AndroidInitializationSettings initializationSettingsAndroid =
AndroidInitializationSettings('@android:drawable/ic_dialog_info');
final DarwinInitializationSettings initializationSettingsIOS =
DarwinInitializationSettings(
  requestAlertPermission: true,
  requestBadgePermission: true,
  requestSoundPermission: true,
);

final InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: initializationSettingsIOS,
);

// Function to request notifications permissions without blocking the app startup
Future<void> _requestNotificationPermissions() async {
  try {
    // Skip notification permissions on iOS web browsers as they handle it differently
    if (kIsWeb) {
      debugPrint('Running on web - skipping notification permission request');
      return;
    }

    // Only request permissions on mobile platforms
    if (!kIsWeb) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('Notification permission status: ${settings.authorizationStatus}');
    } else {
      // For web, we handle it differently and don't wait for user response
      debugPrint('Running on web - notification permissions handled by browser');
    }
  } catch (e) {
    debugPrint('Error requesting notification permissions: $e');
    // Don't let permission errors stop the app
  }
}

Future<FirebaseApp> initializeFirebase() async {
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isNotEmpty) {
      debugPrint('Firebase already initialized, using existing app');
      return Firebase.app();
    }

    // Initialize Firebase
    debugPrint('Initializing Firebase...');
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
    return app;
  } catch (e) {
    debugPrint('Firebase initialization error: $e');

    // If there's already an app, return it
    if (Firebase.apps.isNotEmpty) {
      debugPrint('Using existing Firebase app despite error');
      return Firebase.app();
    }

    rethrow; // Rethrow if we can't recover
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await initializeFirebase();

  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();

  // Initialize service locator
  Services_locator().init();

  // Initialize Flutter Local Notifications (only on mobile)
  if (!kIsWeb) {
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification clicked: ${response.payload}");
        // Handle notification tap
        if (response.payload != null) {
          // Add your navigation logic here if needed
        }
      },
    );

    // Create notification channel (only on Android)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Request permissions in the background (non-blocking)
  _requestNotificationPermissions();

  // Listen to foreground messages (only on mobile)
  if (!kIsWeb) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@android:drawable/ic_dialog_info',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: message.data['data'],
        );
      }
    });

    // Handle when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    // Check if the app was opened from a terminated state via a notification
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  // Get FCM token for this device (in background to avoid blocking)
  // Skip FCM operations on iOS Safari as they might cause issues
  if (!kIsWeb) {
    try {
      FirebaseMessaging.instance.getToken().then((token) {
        debugPrint("FCM Token: $token");
      }).catchError((error) {
        debugPrint("Error getting FCM token: $error");
      });
    } catch (e) {
      debugPrint("Error setting up FCM token: $e");
    }
  } else {
    debugPrint("Skipping FCM token on web - handled by browser");
  }

  // Initialize local user data
  await globalAccountData.init();

  // Override HTTP settings if necessary (only on mobile)
  print('Bearer ${globalAccountData.getToken()}');
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }

  runApp(EasyLocalization(
    supportedLocales: [Locale('en', 'US'), Locale('ar', 'EG')],
    path: 'assets/translation',
    fallbackLocale: Locale('ar', 'EG'),
    startLocale: Locale('ar', 'EG'),
    child: OKToast(child: const MyApp()),
  ));
}

void _handleMessage(RemoteMessage message) {
  if (navigatorKey.currentContext != null) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (_) {
          return AlertDialog(
            title: Text(notification.title ?? 'No Title'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.body ?? 'No Body'),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}