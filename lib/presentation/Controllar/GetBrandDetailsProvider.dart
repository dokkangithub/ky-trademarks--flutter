import 'package:flutter/material.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/data/BrandDetails/DataSource/GetBrandDetailsRemotoData.dart';
import 'package:kyuser/data/BrandDetails/models/BrandDetailsDataModel.dart';
import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';
import 'package:kyuser/domain/BrandDetails/Entities/BrandDetailsDataEntity.dart';
import 'package:kyuser/domain/BrandDetails/UseCase/GetBrandsDetailsUseCase.dart';
import 'package:kyuser/network/RestApi/Comman.dart';

import '../../core/Services_locator.dart';
import '../../data/Brand/DataSource/GetBrandRemotoData.dart';
import '../../data/Brand/models/BrandDataModel.dart';

class GetBrandDetailsProvider extends ChangeNotifier {
  BrandDetailsDataEntity? brandDetails;

  RequestState? state;
  RequestState? statePdf;

  Future<void> getBrandDetails({required int brandNumber}) async {
    state = RequestState.loading;
    notifyListeners();
    var result = await GetBrandsDetailsUseCase(sl()).call(brandNumber:brandNumber);
    result.fold((l) {
      state = RequestState.failed;
      notifyListeners();
      return toast(l.message.toString());
    }, (r) {
      state = RequestState.loaded;
      notifyListeners();

      return brandDetails = r;
    });
  }


}
