class AppealGrivence {
  int? id;
  int? brandId;
  String? theDateOfPaymentOfTheAppealFee;
  String? appealDecision;
  String? appealNotes;
  int? number;
  String? name;

  AppealGrivence({
    this.id,
    this.brandId,
    this.theDateOfPaymentOfTheAppealFee,
    this.appealDecision,
    this.appealNotes,
    this.number,
    this.name,
  });

  factory AppealGrivence.fromJson(Map<String, dynamic> json) {
    return AppealGrivence(
      id: json['id'],
      brandId: json['brand_id'],
      theDateOfPaymentOfTheAppealFee:
      json['the_date_of_payment_of_the_appeal_fee'],
      appealDecision: json['appeal_decision'],
      appealNotes: json['appeal_notes'],
      number: json['number'],
      name: json['name'],
    );
  }
}
