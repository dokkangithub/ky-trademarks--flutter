import 'package:dartz/dartz.dart';
import 'package:kyuser/app/Failure.dart';
import 'package:kyuser/data/BrandDetails/DataSource/GetBrandDetailsRemotoData.dart';
import 'package:kyuser/domain/BrandDetails/DominRepositery/BaseBrandDetailsRepositery.dart';
import 'package:kyuser/domain/BrandDetails/Entities/BrandDetailsDataEntity.dart';

import '../../../network/ErrorModel.dart';

class BrandDetailsRepository extends BaseBrandDetailsRepository {
  final BaseGetBrandDetailsRemoteData baseGetBrandDetailsRemoteData;

  BrandDetailsRepository({required this.baseGetBrandDetailsRemoteData});

  @override
  Future<Either<Failure, BrandDetailsDataEntity>> getBrandDetails({required int brandNumber}) async {
    try {
      final result =
          await baseGetBrandDetailsRemoteData.getBrandDetailsFromRemote(brandNumber:brandNumber);

      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }


}
