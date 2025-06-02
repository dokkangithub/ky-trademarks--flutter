import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';

import '../../../app/Failure.dart';

abstract class BaseBrandRepository {
  Future<Either<Failure, BrandDataEntity>> getAllBrands({required int page ,required int companyId});
}
