import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../resources/Color_Manager.dart';
import '../../../resources/ImagesConstant.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Using ColorFiltered or Image with color parameter instead of Opacity widget
        Align(
          alignment: Alignment.center,
          child: Opacity(
            opacity: 0.1,
            child: Image(
              image: AssetImage(ImagesConstants.background,),
              color: Colors.white.withValues(alpha: 0.05),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
        ),
        SingleChildScrollView(
          // Add physics to make scrolling behavior more predictable
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50,),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 20),
                child: Center(
                  child: kIsWeb
                      ? Image.asset('assets/images/no_data_image.png', width: 300, height: 300)
                      : Lottie.asset(ImagesConstants.noData, width: 300, height: 300, fit: BoxFit.contain),
                ),
              ),
              SizedBox(height: 50,),
              SizedBox(
                width: 310,
                child: Text(
                  "search_by_brand_models".tr(),
                  style: TextStyle(
                    fontFamily: "Shahid",
                    color: ColorManager.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 15,),
              SizedBox(
                width: 280,
                child: Text(
                  "search_by_brand_numbers".tr(),
                  style: TextStyle(
                    fontFamily: "Shahid",
                    color: ColorManager.accent.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}