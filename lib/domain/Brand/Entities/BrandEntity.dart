import 'package:equatable/equatable.dart';


class BrandDataEntity extends Equatable {
  final int status;
  final String message;
  final List<BrandEntity> brand;
  final List<BrandsUpdates> updates;
  final int total; // Added total field

  const BrandDataEntity({
    required this.status,
    required this.message,
    required this.brand,
    required this.updates,
    required this.total, // Added to constructor
  });

  @override
  List<Object?> get props => [status, message, brand, updates, total]; // Added total to props
}

class BrandEntity extends Equatable {
  final int id;
  final String brandName;
  final String brandNumber;
  final int? country;
  final int currentStatus;
  final String newCurrentStatus;
  final int markOrModel;
  final String state;
  final String brandDescription;

  final List<BrandImages> images;

  const BrandEntity(
      {required this.id,
      required this.brandName,
      required this.brandNumber,
      required this.currentStatus,
       required this.newCurrentStatus,
      required this.images,
      required this.markOrModel,
      required this.country,
      required this.state,
      required this.brandDescription});

  @override
// TODO: implement props
  List<Object?> get props =>
      [id, brandName, brandName, currentStatus, images, markOrModel, brandDescription];
}
class BrandsUpdates extends Equatable {
  final String brand_name;
  final int current_status;
  final String date;
  final List<BrandImages> images;

  BrandsUpdates({required this.brand_name,required this.current_status,required this.date,required this.images});


  @override
// TODO: implement props
  List<Object?> get props =>
      [brand_name, current_status, date, date, ];
}

class BrandImages extends Equatable {
  final String image;
  final dynamic conditionId;

  const BrandImages({
    required this.image,
    required this.conditionId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        image,
    conditionId,
      ];
}
class BrandTypes extends Equatable {
  final String type;

  const BrandTypes({
    required this.type,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        type,
      ];
}
