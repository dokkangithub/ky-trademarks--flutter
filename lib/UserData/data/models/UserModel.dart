import 'package:kyuser/UserData/domain/Entities/UserEntity.dart';

class UserModel extends UsersDataEntity {
  const UserModel({
    required super.message,
    required super.status,
    required super.data,

  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? {};
    final customerJson = userJson['customer'] ?? {};
    final adminJson = userJson['admin'] ?? {};

    return UserModel(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: Users.fromJson(customerJson, adminJson),
    );
  }


}

class Users extends singleUserEntity {


  const Users({
    required super.id, required super.name, required super.phone,
    required super.email, required super.activeStatus,required super.adminPhone,required super.pin_code});


  factory Users.fromJson(Map<String, dynamic> customerJson, Map<String, dynamic> adminJson) {
    return Users(
      id: customerJson['id'] ?? 0,
      name: customerJson['name'] ?? '',
      phone: customerJson['phone'] ?? '',
      email: customerJson['email'] ?? '',
      pin_code: customerJson['pin_code'] ?? '',
      adminPhone: adminJson['phone'] ?? '',
      activeStatus: customerJson['status'] ?? 0,
    );
  }
}

