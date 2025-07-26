// lib/data/Company/DataSourceRepositery/CompanyRepository.dart
import 'package:dartz/dartz.dart';
import 'package:kyuser/app/Failure.dart';
import 'package:kyuser/data/Company/DataSource/GetCompanyRemoteData.dart';
import 'package:kyuser/domain/Company/DominRepositery/BaseCompanyRepositery.dart';
import 'package:kyuser/domain/Company/Entities/CompanyEntity.dart';
import '../../../network/ErrorModel.dart';

class CompanyRepository extends BaseCompanyRepository {
  final BaseGetCompanyRemoteData baseGetCompanyRemoteData;

  CompanyRepository({required this.baseGetCompanyRemoteData});

  @override
  Future<Either<Failure, CompanyDataEntity>> getAllCompanies(context) async {
    try {
      final result = await baseGetCompanyRemoteData.getAllCompaniesFromRemote(context);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }
}