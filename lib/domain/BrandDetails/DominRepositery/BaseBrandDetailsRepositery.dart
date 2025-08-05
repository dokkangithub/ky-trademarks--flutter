import 'package:dartz/dartz.dart';

import '../../../app/Failure.dart';
import '../Entities/BrandDetailsDataEntity.dart';

abstract class BaseBrandDetailsRepository {
  Future<Either<Failure, BrandDetailsDataEntity>> getBrandDetails({required int brandNumber});
 }
