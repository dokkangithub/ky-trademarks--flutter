import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Issues/DominRepositery/BaseIssuesRepository.dart';
import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';
import '../../../app/Failure.dart';

class GetIssuesSummaryUseCase {
  final BaseIssuesRepository baseIssuesRepository;

  GetIssuesSummaryUseCase(this.baseIssuesRepository);

  Future<Either<Failure, IssuesSummaryDataEntity>> call({
    required int customerId,
  }) async {
    return await baseIssuesRepository.getIssuesSummary(
      customerId: customerId,
    );
  }
} 