import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';

import '../../../app/Failure.dart';

abstract class BaseSuccessPartnersRepository {
  Future<Either<Failure, List<BrandImages>>> successPartners();
}
