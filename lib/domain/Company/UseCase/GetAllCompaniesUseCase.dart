// lib/domain/Company/UseCase/GetAllCompaniesUseCase.dart
import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Company/DominRepositery/BaseCompanyRepositery.dart';
import 'package:kyuser/domain/Company/Entities/CompanyEntity.dart';
import '../../../app/Failure.dart';

class GetAllCompaniesUseCase {
  final BaseCompanyRepository baseCompanyRepository;

  GetAllCompaniesUseCase(this.baseCompanyRepository);

  Future<Either<Failure, CompanyDataEntity>> call() async {
    return await baseCompanyRepository.getAllCompanies();
  }
}