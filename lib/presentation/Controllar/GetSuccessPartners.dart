import 'package:flutter/material.dart';
import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';
import 'package:kyuser/domain/SuccessPartenrs/UseCase/GetSuccessPartnersUseCase.dart';

import '../../app/RequestState/RequestState.dart';
import '../../core/Services_locator.dart';
import '../../network/RestApi/Comman.dart';

class GetSuccessPartners extends ChangeNotifier{
  List<BrandImages>? allPartnerSuccess=[];
  RequestState? state;
  Future<void> getSuccessPartners() async {
    state = RequestState.loading;
    notifyListeners();
    var result = await GetSuccessPartnersUseCase(sl()).call();
    result.fold((l) {
      state = RequestState.failed;
      notifyListeners();
      return toast(l.message.toString());
    }, (r) {
      state = RequestState.loaded;
      notifyListeners();
      return allPartnerSuccess = r;
    });
  }
}