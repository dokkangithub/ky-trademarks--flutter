import 'package:equatable/equatable.dart';

class ReservationDataEntity extends Equatable {
  final int status;
  final String message;
  final ReservationEntity reservationEntity;

  const ReservationDataEntity({required this.status,required this.message,required this.reservationEntity});

  @override
  // TODO: implement props
  List<Object?> get props => [status,message,reservationEntity];

}

class ReservationEntity extends Equatable {
  final String name;
  final String phone;
  final String nationality;
  final String email;
  final String date_of_visit;
  final String city;

  const ReservationEntity(
      {required this.name,
      required this.phone,
      required this.nationality,
      required this.email,
      required this.date_of_visit,
      required this.city});

  @override
  // TODO: implement props
  List<Object?> get props => [name,phone,nationality,email,date_of_visit,city];
}
