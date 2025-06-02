class ConditionalAcceptance {
  int? id;
  int? brandId;
  String? admissionStatusDateConditional;
  String? recordConditional;
  String? publicityFeePaymentDateConditional;
  String? publishDateConditional;
  String? numberOfNewspaperConditional;
  int? number;
  String? exhibitionDetailsConditional;
  String? theApplicantResponseToTheObjectionConditional;
  String? theDateOfTheHearingSessionConditional;
  String? decisionOfTheExhibitionCommitteeConditional;
  String? renewalDateConditional;
  String? dateOfPaymentOfTheRegistrationFeeConditional;
  String? dateOfRegistrationConditional;
  String? name;
  String? noteTheConditionalAcceptance;
  String? requirements;
  String? notifyTheStudentOfTheOpposition;
  String? firstNotificationOfTheOppositionApostate;
  String? secondNotificationOfTheOppositionApostate;

  ConditionalAcceptance({
    this.id,
    this.brandId,
    this.admissionStatusDateConditional,
    this.recordConditional,
    this.publicityFeePaymentDateConditional,
    this.publishDateConditional,
    this.numberOfNewspaperConditional,
    this.number,
    this.exhibitionDetailsConditional,
    this.theApplicantResponseToTheObjectionConditional,
    this.theDateOfTheHearingSessionConditional,
    this.decisionOfTheExhibitionCommitteeConditional,
    this.renewalDateConditional,
    this.dateOfPaymentOfTheRegistrationFeeConditional,
    this.dateOfRegistrationConditional,
    this.name,
    this.noteTheConditionalAcceptance,
    this.requirements,
    this.notifyTheStudentOfTheOpposition,
    this.firstNotificationOfTheOppositionApostate,
    this.secondNotificationOfTheOppositionApostate,
  });

  factory ConditionalAcceptance.fromJson(Map<String, dynamic> json) {
    return ConditionalAcceptance(
      id: json['id'],
      brandId: json['brand_id'],
      admissionStatusDateConditional: json['admission_status_date_conditional'],
      recordConditional: json['record_conditional'],
      publicityFeePaymentDateConditional:
      json['publicity_fee_payment_date_conditional'],
      publishDateConditional: json['publish_date_conditional'],
      numberOfNewspaperConditional: json['number_of_newspaper_conditional'],
      number: json['number'],
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
      name: json['name'],
      noteTheConditionalAcceptance: json['note_the_conditional_acceptance'],
      requirements: json['requirements'],
      notifyTheStudentOfTheOpposition:
      json['notify_the_student_of_the_opposition'],
      firstNotificationOfTheOppositionApostate:
      json['first_notification_of_the_opposition_apostate'],
      secondNotificationOfTheOppositionApostate:
      json['second_notification_of_the_opposition_apostate'],
    );
  }
}
