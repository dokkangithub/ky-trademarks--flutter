class Acceptance {
  int? id;
  int? brandId;
  String? name;
  String? admissionStatusDate;
  String? record;
  String? publicityFeePaymentDate;
  int? number;
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

  Acceptance({
    this.id,
    this.brandId,
    this.name,
    this.admissionStatusDate,
    this.record,
    this.publicityFeePaymentDate,
    this.number,
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
  });

  factory Acceptance.fromJson(Map<String, dynamic> json) {
    return Acceptance(
      id: json['id'],
      brandId: json['brand_id'],
      name: json['name'],
      admissionStatusDate: json['admission_status_date'],
      record: json['record'],
      publicityFeePaymentDate: json['publicity_fee_payment_date'],
      number: json['number'],
      publishDate: json['publish_date'],
      numberOfNewspaper: json['number_of_newspaper'],
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
    );
  }
}
