import 'package:dartz/dartz.dart';
import 'package:kyuser/app/Failure.dart';
import 'package:kyuser/data/SuccessPartners/DataSource/GetSuccessPartnerRemotoData.dart';
import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';
import 'package:kyuser/domain/SuccessPartenrs/DominRepositery/BaseSuccessPartnersRepository.dart';

import '../../../network/ErrorModel.dart';

class SuccessPartnerRepositey extends BaseSuccessPartnersRepository {
  final BaseGetSuccessPartnerRemoteData baseGetSuccessPartnerRemoteData;

  SuccessPartnerRepositey({required this.baseGetSuccessPartnerRemoteData});



  @override
  Future<Either<Failure, List<BrandImages>>> successPartners()async {
    try {
      final result = await baseGetSuccessPartnerRemoteData.successPartner();
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }
}
