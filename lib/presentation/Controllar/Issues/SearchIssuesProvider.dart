import 'package:flutter/material.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';
import 'package:kyuser/domain/Issues/UseCase/SearchIssuesUseCase.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import '../../../core/Services_locator.dart';

class SearchIssuesProvider extends ChangeNotifier {
  List<IssueSearchEntity> searchResults = [];
  RequestState state = RequestState.loading;
  int currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  String currentQuery = '';
  int totalResults = 0;

  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;

  // Reset search for new query
  void resetSearch() {
    currentPage = 1;
    _hasMoreData = true;
    _isLoading = false;
    searchResults.clear();
    totalResults = 0;
    state = RequestState.loading;
  }

  Future<void> searchIssues({
    required String query,
    required int customerId,
    int page = 1,
    int perPage = 15,
  }) async {
    if (page == 1) {
      state = RequestState.loading;
      searchResults.clear();
      _hasMoreData = true;
      _isLoading = false;
      currentQuery = query;
    }
    notifyListeners();

    var result = await SearchIssuesUseCase(sl()).call(
      query: query,
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
        totalResults = r.meta.total;
        searchResults = r.data;
      } else {
        searchResults.addAll(r.data);
      }

      _hasMoreData = r.data.isNotEmpty && r.data.length >= perPage;
      state = RequestState.loaded;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> loadMoreSearchResults(int customerId, {int perPage = 15}) async {
    if (_isLoading || !_hasMoreData || currentQuery.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    currentPage++;
    await searchIssues(
      query: currentQuery,
      customerId: customerId,
      page: currentPage,
      perPage: perPage,
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    searchResults.clear();
    currentQuery = '';
    totalResults = 0;
    _hasMoreData = true;
    _isLoading = false;
    currentPage = 1;
    state = RequestState.loading;
    notifyListeners();
  }
} 