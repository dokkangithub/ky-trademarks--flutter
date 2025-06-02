import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';
 import 'package:kyuser/domain/SuccessPartenrs/DominRepositery/BaseSuccessPartnersRepository.dart';
 import '../../../app/Failure.dart';

class GetSuccessPartnersUseCase {
 final BaseSuccessPartnersRepository baseSuccessPartnersRepository;
 GetSuccessPartnersUseCase(this.baseSuccessPartnersRepository);
  Future<Either<Failure, List<BrandImages>>> call() async {
    return await baseSuccessPartnersRepository.successPartners();
  }
}