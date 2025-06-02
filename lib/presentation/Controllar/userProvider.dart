import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/domain/User/Entities/UserEntity.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import '../../core/Services_locator.dart';
import '../../domain/User/UseCase/GetUserUseCase.dart';

class GetUserProvider extends ChangeNotifier {
  UserEntity? userData;
  RequestState state = RequestState.loading;

  Future<void> getUserData() async {
    state = RequestState.loading;
    notifyListeners();

    var result = await GetUserDataUseCase(sl()).call();
    result.fold((l) {
      state = RequestState.failed;
      notifyListeners();
      return toast(l.message.toString());
    }, (r) {
      userData = r.user;
      state = RequestState.loaded;
      notifyListeners();
    });
  }

  Future<void> updateUserAvatar({required File avatarFile}) async {
    state = RequestState.loading;
    notifyListeners();

    var result = await UpdateUserAvatarUseCase(sl()).call(avatarFile: avatarFile);
    result.fold((l) {
      state = RequestState.failed;
      notifyListeners();
      return toast(l.message.toString());
    }, (r) {
      userData = r.user;
      state = RequestState.loaded;
      notifyListeners();
    });
  }


}