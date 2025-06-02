// lib/domain/Company/DominRepositery/BaseCompanyRepositery.dart
import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Company/Entities/CompanyEntity.dart';
import '../../../app/Failure.dart';

abstract class BaseCompanyRepository {
  Future<Either<Failure, CompanyDataEntity>> getAllCompanies();
}