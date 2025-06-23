import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Issues/DominRepositery/BaseIssuesRepository.dart';
import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';
import '../../../app/Failure.dart';

class SearchIssuesUseCase {
  final BaseIssuesRepository baseIssuesRepository;

  SearchIssuesUseCase(this.baseIssuesRepository);

  Future<Either<Failure, IssuesSearchDataEntity>> call({
    required String query,
    required int customerId,
    int page = 1,
    int perPage = 15,
  }) async {
    return await baseIssuesRepository.searchIssues(
      query: query,
      customerId: customerId,
      page: page,
      perPage: perPage,
    );
  }
} 