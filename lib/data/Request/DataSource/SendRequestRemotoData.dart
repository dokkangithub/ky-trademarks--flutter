
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:io' as file;

import 'package:kyuser/network/SuccessResponse.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../network/RestApi/Comman.dart';

import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:image_picker/image_picker.dart'; // For XFile

abstract class BaseSendRequestRemotoData {
  Future<SuccessResponse> sendRequestToRemote({
    required Map<String, String> data,
    required dynamic image1, // Changed to dynamic
    dynamic image2,
    dynamic image3,
  });
}



class SendRequestToRemoteData extends BaseSendRequestRemotoData {
  @override
  Future<SuccessResponse> sendRequestToRemote({
    required Map<String, String> data,
    required dynamic image1, // Accepts File or XFile
    dynamic image2,
    dynamic image3,
  }) async {
    print(data);
    final url = Uri.parse("${ApiConstant.baseUrl}${ApiConstant.slug}requests");

    try {
      http.MultipartRequest request = http.MultipartRequest("POST", url);

      // Handle images based on platform
      if (kIsWeb) {
        // Web: Handle XFile
        if (image1 != null) {
          final bytes = await (image1 as XFile).readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'image1',
            bytes,
            filename: 'image1.jpg',
          ));
        }
        if (image2 != null) {
          final bytes = await (image2 as XFile).readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'image2',
            bytes,
            filename: 'image2.jpg',
          ));
        }
        if (image3 != null) {
          final bytes = await (image3 as XFile).readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'image3',
            bytes,
            filename: 'image3.jpg',
          ));
        }
      } else {
        // Non-web: Handle File
        if (image1 != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'image1',
            (image1 as file.File).path,
            filename: 'image1.jpg',
          ));
        }
        if (image2 != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'image2',
            (image2 as file.File).path,
            filename: 'image2.jpg',
          ));
        }
        if (image3 != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'image3',
            (image3 as file.File).path,
            filename: 'image3.jpg',
          ));
        }
      }

      // Add the JSON fields
      request.fields.addAll(data);

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('=========request response body:===========');
      print(response.body);

      if (response.statusCode == 200) {
        print("-------------------");
        return SuccessResponse(message: "تم تنفيذ طلبك بنجاح");
      } else {
        final errorMessage = json.decode(response.body)["message"] ?? "فشل تنفيذ الطلب";
        return SuccessResponse(message: errorMessage);
      }
    } catch (e) {
      print(e.toString());
      toast(e.toString()); // Assuming toast is available from Comman.dart
      return SuccessResponse(message: "فشل تنفيذ طلبك: $e");
    }
  }
}


