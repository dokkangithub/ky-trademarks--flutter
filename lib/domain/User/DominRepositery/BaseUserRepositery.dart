import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/User/Entities/UserEntity.dart';

import '../../../app/Failure.dart';

abstract class BaseUserRepository {
  Future<Either<Failure, UserDataEntity>> getUserData();
  Future<Either<Failure, UserDataEntity>> updateUserAvatar({required File avatarFile});

}