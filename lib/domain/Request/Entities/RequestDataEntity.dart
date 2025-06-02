import 'package:equatable/equatable.dart';

class RequestDataEntity extends Equatable {
  final int status;
  final String message;
  final RequestEntity requestEntity;

  const RequestDataEntity({required this.status,required this.message,required this.requestEntity});

  @override
  // TODO: implement props
  List<Object?> get props => [status,message,requestEntity];

}

class RequestEntity extends Equatable {
  final String name;
  final String description;
  final List<dynamic> images;

  RequestEntity(
      {required this.name,
      required this.description,
      required this.images,});


  @override
  // TODO: implement props
  List<Object?> get props => [name,description,images,];
}
