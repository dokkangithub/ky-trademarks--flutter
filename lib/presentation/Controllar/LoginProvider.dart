import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:kyuser/core/Constant/Api_Constant.dart';
import 'package:kyuser/network/ErrorModel.dart';
import '../../UserData/data/models/UserModel.dart';
import '../../fcm_service.dart';
import '../../network/RestApi/Comman.dart';
import '../../resources/StringManager.dart';
import '../Screens/disactive_accounts_screen.dart';
import '../Screens/login/Login.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';

class LoginProvider extends ChangeNotifier {
  TextEditingController phoneController = TextEditingController();

  bool loading = false;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "${ApiConstant.baseUrl}${ApiConstant.slug}",
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        HttpHeaders.cacheControlHeader: 'no-cache',
        'Accept': 'application/json',
      },
      validateStatus: (_) => true,
    ),
  )..interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        compact: true,
      ),
    );

  Future<void> loginWithUserAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    loading = true;
    notifyListeners();

    if (!await isNetworkAvailable()) {
      toast(StringConstant.errorInternetNotAvailable);
      loading = false;
      notifyListeners();
      return;
    }

    try {
      final String? fcmToken = await FcmService.getFcmToken(context);

      final Response res = await _dio.post(
        ApiConstant.loginUser,
        data: {
          "email": email,
          "password": password,
          "token": LoginScreen.token?.toString() ?? '',
        },
        options: Options(
          headers: {
            if (fcmToken != null && fcmToken.isNotEmpty) 'fcm-token': fcmToken,
          },
        ),
      );

      final Map<String, dynamic> responseData = res.data is Map<String, dynamic>
          ? res.data
          : json.decode(res.data.toString());

      if (res.statusCode == 200) {
        final int status = responseData['status'];

        if (status == 0) {
          loading = false;
          notifyListeners();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const InactiveAccountScreen(),
            ),
          );
          return;
        }

        // ✅ active account
        final UserModel user = UserModel.fromJson(responseData);
        saveUserData(user);

        await globalAccountData.setIsAdmin(false);

        loading = false;
        notifyListeners();

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/tabBar',
          (route) => false,
        );
      } else {
        throw ServerException(
          errorModel: ErrorModel.fromJson(responseData),
        );
      }
    } on DioException catch (e) {
      toast("البيانات غير صحيحة");
      debugPrint('❌ Dio Error: ${e.message}');
    } catch (e) {
      toast("البيانات غير صحيحة");
      debugPrint('❌ Unknown Error: $e');
    }

    loading = false;
    notifyListeners();
  }
}
