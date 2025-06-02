import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/User/Entities/UserEntity.dart';
import '../../../app/Failure.dart';
import '../DominRepositery/BaseUserRepositery.dart';


class GetUserDataUseCase {
  final BaseUserRepository baseUserRepository;
  GetUserDataUseCase(this.baseUserRepository);
  Future<Either<Failure, UserDataEntity>> call() async {
    return await baseUserRepository.getUserData();
  }
}

class UpdateUserAvatarUseCase {
  final BaseUserRepository baseUserRepository;
  UpdateUserAvatarUseCase(this.baseUserRepository);
  Future<Either<Failure, UserDataEntity>> call({required File avatarFile}) async {
    return await baseUserRepository.updateUserAvatar(avatarFile: avatarFile);
  }
}