import 'package:kyuser/domain/Issues/Entities/IssuesEntity.dart';

// Main Issues List Response Model
class IssuesDataModel extends IssuesDataEntity {
  const IssuesDataModel({
    required super.status,
    required super.message,
    required super.data,
    required super.meta,
  });

  factory IssuesDataModel.fromJson(Map<String, dynamic> json) {
    return IssuesDataModel(
      status: json['status'] as int? ?? 0,
      message: (json['message'] as String?) ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => IssueModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      meta: MetaModel.fromJson((json['meta'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

// Single Issue Details Response Model
class IssueDetailsDataModel extends IssueDetailsDataEntity {
  const IssueDetailsDataModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory IssueDetailsDataModel.fromJson(Map<String, dynamic> json) {
    return IssueDetailsDataModel(
      status: json['status'] as int,
      message: json['message'] as String,
      data: IssueDetailsModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

// Issues Summary Response Model
class IssuesSummaryDataModel extends IssuesSummaryDataEntity {
  const IssuesSummaryDataModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory IssuesSummaryDataModel.fromJson(Map<String, dynamic> json) {
    return IssuesSummaryDataModel(
      status: json['status'] as int? ?? 0,
      message: (json['message'] as String?) ?? '',
      data: IssuesSummaryModel.fromJson((json['data'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

// Issues Search Response Model
class IssuesSearchDataModel extends IssuesSearchDataEntity {
  const IssuesSearchDataModel({
    required super.status,
    required super.message,
    required super.data,
    required super.meta,
  });

  factory IssuesSearchDataModel.fromJson(Map<String, dynamic> json) {
    return IssuesSearchDataModel(
      status: json['status'] as int,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => IssueSearchModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: SearchMetaModel.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

// Issue Model (for list)
class IssueModel extends IssueEntity {
  const IssueModel({
    required super.id,
    required super.refusedType,
    required super.createdAt,
    required super.updatedAt,
    required super.customer,
    required super.company,
    required super.brand,
    required super.refusedDetails,
    required super.sessions,
    required super.reminders,
    required super.sessionsCount,
    required super.remindersCount,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: json['id'] as int? ?? 0,
      refusedType: (json['refused_type'] as String?) ?? '',
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',
      customer: CustomerModel.fromJson((json['customer'] as Map<String, dynamic>?) ?? {}),
      company: CompanyModel.fromJson((json['company'] as Map<String, dynamic>?) ?? {}),
      brand: BrandModel.fromJson((json['brand'] as Map<String, dynamic>?) ?? {}),
      refusedDetails: RefusedDetailsModel.fromJson((json['refused_details'] as Map<String, dynamic>?) ?? {}),
      sessions: (json['sessions'] as List<dynamic>?) ?? [],
      reminders: (json['reminders'] as List<dynamic>?) ?? [],
      sessionsCount: json['sessions_count'] as int? ?? 0,
      remindersCount: json['reminders_count'] as int? ?? 0,
    );
  }
}

// Issue Details Model (for single issue)
class IssueDetailsModel extends IssueDetailsEntity {
  const IssueDetailsModel({
    required super.id,
    required super.refusedType,
    required super.createdAt,
    required super.updatedAt,
    required super.customer,
    required super.company,
    required super.brand,
    required super.refusedDetails,
    required super.sessions,
    required super.reminders,
    required super.statistics,
  });

  factory IssueDetailsModel.fromJson(Map<String, dynamic> json) {
    return IssueDetailsModel(
      id: json['id'] as int,
      refusedType: json['refused_type'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      customer: CustomerDetailsModel.fromJson(json['customer'] as Map<String, dynamic>),
      company: CompanyModel.fromJson(json['company'] as Map<String, dynamic>),
      brand: BrandDetailsModel.fromJson(json['brand'] as Map<String, dynamic>),
      refusedDetails: RefusedDetailsModel.fromJson(json['refused_details'] as Map<String, dynamic>),
      sessions: json['sessions'] as List<dynamic>,
      reminders: json['reminders'] as List<dynamic>,
      statistics: StatisticsModel.fromJson(json['statistics'] as Map<String, dynamic>),
    );
  }
}

// Customer Model
class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int? ?? 0,
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
    );
  }
}

// Customer Details Model (with address)
class CustomerDetailsModel extends CustomerDetailsEntity {
  const CustomerDetailsModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
  });

  factory CustomerDetailsModel.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
    );
  }
}

// Company Model
class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.id,
    required super.companyName,
    required super.address,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int,
      companyName: json['company_name'] as String,
      address: json['address'] as String?,
    );
  }
}

// Brand Model
class BrandModel extends BrandEntity {
  const BrandModel({
    required super.id,
    required super.brandName,
    required super.brandNumber,
    required super.brandDescription,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as int,
      brandName: json['brand_name'] as String,
      brandNumber: json['brand_number'] as String,
      brandDescription: json['brand_description'] as String?,
    );
  }
}

// Brand Details Model (with brand_details field)
class BrandDetailsModel extends BrandDetailsEntity {
  const BrandDetailsModel({
    required super.id,
    required super.brandName,
    required super.brandNumber,
    required super.brandDescription,
    required super.brandDetails,
  });

  factory BrandDetailsModel.fromJson(Map<String, dynamic> json) {
    return BrandDetailsModel(
      id: json['id'] as int,
      brandName: json['brand_name'] as String,
      brandNumber: json['brand_number'] as String,
      brandDescription: json['brand_description'] as String?,
      brandDetails: json['brand_details'] as String?,
    );
  }
}

// Refused Details Model
class RefusedDetailsModel extends RefusedDetailsEntity {
  const RefusedDetailsModel({
    required super.id,
    required super.issueId,
    required super.createdAt,
    required super.updatedAt,
    super.appealDate,
    super.appealNumber,
    super.refusedDate,
    super.expertOpinion,
    super.dateOfThePublicAuthorityResponseNote,
    super.dateOfACommentNoteOnTheAuthorityResponse,
    super.appealDateOpposition,
    super.appealNumberOpposition,
    super.refusedDateOpposition,
    super.reasonsOfTheAppealOpposition,
    super.dateOfLegalDocuments,
    super.submissionOfTheFirstDefenseNoteForTheAppealOpposition,
    super.dateOfPublicAuthorityResponseNoteOpposition,
    super.dateOfACommentNoteOnTheAuthorityResponseOpposition,
    super.dateOfAttendanceOfThePleadingSessionsOpposition,
    super.dateOfJudgmentOpposition,
  });

  factory RefusedDetailsModel.fromJson(Map<String, dynamic> json) {
    return RefusedDetailsModel(
      id: json['id'] as int,
      issueId: json['issue_id'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      appealDate: json['appeal_date'] as String?,
      appealNumber: json['appeal_number'] as String?,
      refusedDate: json['refused_date'] as String?,
      expertOpinion: json['expert_opinion'] as String?,
      dateOfThePublicAuthorityResponseNote: json['date_of_the_public_authority_response_note'] as String?,
      dateOfACommentNoteOnTheAuthorityResponse: json['date_of_a_comment_note_on_the_authority_response'] as String?,
      appealDateOpposition: json['appeal_date_opposition'] as String?,
      appealNumberOpposition: json['appeal_number_opposition'] as String?,
      refusedDateOpposition: json['refused_date_opposition'] as String?,
      reasonsOfTheAppealOpposition: json['reasons_of_the_appeal_opposition'] as String?,
      dateOfLegalDocuments: json['date_of_legal_documents'] as String?,
      submissionOfTheFirstDefenseNoteForTheAppealOpposition: json['submission_of_the_first_defense_note_for_the_appeal_opposition'] as String?,
      dateOfPublicAuthorityResponseNoteOpposition: json['date_of_public_authority_response_note_opposition'] as String?,
      dateOfACommentNoteOnTheAuthorityResponseOpposition: json['date_of_a_comment_note_on_the_authority_response_opposition'] as String?,
      dateOfAttendanceOfThePleadingSessionsOpposition: json['date_of_attendance_of_the_pleading_sessions_opposition'] as String?,
      dateOfJudgmentOpposition: json['date_of_judgment_opposition'] as String?,
    );
  }
}

// Meta Model for pagination
class MetaModel extends MetaEntity {
  const MetaModel({
    required super.currentPage,
    required super.perPage,
    required super.total,
    required super.lastPage,
    required super.from,
    required super.to,
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      currentPage: json['current_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 1,
      from: json['from'] as int? ?? 0,
      to: json['to'] as int? ?? 0,
    );
  }
}

// Statistics Model
class StatisticsModel extends StatisticsEntity {
  const StatisticsModel({
    required super.sessionsCount,
    required super.remindersCount,
    required super.completedSessions,
    required super.pendingSessions,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      sessionsCount: json['sessions_count'] as int,
      remindersCount: json['reminders_count'] as int,
      completedSessions: json['completed_sessions'] as int,
      pendingSessions: json['pending_sessions'] as int,
    );
  }
}

// Issues Summary Model
class IssuesSummaryModel extends IssuesSummaryEntity {
  const IssuesSummaryModel({
    required super.customerInfo,
    required super.statistics,
    required super.recentIssues,
  });

  factory IssuesSummaryModel.fromJson(Map<String, dynamic> json) {
    return IssuesSummaryModel(
      customerInfo: CustomerModel.fromJson((json['customer_info'] as Map<String, dynamic>?) ?? {}),
      statistics: SummaryStatisticsModel.fromJson((json['statistics'] as Map<String, dynamic>?) ?? {}),
      recentIssues: (json['recent_issues'] as List<dynamic>?)
          ?.map((e) => RecentIssueModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

// Summary Statistics Model
class SummaryStatisticsModel extends SummaryStatisticsEntity {
  const SummaryStatisticsModel({
    required super.totalIssues,
    required super.normalIssues,
    required super.oppositionIssues,
  });

  factory SummaryStatisticsModel.fromJson(Map<String, dynamic> json) {
    return SummaryStatisticsModel(
      totalIssues: json['total_issues'] as int? ?? 0,
      normalIssues: json['normal_issues'] as int? ?? 0,
      oppositionIssues: json['opposition_issues'] as int? ?? 0,
    );
  }
}

// Recent Issue Model
class RecentIssueModel extends RecentIssueEntity {
  const RecentIssueModel({
    required super.id,
    required super.refusedType,
    required super.companyName,
    required super.brandName,
    required super.createdAt,
  });

  factory RecentIssueModel.fromJson(Map<String, dynamic> json) {
    return RecentIssueModel(
      id: json['id'] as int,
      refusedType: json['refused_type'] as String,
      companyName: json['company_name'] as String,
      brandName: json['brand_name'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}

// Issue Search Model
class IssueSearchModel extends IssueSearchEntity {
  const IssueSearchModel({
    required super.id,
    required super.refusedType,
    required super.companyName,
    required super.brandName,
    required super.brandNumber,
    required super.createdAt,
  });

  factory IssueSearchModel.fromJson(Map<String, dynamic> json) {
    return IssueSearchModel(
      id: json['id'] as int,
      refusedType: json['refused_type'] as String,
      companyName: json['company_name'] as String,
      brandName: json['brand_name'] as String,
      brandNumber: json['brand_number'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}

// Search Meta Model
class SearchMetaModel extends SearchMetaEntity {
  const SearchMetaModel({
    required super.currentPage,
    required super.perPage,
    required super.total,
    required super.lastPage,
    required super.searchQuery,
    required super.refusedTypeFilter,
  });

  factory SearchMetaModel.fromJson(Map<String, dynamic> json) {
    return SearchMetaModel(
      currentPage: json['current_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      lastPage: json['last_page'] as int,
      searchQuery: json['search_query'] as String,
      refusedTypeFilter: json['refused_type_filter'] as String?,
    );
  }
} 