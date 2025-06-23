import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Issues/DominRepositery/BaseIssuesRepository.dart';
import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';
import '../../../app/Failure.dart';

class GetIssuesUseCase {
  final BaseIssuesRepository baseIssuesRepository;

  GetIssuesUseCase(this.baseIssuesRepository);

  Future<Either<Failure, IssuesDataEntity>> call({
    required int customerId,
    int page = 1,
    int perPage = 10,
  }) async {
    return await baseIssuesRepository.getIssues(
      customerId: customerId,
      page: page,
      perPage: perPage,
    );
  }
} 