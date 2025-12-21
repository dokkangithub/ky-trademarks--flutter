import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FcmService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<String?> getFcmToken(BuildContext context) async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint(' FCM TOKEN: $token');
      return token;
    } catch (e) {
      debugPrint(' Failed to get FCM token: $e');
      return null;
    }
  }
}
