import 'package:dartz/dartz.dart';
import 'package:kyuser/UserData/domain/DominRepositery/BaseLoginRepositery.dart';
import '../../../app/Failure.dart';
import '../Entities/UserEntity.dart';

class GetUserDataWithLogin  {
  BaseBaseLoginRepository baseBaseLoginRepository;

  GetUserDataWithLogin({required this.baseBaseLoginRepository});

  Future<Either<Failure, UsersDataEntity>> call() async {
    return await baseBaseLoginRepository.loginWithEmailAndPassword();
  }
}
