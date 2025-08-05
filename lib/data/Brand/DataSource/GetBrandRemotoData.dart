import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:kyuser/data/Brand/models/BrandDataModel.dart';
import 'package:http/http.dart' as http;
import 'package:kyuser/utilits/Local_User_Data.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../network/ErrorModel.dart';

abstract class BaseGetBrandRemoteData {
  Future<BrandDataModel> getAllBrandFromRemote({required int page ,required int companyId});
}

class GetBrandRemoteData extends BaseGetBrandRemoteData {
  @override
  Future<BrandDataModel> getAllBrandFromRemote({required int page,required int companyId }) async {
    final result = await http.get(Uri.parse(
        "${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.getBrands}${globalAccountData.getId()}/$companyId?page=$page"),headers: {'Authorization': 'Bearer ${globalAccountData.getToken()}','Content-Type':'application/json','Accept':"application/json"});
    debugPrint('=======brands======');
    print('111111${globalAccountData.getId()}');
    print('111111${companyId}');
    debugPrint(result.request!.url.toString());
    debugPrint(result.body);
    print(Uri.parse(
        "${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.getBrands}${globalAccountData.getId()}"));
    if (result.statusCode == 200) {
      return BrandDataModel.fromJson(json.decode(result.body));
    } else {
      throw ServerException(
          errorModel: ErrorModel.fromJson(json.decode(result.body)));
    }
  }

  Future<String> adminPhone() async {
    try {
      print('Starting adminPhone request');
      final Uri url = Uri.parse("${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.adminPhone}");
      print('Request URL: $url');

      // Check if we're on web platform
      if (kIsWeb) {
        print('Running on web platform');
        return "201004000856";
      }

      final result = await http.get(url,headers: {'Authorization': 'Bearer ${globalAccountData.getToken()}',});
      print('Response status code: ${result.statusCode}');

      if (result.statusCode == 200) {
        var data = json.decode(result.body);
        print('Parsed data: $data');
        return data["user"]["phone"];
      } else {
        throw ServerException(
            errorModel: ErrorModel.fromJson(json.decode(result.body)));
      }
    } catch (e) {
      print('Exception in adminPhone: $e');
      throw e;
    }
  }

}