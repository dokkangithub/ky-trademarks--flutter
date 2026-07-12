import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/RequestState/RequestState.dart';
import 'package:http/http.dart' as http;

import '../../../core/Constant/Api_Constant.dart';
import '../../../network/ErrorModel.dart';
import '../../../utilits/Local_User_Data.dart';

class Notification {
  final String content;
  final String title;
  final int id;

  Notification({required this.content, required this.title, required this.id});

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
        content: json["content"],
        title: json["title"],
        id: json["brand_id"] ?? 0);
  }
}

class NotificationProvider extends ChangeNotifier {
  List<Notification> notification = [];

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
}
