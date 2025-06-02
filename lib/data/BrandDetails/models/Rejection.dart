class Rejection {
  int? id;
  int? brandId;
  String? name;
  String? theDateOfTheRejection;
  String? theReasonOfRefuse;
  String? technicalOpinion;
  int? number;

  Rejection({
    this.id,
    this.brandId,
    this.name,
    this.theDateOfTheRejection,
    this.theReasonOfRefuse,
    this.technicalOpinion,
    this.number,
  });

  factory Rejection.fromJson(Map<String, dynamic> json) {
    return Rejection(
      id: json['id'],
      brandId: json['brand_id'],
      name: json['name'],
      theDateOfTheRejection: json['the_date_of_the_rejection'],
      theReasonOfRefuse: json['the_reason_of_refuse'],
      technicalOpinion: json['technical_opinion'],
      number: json['number'],
    );
  }
}
