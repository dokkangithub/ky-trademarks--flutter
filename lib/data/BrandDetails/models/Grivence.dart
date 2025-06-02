class Grivence {
  int? id;
  int? brandId;
  String? name;
  String? theDateOfPaymentOfTheGrievanceFee;
  String? grivenceNotes;
  String? grievanceCommitteeNumber;
  String? historyOfTheGrievanceCommittee;
  int? number;

  Grivence({
    this.id,
    this.brandId,
    this.name,
    this.theDateOfPaymentOfTheGrievanceFee,
    this.grivenceNotes,
    this.grievanceCommitteeNumber,
    this.historyOfTheGrievanceCommittee,
    this.number,
  });

  factory Grivence.fromJson(Map<String, dynamic> json) {
    return Grivence(
      id: json['id'],
      brandId: json['brand_id'],
      name: json['name'],
      theDateOfPaymentOfTheGrievanceFee:
      json['the_date_of_payment_of_the_grievance_fee'],
      grivenceNotes: json['grivence_notes'],
      grievanceCommitteeNumber: json['grievance_committee_number'],
      historyOfTheGrievanceCommittee:
      json['history_of_the_grievance_committee'],
      number: json['number'],
    );
  }
}
