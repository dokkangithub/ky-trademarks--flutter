import 'package:flutter/material.dart';
import 'package:kyuser/resources/ImagesConstant.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  LoadingWidget({super.key});
  double? height;
  double? width;

  @override
  Widget build(BuildContext context) {
    return  Lottie.asset(
      ImagesConstants.loading,
      fit: BoxFit.fill,
      height: height??80,
      width: width??150,

    );
  }
}
