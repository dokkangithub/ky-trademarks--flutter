import 'package:dartz/dartz.dart';

import '../../../app/Failure.dart';
import '../../../network/SuccessResponse.dart';

abstract class BaseReservationRepository {
  Future<Either<Failure, SuccessResponse>> sendReservationByUser({required Map<String,String> json});
}
