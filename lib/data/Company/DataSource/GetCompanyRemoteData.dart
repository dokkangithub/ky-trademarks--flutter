// lib/data/Company/DataSource/GetCompanyRemoteData.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kyuser/data/Company/models/CompanyDataModel.dart';
import 'package:http/http.dart' as http;
import 'package:kyuser/utilits/Local_User_Data.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../network/ErrorModel.dart';

abstract class BaseGetCompanyRemoteData {
  Future<CompanyDataModel> getAllCompaniesFromRemote();
}

class GetCompanyRemoteData extends BaseGetCompanyRemoteData {
  @override
  Future<CompanyDataModel> getAllCompaniesFromRemote() async {
    final result = await http.get(Uri.parse(
        "${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.getCompany}${globalAccountData.getId()}"));

    debugPrint('=======companies======');
    debugPrint(result.request!.url.toString());
    debugPrint(result.body);

    if (result.statusCode == 200) {
      return CompanyDataModel.fromJson(json.decode(result.body));
    } else {
      throw ServerException(
          errorModel: ErrorModel.fromJson(json.decode(result.body)));
    }
  }
}