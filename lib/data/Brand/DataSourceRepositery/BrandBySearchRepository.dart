//BrandBySearchRepository
import 'package:dartz/dartz.dart';
import 'package:kyuser/app/Failure.dart';
import 'package:kyuser/data/Brand/DataSource/GetBrandBySearchRemotoData.dart';
 import 'package:kyuser/domain/Brand/DominRepositery/BaseBrandGettingBySearchRepositery.dart';
 import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';

import '../../../network/ErrorModel.dart';

class BrandBySearchRepository extends BaseBrandGettingBySearchRepository{
  final BaseGetBrandBySearchRemoteData baseGetBrandBySearchRemoteData;

  BrandBySearchRepository({required this.baseGetBrandBySearchRemoteData});
  @override
  Future<Either<Failure, BrandDataEntity>> getAllBrandsBySearch({required keyWord,required int page}) async {
    try {

      final result = await baseGetBrandBySearchRemoteData.getAllBrandBySearchFromRemote(keyWard: keyWord, page: page,);

      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }



}