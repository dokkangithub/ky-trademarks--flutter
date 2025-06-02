import 'package:dartz/dartz.dart';
import 'package:kyuser/app/Failure.dart';
import 'package:kyuser/network/SuccessResponse.dart';
import '../../../domain/Request/DominRepositery/BaseRequestRepositery.dart';
import '../../../network/ErrorModel.dart';
import '../DataSource/SendRequestRemotoData.dart';

class SendRequestRepository extends BaseRequestRepository {
  final BaseSendRequestRemotoData baseSendRequestRemotoData;

  SendRequestRepository({required this.baseSendRequestRemotoData});

  @override
  Future<Either<Failure, SuccessResponse>> sendRequestByUser({
    required Map<String, String> json,
    required dynamic image1, // Changed to dynamic
    dynamic image2,
    dynamic image3,
  }) async {
    try {
      final result = await baseSendRequestRemotoData.sendRequestToRemote(
        data: json,
        image1: image1,
        image2: image2,
        image3: image3,
      );
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.errorModel.message));
    }
  }
}