import 'package:flutter/material.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';
import 'package:kyuser/domain/Brand/UseCase/GetAllBrandsBySearchUseCase.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import '../../core/Services_locator.dart';

class GetBrandBySearchProvider extends ChangeNotifier {
  List<BrandEntity> allBrands = [];
  RequestState state = RequestState.loading;
  int brandCurrentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;

  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;

  Future<void> getAllBrandsBySearch({required String keyWord, int page = 1}) async {
    if (page == 1) {
      state = RequestState.loading;
      allBrands.clear();
    }
    notifyListeners();

    var result = await GetAllBrandsBySearchUseCase(sl()).call(keyWord: keyWord, page: page);
    result.fold((l) {
      state = RequestState.failed;
      _hasMoreData = false;
      notifyListeners();
      return toast(l.message.toString());
    }, (r) {
      if (page == 1) {
        allBrands = r.brand;
      } else {
        allBrands.addAll(r.brand);
      }

      _hasMoreData = r.brand.isNotEmpty;
      state = RequestState.loaded;
      notifyListeners();
    });
  }


  Future<void> loadMoreBrands(String keyWord) async {
    if (_isLoading || !_hasMoreData) return;

    print("Loading more brands..."); // Debug print
    _isLoading = true;
    notifyListeners();

    brandCurrentPage++;
    await getAllBrandsBySearch(keyWord: keyWord, page: brandCurrentPage);

    _isLoading = false;
    notifyListeners();
  }

}