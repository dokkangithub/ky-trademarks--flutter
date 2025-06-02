class Renovations {
  int? id;
  int? brandId;
  String? dateOfRenewalStatus;
  String? dateOfRenewalFee;
  String? renewalDateRenovations;
  String? renewalPeriod;
  int? number;
  String? name;

  Renovations({
    this.id,
    this.brandId,
    this.dateOfRenewalStatus,
    this.dateOfRenewalFee,
    this.renewalDateRenovations,
    this.renewalPeriod,
    this.number,
    this.name,
  });

  factory Renovations.fromJson(Map<String, dynamic> json) {
    return Renovations(
      id: json['id'],
      brandId: json['brand_id'],
      dateOfRenewalStatus: json['date_of_renewal_status'],
      dateOfRenewalFee: json['date_of_renewal_fee'],
      renewalDateRenovations: json['renewal_date_renovations'],
      renewalPeriod: json['renewal_period'],
      number: json['number'],
      name: json['name'],
    );
  }
}
