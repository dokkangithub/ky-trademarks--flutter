import 'package:kyuser/domain/Brand/Entities/BrandEntity.dart';


class BrandDataModel extends BrandDataEntity {
  const BrandDataModel({
    required super.status,
    required super.message,
    required super.brand,
    required super.updates,
    required super.total, // Added total
  });

  factory BrandDataModel.fromJson(Map<String, dynamic> json) {
    return BrandDataModel(
      status: json['status'] as int,
      message: json['message'] as String,
      brand: _parseBrands(json['brand']),
      updates: _parseUpdates(json['updates']),
      total: json['brand'] != null 
          ? (json['brand']['total'] as int? ?? 0)
          : 0,
    );
  }

  static List<BrandModel> _parseBrands(dynamic brandJson) {
    if (brandJson == null) return [];
    final brandData = (brandJson as Map<String, dynamic>)['data'] as List<dynamic>?;
    return brandData?.map((e) => BrandModel.fromJson(e)).toList() ?? [];
  }

  static List<BrandsUpdateModel> _parseUpdates(dynamic updatesJson) {
    if (updatesJson == null) return [];
    final updatesData = (updatesJson as Map<String, dynamic>)['data'] as List<dynamic>?;
    return updatesData?.map((e) => BrandsUpdateModel.fromJson(e)).toList() ?? [];
  }
}

class BrandModel extends BrandEntity {
  const BrandModel({
    required super.id,
    required super.brandName,
    required super.brandNumber,
    required super.country,
    required super.currentStatus,
    required super.newCurrentStatus,
    required super.markOrModel,
    required super.state,
    required super.images,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as int,
      brandName: json['brand_name'] as String,
      brandNumber: json['brand_number'] ==null?'':json['brand_number'] as String,
      currentStatus: json['current_status'] as int,
      newCurrentStatus: (json['new_current'] ?? '') as String,
      country: json['country'] as int?,
      markOrModel: json['mark_or_model'] as int,
      state: (json['state'] ?? '') as String,
      images: _parseImages(json['images']),
    );
  }

  static List<ImagesModel> _parseImages(List<dynamic>? imagesJson) {
    return imagesJson?.map((e) => ImagesModel.fromJson(e)).toList() ?? [];
  }
}

class BrandsUpdateModel extends BrandsUpdates {
  BrandsUpdateModel({
    required super.brand_name,
    required super.current_status,
    required super.date,
    required super.images,
  });

  factory BrandsUpdateModel.fromJson(Map<String, dynamic> json) {
    // Handle both String and Map formats for date field
    String dateString;
    final dateValue = json['date'];
    
    if (dateValue is Map<String, dynamic>) {
      // If date is a Map, extract created_at
      dateString = dateValue['created_at'] as String;
    } else if (dateValue is String) {
      // If date is already a String, use it directly
      dateString = dateValue;
    } else {
      // Fallback to empty string if neither
      dateString = '';
    }
    
    return BrandsUpdateModel(
      brand_name: json['brand_name'] as String,
      current_status: json['current_status'] as int,
      date: dateString,
      images: _parseImages(json['images']),
    );
  }

  static List<ImagesModel> _parseImages(List<dynamic>? imagesJson) {
    return imagesJson?.map((e) => ImagesModel.fromJson(e)).toList() ?? [];
  }
}

class ImagesModel extends BrandImages {
  const ImagesModel({
    required super.image,
    required super.conditionId,
    required this.type,
  });

  final String type;

  factory ImagesModel.fromJson(Map<String, dynamic> json) {
    return ImagesModel(
      image: json['image'] as String,
      conditionId: json['condition_id'],
      type: (json['type'] ?? '') as String,
    );
  }
}

class TypesModel extends BrandTypes {
  const TypesModel({required super.type}) ;

  factory TypesModel.fromJson(Map<String, dynamic> json) {
    return TypesModel(type: json["type"]);
  }
}