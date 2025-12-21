import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NotificationHelper {
  /// Logs any incoming [RemoteMessage] in debug mode to help during development.
  static void logRemoteMessage(RemoteMessage message, {String source = ''}) {
    if (!kDebugMode) return;

    final String prefix =
        source.isNotEmpty ? '🔔 FCM [$source]' : '🔔 FCM Message';

    debugPrint('$prefix -----------------------------');
    debugPrint('Message ID: ${message.messageId}');
    debugPrint('From: ${message.from}');
    debugPrint('Category: ${message.category}');
    debugPrint('CollapseKey: ${message.collapseKey}');
    debugPrint('SentTime: ${message.sentTime}');
    debugPrint('TTL: ${message.ttl}');

    debugPrint('Notification Title: ${message.notification?.title}');
    debugPrint('Notification Body: ${message.notification?.body}');

    if (message.data.isNotEmpty) {
      debugPrint('Data: ${message.data}');
    } else {
      debugPrint('Data: {}');
    }

    debugPrint('------------------------------------------');
  }

  static Future<void> initialize(FlutterLocalNotificationsPlugin fln) async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await fln.initialize(initSettings);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      logRemoteMessage(message, source: 'onMessage (foreground)');
      await showNotification(message, fln);
    });

    // When user taps a notification and opens the app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logRemoteMessage(
        message,
        source: 'onMessageOpenedApp (tap notification)',
      );
      log("Notification Opened Type: ${message.data['type']}");
    });

    // Message that opened the app from a terminated state
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      logRemoteMessage(initialMessage, source: 'getInitialMessage');
    }
  }

  static Future<void> showNotification(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    String? title = message.notification?.title ?? message.data['title'];
    String? body = message.notification?.body ?? message.data['body'];
    String? imageUrl;

    if (Platform.isAndroid) {
      imageUrl =
          message.notification?.android?.imageUrl ?? message.data['image'];
    } else if (Platform.isIOS) {
      imageUrl = message.notification?.apple?.imageUrl ?? message.data['image'];
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        await _showBigPictureNotification(title, body, imageUrl, fln);
      } catch (e) {
        await _showTextNotification(title, body, fln);
      }
    } else {
      await _showTextNotification(title, body, fln);
    }
  }

  static Future<void> _showTextNotification(
    String? title,
    String? body,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.max,
      priority: Priority.max,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await fln.show(0, title, body, platformDetails);
  }

  static Future<void> _showBigPictureNotification(
    String? title,
    String? body,
    String imageUrl,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    final String largeIconPath = await _downloadAndSaveFile(
      imageUrl,
      'largeIcon',
    );
    final String bigPicturePath = await _downloadAndSaveFile(
      imageUrl,
      'bigPicture',
    );

    final BigPictureStyleInformation bigPictureStyle =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      contentTitle: title,
      summaryText: body,
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'Default',
      styleInformation: bigPictureStyle,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await fln.show(0, title, body, platformDetails);
  }

  static Future<String> _downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}

class NotificationBody {
  int? orderId;
  String? type;

  NotificationBody({this.orderId, this.type});

  NotificationBody.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['type'] = type;
    return data;
  }
}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  // This is called when a message arrives while the app is in the background
  // or terminated (for data-only messages). We only log here to avoid
  // complex UI work in the background isolate.
  NotificationHelper.logRemoteMessage(message, source: 'onBackgroundMessage');
  // var androidInitialize = new AndroidInitializationSettings('notification_icon');
  // var iOSInitialize = new IOSInitializationSettings();
  // var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  // NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, true);
}
