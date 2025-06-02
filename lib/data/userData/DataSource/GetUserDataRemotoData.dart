import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kyuser/utilits/Local_User_Data.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../network/ErrorModel.dart';
import '../models/UserData.dart';

abstract class BaseGetUserRemoteData {
  Future<UserDataModel> getUserFromRemote();
  Future<UserDataModel> updateUserAvatar({required File avatarFile});

}

class GetUserRemoteData extends BaseGetUserRemoteData {
  @override
  Future<UserDataModel> getUserFromRemote() async {
    // Get user email from local data
    String userEmail = globalAccountData.getEmail().toString();

    // Create URI with query parameter
    final uri = Uri.parse(
        "${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.getAvatar}")
        .replace(queryParameters: {'email': userEmail});

    debugPrint('=======user data endpoint======');
    debugPrint(uri.toString());

    final result = await http.get(uri);

    debugPrint('=======user data response======');
    debugPrint('Status code: ${result.statusCode}');
    debugPrint(result.body);

    if (result.statusCode == 200) {
      try {
        return UserDataModel.fromJson(json.decode(result.body));
      } catch (e) {
        debugPrint('JSON parsing error: $e');
        throw ServerException(
            errorModel: ErrorModel(message: "Failed to parse response: $e", statusCode: 500));
      }
    } else {
      debugPrint('Server error with status: ${result.statusCode}');
      try {
        return throw ServerException(
            errorModel: ErrorModel.fromJson(json.decode(result.body)));
      } catch (e) {
        // If we can't parse the JSON error, create a generic one
        throw ServerException(
            errorModel: ErrorModel(
                message: "Server error with status: ${result.statusCode}",
                statusCode: result.statusCode));
      }
    }
  }

  @override
  Future<UserDataModel> updateUserAvatar({required File avatarFile}) async {
    // Get user email from local data
    String userEmail = globalAccountData.getEmail().toString();

    // Create multipart request
    var request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConstant.baseUrl}${ApiConstant.slug}${ApiConstant.updateProfile}")
    );

    // Add email field
    request.fields['email'] = userEmail;

    // Add file
    var fileStream = http.ByteStream(avatarFile.openRead());
    var fileLength = await avatarFile.length();

    var multipartFile = http.MultipartFile(
        'avatar',
        fileStream,
        fileLength,
        filename: avatarFile.path.split('/').last
    );

    request.files.add(multipartFile);

    debugPrint('=======update profile request======');
    debugPrint(request.url.toString());

    // Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    debugPrint('=======update profile response======');
    debugPrint('Status code: ${response.statusCode}');
    debugPrint(response.body);

    if (response.statusCode == 200) {
      try {
        return UserDataModel.fromJson(json.decode(response.body));
      } catch (e) {
        debugPrint('JSON parsing error: $e');
        throw ServerException(
            errorModel: ErrorModel(message: "Failed to parse response: $e", statusCode: 500));
      }
    } else {
      debugPrint('Server error with status: ${response.statusCode}');
      try {
        throw ServerException(
            errorModel: ErrorModel.fromJson(json.decode(response.body)));
      } catch (e) {
        throw ServerException(
            errorModel: ErrorModel(
                message: "Server error with status: ${response.statusCode}",
                statusCode: response.statusCode));
      }
    }
  }
}