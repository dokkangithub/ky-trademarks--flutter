import 'dart:convert';
import 'package:kyuser/data/Brand/models/BrandDataModel.dart';
import 'package:http/http.dart' as http;
import '../../../core/Constant/Api_Constant.dart';
import '../../../network/ErrorModel.dart';
import '../../../utilits/Local_User_Data.dart';

abstract class BaseGetSuccessPartnerRemoteData {
  Future<List<ImagesModel>> successPartner();
}

class GetSuccessPartnerRemotoData extends BaseGetSuccessPartnerRemoteData {
  @override
  Future<List<ImagesModel>> successPartner() async {
     final result = await http.get(Uri.parse(
        "${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.partenrs}"),headers: {'Authorization': 'Bearer ${globalAccountData.getToken()}','Content-Type': 'application/json',
       'Accept': "application/json"});
     print("${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.partenrs}");
    if (result.statusCode == 200) {
      print(result.body);
      var state=json.decode(result.body);
      return  List<ImagesModel>.from(state["partenrs"].map((e)=>ImagesModel.fromJson(e))).toList();
    } else {
      throw ServerException(errorModel:json.decode(result.body));

    }
  }

}
