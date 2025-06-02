import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kyuser/resources/ImagesConstant.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../../data/Brand/DataSource/GetBrandRemotoData.dart';
import '../../resources/Color_Manager.dart';
import '../../resources/StringManager.dart';
import 'package:provider/provider.dart';
import 'package:kyuser/presentation/Controllar/LoginProvider.dart'; // Assuming this path is correct
import 'package:kyuser/network/RestApi/Comman.dart';

import 'AddRequest.dart';
import 'PaymentWays.dart';

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;
    final isTablet = size.width > 600 && size.width <= 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            // Right Side - Image (unchanged)
            if (isDesktop || isTablet)
              Expanded(
                flex: 6,
                child: SizedBox(
                    height: MediaQuery.sizeOf(context).height,
                    child: Image.asset(
                      ImagesConstants.kyLogin,
                      fit: BoxFit.cover,
                    )),
              ),
            // Left Side - Login Form
            Expanded(
              flex: isDesktop ? 4 : 10,
              child: Container(
                height: MediaQuery.sizeOf(context).height,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Color(0xff00acc8), Color(0xff155e7d)],
                  stops: [0.25, 0.8],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
                padding: EdgeInsets.all(isDesktop ? 40.0 : 20.0),
                child: SingleChildScrollView(
                  child: Consumer<LoginProvider>(
                    builder: (context, model, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading
                        Text(
                          'login_your_account'.tr(),
                          style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: StringConstant.fontName,
                          ),
                        ),
                        const SizedBox(height: 40.0),

                        // Email Input
                        _buildFormLabel('email'.tr()),
                        const SizedBox(height: 8.0),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'enter_email'.tr(),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24.0),

                        // Password Input
                        _buildFormLabel('password'.tr()),
                        const SizedBox(height: 8.0),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'password'.tr(),
                          obscureText: _obscureText,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: ColorManager.lightGrey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _handleForgotPassword,
                              child: Text(
                                "forget_password".tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: ColorManager.lightGrey,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: StringConstant.fontName),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        // Submit Button with LoginProvider
                        SizedBox(
                          width: double.infinity,
                          height: 56.0,
                          child: ElevatedButton(
                            onPressed: model.loading
                                ? null
                                : () => _handleLogin(model),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 0,
                            ),
                            child: model.loading
                                ? CircularProgressIndicator(
                                    color: Colors.black87)
                                : Text(
                                    'login'.tr(),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: StringConstant.fontName,
                                      color: Colors.black87,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        _buildNoAccountSection(),
                        _buildApplyNowSection(),
                        _buildTermsText(),
                        _buildPaymentMethodsSection()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods (unchanged from your new screen)
  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: ColorManager.lightGrey,
          fontFamily: StringConstant.fontName),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(fontFamily: StringConstant.fontName),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
              color: Colors.grey.shade400, fontFamily: StringConstant.fontName),
          contentPadding: const EdgeInsets.all(20.0),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildNoAccountSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "have_no_account".tr(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: StringConstant.fontName),
        ),
        const SizedBox(width: 5),
        OutlinedButton(
          style: ButtonStyle(
            side: WidgetStateProperty.all(
              BorderSide(color: ColorManager.lightGrey),
            ),
          ),
          onPressed: _handleContactUs,
          child: Text(
            "contact_us".tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ColorManager.lightGrey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: StringConstant.fontName),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyNowSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            style: ButtonStyle(
              side: WidgetStateProperty.all(
                BorderSide(color: ColorManager.lightGrey),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddRequest(
                    canBack: true,
                  ),
                ),
              );
            },
            child: Text(
              "or_ask".tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.lightGrey,
                    fontFamily: StringConstant.fontName,
                  ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          "agree_services".tr(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ColorManager.lightGrey,
              fontWeight: FontWeight.w900,
              fontSize: 11.5,
              fontFamily: StringConstant.fontName),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isNarrow = constraints.maxWidth < 600;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  "payment_browse".tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: isNarrow ? 12 : 14,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.lightGrey,
                    fontFamily: StringConstant.fontName,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: isNarrow ? 8 : 10),
              OutlinedButton(
                style: ButtonStyle(
                  side: WidgetStateProperty.all(
                    BorderSide(color: ColorManager.lightGrey),
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentWays()),
                ),
                child: Text(
                  "payment methods".tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: isNarrow ? 12 : 14,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.white,
                    fontFamily: StringConstant.fontName,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
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
      print('Starting _handleContactUs');
      final getBrandRemoteData = GetBrandRemoteData();

      final String phoneNumber = await getBrandRemoteData.adminPhone();
      print('Retrieved phone number: $phoneNumber');

      if (phoneNumber.isNotEmpty) {
        await openWhatsappCrossPlatform(
          context: context,
          number: phoneNumber,
          text: "من فضلك , اريد انشاء حساب جديد",
        );
      } else {
        print('Empty phone number returned');
        // Handle empty phone number case
      }
    } catch (e) {
      print('Error in _handleContactUs: $e');
      // Show an error message to the user
    }
  }

  Future<void> openWhatsappCrossPlatform({
    required BuildContext context,
    required String number,
    required String text,
  }) async {
    print(number);
    String formattedNumber = number.replaceAll('+', '');
    String encodedText = Uri.encodeComponent(text);
    final String urlString = kIsWeb
        ? "https://web.whatsapp.com/send?phone=$formattedNumber&text=$encodedText"
        : "https://wa.me/$formattedNumber?text=$encodedText";
    final Uri url = Uri.parse(urlString);

    try {
      if (kIsWeb) {
        // On web, open in a new tab to avoid same-tab navigation issues
        final bool launched = await launcher.launchUrl(
          url,
          mode: launcher.LaunchMode.externalApplication,
          // Forces new tab/window
          webOnlyWindowName: '_blank',
        );
      } else {
        // On mobile, use external application mode
        final bool launched = await launcher.launchUrl(
          url,
          mode: launcher.LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
