import 'package:flutter/material.dart';

import 'Color_Manager.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
      // main colors of the app
      primaryColor: ColorManager.primary,
      primaryColorLight: ColorManager.white,
      primaryColorDark: ColorManager.lightGrey,
      hintColor: ColorManager.accent,
      // fontFamily: "Shahid",
      appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontFamily: "Shahid",
              color: ColorManager.primary,
              fontWeight: FontWeight.w600,
              fontSize: 20)),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: ColorManager.primaryByOpacity,fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: "Shahid"
         ),
        displayMedium: TextStyle(
          color: ColorManager.mediumGrey,fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: "Shahid"
        ),
        displaySmall: TextStyle(
          color: ColorManager.lightGrey,fontSize: 17,
          fontWeight: FontWeight.w500,
          fontFamily: "Shahid"
        ),
      ),

      // card view theme
       // Button theme
       // input decoration theme (text form field)

      );
}
