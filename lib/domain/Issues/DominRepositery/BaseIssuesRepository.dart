import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';
import '../../../app/Failure.dart';

abstract class BaseIssuesRepository {
  Future<Either<Failure, IssuesDataEntity>> getIssues({
    required int customerId,
    int page = 1,
    int perPage = 10,
  });
  
  Future<Either<Failure, IssueDetailsDataEntity>> getIssueDetails({
    required int issueId,
    required int customerId,
  });
  
  Future<Either<Failure, IssuesSummaryDataEntity>> getIssuesSummary({
    required int customerId,
  });
  
  Future<Either<Failure, IssuesSearchDataEntity>> searchIssues({
    required String query,
    required int customerId,
    int page = 1,
    int perPage = 15,
  });
} 