import 'dart:convert';
import 'dart:io' as file;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // For XFile
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import '../../core/Services_locator.dart';
import '../../domain/Request/UseCase/PostRequestUseCase.dart';

class RequestProvider extends ChangeNotifier {
  RequestState? state;

  Future<void> sendRequest(
      Map<String, String> json, {
        dynamic image1, // Changed to dynamic to accept File or XFile
        dynamic image2,
        dynamic image3,
      }) async {
    state = RequestState.loading;
    notifyListeners();

    try {
      // Ensure at least image1 is provided (as per your UI logic)
      if (image1 == null) {
        state = RequestState.failed;
        notifyListeners();
        toast("photo_at_least".tr()); // Assuming toast is available via Comman.dart
        return;
      }

      // Call the use case with the provided images
      var result = await PostRequestUseCase(sl()).call(
        json: json,
        image1: image1,
        image2: image2,
        image3: image3,
      );

      result.fold(
            (l) {
          state = RequestState.failed;
          notifyListeners();
          toast(l.message.toString()); // Show error message
        },
            (r) {
          state = RequestState.loaded;
          notifyListeners();
        },
      );
    } catch (e) {
      state = RequestState.failed;
      notifyListeners();
      toast("An unexpected error occurred: $e");
    }
  }
}