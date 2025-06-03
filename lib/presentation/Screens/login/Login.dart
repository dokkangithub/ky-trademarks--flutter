import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kyuser/resources/ImagesConstant.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../../../data/Brand/DataSource/GetBrandRemotoData.dart';
import '../../../resources/Color_Manager.dart';
import '../../../resources/StringManager.dart';
import 'package:provider/provider.dart';
import 'package:kyuser/presentation/Controllar/LoginProvider.dart'; // Assuming this path is correct
import 'package:kyuser/network/RestApi/Comman.dart';

import '../add request/AddRequest.dart';
import '../PaymentWays.dart';
import 'widgets/mobile_view.dart';
import 'widgets/web_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static var token;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle login similar to the old screen
  void _handleLogin(LoginProvider model) {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      toast("من فضلك ادخل جميع الحقول");
    } else if (_passwordController.text.length < 6) {
      toast("الرقم السري غير صحيح");
    } else {
      model.loginWithUserAndPassword(
        context: context,
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb || size.width > 900;

    return Scaffold(
      body: isWeb
          ? WebLoginView(
              emailController: _emailController,
              passwordController: _passwordController,
              obscureText: _obscureText,
              togglePasswordVisibility: _togglePasswordVisibility,
              handleLogin: _handleLogin,
              handleForgotPassword: _handleForgotPassword,
              handleContactUs: _handleContactUs,
            )
          : MobileLoginView(
              emailController: _emailController,
              passwordController: _passwordController,
              obscureText: _obscureText,
              togglePasswordVisibility: _togglePasswordVisibility,
              handleLogin: _handleLogin,
              handleForgotPassword: _handleForgotPassword,
              handleContactUs: _handleContactUs,
            ),
    );
  }

  void _handleForgotPassword() async {
    final getBrandRemoteData = GetBrandRemoteData();
    await getBrandRemoteData.adminPhone().then((value) {
      openWhatsappCrossPlatform(
        context: context,
        number: value,
        text: "من فضلك قم بأرسال كلمة المرور الخاصة بي !",
      );
    });
  }

  void _handleContactUs() async {
    try {
      final getBrandRemoteData = GetBrandRemoteData();
      final String phoneNumber = await getBrandRemoteData.adminPhone();
      
      if (phoneNumber.isNotEmpty) {
        await openWhatsappCrossPlatform(
          context: context,
          number: phoneNumber,
          text: "من فضلك , اريد انشاء حساب جديد",
        );
      }
    } catch (e) {
      print('Error in _handleContactUs: $e');
    }
  }

  Future<void> openWhatsappCrossPlatform({
    required BuildContext context,
    required String number,
    required String text,
  }) async {
    String formattedNumber = number.replaceAll('+', '');
    String encodedText = Uri.encodeComponent(text);
    final String urlString = kIsWeb
        ? "https://web.whatsapp.com/send?phone=$formattedNumber&text=$encodedText"
        : "https://wa.me/$formattedNumber?text=$encodedText";
    final Uri url = Uri.parse(urlString);

    try {
      if (kIsWeb) {
        // On web, open in a new tab to avoid same-tab navigation issues
        await launcher.launchUrl(
          url,
          mode: launcher.LaunchMode.externalApplication,
          // Forces new tab/window
          webOnlyWindowName: '_blank',
        );
      } else {
        // On mobile, use external application mode
        await launcher.launchUrl(
          url,
          mode: launcher.LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
