// lib/data/Company/models/CompanyDataModel.dart
import 'package:kyuser/domain/Company/Entities/CompanyEntity.dart';

class CompanyDataModel extends CompanyDataEntity {
  const CompanyDataModel({
    required super.status,
    required super.message,
    required super.company,
  });

  factory CompanyDataModel.fromJson(Map<String, dynamic> json) {
    return CompanyDataModel(
      status: json['status'] as int,
      message: json['message'] as String,
      company: _parseCompanies(json['company']),
    );
  }

  static List<CompanyModel> _parseCompanies(List<dynamic>? companyJson) {
    return companyJson?.map((e) => CompanyModel.fromJson(e)).toList() ?? [];
  }
}

class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.id,
    required super.avatar,
    required super.companyName,
    required super.address,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int,
      avatar: json['avatar'] as String?,
      companyName: json['company_name'] as String,
      address: json['address'] as String,
    );
  }
}