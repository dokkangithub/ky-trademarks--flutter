// lib/presentation/Controllar/GetCompanyProvider.dart
import 'package:flutter/material.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/domain/Company/Entities/CompanyEntity.dart';
import 'package:kyuser/domain/Company/UseCase/GetAllCompaniesUseCase.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import '../../core/Services_locator.dart';

class GetCompanyProvider extends ChangeNotifier {
  List<CompanyEntity> allCompanies = [];
  RequestState state = RequestState.loading;
  CompanyEntity? _selectedCompany; // Add selected company property

  // Getter for selectedCompany
  CompanyEntity? get selectedCompany => _selectedCompany;

  Future<void> getAllCompanies(context) async {
    state = RequestState.loading;
    allCompanies.clear();
    notifyListeners();

    var result = await GetAllCompaniesUseCase(sl()).call(context);
    result.fold((l) {
      state = RequestState.failed;
      notifyListeners();
      return toast(l.message.toString());
    }, (r) {
      allCompanies = r.company;
      _selectedCompany = allCompanies.isNotEmpty ? allCompanies[0] : null; // Set default selected company
      state = RequestState.loaded;
      notifyListeners();
    });
  }

  // Method to set the selected company
  void setSelectedCompany(CompanyEntity company) {
    _selectedCompany = company;
    notifyListeners();
  }
}