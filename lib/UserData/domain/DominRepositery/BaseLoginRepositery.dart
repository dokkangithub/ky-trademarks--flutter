
import 'package:dartz/dartz.dart';
import '../../../app/Failure.dart';
import '../Entities/UserEntity.dart';

abstract class BaseBaseLoginRepository {
 Future<Either<Failure,UsersDataEntity>> loginWithEmailAndPassword();
}
