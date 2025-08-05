// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:kyuser/UserData/domain/UseCase/GetUserData.dart';

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
