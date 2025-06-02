 import 'dart:convert';
import 'package:kyuser/domain/BrandDetails/Entities/BrandDetailsDataEntity.dart';
import '../../Brand/models/BrandDataModel.dart';

class BrandDetailsDataModel extends BrandDetailsDataEntity {
  const BrandDetailsDataModel(
      {required super.status, required super.message, required super.brand
      ,required super.images,required super.AllResult
      });

  factory BrandDetailsDataModel.fromJson( json) {
    List<ImagesModel> images = List<ImagesModel>.from(
        (json["images"] as List)
            .where((e) => e is Map<String, dynamic>) // Filter out the empty array
            .map((e) => ImagesModel.fromJson(e))
    );

    if (json["brand"]["cr"] != null) {
      List<ImagesModel> crImages = List<ImagesModel>.from(
          (jsonDecode(json["brand"]["cr"]) as List<dynamic>)
              .where((e) => e is Map<String, dynamic>) // Filter out any non-map elements
              .map((e) => ImagesModel.fromJson(e)));
      images = [...images, ...crImages];
    }

    print('ffffff$images');
    return BrandDetailsDataModel(
      status: json['status']??0,
      message: json['message']??"",
      brand:  BrandDetailsModel.fromJson(json["brand"]),
      AllResult: List<AllResultModel>.from(json["allResult"].map((e)=>
          AllResultModel.fromJson(e))).toList(),
      images:  images
      //List<ImagesModel>.from((json["images"]).map((e) => ImagesModel.fromJson(e))),
    );
  }
}
class BrandDetailsModel extends BrandDetailsEntity {
  const BrandDetailsModel(
      {required super.id,
      required super.customerId,
      required super.brandName,
      required super.applicant,
      required super.brandNumber,
      required super.currentStatus,
      required super.newCurrentState,
      required super.markOrModel,
      required super.country,
      required super.applicationDate,
      required super.completedPowerOfAttorneyRequest,
      required super.importNumber,
      required super.dateOfSupply,
      required super.tawkeelImage,
      required super.notes,
      required super.paymentStatus,
      required super.brandDescription,
      required super.brandDetails,
      required super.customerAddress,
      required super.customerName,
      required super.countryName,
      required super.adminName,
      required super.dateOfUnderTaking,
      required super.number,
      required super.renewableNotificationDate,
      required super.createdAt,
      required super.updatedAt,
  required super.companyId,
        required super.recordingDateOfSupply,
        required super.cr,
        required super.completedPowerOfAttorneyRequestImages,
        required super.completedPowerOfAttorneyRequestTypes
       });

  factory BrandDetailsModel.fromJson(Map<String, dynamic> json) {
    return BrandDetailsModel(
        id: json['id'],
        customerId: json['customer_id']??0,
        brandName: json['brand_name']??"",
        brandNumber: json['brand_number']??"",
        currentStatus: json['current_status']??0,
        newCurrentState: json['new_current']??'',
        markOrModel: json['mark_or_model']??0,
        applicant: json["customer"]['applicant']??"",
        country: json['country']??0,
        applicationDate: json['application_date']??"",
        completedPowerOfAttorneyRequest: json['completed_power_of_attorney_request']??0,
        importNumber: json['import_number']??"",
        dateOfSupply: json['date_of_supply']??"",
        tawkeelImage: json['date_of_supply_image']==null?"":json['date_of_supply_image'].toString(),
        notes: json['notes']??"",
        paymentStatus: json['payment_status']??"",
        brandDescription: json['brand_description']??"",
        brandDetails: json['brand_details']??"",
        customerName: json['customer_name']??"",
        customerAddress: json['customer_address']??"",
        countryName: json['country_name']??"",
      adminName: json["admin_name"]??"",
      dateOfUnderTaking: json["date_of_undertaking"]??"",
      number: json["number"],
      renewableNotificationDate: json["renewable_notification_date"]??"",
      createdAt: json["created_at"]??"",
      updatedAt: json["updated_at"]??"",
      companyId: json["company_id"]??0,
      recordingDateOfSupply: json["recording_date_of_supply"],
      cr: json["cr"] != null
          ? List<ImagesModel>.from(
          (jsonDecode(json["cr"]) as List<dynamic>)
              .map((e) => ImagesModel.fromJson(e)))
          : [],
      completedPowerOfAttorneyRequestImages: json["completed_power_of_attorney_request_images"] != null
          ?List<ImagesModel>.from((json["completed_power_of_attorney_request_images"]).map((e) => ImagesModel.fromJson(e)))
          : [],
      completedPowerOfAttorneyRequestTypes: json["completed_power_of_attorney_request_images"] != null
          ?List<TypesModel>.from((json["completed_power_of_attorney_request_images"]).map((e) => TypesModel.fromJson(e)))
          : [],
        );
  }
}
class AllResultModel extends AllResult {
  AllResultModel({
    super.created_at,
    super.states,
     super.id,
     super.brandId,
     super.number,
     super.name,
     super.dateOfTheCaseOfTheDecisionOfTheGrievanceCommittee,
     super.theDecisionOfTheApplicationToAcceptOrReject,
     super.technicalOpinionDecision,
     super.dateOfRenewalStatus,
     super.dateOfRenewalFee,
     super.renewalDateRenovations,
     super.renewalPeriod,
     super.admissionStatusDateConditional,
     super.recordConditional,
     super.publicityFeePaymentDateConditional,
     super.publishDateConditional,
     super.numberOfNewspaperConditional,
     super.exhibitionDetailsConditional,
     super.theApplicantResponseToTheObjectionConditional,
     super.theDateOfTheHearingSessionConditional,
     super.decisionOfTheExhibitionCommitteeConditional,
     super.renewalDateConditional,
     super.dateOfPaymentOfTheRegistrationFeeConditional,
     super.dateOfRegistrationConditional,
     super.noteTheConditionalAcceptance,
     super.requirements,
     super.notifyTheStudentOfTheOpposition,
     super.firstNotificationOfTheOppositionApostate,
     super.secondNotificationOfTheOppositionApostate,
     super.theDateOfPaymentOfTheAppealFee,
     super.appealDecision,
     super.appealNotes,
     super.admissionStatusDate,
     super.record,
     super.publicityFeePaymentDate,
     super.publishDate,
     super.numberOfNewspaper,
     super.notifyTheStudentOfOpposition,
     super.exhibitionDetails,
     super.firstNoticeOfOppositionApostate,
     super.secondNoticeOfOppositionApostate,
     super.theApplicantResponseToTheObjection,
     super.theDateOfTheHearingSession,
     super.decisionOfTheExhibitionCommittee,
     super.dateOfPaymentOfTheRegistrationFee,
     super.dateOfRegistration,
     super.renewalDate,
     super.acceptanceNote,
     super.theDateOfPaymentOfTheGrievanceFee,
     super.grivenceNotes,
     super.grievanceCommitteeNumber,
     super.historyOfTheGrievanceCommittee,
     super.theDateOfTheRejection,
     super.theReasonOfRefuse,
     super.technicalOpinion,
    super.dateOfAppeal,
    super.commissionersDecision,
    super.courtDecision,
    super.giveUpDate,
    super.giveUpNotes,
    super.acceptGallery,
    super.appealBrandRegistrationGallery,
    super.appealGrivenceGallery,
    super.conditionalAcceptanceGallery,
    super.giveUpGallery,
    super.grievanceGallery,
    super.grievanceTeamDecisionGallery,
    super.processingGallery,
    super.refusedGallery,
    super.renovationsGallery,
    super.publish_date_Gallery,
    super.replyImportNumOpposition,
    super.dateNotifyTheStudentOfOpposition,
    super.opposition_note,
    super.importNumberPosition
});

  factory AllResultModel.fromJson(Map<String, dynamic> json,) {
      return AllResultModel(
       states: json["name"],
       id: json['id'],
       brandId: json['brand_id'],
       number: json['number'],
       name: json['name'],
        created_at:json["created_at"],
        acceptGallery:json["accept_images"]==null?[]:  List<ImagesModel>.from((json["accept_images"]).map((e) => ImagesModel.fromJson(e))),
        renovationsGallery: json["renovation_images"]==null?[]:  List<ImagesModel>.from((json["renovation_images"]).map((e) => ImagesModel.fromJson(e))),
        appealBrandRegistrationGallery:json["rejestration_images"]==null?[]:  List<ImagesModel>.from((json["rejestration_images"]).map((e) => ImagesModel.fromJson(e))),
        appealGrivenceGallery:json["appeal_grivence_images"]==null?[]:  List<ImagesModel>.from((json["appeal_grivence_images"]).map((e) => ImagesModel.fromJson(e))),
        conditionalAcceptanceGallery:json["conditional_acceptance_images"]==null?[]:  List<ImagesModel>.from((json["conditional_acceptance_images"]).map((e) => ImagesModel.fromJson(e))),
        refusedGallery:json["refused_images"]==null?[]:  List<ImagesModel>.from((json["refused_images"]).map((e) => ImagesModel.fromJson(e))),
        processingGallery:json["processing_images"]==null?[]:  List<ImagesModel>.from((json["processing_images"]).map((e) => ImagesModel.fromJson(e))),
        grievanceTeamDecisionGallery: json["grievance_team_decision_images"]==null?[]: List<ImagesModel>.from((json["grievance_team_decision_images"]).map((e) => ImagesModel.fromJson(e))),
        grievanceGallery:json["grievance_images"]==null?[]:  List<ImagesModel>.from((json["grievance_images"]).map((e) => ImagesModel.fromJson(e))),
        giveUpGallery:json["giveup_images"]==null?[]:  (List<ImagesModel>.from(json["giveup_images"].map((e) => ImagesModel.fromJson(e))).toList())??[],


        ///         --------------->  DECISION   <---------------

        dateOfTheCaseOfTheDecisionOfTheGrievanceCommittee:
       json['date_of_the_case_of_the_decision_of_the_grievance_committee'],
       theDecisionOfTheApplicationToAcceptOrReject:
       json['the_decision_of_the_application_to_accept_or_reject'],
       technicalOpinionDecision: json['technical_opinion_decision'],

       ///         --------------->  Renovations   <---------------

       dateOfRenewalStatus: json['date_of_renewal_status'],
       dateOfRenewalFee: json['date_of_renewal_fee'],
       renewalDateRenovations: json['renewal_date_renovations'],
       renewalPeriod: json['renewal_period'],


        ///         --------------->  ConditionalAcceptance   <---------------

       admissionStatusDateConditional: json['admission_status_date_conditional'],
       recordConditional: json['record_conditional'],
       publicityFeePaymentDateConditional:
       json['publicity_fee_payment_date_conditional'],
       publishDateConditional: json['publish_date_conditional'],
       numberOfNewspaperConditional: json['number_of_newspaper_conditional'],
       exhibitionDetailsConditional: json['exhibition_details_conditional'],
       theApplicantResponseToTheObjectionConditional:
       json['the_applicant_response_to_the_objection_conditional'],
       theDateOfTheHearingSessionConditional:
       json['the_date_of_the_hearing_session_conditional'],
       decisionOfTheExhibitionCommitteeConditional:
       json['decision_of_the_exhibition_committee_conditional'],
       renewalDateConditional: json['renewal_date_conditional'],
       dateOfPaymentOfTheRegistrationFeeConditional:
       json['date_of_payment_of_the_registration_fee_conditional'],
       dateOfRegistrationConditional: json['date_of_registration_conditional'],
       noteTheConditionalAcceptance: json['note_the_conditional_acceptance'],
       requirements: json['requirements'],
       notifyTheStudentOfTheOpposition:
       json['notify_the_student_of_the_opposition'],
       firstNotificationOfTheOppositionApostate:
       json['first_notification_of_the_opposition_apostate'],
       secondNotificationOfTheOppositionApostate:
       json['second_notification_of_the_opposition_apostate'],

        ///         --------------->  APPEAL Grievance   <---------------


       theDateOfPaymentOfTheAppealFee:
       json['the_date_of_payment_of_the_appeal_fee'],
       appealDecision: json['appeal_decision'],
       appealNotes: json['appeal_notes'],

        ///         --------------->  ACCEPT   <---------------


        admissionStatusDate: json['admission_status_date'],
       record: json['record'],
       publicityFeePaymentDate: json['publicity_fee_payment_date'],
       publishDate: json['publish_date'],
       numberOfNewspaper: json['number_of_newspaper']??"",
       notifyTheStudentOfOpposition: json['notify_the_student_of_opposition'],
       exhibitionDetails: json['exhibition_details'],
       firstNoticeOfOppositionApostate:
       json['first_notice_of_opposition_apostate'],
       secondNoticeOfOppositionApostate:
       json['second_notice_of_opposition_apostate'],
       theApplicantResponseToTheObjection:
       json['the_applicant_response_to_the_objection'],
       theDateOfTheHearingSession: json['the_date_of_the_hearing_session'],
       decisionOfTheExhibitionCommittee:
       json['decision_of_the_exhibition_committee'],
       dateOfPaymentOfTheRegistrationFee:
       json['date_of_payment_of_the_registration_fee'],
       dateOfRegistration: json['date_of_registration'],
       renewalDate: json['renewal_date'],
       acceptanceNote: json['acceptance_note'],
       replyImportNumOpposition: json['reply_import_number_opposition'],
       theDateOfPaymentOfTheGrievanceFee:
       json['the_date_of_payment_of_the_grievance_fee'],
       grivenceNotes: json['grivence_notes'],
       grievanceCommitteeNumber: json['grievance_committee_number'],
       historyOfTheGrievanceCommittee:
       json['history_of_the_grievance_committee'],
        publish_date_Gallery:json["publish_date_images"]==null?[]:  List<ImagesModel>.from((json["publish_date_images"]).map((e) => ImagesModel.fromJson(e))),
dateNotifyTheStudentOfOpposition: json["date_notify_the_student_of_opposition"]??"",
       opposition_note: json['opposition_note'],
importNumberPosition: json["import_number_opposition"],
       /// REFUSED
       theDateOfTheRejection: json['the_date_of_the_rejection'],
       theReasonOfRefuse: json['the_reason_of_refuse'],
       technicalOpinion: json['technical_opinion'],

        ///AppealBrandRegistration

        dateOfAppeal: json['The_date_of_the_appeal_brand'],
        commissionersDecision: json['commissioners_decision'],
        courtDecision: json['court_decision'],

        ///GiveUp

        giveUpDate: json['giveup_date'],
        giveUpNotes: json['giveup_notes'],

    );
  }

}



























 /*
  *  factory AllResultModel.fromJson(Map<String, dynamic> json,) {
    print(json["created_at"]);
     return AllResultModel(
        states:json["name"],
        rejection:json["name"]=="الرفض"?  Rejection.fromJson(json):null,
        grivence:json["name"]=="التظلم"? Grivence.fromJson(json):null,
        acceptance:json["name"]=="قبول"? Acceptance.fromJson(json):null,
        appealGrivence:json["name"]=="الطعن ضد التظلم"?
            AppealGrivence.fromJson(json):null,
        conditionalAcceptance:json["name"]=="قبول مشترط"?
           ConditionalAcceptance.fromJson(json):ConditionalAcceptance(),
        renovations:json["name"]=="التجديدات"?
          Renovations.fromJson(json):null,
        decision:json["name"]=="قرار لجنه التظلم"?
            Decision.fromJson(json):null,
        underTechnicalInspection:json["name"]=="تحت الفحص الفني"?
        UnderTechnicalInspection.fromJson(json):null
    );
  }
  *
  * */



 // AllResultModel(
 //   {  super.states,
 //     super.rejection,
 //     super.grivence,
 //     super.acceptance,
 //     super.appealGrivence,
 //     super.conditionalAcceptance,
 //     super.renovations,
 //     super.decision,
 //     super.underTechnicalInspection,
 //    });