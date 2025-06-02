import 'package:dartz/dartz.dart';
import '../../../app/Failure.dart';
import '../../../network/SuccessResponse.dart';

abstract class BaseRequestRepository {
  Future<Either<Failure, SuccessResponse>> sendRequestByUser({
    required Map<String, String> json,
    required dynamic image1, // Changed to dynamic
    dynamic image2,
    dynamic image3,
  });
}