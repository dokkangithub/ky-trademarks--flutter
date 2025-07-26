import 'package:equatable/equatable.dart';
import 'package:kyuser/UserData/data/models/UserModel.dart';

class UsersDataEntity extends Equatable {
 final int status;
 final String message;
 final  Users data;

  const UsersDataEntity({
   required this.status,required this.message,required this.data});

  @override
  // TODO: implement props
  List<Object?> get props =>[status,message,data];

}

class singleUserEntity extends Equatable{

final  int id;
final int activeStatus;
final String name;
final String email;
final String phone;
final String adminPhone;
final int pin_code;
final String token;
  const singleUserEntity({
    required this.id,
    required this.activeStatus,
    required this.name,
    required this.email,
    required this.phone,
    required this.adminPhone,
    required this.pin_code,
    required this.token
  });


  @override
  // TODO: implement props
  List<Object?> get props => [id,activeStatus,name,email,phone,adminPhone,pin_code];

}