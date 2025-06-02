import 'package:equatable/equatable.dart';
import '../../../data/Brand/models/BrandDataModel.dart';
import '../../../data/BrandDetails/models/BrandDetailsDataModel.dart';

class BrandDetailsDataEntity extends Equatable {
  final int status;
  final String message;
  final BrandDetailsModel brand;
  final List<dynamic> images;
  final List<dynamic> AllResult;

  const BrandDetailsDataEntity(
      {required this.status,
      required this.message,
      required this.brand,
      required this.images,
      required this.AllResult});

  @override
  // TODO: implement props
  List<Object?> get props => [status, message, brand, images];
}

class BrandDetailsEntity {
  final int id;
  final int customerId;
  final int companyId;
  final String brandName;
  final String brandNumber;
  final String newCurrentState;
  final int currentStatus;
  final int markOrModel;
  final int country;
  final int number;
  final String applicationDate;
  final int completedPowerOfAttorneyRequest;
  final String importNumber;
  final String dateOfSupply;
  final String tawkeelImage;
  final String notes;
  final String paymentStatus;
  final String brandDescription;
  final String brandDetails;
  final String? customerName;
  final String? customerAddress;
  final String? countryName;
  final String? applicant;
  final String? adminName;
  final String? dateOfUnderTaking;
  final String? renewableNotificationDate;
  final String? createdAt;
  final String? updatedAt;
  final String? recordingDateOfSupply;
  final List<ImagesModel> cr;
  final List<ImagesModel> completedPowerOfAttorneyRequestImages;
  final List<TypesModel> completedPowerOfAttorneyRequestTypes;



  const BrandDetailsEntity({
    required this.id,
    required this.customerId,
    required this.companyId,
    required this.brandName,
    required this.brandNumber,
    required this.currentStatus,
    required this.newCurrentState,
    required this.markOrModel,
    required this.country,
    required this.applicationDate,
    required this.completedPowerOfAttorneyRequest,
    required this.importNumber,
    required this.dateOfSupply,
    required this.notes,
    required this.paymentStatus,
    required this.brandDescription,
    required this.brandDetails,
    required this.customerName,
    required this.customerAddress,
    required this.applicant,
    required this.countryName,
    required this.tawkeelImage,
    required this.adminName,
    required this.dateOfUnderTaking,
    required this.number,
    required this.renewableNotificationDate,
    required this.createdAt,
    required this.updatedAt,
    required this.recordingDateOfSupply,
    required this.cr,
    required this.completedPowerOfAttorneyRequestImages,
    required this.completedPowerOfAttorneyRequestTypes,

  });
}

class AllResult {
   String  ? states;
    // Rejection ? rejection;
    // Grivence ? grivence;
    // Acceptance  ?  acceptance;
    // AppealGrivence ? appealGrivence;
    // ConditionalAcceptance? conditionalAcceptance;
    // Renovations ?  renovations;
    // Decision ? decision;
    // UnderTechnicalInspection ? underTechnicalInspection;
     int? id;
     int? brandId;
     String? name;
     String? dateOfTheCaseOfTheDecisionOfTheGrievanceCommittee;
     String? theDecisionOfTheApplicationToAcceptOrReject;
     String? technicalOpinionDecision;
     int? number;
     String? dateOfRenewalStatus;
     String? dateOfRenewalFee;
     String? renewalDateRenovations;
     String? renewalPeriod;
     String? admissionStatusDateConditional;
     String? recordConditional;
     String? publicityFeePaymentDateConditional;
     String? publishDateConditional;
     String? numberOfNewspaperConditional;
     String? exhibitionDetailsConditional;
     String? theApplicantResponseToTheObjectionConditional;
     String? theDateOfTheHearingSessionConditional;
     String? decisionOfTheExhibitionCommitteeConditional;
     String? renewalDateConditional;
     String? dateOfPaymentOfTheRegistrationFeeConditional;
     String? dateOfRegistrationConditional;
     String? noteTheConditionalAcceptance;
     String? requirements;
     String? notifyTheStudentOfTheOpposition;
     String? firstNotificationOfTheOppositionApostate;
     String? secondNotificationOfTheOppositionApostate;
     String? theDateOfPaymentOfTheAppealFee;
     String? appealDecision;
     String? appealNotes;
     String? admissionStatusDate;
     String? record;
     String? publicityFeePaymentDate;
     String? publishDate;
     String? numberOfNewspaper;
     String? notifyTheStudentOfOpposition;
     String? exhibitionDetails;
     String? firstNoticeOfOppositionApostate;
     String? secondNoticeOfOppositionApostate;
     String? theApplicantResponseToTheObjection;
     String? theDateOfTheHearingSession;
     String? decisionOfTheExhibitionCommittee;
     String? dateOfPaymentOfTheRegistrationFee;
     String? dateOfRegistration;
     String? renewalDate;
     String? acceptanceNote;
     String? theDateOfPaymentOfTheGrievanceFee;
     String? grivenceNotes;
     String? grievanceCommitteeNumber;
     String? historyOfTheGrievanceCommittee;
     String? theDateOfTheRejection;
     String? theReasonOfRefuse;
     String? technicalOpinion;
     String ? created_at;
     String ? dateNotifyStudentOpposition;
     ///AppealBrandRegistration
     String? dateOfAppeal;
     String? commissionersDecision;
     String? courtDecision;
     String? dateNotifyTheStudentOfOpposition;
     ///GiveUp
      String? giveUpDate;
      String? giveUpNotes;
      String? replyImportNumOpposition;
      String? opposition_note;
      String? importNumberPosition;
      List<dynamic>? acceptGallery;
      List<dynamic>? appealBrandRegistrationGallery;
      List<dynamic>? appealGrivenceGallery;
      List<dynamic>? conditionalAcceptanceGallery;
      List<dynamic>? giveUpGallery;
      List<dynamic>? grievanceTeamDecisionGallery;
      List<dynamic>? grievanceGallery;
      List<dynamic>? processingGallery;
      List<dynamic>? refusedGallery;
      List<dynamic>? renovationsGallery;
      List<dynamic>? publish_date_Gallery;



     AllResult({
      this.states,
       this.id,
       this.brandId,
       this.number,
       this.name,
       this.dateOfTheCaseOfTheDecisionOfTheGrievanceCommittee,
       this.theDecisionOfTheApplicationToAcceptOrReject,
       this.technicalOpinionDecision,
       this.dateOfRenewalStatus,
       this.dateOfRenewalFee,
       this.renewalDateRenovations,
       this.renewalPeriod,
       this.admissionStatusDateConditional,
       this.recordConditional,
       this.publicityFeePaymentDateConditional,
       this.publishDateConditional,
       this.numberOfNewspaperConditional,
       this.exhibitionDetailsConditional,
       this.theApplicantResponseToTheObjectionConditional,
       this.theDateOfTheHearingSessionConditional,
       this.decisionOfTheExhibitionCommitteeConditional,
       this.renewalDateConditional,
       this.dateOfPaymentOfTheRegistrationFeeConditional,
       this.dateOfRegistrationConditional,
       this.noteTheConditionalAcceptance,
       this.requirements,
       this.notifyTheStudentOfTheOpposition,
       this.firstNotificationOfTheOppositionApostate,
       this.secondNotificationOfTheOppositionApostate,
       this.theDateOfPaymentOfTheAppealFee,
       this.appealDecision,
       this.appealNotes,
       this.admissionStatusDate,
       this.record,
       this.publicityFeePaymentDate,
       this.publishDate,
       this.numberOfNewspaper,
       this.notifyTheStudentOfOpposition,
       this.exhibitionDetails,
       this.firstNoticeOfOppositionApostate,
       this.secondNoticeOfOppositionApostate,
       this.theApplicantResponseToTheObjection,
       this.theDateOfTheHearingSession,
       this.decisionOfTheExhibitionCommittee,
       this.dateOfPaymentOfTheRegistrationFee,
       this.dateOfRegistration,
       this.renewalDate,
       this.acceptanceNote,
       this.theDateOfPaymentOfTheGrievanceFee,
       this.grivenceNotes,
       this.grievanceCommitteeNumber,
       this.historyOfTheGrievanceCommittee,
       this.theDateOfTheRejection,
       this.theReasonOfRefuse,
       this.technicalOpinion,
       this.created_at,
       this.dateOfAppeal,
       this.commissionersDecision,
       this.courtDecision,
       this.giveUpDate,
       this.giveUpNotes,
       this.acceptGallery,
       this.appealBrandRegistrationGallery,
       this.appealGrivenceGallery,
       this.conditionalAcceptanceGallery,
       this.giveUpGallery,
       this.grievanceGallery,
       this.grievanceTeamDecisionGallery,
       this.processingGallery,
       this.refusedGallery,
       this.renovationsGallery,
       this.publish_date_Gallery,
       this.replyImportNumOpposition,
       this.dateNotifyTheStudentOfOpposition,
       this.opposition_note,
       this.importNumberPosition







       // this.rejection,
      // this.grivence,
      // this.acceptance,
      // this.appealGrivence,
      // this.conditionalAcceptance,
      // this.renovations,
      // this.decision,
      // this.underTechnicalInspection,
  });
}
