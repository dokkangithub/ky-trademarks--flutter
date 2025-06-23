import 'package:equatable/equatable.dart';

// Main Issues List Response Entity
class IssuesDataEntity extends Equatable {
  final int status;
  final String message;
  final List<IssueEntity> data;
  final MetaEntity meta;

  const IssuesDataEntity({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  @override
  List<Object?> get props => [status, message, data, meta];
}

// Single Issue Details Response Entity
class IssueDetailsDataEntity extends Equatable {
  final int status;
  final String message;
  final IssueDetailsEntity data;

  const IssueDetailsDataEntity({
    required this.status,
    required this.message,
    required this.data,
  });

  @override
  List<Object?> get props => [status, message, data];
}

// Issues Summary Response Entity
class IssuesSummaryDataEntity extends Equatable {
  final int status;
  final String message;
  final IssuesSummaryEntity data;

  const IssuesSummaryDataEntity({
    required this.status,
    required this.message,
    required this.data,
  });

  @override
  List<Object?> get props => [status, message, data];
}

// Issues Search Response Entity
class IssuesSearchDataEntity extends Equatable {
  final int status;
  final String message;
  final List<IssueSearchEntity> data;
  final SearchMetaEntity meta;

  const IssuesSearchDataEntity({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  @override
  List<Object?> get props => [status, message, data, meta];
}

// Issue Entity (for list)
class IssueEntity extends Equatable {
  final int id;
  final String refusedType;
  final String createdAt;
  final String updatedAt;
  final CustomerEntity customer;
  final CompanyEntity company;
  final BrandEntity brand;
  final RefusedDetailsEntity refusedDetails;
  final List<dynamic> sessions;
  final List<dynamic> reminders;
  final int sessionsCount;
  final int remindersCount;

  const IssueEntity({
    required this.id,
    required this.refusedType,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    required this.company,
    required this.brand,
    required this.refusedDetails,
    required this.sessions,
    required this.reminders,
    required this.sessionsCount,
    required this.remindersCount,
  });

  @override
  List<Object?> get props => [
        id,
        refusedType,
        createdAt,
        updatedAt,
        customer,
        company,
        brand,
        refusedDetails,
        sessions,
        reminders,
        sessionsCount,
        remindersCount,
      ];
}

// Issue Details Entity (for single issue)
class IssueDetailsEntity extends Equatable {
  final int id;
  final String refusedType;
  final String createdAt;
  final String updatedAt;
  final CustomerDetailsEntity customer;
  final CompanyEntity company;
  final BrandDetailsEntity brand;
  final RefusedDetailsEntity refusedDetails;
  final List<dynamic> sessions;
  final List<dynamic> reminders;
  final StatisticsEntity statistics;

  const IssueDetailsEntity({
    required this.id,
    required this.refusedType,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    required this.company,
    required this.brand,
    required this.refusedDetails,
    required this.sessions,
    required this.reminders,
    required this.statistics,
  });

  @override
  List<Object?> get props => [
        id,
        refusedType,
        createdAt,
        updatedAt,
        customer,
        company,
        brand,
        refusedDetails,
        sessions,
        reminders,
        statistics,
      ];
}

// Customer Entity
class CustomerEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;

  const CustomerEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [id, name, email, phone];
}

// Customer Details Entity (with address)
class CustomerDetailsEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? address;

  const CustomerDetailsEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  List<Object?> get props => [id, name, email, phone, address];
}

// Company Entity
class CompanyEntity extends Equatable {
  final int id;
  final String companyName;
  final String? address;

  const CompanyEntity({
    required this.id,
    required this.companyName,
    required this.address,
  });

  @override
  List<Object?> get props => [id, companyName, address];
}

// Brand Entity
class BrandEntity extends Equatable {
  final int id;
  final String brandName;
  final String brandNumber;
  final String? brandDescription;

  const BrandEntity({
    required this.id,
    required this.brandName,
    required this.brandNumber,
    required this.brandDescription,
  });

  @override
  List<Object?> get props => [id, brandName, brandNumber, brandDescription];
}

// Brand Details Entity (with brand_details field)
class BrandDetailsEntity extends Equatable {
  final int id;
  final String brandName;
  final String brandNumber;
  final String? brandDescription;
  final String? brandDetails;

  const BrandDetailsEntity({
    required this.id,
    required this.brandName,
    required this.brandNumber,
    required this.brandDescription,
    required this.brandDetails,
  });

  @override
  List<Object?> get props => [id, brandName, brandNumber, brandDescription, brandDetails];
}

// Refused Details Entity
class RefusedDetailsEntity extends Equatable {
  final int id;
  final int issueId;
  final String createdAt;
  final String updatedAt;
  
  // Normal issue fields
  final String? appealDate;
  final String? appealNumber;
  final String? refusedDate;
  final String? expertOpinion;
  final String? dateOfThePublicAuthorityResponseNote;
  final String? dateOfACommentNoteOnTheAuthorityResponse;
  
  // Opposition issue fields
  final String? appealDateOpposition;
  final String? appealNumberOpposition;
  final String? refusedDateOpposition;
  final String? reasonsOfTheAppealOpposition;
  final String? dateOfLegalDocuments;
  final String? submissionOfTheFirstDefenseNoteForTheAppealOpposition;
  final String? dateOfPublicAuthorityResponseNoteOpposition;
  final String? dateOfACommentNoteOnTheAuthorityResponseOpposition;
  final String? dateOfAttendanceOfThePleadingSessionsOpposition;
  final String? dateOfJudgmentOpposition;

  const RefusedDetailsEntity({
    required this.id,
    required this.issueId,
    required this.createdAt,
    required this.updatedAt,
    this.appealDate,
    this.appealNumber,
    this.refusedDate,
    this.expertOpinion,
    this.dateOfThePublicAuthorityResponseNote,
    this.dateOfACommentNoteOnTheAuthorityResponse,
    this.appealDateOpposition,
    this.appealNumberOpposition,
    this.refusedDateOpposition,
    this.reasonsOfTheAppealOpposition,
    this.dateOfLegalDocuments,
    this.submissionOfTheFirstDefenseNoteForTheAppealOpposition,
    this.dateOfPublicAuthorityResponseNoteOpposition,
    this.dateOfACommentNoteOnTheAuthorityResponseOpposition,
    this.dateOfAttendanceOfThePleadingSessionsOpposition,
    this.dateOfJudgmentOpposition,
  });

  @override
  List<Object?> get props => [
        id,
        issueId,
        createdAt,
        updatedAt,
        appealDate,
        appealNumber,
        refusedDate,
        expertOpinion,
        dateOfThePublicAuthorityResponseNote,
        dateOfACommentNoteOnTheAuthorityResponse,
        appealDateOpposition,
        appealNumberOpposition,
        refusedDateOpposition,
        reasonsOfTheAppealOpposition,
        dateOfLegalDocuments,
        submissionOfTheFirstDefenseNoteForTheAppealOpposition,
        dateOfPublicAuthorityResponseNoteOpposition,
        dateOfACommentNoteOnTheAuthorityResponseOpposition,
        dateOfAttendanceOfThePleadingSessionsOpposition,
        dateOfJudgmentOpposition,
      ];
}

// Meta Entity for pagination
class MetaEntity extends Equatable {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int from;
  final int to;

  const MetaEntity({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  @override
  List<Object?> get props => [currentPage, perPage, total, lastPage, from, to];
}

// Statistics Entity
class StatisticsEntity extends Equatable {
  final int sessionsCount;
  final int remindersCount;
  final int completedSessions;
  final int pendingSessions;

  const StatisticsEntity({
    required this.sessionsCount,
    required this.remindersCount,
    required this.completedSessions,
    required this.pendingSessions,
  });

  @override
  List<Object?> get props => [sessionsCount, remindersCount, completedSessions, pendingSessions];
}

// Issues Summary Entity
class IssuesSummaryEntity extends Equatable {
  final CustomerEntity customerInfo;
  final SummaryStatisticsEntity statistics;
  final List<RecentIssueEntity> recentIssues;

  const IssuesSummaryEntity({
    required this.customerInfo,
    required this.statistics,
    required this.recentIssues,
  });

  @override
  List<Object?> get props => [customerInfo, statistics, recentIssues];
}

// Summary Statistics Entity
class SummaryStatisticsEntity extends Equatable {
  final int totalIssues;
  final int normalIssues;
  final int oppositionIssues;

  const SummaryStatisticsEntity({
    required this.totalIssues,
    required this.normalIssues,
    required this.oppositionIssues,
  });

  @override
  List<Object?> get props => [totalIssues, normalIssues, oppositionIssues];
}

// Recent Issue Entity
class RecentIssueEntity extends Equatable {
  final int id;
  final String refusedType;
  final String companyName;
  final String brandName;
  final String createdAt;

  const RecentIssueEntity({
    required this.id,
    required this.refusedType,
    required this.companyName,
    required this.brandName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, refusedType, companyName, brandName, createdAt];
}

// Issue Search Entity
class IssueSearchEntity extends Equatable {
  final int id;
  final String refusedType;
  final String companyName;
  final String brandName;
  final String brandNumber;
  final String createdAt;

  const IssueSearchEntity({
    required this.id,
    required this.refusedType,
    required this.companyName,
    required this.brandName,
    required this.brandNumber,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, refusedType, companyName, brandName, brandNumber, createdAt];
}

// Search Meta Entity
class SearchMetaEntity extends Equatable {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final String searchQuery;
  final String? refusedTypeFilter;

  const SearchMetaEntity({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.searchQuery,
    required this.refusedTypeFilter,
  });

  @override
  List<Object?> get props => [currentPage, perPage, total, lastPage, searchQuery, refusedTypeFilter];
} 