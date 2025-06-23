import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kyuser/data/Issues/models/IssuesDataModel.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../network/ErrorModel.dart';

abstract class BaseGetIssuesRemoteData {
  Future<IssuesDataModel> getIssuesFromRemote({
    required int customerId,
    int page = 1,
    int perPage = 10,
  });
  
  Future<IssueDetailsDataModel> getIssueDetailsFromRemote({
    required int issueId,
    required int customerId,
  });
  
  Future<IssuesSummaryDataModel> getIssuesSummaryFromRemote({
    required int customerId,
  });
  
  Future<IssuesSearchDataModel> searchIssuesFromRemote({
    required String query,
    required int customerId,
    int page = 1,
    int perPage = 15,
  });
}

class GetIssuesRemoteData extends BaseGetIssuesRemoteData {
  @override
  Future<IssuesDataModel> getIssuesFromRemote({
    required int customerId,
    int page = 1,
    int perPage = 10,
  }) async {
    final url = Uri.parse(
        "${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.issues}?customer_id=$customerId&page=$page&per_page=$perPage");
    
    debugPrint('=======Issues List======');
    debugPrint('Customer ID: $customerId');
    debugPrint('Page: $page, Per Page: $perPage');
    debugPrint(url.toString());

    final result = await http.get(url);
    
    debugPrint(result.body);

    if (result.statusCode == 200) {
      return IssuesDataModel.fromJson(json.decode(result.body));
    } else {
      throw ServerException(
          errorModel: ErrorModel.fromJson(json.decode(result.body)));
    }
  }

  @override
  Future<IssueDetailsDataModel> getIssueDetailsFromRemote({
    required int issueId,
    required int customerId,
  }) async {
    final url = Uri.parse(
        "${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.issues}/$issueId?customer_id=$customerId");
    
    debugPrint('=======Issue Details======');
    debugPrint('Issue ID: $issueId');
    debugPrint('Customer ID: $customerId');
    debugPrint(url.toString());

    final result = await http.get(url);
    
    debugPrint(result.body);

    if (result.statusCode == 200) {
      return IssueDetailsDataModel.fromJson(json.decode(result.body));
    } else {
      throw ServerException(
          errorModel: ErrorModel.fromJson(json.decode(result.body)));
    }
  }

  @override
  Future<IssuesSummaryDataModel> getIssuesSummaryFromRemote({
    required int customerId,
  }) async {
    final url = Uri.parse(
        "${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.issuesSummary}?customer_id=$customerId");
    
    debugPrint('=======Issues Summary======');
    debugPrint('Customer ID: $customerId');
    debugPrint(url.toString());

    final result = await http.get(url);
    
    debugPrint(result.body);

    if (result.statusCode == 200) {
      return IssuesSummaryDataModel.fromJson(json.decode(result.body));
    } else {
      throw ServerException(
          errorModel: ErrorModel.fromJson(json.decode(result.body)));
    }
  }

  @override
  Future<IssuesSearchDataModel> searchIssuesFromRemote({
    required String query,
    required int customerId,
    int page = 1,
    int perPage = 15,
  }) async {
    final url = Uri.parse(
        "${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.issuesSearch}?query=$query&customer_id=$customerId&page=$page&per_page=$perPage");
    
    debugPrint('=======Issues Search======');
    debugPrint('Query: $query');
    debugPrint('Customer ID: $customerId');
    debugPrint('Page: $page, Per Page: $perPage');
    debugPrint(url.toString());

    final result = await http.get(url);
    
    debugPrint(result.body);

    if (result.statusCode == 200) {
      return IssuesSearchDataModel.fromJson(json.decode(result.body));
    } else {
      throw ServerException(
          errorModel: ErrorModel.fromJson(json.decode(result.body)));
    }
  }
} 