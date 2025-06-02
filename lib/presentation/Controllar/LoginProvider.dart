// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
 import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kyuser/core/Constant/Api_Constant.dart';
import 'package:kyuser/network/ErrorModel.dart';
import '../../UserData/data/models/UserModel.dart';
import '../../network/RestApi/Comman.dart';
import '../../resources/StringManager.dart';
import '../Screens/Login.dart';

class LoginProvider extends ChangeNotifier {
  TextEditingController phoneController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;
  int screenState = 0;
  Color blue = const Color(0xff8cccff);
  bool state = false;
  bool loading = false;

  ///  loginWithUserAndPassword
  Future loginWithUserAndPassword(
      {required String email, required String password, context}) async {
    loading = true;
    notifyListeners();
    if (await isNetworkAvailable()) {
      final res = await http.post(
          Uri.parse("${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.loginUser}"),
          body: {
            "email": email,
            "password": password,
            "token": LoginScreen.token.toString()
          },
          headers: {
            HttpHeaders.cacheControlHeader: 'no-cache',
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Origin': '*',
          });
      try {

        if (res.statusCode == 200) {
          print(Uri.parse("${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.loginUser}"));
          final statusState = json.decode(res.body);
          UserModel.fromJson(statusState);
          loading = false;
          notifyListeners();
          Navigator.pushNamedAndRemoveUntil(
              context, '/tabBar', (Route<dynamic> route) => false);
          saveUserData(UserModel.fromJson(statusState));
          notifyListeners();

        } else {
          loading = false;
          notifyListeners();
          ServerException(errorModel: json.decode(res.body));
        }
      } catch (e) {
        loading = false;
        notifyListeners();
        toast("البيانات غير صحيحة");
      }
    } else {
      toast(StringConstant.errorInternetNotAvailable);
    }
  }
}
