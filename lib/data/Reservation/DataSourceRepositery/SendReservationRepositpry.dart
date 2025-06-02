import 'package:dartz/dartz.dart';
import 'package:kyuser/app/Failure.dart';
import 'package:kyuser/data/Reservation/DataSource/SendResevationRemotoData.dart';
import 'package:kyuser/domain/Reservation/DominRepositery/BaseReservationRepositery.dart';
 import 'package:kyuser/network/SuccessResponse.dart';

import '../../../network/ErrorModel.dart';

class SendReservationRepository extends BaseReservationRepository {
  final BaseSendResevationRemotoData baseSendResevationRemotoData;

  SendReservationRepository({required this.baseSendResevationRemotoData});

  @override
  Future<Either<Failure, SuccessResponse>> sendReservationByUser({required Map<String,String> json}) async {
    try {
      final result =
          await baseSendResevationRemotoData.sendReservationToRemote(json:json);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }

}
