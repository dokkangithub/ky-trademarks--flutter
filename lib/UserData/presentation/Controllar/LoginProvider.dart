// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kyuser/UserData/domain/UseCase/GetUserData.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../network/RestApi/Comman.dart';
import '../../../resources/StringManager.dart';
import '../../data/models/UserModel.dart';

class LoginProvider extends ChangeNotifier {
 final GetUserDataWithLogin getUserDataWithLogin;

  bool state = false;
  bool loading = false;

  LoginProvider({required this.getUserDataWithLogin});

  ///  Login With Email And Password
  Future loginWithEmailAndPassword({required String email , required String password}) async {
    var result = await getUserDataWithLogin.call();
    // result.fold(
    //         (l) => emit(state.copyWith(
    //         requestState: RequestState.failed, message: l.message)),
    //         (r) => emit(state.copyWith(
    //         requestState: RequestState.loaded, all_Products: r)));
  }
}
