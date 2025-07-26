import 'dart:convert';
import 'package:kyuser/data/Brand/models/BrandDataModel.dart';
import 'package:http/http.dart' as http;
import 'package:kyuser/data/BrandDetails/models/BrandDetailsDataModel.dart';
import 'package:kyuser/data/Reservation/models/ReservationModel.dart';
import 'package:kyuser/network/SuccessResponse.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../network/ErrorModel.dart';
import '../../../utilits/Local_User_Data.dart';

abstract class BaseSendResevationRemotoData {
  Future<SuccessResponse> sendReservationToRemote(
      {required Map<String,String> json});
}

class SendReservationToRemoteData extends BaseSendResevationRemotoData {
  @override
  Future<SuccessResponse> sendReservationToRemote(
      {required Map<String,String> json}) async {
    print(json);
    final result = await http.post(Uri.parse(
        "${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.contacts}",),body: json);

    if (result.statusCode == 200) {
      return SuccessResponse(message:"تم تنفيذ طلبك بنجاح");
    } else {

      return SuccessResponse(message:"فشل تنفيذ الطلب");

    }
  }

}
