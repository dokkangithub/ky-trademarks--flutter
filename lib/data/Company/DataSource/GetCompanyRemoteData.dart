// lib/data/Company/DataSource/GetCompanyRemoteData.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kyuser/data/Company/models/CompanyDataModel.dart';
import 'package:http/http.dart' as http;
import 'package:kyuser/utilits/Local_User_Data.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../network/ErrorModel.dart';
import '../../../presentation/Screens/login/Login.dart';

abstract class BaseGetCompanyRemoteData {
  Future<CompanyDataModel> getAllCompaniesFromRemote(context);
}

class GetCompanyRemoteData extends BaseGetCompanyRemoteData {
  @override
  Future<CompanyDataModel> getAllCompaniesFromRemote(context) async {
    final result = await http.get(
        Uri.parse(
            "${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.getCompany}${globalAccountData.getId()}"),
        headers: {
          'Authorization': 'Bearer ${globalAccountData.getToken()}',
          'Content-Type': 'application/json',
          'Accept': "application/json"
        });

    debugPrint('=======companies======');
    debugPrint(result.request!.url.toString());
    debugPrint(result.body);

    print('status codeeee ${result.statusCode}');
    if (result.statusCode == 200) {
      return CompanyDataModel.fromJson(json.decode(result.body));
    } else if (result.statusCode == 401 || result.statusCode == 403) {
      // Unauthorized or Forbidden – Navigate to inactive account screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );

      // You still need to return or throw something to satisfy the function's return type
      throw ServerException(
        errorModel: ErrorModel(
            message: "الحساب غير مفعل", statusCode: result.statusCode),
      );
    } else {
      throw ServerException(
          errorModel: ErrorModel.fromJson(json.decode(result.body)));
    }
  }
}
