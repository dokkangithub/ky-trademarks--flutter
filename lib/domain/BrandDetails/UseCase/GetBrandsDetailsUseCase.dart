import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/BrandDetails/DominRepositery/BaseBrandDetailsRepositery.dart';
import 'package:kyuser/domain/BrandDetails/Entities/BrandDetailsDataEntity.dart';
import '../../../app/Failure.dart';

class GetBrandsDetailsUseCase {
 final BaseBrandDetailsRepository baseBrandDetailsRepository;
 GetBrandsDetailsUseCase(this.baseBrandDetailsRepository);
  Future<Either<Failure,BrandDetailsDataEntity>> call({required int brandNumber}) async {
    return  await baseBrandDetailsRepository.getBrandDetails(brandNumber:brandNumber);
  }

}