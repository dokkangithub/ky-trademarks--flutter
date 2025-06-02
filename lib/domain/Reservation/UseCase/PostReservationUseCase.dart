import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Reservation/DominRepositery/BaseReservationRepositery.dart';
 import '../../../app/Failure.dart';
import '../../../network/SuccessResponse.dart';

class PostReservationUseCase {
 final BaseReservationRepository baseReservationRepository;
 PostReservationUseCase(this.baseReservationRepository);
  Future<Either<Failure,SuccessResponse>> call({required Map<String,String> json}) async {
    return await baseReservationRepository.sendReservationByUser(json:json);
  }
}