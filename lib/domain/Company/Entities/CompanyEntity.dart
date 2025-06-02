// lib/domain/Company/Entities/CompanyEntity.dart
import 'package:equatable/equatable.dart';

class CompanyDataEntity extends Equatable {
  final int status;
  final String message;
  final List<CompanyEntity> company;

  const CompanyDataEntity({
    required this.status,
    required this.message,
    required this.company,
  });

  @override
  List<Object?> get props => [status, message, company];
}

class CompanyEntity extends Equatable {
  final int id;
  final String? avatar;
  final String companyName;
  final String address;

  const CompanyEntity({
    required this.id,
    required this.avatar,
    required this.companyName,
    required this.address,
  });

  @override
  List<Object?> get props => [id, avatar, companyName, address];
}