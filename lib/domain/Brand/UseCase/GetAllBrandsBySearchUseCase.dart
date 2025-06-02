import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Brand/DominRepositery/BaseBrandGettingBySearchRepositery.dart';
import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';
import '../../../app/Failure.dart';

class GetAllBrandsBySearchUseCase {
  final BaseBrandGettingBySearchRepository baseBrandGettingBySearchRepository;

  GetAllBrandsBySearchUseCase(this.baseBrandGettingBySearchRepository);

  Future<Either<Failure, BrandDataEntity>> call({required keyWord, required int page}) async {
    return await baseBrandGettingBySearchRepository.getAllBrandsBySearch(
        keyWord: keyWord, page: page);
  }
}
