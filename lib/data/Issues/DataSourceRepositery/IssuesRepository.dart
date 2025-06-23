import 'package:dartz/dartz.dart';
import 'package:kyuser/app/Failure.dart';
import 'package:kyuser/data/Issues/DataSource/GetIssuesRemoteData.dart';
import 'package:kyuser/domain/Issues/DominRepositery/BaseIssuesRepository.dart';
import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';
import '../../../network/ErrorModel.dart';

class IssuesRepository extends BaseIssuesRepository {
  final BaseGetIssuesRemoteData baseGetIssuesRemoteData;

  IssuesRepository({required this.baseGetIssuesRemoteData});

  @override
  Future<Either<Failure, IssuesDataEntity>> getIssues({
    required int customerId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final result = await baseGetIssuesRemoteData.getIssuesFromRemote(
        customerId: customerId,
        page: page,
        perPage: perPage,
      );
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }

  @override
  Future<Either<Failure, IssueDetailsDataEntity>> getIssueDetails({
    required int issueId,
    required int customerId,
  }) async {
    try {
      final result = await baseGetIssuesRemoteData.getIssueDetailsFromRemote(
        issueId: issueId,
        customerId: customerId,
      );
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }

  @override
  Future<Either<Failure, IssuesSummaryDataEntity>> getIssuesSummary({
    required int customerId,
  }) async {
    try {
      final result = await baseGetIssuesRemoteData.getIssuesSummaryFromRemote(
        customerId: customerId,
      );
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }

  @override
  Future<Either<Failure, IssuesSearchDataEntity>> searchIssues({
    required String query,
    required int customerId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final result = await baseGetIssuesRemoteData.searchIssuesFromRemote(
        query: query,
        customerId: customerId,
        page: page,
        perPage: perPage,
      );
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }
} 