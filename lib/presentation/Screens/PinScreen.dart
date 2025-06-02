import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import 'package:kyuser/resources/ImagesConstant.dart';

import '../../data/Brand/DataSource/GetBrandRemotoData.dart';
import '../../resources/Color_Manager.dart';
import '../../resources/Route_Manager.dart';
import '../../resources/StringManager.dart';
import '../../utilits/Local_User_Data.dart';

class PinScreen extends StatelessWidget {
  TextEditingController controller = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.topCenter,
            height: 320,
            child: Stack(
              children: [
                cachedImage(ImagesConstants.partBack,
                    width: double.infinity, fit: BoxFit.cover),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Image.asset(ImagesConstants.homeTapBar,
                        fit: BoxFit.contain,width: 180,height: 150,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(150),
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(0, 5), // changes position of shadow
                                  ),
                                ],
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2)),
                            child: cachedImage(null,
                                width: 100, height: 100, fit: BoxFit.contain),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Text(
             "${globalAccountData.getUsername()}",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22.0,
                fontFamily:StringConstant.fontName,
                letterSpacing: 1,
                color: Colors.black),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(ImagesConstants.pin),
              SizedBox(
                width: 10,
              ),
              Text(
                "Enter PIN Code",
                // "${globalAccountData.getUsername()}",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.0,
                    fontFamily: "Shahid",
                    letterSpacing: 1,
                    color: Colors.grey),
              ),
            ],
          ),
          SizedBox(
            height: 40,
          ),
          materialPin(context),
          SizedBox(
            height: 14,
          ),
          InkWell(
            onTap:() async {
          GetBrandRemoteData getBrandRemoteData = GetBrandRemoteData();
          await getBrandRemoteData.adminPhone().then((value) {
          print(value);
          openWhatsapp(context: context, number: value, text: " لقد نسيت الكود الخاص بي ارجو ارساله الي");
          });
          },
            child: Text(
              'نسيت الكود؟',

                style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
                    fontFamily:StringConstant.fontName,
                decoration: TextDecoration.underline,
                decorationColor:  Colors.grey,
                letterSpacing: 1,
                color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget materialPin(context) {
    return PinCodeTextField(
      autofocus: true,
      controller: controller,
      highlightColor: ColorManager.primaryByOpacity,
      defaultBorderColor: ColorManager.primaryByOpacity,
      hasTextBorderColor: ColorManager.primaryByOpacity,
      highlightPinBoxColor: ColorManager.primaryByOpacity,
      maxLength: 4,
       onTextChanged: (text) {
        if (text.length == 4) {
          if (text == globalAccountData.getUserPin()) {
            Navigator.pushNamed(context, Routes.tabBarRoute);
          } else {
            // toast("عفواُ, هذة الكود خاطئ");
          }
        }
      },
      onDone: (text) {
        if (text.length == 4) {
          if (int.parse(text) == globalAccountData.getUserPin()) {
            Navigator.pushNamed(context, Routes.tabBarRoute);
          } else {
            toast("عفواُ, هذة الكود خاطئ");
          }
        }
      },
      pinBoxWidth: 24,
      pinBoxHeight: 24,
      hasUnderline: false,
      wrapAlignment: WrapAlignment.spaceBetween,
      pinBoxDecoration: ProvidedPinBoxDecoration.roundedPinBoxDecoration,
      pinTextStyle: TextStyle(fontSize: 22.0, color: Colors.transparent),
      pinTextAnimatedSwitcherTransition:
          ProvidedPinBoxTextAnimation.rotateTransition,
      pinTextAnimatedSwitcherDuration: Duration(milliseconds: 300),
      highlightAnimationBeginColor: ColorManager.primary,
      highlightAnimationEndColor: ColorManager.primary,
      keyboardType: TextInputType.number,
    );
  }
}
