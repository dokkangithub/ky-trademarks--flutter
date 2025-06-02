import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Brand/DominRepositery/BaseBrandRepositery.dart';
import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';

import '../../../app/Failure.dart';

class GetAllBrandsUseCase {
 final BaseBrandRepository baseBrandRepository;
  GetAllBrandsUseCase(this.baseBrandRepository);
  Future<Either<Failure,BrandDataEntity>> call({required int page ,required int companyId}) async {
    return await baseBrandRepository.getAllBrands(page: page, companyId: companyId);
  }
}