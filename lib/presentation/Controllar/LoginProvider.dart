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
import '../Screens/disactive_accounts_screen.dart';
import '../Screens/login/Login.dart';

class LoginProvider extends ChangeNotifier {
  TextEditingController phoneController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;
  int screenState = 0;
  Color blue = const Color(0xff8cccff);
  bool state = false;
  bool loading = false;

  ///  loginWithUserAndPassword
  Future loginWithUserAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    loading = true;
    notifyListeners();

    if (await isNetworkAvailable()) {
      final res = await http.post(
        Uri.parse("${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.loginUser}"),
        body: {
          "email": email,
          "password": password,
          "token": LoginScreen.token.toString(),
        },
        headers: {
          HttpHeaders.cacheControlHeader: 'no-cache',
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
        },
      );

      print('444444${LoginScreen.token.toString()}');

      try {
        final responseData = json.decode(res.body);

        if (res.statusCode == 200) {
          final int status = responseData['status'];

          if (status == 0) {
            // Account is inactive
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const InactiveAccountScreen()),
            );
            loading = false;
            notifyListeners();
            return;
          }

          // Account is active
          UserModel user = UserModel.fromJson(responseData);
          saveUserData(user);

          loading = false;
          notifyListeners();

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/tabBar',
                (Route<dynamic> route) => false,
          );
        } else {
          loading = false;
          notifyListeners();
          throw ServerException(errorModel: json.decode(res.body));
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
