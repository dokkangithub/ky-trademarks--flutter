import 'package:kyuser/domain/User/Entities/UserEntity.dart';

class UserDataModel extends UserDataEntity {
  const UserDataModel({
    required super.status,
    required super.message,
    super.user,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
}

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.avatar,
    required super.name,
    required super.phone,
    required super.email,
    required super.status,
    required super.printReport,
    required super.token,
    required super.pinCode,
    super.address,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      avatar: json['avatar'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      printReport: json['print_report'] as String? ?? '',
      token: json['token'] as String? ?? '',
      pinCode: json['pin_code'] as int? ?? 0,
      address: json['address'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}