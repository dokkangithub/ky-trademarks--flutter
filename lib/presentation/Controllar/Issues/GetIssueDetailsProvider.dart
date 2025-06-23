import 'package:flutter/material.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';
import 'package:kyuser/domain/Issues/UseCase/GetIssueDetailsUseCase.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import '../../../core/Services_locator.dart';

class GetIssueDetailsProvider extends ChangeNotifier {
  IssueDetailsEntity? issueDetails;
  RequestState state = RequestState.loading;

  Future<void> getIssueDetails({
    required int issueId,
    required int customerId,
  }) async {
    state = RequestState.loading;
    notifyListeners();
    
    var result = await GetIssueDetailsUseCase(sl()).call(
      issueId: issueId,
      customerId: customerId,
    );
    
    result.fold((l) {
      state = RequestState.failed;
      notifyListeners();
      return toast(l.message.toString());
    }, (r) {
      state = RequestState.loaded;
      issueDetails = r.data;
      notifyListeners();
    });
  }

  void clearIssueDetails() {
    issueDetails = null;
    state = RequestState.loading;
    notifyListeners();
  }
} 