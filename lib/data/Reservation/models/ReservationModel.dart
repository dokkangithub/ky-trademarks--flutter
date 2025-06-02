 import 'package:kyuser/domain/Reservation/Entities/ReservationDataEntity.dart';

class ReservationDataModel extends ReservationDataEntity {
  const ReservationDataModel(
      {required super.status,
      required super.message,
      required super.reservationEntity});


}

class ReservationModel extends ReservationEntity {
  const ReservationModel(
      {required super.name,
      required super.phone,
      required super.nationality,
      required super.email,
      required super.date_of_visit,
      required super.city});

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'nationality': nationality,
    'date_of_visit': date_of_visit,
    'city': city,
    'phone': phone,
  };
}
