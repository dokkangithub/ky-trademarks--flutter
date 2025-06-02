import 'package:equatable/equatable.dart';

import 'RestApi/Comman.dart';

class ErrorModel extends Equatable{
  final String message;
  final int statusCode;
  // final String success;

const  ErrorModel({
  required this.message,required this.statusCode,});
 factory ErrorModel.fromJson(Map<String,dynamic> map){
    return ErrorModel(
     message: map["message"],
     statusCode: map["statusCode"],
     // success :  map["data"]["success"],
   );
 }
  @override
   List<Object?> get props =>[
    message,
    statusCode,
    // success
  ];
}

class ServerException implements Exception {
  ErrorModel errorModel;

  ServerException({required this.errorModel}){
    showToast();
  }
  showToast(){
    return toast(errorModel.message);
  }
}
