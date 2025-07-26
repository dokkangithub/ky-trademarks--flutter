import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kyuser/data/Brand/models/BrandDataModel.dart';
import 'package:http/http.dart' as http;
import 'package:kyuser/utilits/Local_User_Data.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../network/ErrorModel.dart';

abstract class BaseGetBrandBySearchRemoteData {
  Future<BrandDataModel> getAllBrandBySearchFromRemote({required String keyWard,required int page});
}

class GetBrandBySearchRemoteData extends BaseGetBrandBySearchRemoteData {
  @override
  Future<BrandDataModel> getAllBrandBySearchFromRemote({required String keyWard,required int page}) async {
    print(keyWard);
    print("${ApiConstant.baseUrl}${ApiConstant.firstSearchSecForBrand}${globalAccountData.getId().toString()}"
        "${ApiConstant.secondSearchSecForBrand}$keyWard");
    print(globalAccountData.getId());
    final result = await http.get(
        Uri.parse("${ApiConstant.baseUrl}${ApiConstant.firstSearchSecForBrand}${globalAccountData.getId().toString()}"
            "${ApiConstant.secondSearchSecForBrand}$keyWard&page=$page"),headers: {'Authorization': 'Bearer ${globalAccountData.getToken()}','Content-Type':'application/json','Accept':"application/json"});
    print(
        Uri.parse("${ApiConstant.baseUrl}${ApiConstant.firstSearchSecForBrand}${globalAccountData.getId().toString()}"
            "${ApiConstant.secondSearchSecForBrand}$keyWard"));
    debugPrint("getAllBrandBySearch::::\n"+result.request.toString());

    if (result.statusCode == 200) {
      return BrandDataModel.fromJson(json.decode(result.body));
    } else {
      print(result.body);

      throw ServerException(errorModel: ErrorModel.fromJson(json.decode(result.body)));
    }
  }
}