import 'package:flutter/material.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';
import 'package:kyuser/domain/Issues/UseCase/GetIssuesSummaryUseCase.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import '../../../core/Services_locator.dart';

class GetIssuesSummaryProvider extends ChangeNotifier {
  IssuesSummaryEntity? issuesSummary;
  RequestState state = RequestState.loading;

  Future<void> getIssuesSummary({
    required int customerId,
  }) async {
    state = RequestState.loading;
    notifyListeners();
    
    var result = await GetIssuesSummaryUseCase(sl()).call(
      customerId: customerId,
    );
    
    result.fold((l) {
      state = RequestState.failed;
      notifyListeners();
      return toast(l.message.toString());
    }, (r) {
      state = RequestState.loaded;
      issuesSummary = r.data;
      notifyListeners();
    });
  }

  void clearSummary() {
    issuesSummary = null;
    state = RequestState.loading;
    notifyListeners();
  }
} 