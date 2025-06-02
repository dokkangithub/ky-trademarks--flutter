//ReservationProvider
import 'package:flutter/material.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import '../../core/Services_locator.dart';
import '../../domain/Reservation/UseCase/PostReservationUseCase.dart';
class ReservationProvider extends ChangeNotifier {
  RequestState state=RequestState.loading;
  Future<void> sendReservation(  Map<String,String> json) async {
    state = RequestState.loading;
    notifyListeners();
    var result = await PostReservationUseCase(sl()).call(json: json);
    result.fold((l) {
      state = RequestState.failed;
      notifyListeners();
      return toast(l.message.toString());
    }, (r) {
      state = RequestState.loaded;
      notifyListeners();
    });
  }
}
