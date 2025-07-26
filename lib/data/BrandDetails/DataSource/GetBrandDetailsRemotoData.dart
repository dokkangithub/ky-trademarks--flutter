import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:kyuser/data/BrandDetails/models/BrandDetailsDataModel.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../network/ErrorModel.dart';
import '../../../utilits/Local_User_Data.dart';

abstract class BaseGetBrandDetailsRemoteData {
  Future<BrandDetailsDataModel> getBrandDetailsFromRemote(
      {required int brandNumber});

}

class GetBrandDetailsRemoteData extends BaseGetBrandDetailsRemoteData {
  @override
  Future<BrandDetailsDataModel> getBrandDetailsFromRemote(
      {required int brandNumber}) async {
    final result = await http.get(Uri.parse(
        "${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.brandDetails}$brandNumber"),headers: {'Authorization': 'Bearer ${globalAccountData.getToken()}','Content-Type':'application/json','Accept':"application/json"});
    print('=======Brand Details======');
    debugPrint(result.request.toString());
    debugPrint(result.body);
    if (result.statusCode == 200) {
      print('=======Brand Details======');
      debugPrint(result.body);
      print('===============================');

      // print(JsonEncoder.withIndent('  ').convert(json.decode(result.body)));
      return BrandDetailsDataModel.fromJson(json.decode(result.body));
    } else {
      throw ServerException(
          errorModel: ErrorModel.fromJson(json.decode(result.body))


      );
    }
  }

}
