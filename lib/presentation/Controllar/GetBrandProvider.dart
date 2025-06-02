import 'package:flutter/material.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';
import 'package:kyuser/domain/Brand/UseCase/GetAllBrandsUseCase.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import '../../core/Services_locator.dart';


class GetBrandProvider extends ChangeNotifier {
  List<BrandEntity> allBrands = [];
  List<BrandsUpdates> allBrandUpdates = [];
  RequestState state = RequestState.loading;
  int totalMarks = 0;
  int brandCurrentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;

  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;

  Future<void> getAllBrandsWidget({int page = 1,required int companyId}) async {
    if (page == 1) {
      state = RequestState.loading;
      allBrands.clear();
      allBrandUpdates.clear();
    }
    notifyListeners();

    var result = await GetAllBrandsUseCase(sl()).call(page: page, companyId: companyId);
    result.fold((l) {
      state = RequestState.failed;
      _hasMoreData = false;
      notifyListeners();
      return toast(l.message.toString());
    }, (r) {
      if (page == 1) {
        totalMarks=r.total;
        print('dddd${r.total}');
        allBrands = r.brand;
        allBrandUpdates=r.updates;
      } else {
        allBrands.addAll(r.brand);
        allBrandUpdates.addAll(r.updates);
      }

      _hasMoreData = r.brand.isNotEmpty;
      state = RequestState.loaded;
      notifyListeners();
    });
  }

  Future<void> loadMoreBrands(int companyId) async {
    if (_isLoading || !_hasMoreData) return;

    _isLoading = true;
    notifyListeners();

    brandCurrentPage++;
    await getAllBrandsWidget(page: brandCurrentPage, companyId: companyId);

    _isLoading = false;
    notifyListeners();
  }
}