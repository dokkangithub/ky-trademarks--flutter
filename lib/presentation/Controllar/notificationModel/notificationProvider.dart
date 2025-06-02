import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../app/RequestState/RequestState.dart';
import 'package:http/http.dart' as http;

import '../../../core/Constant/Api_Constant.dart';
import '../../../network/ErrorModel.dart';
import '../../../utilits/Local_User_Data.dart';
class Notification{
  final String content;
  final String title;
  final int id;

  Notification({required this.content,required this.title,required this.id});

 factory Notification.fromJson(Map<String,dynamic> json){
    return Notification(content: json["content"], title:json["title"], id:json["brand_id"]??0 );
  }
}
class NotificationProvider extends ChangeNotifier{
  List<Notification>? notification;

  RequestState? state;

  Future<List<Notification>?> getUserNotification() async {
    state = RequestState.loading;
    notifyListeners();
    final result = await http.get(
        Uri.parse("${ApiConstant.baseUrl}${ApiConstant.slug}notifactions/${globalAccountData.getId()}"));

    if (result.statusCode == 200) {
      var status=json.decode(result.body);
      print(result.body);
      notification= List<Notification>.from(status["data"].map((e)=>Notification.fromJson(e))).toList();
      print(notification![0].content);
      state=RequestState.loaded;
      notifyListeners();
      return notification;
    } else {
      notifyListeners();
      state=RequestState.failed;

      throw ServerException(
          errorModel: ErrorModel.fromJson(json.decode(result.body)));
    }
  }
}