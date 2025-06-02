import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kyuser/resources/ImagesConstant.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../../../../data/Brand/DataSource/GetBrandRemotoData.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';
import 'package:provider/provider.dart';
import 'package:kyuser/presentation/Controllar/LoginProvider.dart';
import 'package:kyuser/network/RestApi/Comman.dart';

import '../../AddRequest.dart';
import '../../PaymentWays.dart';

class WebLoginView extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscureText;
  final VoidCallback togglePasswordVisibility;
  final Function(LoginProvider) handleLogin;
  final VoidCallback handleForgotPassword;
  final VoidCallback handleContactUs;

  const WebLoginView({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.obscureText,
    required this.togglePasswordVisibility,
    required this.handleLogin,
    required this.handleForgotPassword,
    required this.handleContactUs,
  }) : super(key: key);

  @override
  State<WebLoginView> createState() => _WebLoginViewState();
}

class _WebLoginViewState extends State<WebLoginView> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 1200;
    final isMediumScreen = size.width > 900 && size.width <= 1200;
    final isSmallScreen = size.width <= 900;
    
    return Row(
      children: [
        // Left Side - Image (not shown on smaller screens)
        if (!isSmallScreen)
        Expanded(
          flex: isLargeScreen ? 6 : 5,
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            child: Image.asset(
              ImagesConstants.kyLogin,
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Right Side - Login Form
        Expanded(
          flex: isSmallScreen ? 12 : (isMediumScreen ? 7 : 6),
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff00acc8), Color(0xff155e7d)],
                stops: [0.25, 0.8],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 60.0 : (isMediumScreen ? 40.0 : 30.0),
              vertical: isLargeScreen ? 40.0 : 30.0,
            ),
            child: SingleChildScrollView(
              child: Consumer<LoginProvider>(
                builder: (context, model, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Only show logo on small screens
                    if (isSmallScreen)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Image.asset(
                            ImagesConstants.kyLogin,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      
                    // Heading
                    Text(
                      'login_your_account'.tr(),
                      style: TextStyle(
                        fontSize: isLargeScreen ? 34.0 : 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: StringConstant.fontName,
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 50.0 : 40.0),

                    // Email Input
                    _buildFormLabel('email'.tr()),
                    const SizedBox(height: 10.0),
                    _buildTextField(
                      controller: widget.emailController,
                      hintText: 'enter_email'.tr(),
                      keyboardType: TextInputType.emailAddress,
                      height: 50.0,
                    ),
                    const SizedBox(height: 30.0),

                    // Password Input
                    _buildFormLabel('password'.tr()),
                    const SizedBox(height: 10.0),
                    _buildTextField(
                      controller: widget.passwordController,
                      hintText: 'password'.tr(),
                      obscureText: widget.obscureText,
                      height: 50.0,
                      suffixIcon: IconButton(
                        icon: Icon(
                          widget.obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: ColorManager.lightGrey,
                        ),
                        onPressed: widget.togglePasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: widget.handleForgotPassword,
                          child: Text(
                            "forget_password".tr(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: ColorManager.lightGrey,
                              fontWeight: FontWeight.w600,
                              fontFamily: StringConstant.fontName,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    
                    // Submit Button with LoginProvider
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: model.loading
                            ? null
                            : () => widget.handleLogin(model),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          elevation: 0,
                        ),
                        child: model.loading
                            ? const CircularProgressIndicator(
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
                    const SizedBox(height: 30.0),
                    
                    // Have no account section and Apply now section in one row
                    Column(
                      children: [
                        Text(
                          "have_no_account".tr(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: StringConstant.fontName,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              style: ButtonStyle(
                                side: MaterialStateProperty.all(
                                  BorderSide(color: ColorManager.lightGrey),
                                ),
                              ),
                              onPressed: widget.handleContactUs,
                              child: Text(
                                "contact_us".tr(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: ColorManager.lightGrey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  fontFamily: StringConstant.fontName,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            OutlinedButton(
                              style: ButtonStyle(
                                side: MaterialStateProperty.all(
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
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildTermsText(),
                    _buildPaymentMethodsSection(isLargeScreen),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: ColorManager.lightGrey,
        fontFamily: StringConstant.fontName,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    double height = 50.0,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            color: Colors.grey.shade400,
            fontFamily: StringConstant.fontName,
          ),
          contentPadding: const EdgeInsets.all(15.0),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
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
            fontFamily: StringConstant.fontName,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection(bool isLargeScreen) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              "payment_browse".tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isLargeScreen ? 14 : 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: ColorManager.lightGrey,
                fontFamily: StringConstant.fontName,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: isLargeScreen ? 10 : 8),
          OutlinedButton(
            style: ButtonStyle(
              side: MaterialStateProperty.all(
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
                fontSize: isLargeScreen ? 14 : 12,
                fontWeight: FontWeight.w700,
                color: ColorManager.white,
                fontFamily: StringConstant.fontName,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
