import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Issues/DominRepositery/BaseIssuesRepository.dart';
import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';
import '../../../app/Failure.dart';

class GetIssueDetailsUseCase {
  final BaseIssuesRepository baseIssuesRepository;

  GetIssueDetailsUseCase(this.baseIssuesRepository);

  Future<Either<Failure, IssueDetailsDataEntity>> call({
    required int issueId,
    required int customerId,
  }) async {
    return await baseIssuesRepository.getIssueDetails(
      issueId: issueId,
      customerId: customerId,
    );
  }
} 