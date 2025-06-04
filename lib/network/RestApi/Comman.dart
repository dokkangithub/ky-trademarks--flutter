import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';
import 'package:kyuser/UserData/data/models/UserModel.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../resources/ImagesConstant.dart';
import '../../resources/Color_Manager.dart';
import '../../resources/StringManager.dart';
import '../../utilits/Local_User_Data.dart';


Future<void> saveUserData(UserModel data) async {
  await globalAccountData.setId(data.data.id.toString());
  await globalAccountData.setUsername(data.data.name);
  await globalAccountData.setEmail(data.data.email);
  // await globalAccountData.setState(data.data!.city.toString());
  await globalAccountData.setPhone(data.data.phone);
  await globalAccountData.setAdminPhone(data.data.adminPhone);
  debugPrint(data.data.pin_code.toString() + "||||||");
  await globalAccountData.setUserPin(data.data.pin_code);
  // await globalAccountData.setAddress(data.data!.address!);
  await globalAccountData.setLoginInState(true);
}

Future<void> logOut() async {
  await globalAccountData.setId('');
  await globalAccountData.setPhone('');
  await globalAccountData.setActiveStatus('');
  await globalAccountData.setUsername('');
  await globalAccountData.setLoginInState(false);
  await globalAccountData.setEmail('');
  await globalAccountData.setUserPin(014785);
}

// toast(
//   String? value, {
//   ToastGravity? gravity,
//   length = Toast.LENGTH_SHORT,
//   Color? bgColor,
//   Color? textColor,
//   bool print = false,
// }) {
//   Fluttertoast.showToast(
//     msg: value!,
//     gravity: gravity,
//     toastLength: length,
//     backgroundColor: bgColor ?? ColorManager.primary,
//     textColor: textColor,
//   );
// }


toast(
    String? value, {
      Object? gravity, // Changed from ToastGravity
      length = 2, // Changed from Toast.LENGTH_SHORT to direct value
      Color? bgColor,
      Color? textColor,
      bool print = false,
    }) {
  // Convert gravity parameter to oktoast position
  ToastPosition position = ToastPosition.bottom;
  if (gravity == 'top') {
    position = ToastPosition.top;
  } else if (gravity == 'center') {
    position = ToastPosition.center;
  }

  // Convert length to oktoast duration
  Duration duration = Duration(seconds: length is int ? length : 2);

  showToast(
    value!,
    position: position,
    duration: duration,
    backgroundColor: bgColor ?? ColorManager.primary,
    textStyle: TextStyle(color: textColor ?? Colors.white),
  );
}

/// returns true if network is available
Future<bool> isNetworkAvailable() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

/// returns true if connected to mobile
Future<bool> isConnectedToMobile() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult == ConnectivityResult.mobile;
}

/// returns true if connected to wifi
Future<bool> isConnectedToWiFi() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult == ConnectivityResult.wifi;
}



Widget cachedImage(
    String? url, {
      double? height,
      double? width,
      double? phWidth,
      BoxFit? fit,
      BoxFit? placeHolderFit,
      AlignmentGeometry? alignment,
      bool usePlaceholderIfUrlEmpty = true,
    }) {
  if (url == null) {
    return placeHolderWidget(
      height: height,
      width: phWidth ?? width,
      fit: BoxFit.contain,
      alignment: alignment,
    );
  } else if (url.startsWith('http')) {
    if (kIsWeb) {
      // Use ImageNetwork for web
      return ImageNetwork(
        image: url,
        height: height ?? 100.0,
        width: width ?? 150.0,
        duration: 1500,
        curve: Curves.easeIn,
        onPointer: true,
        debugPrint: false,
        backgroundColor: Colors.transparent,
        fitWeb: BoxFitWeb.contain,
        onLoading: placeHolderWidget(
          height: height,
          width: phWidth ?? width,
          fit: BoxFit.contain,
          alignment: alignment,
        ),
        onError: const Icon(
          Icons.error,
          color: Colors.red,
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: width,
        fit: fit,
        alignment: alignment as Alignment? ?? Alignment.center,
        errorWidget: (_, s, d) {
          return placeHolderWidget(
            height: height,
            width: phWidth ?? width,
            fit: BoxFit.contain,
            alignment: alignment,
          );
        },
        placeholder: (_, s) {
          if (!usePlaceholderIfUrlEmpty) return const SizedBox();
          return placeHolderWidget(
            height: height,
            width: phWidth ?? width,
            fit: BoxFit.contain,
            alignment: alignment,
          );
        },
      );
    }
  } else {
    return Image.asset(
      url,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment ?? Alignment.center,
    );
  }
}

Widget placeHolderWidget(
    {double? height,
    double? width,
    BoxFit? fit,
    AlignmentGeometry? alignment}) {
  return Image.asset(
    ImagesConstants.homeTapBar,
    height: height,
    width: width,
    fit: fit ?? BoxFit.cover,
    alignment: alignment ?? Alignment.center,
  );
}

OutlineInputBorder borderStyle = OutlineInputBorder(
  borderSide: BorderSide.none,
  borderRadius: BorderRadius.circular(40),
);

validateObjects() {
  return (val) {
    if (val == null || val == "") {
      return "هذا الحقل مطلوب";
    } else {
      return null;
    }
  };
}

InputDecoration decoration(text, {icon}) {
  return InputDecoration(
    prefixIcon: Icon(
      icon,
      color: ColorManager.primary,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    prefixIconConstraints:
        BoxConstraints(maxWidth: icon == null ? 20 : double.infinity),
    hintText: text,
    hintStyle: TextStyle(
        color: ColorManager.mediumGrey,
        letterSpacing: 0.6,
        fontFamily: "Shahid",
        fontSize: 13),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(40),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(40),
    ),
    disabledBorder: borderStyle,
    border: borderStyle,
  );
}

void openWhatsapp(
    {required BuildContext context,
    required String text,
    required String number}) async {
  var whatsapp = number;
  // var whatsappURlAndroid = "https://wa.me/<$number>";
  var whatsappURlAndroid = "whatsapp://send?phone=$whatsapp&text=$text";
  var whatsappURLIos = "https://wa.me/$whatsapp?text=${Uri.tryParse(text)}";
  if (Platform.isIOS) {
    if (await canLaunchUrl(Uri.parse(whatsappURLIos))) {
      await launchUrl(Uri.parse(
        whatsappURLIos,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Whatsapp not installed")));
    }
  } else {
    // if (await canLaunch(whatsappURlAndroid))
    //       await launch(whatsappURlAndroid);

    await launchUrl(Uri.parse(whatsappURlAndroid));
    //  else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text("Whatsapp not installed")));
    // }

  }
}

bool checkNullValue({dynamic value}) {
  if (value == null) {
    return false;
  } else if (value is int && value == 0) {
    return false;
  } else if (value is String && value.isEmpty) {
    return false;
  } else if (value is bool && value == false) {
    return false;
  }
  return true;
}

Padding stateOfBrand(TextStyle? headline1, text, created_at,
    {double? nameWidth}) {
  return Padding(
    padding: const EdgeInsetsDirectional.only(start: 10, end: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Container(
              width: nameWidth,
              child: Text(
                "$text",
                style: headline1?.copyWith(
                    fontSize: 14, color: ColorManager.primaryByOpacity),
              )),
        ),
        SizedBox(
          width: 12,
        ),
        Expanded(
          flex: 2,
          child: Text(
            "${DateFormat('EEEE , d MMM, yyyy').format(DateTime.parse(created_at))}",
            style: headline1?.copyWith(
                fontSize: 14, color: ColorManager.primaryByOpacity),
          ),
        ),
      ],
    ),
  );
}

String convertStateBrandNumberToString(int state) {
  switch (state) {
    case 1:
      return StringConstant.processing;
    case 2:
      return StringConstant.accept;
    case 3:
      return StringConstant.reject;
    case 4:
      return StringConstant.grievance;
    case 5:
      return StringConstant.grievanceTeamDecision;
    case 6:
      return StringConstant.renovations;
    case 7:
      return StringConstant.objectionInGrievance;
    case 8:
      return StringConstant.acceptBut;
    case 9:
      return StringConstant.giveUp;
    case 10:
      return StringConstant.appealBrandRegistration;
    default:
      return "لا يوجد حالة علامة ";
  }
}
