 import 'package:kyuser/domain/Request/Entities/RequestDataEntity.dart';
import 'package:kyuser/domain/Reservation/Entities/ReservationDataEntity.dart';

class RequestDataModel extends RequestDataEntity {
  const RequestDataModel(
      {required super.status,
      required super.message,
      required super.requestEntity});


}

class RequestModel extends RequestEntity {
   RequestModel(
      {required super.name,
      required super.description,
      required super.images,

      });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'images': images,

  };
}
