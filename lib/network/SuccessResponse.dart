// ignore_for_file: non_constant_identifier_names


import 'RestApi/Comman.dart';

class SuccessResponse {
  String? message;
  int? status_Code;
  int? quantity;
  num? allCost;

  SuccessResponse(
      {this.message, this.status_Code, this.quantity, this.allCost}) {
    showToast();
  }

  showToast() {
    return toast(message);
  }
}

class SuccessGet {
  List myProduct=[];
  // List<CartEntity>? myProduct=[];
  num? allCost;
  num ? Coupon;
  SuccessGet({required this.myProduct, this.allCost,this.Coupon});
}
