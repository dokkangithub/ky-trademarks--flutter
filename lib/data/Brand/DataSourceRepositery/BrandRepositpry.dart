import 'package:dartz/dartz.dart';
import 'package:kyuser/app/Failure.dart';
import 'package:kyuser/data/Brand/DataSource/GetBrandRemotoData.dart';
import 'package:kyuser/domain/Brand/DominRepositery/BaseBrandRepositery.dart';
import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';

import '../../../network/ErrorModel.dart';

class BrandRepository extends BaseBrandRepository{
  final BaseGetBrandRemoteData baseGetBrandRemoteData;

  BrandRepository({required this.baseGetBrandRemoteData});
  @override
  Future<Either<Failure, BrandDataEntity>> getAllBrands({int page = 1,required int companyId}) async {
    try {

      final result = await baseGetBrandRemoteData.getAllBrandFromRemote(page: page, companyId: companyId);

      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }

}