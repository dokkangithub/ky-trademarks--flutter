class Decision {
  int? id;
  int? brandId;
  String? name;
  String? dateOfTheCaseOfTheDecisionOfTheGrievanceCommittee;
  String? theDecisionOfTheApplicationToAcceptOrReject;
  String? technicalOpinionDecision;
  int? number;

  Decision({
    this.id,
    this.brandId,
    this.name,
    this.dateOfTheCaseOfTheDecisionOfTheGrievanceCommittee,
    this.theDecisionOfTheApplicationToAcceptOrReject,
    this.technicalOpinionDecision,
    this.number,
  });

  factory Decision.fromJson(Map<String, dynamic> json) {
    return Decision(
      id: json['id'],
      brandId: json['brand_id'],
      name: json['name'],
      dateOfTheCaseOfTheDecisionOfTheGrievanceCommittee:
      json['date_of_the_case_of_the_decision_of_the_grievance_committee'],
      theDecisionOfTheApplicationToAcceptOrReject:
      json['the_decision_of_the_application_to_accept_or_reject'],
      technicalOpinionDecision: json['technical_opinion_decision'],
      number: json['number'],
    );
  }
}
