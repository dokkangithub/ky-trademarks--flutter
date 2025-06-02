import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';

import '../../../app/Failure.dart';

abstract class BaseBrandGettingBySearchRepository {
  Future<Either<Failure, BrandDataEntity>> getAllBrandsBySearch({required keyWord,required int page});
}
