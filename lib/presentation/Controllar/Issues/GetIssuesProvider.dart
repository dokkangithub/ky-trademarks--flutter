import 'package:flutter/material.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';
import 'package:kyuser/domain/Issues/UseCase/GetIssuesUseCase.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import '../../../core/Services_locator.dart';

class GetIssuesProvider extends ChangeNotifier {
  List<IssueEntity> allIssues = [];
  RequestState state = RequestState.loading;
  int currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  int totalIssues = 0;

  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;

  // Reset data for new customer or refresh
  void resetData() {
    currentPage = 1;
    _hasMoreData = true;
    _isLoading = false;
    allIssues.clear();
    totalIssues = 0;
    state = RequestState.loading;
  }

  Future<void> getIssues({
    required int customerId,
    int page = 1,
    int perPage = 10,
  }) async {
    if (page == 1) {
      state = RequestState.loading;
      allIssues.clear();
      _hasMoreData = true;
      _isLoading = false;
    }
    notifyListeners();

    var result = await GetIssuesUseCase(sl()).call(
      customerId: customerId,
      page: page,
      perPage: perPage,
    );
    
    result.fold((l) {
      state = RequestState.failed;
      _hasMoreData = false;
      _isLoading = false;
      notifyListeners();
      return toast(l.message.toString());
    }, (r) {
      if (page == 1) {
        totalIssues = r.meta.total;
        allIssues = r.data;
      } else {
        allIssues.addAll(r.data);
      }

      _hasMoreData = r.data.isNotEmpty && r.data.length >= perPage;
      state = RequestState.loaded;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> loadMoreIssues(int customerId, {int perPage = 10}) async {
    if (_isLoading || !_hasMoreData) return;

    _isLoading = true;
    notifyListeners();

    currentPage++;
    await getIssues(
      customerId: customerId,
      page: currentPage,
      perPage: perPage,
    );

    _isLoading = false;
    notifyListeners();
  }
} 