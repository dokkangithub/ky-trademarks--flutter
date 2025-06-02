import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:kyuser/app/Failure.dart';
import 'package:kyuser/domain/User/Entities/UserEntity.dart';

import '../../../domain/User/DominRepositery/BaseUserRepositery.dart';
import '../../../network/ErrorModel.dart';
import '../DataSource/GetUserDataRemotoData.dart';

class UserRepository extends BaseUserRepository {
  final BaseGetUserRemoteData baseGetUserRemoteData;

  UserRepository({required this.baseGetUserRemoteData});
  @override
  Future<Either<Failure, UserDataEntity>> getUserData() async {
    try {
      final result = await baseGetUserRemoteData.getUserFromRemote();
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }

  @override
  Future<Either<Failure, UserDataEntity>> updateUserAvatar({required File avatarFile}) async {
    try {
      final result = await baseGetUserRemoteData.updateUserAvatar(avatarFile: avatarFile);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }
}