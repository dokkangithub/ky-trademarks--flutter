import 'package:equatable/equatable.dart';

class UserDataEntity extends Equatable {
  final int status;
  final String message;
  final UserEntity user;

  const UserDataEntity({
    required this.status,
    required this.message,
    required this.user
  });

  @override
  List<Object?> get props => [status, message, user];
}

class UserEntity extends Equatable {
  final int id;
  final String avatar;
  final String name;
  final String phone;
  final String email;
  final int status;
  final String printReport;
  final String token;
  final int pinCode;
  final String? address;
  final String createdAt;
  final String updatedAt;

  const UserEntity({
    required this.id,
    required this.avatar,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.printReport,
    required this.token,
    required this.pinCode,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    avatar,
    name,
    phone,
    email,
    status,
    printReport,
    token,
    pinCode,
    address,
    createdAt,
    updatedAt
  ];
}