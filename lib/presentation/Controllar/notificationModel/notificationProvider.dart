import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/RequestState/RequestState.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/Constant/Api_Constant.dart';
import '../../../network/ErrorModel.dart';
import '../../../utilits/Local_User_Data.dart';

class Notification {
  final int notificationId;
  final String content;
  final String title;
  final int brandId;

  Notification({
    required this.notificationId,
    required this.content,
    required this.title,
    required this.brandId,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
        notificationId: int.tryParse('${json["id"] ?? 0}') ?? 0,
        content: json["content"],
        title: json["title"],
        brandId: int.tryParse('${json["brand_id"] ?? 0}') ?? 0);
  }
}

class NotificationProvider extends ChangeNotifier {
  String get _lastSeenNotificationIdKey =>
      'last_seen_notification_id_v2_${globalAccountData.getId() ?? 'guest'}';

  List<Notification> notification = [];
  int unreadCount = 0;

  RequestState? state;

  Future<List<Notification>?> getUserNotification() async {
    state = RequestState.loading;
    notifyListeners();
    try {
      final result = await http.get(
        Uri.parse(
            "${ApiConstant.baseUrl}${ApiConstant.slug}notifactions/${globalAccountData.getId()}"),
        headers: {'Authorization': 'Bearer ${globalAccountData.getToken()}'},
      ).timeout(const Duration(seconds: 15));

      if (result.statusCode != 200) {
        throw ServerException(
          errorModel: ErrorModel.fromJson(json.decode(result.body)),
        );
      }

      final status = json.decode(result.body) as Map<String, dynamic>;
      final data = status['data'];
      notification = data is List
          ? data
              .whereType<Map>()
              .map((item) =>
                  Notification.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : [];
      final preferences = await SharedPreferences.getInstance();
      final lastSeenId = preferences.getInt(_lastSeenNotificationIdKey) ?? 0;
      unreadCount =
          notification.where((item) => item.notificationId > lastSeenId).length;
      state = RequestState.loaded;
      notifyListeners();
      return notification;
    } on TimeoutException {
      state = RequestState.failed;
      notifyListeners();
      return null;
    } catch (_) {
      state = RequestState.failed;
      notifyListeners();
      return null;
    }
  }

  void registerIncomingNotification() {
    unreadCount++;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    if (notification.isNotEmpty) {
      final latestId = notification
          .map((item) => item.notificationId)
          .reduce((first, second) => first > second ? first : second);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt(_lastSeenNotificationIdKey, latestId);
    }
    if (unreadCount != 0) {
      unreadCount = 0;
      notifyListeners();
    }
  }
}
