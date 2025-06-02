
class UnderTechnicalInspection {
  int? id;
  int? brandId;
  int? number;
  String? name;

  UnderTechnicalInspection({
    this.id,
    this.brandId,
    this.number,
    this.name,
  });

  factory UnderTechnicalInspection.fromJson(Map<String, dynamic> json) {
    return UnderTechnicalInspection(
      id: json['id'],
      brandId: json['brand_id'],
      number: json['number'],
      name: json['name'],
    );
  }
}
