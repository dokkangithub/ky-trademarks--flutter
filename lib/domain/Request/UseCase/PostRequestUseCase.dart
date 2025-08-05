import 'package:dartz/dartz.dart';
import 'package:kyuser/domain/Request/DominRepositery/BaseRequestRepositery.dart';
import '../../../app/Failure.dart';
import '../../../network/SuccessResponse.dart';

class PostRequestUseCase {
 final BaseRequestRepository baseRequestRepository;

 PostRequestUseCase(this.baseRequestRepository);

 Future<Either<Failure, SuccessResponse>> call({
  required Map<String, String> json,
  required dynamic image1, // Changed to dynamic
  dynamic image2,
  dynamic image3,
 }) async {
  return await baseRequestRepository.sendRequestByUser(
   json: json,
   image1: image1,
   image2: image2,
   image3: image3,
  );
 }
}