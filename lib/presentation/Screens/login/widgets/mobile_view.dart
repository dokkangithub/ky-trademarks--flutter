import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:kyuser/resources/ImagesConstant.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';
import 'package:provider/provider.dart';
import 'package:kyuser/presentation/Controllar/LoginProvider.dart';

import '../../add request/AddRequest.dart';
import '../../payment ways/PaymentWays.dart';

class MobileLoginView extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscureText;
  final VoidCallback togglePasswordVisibility;
  final Function(LoginProvider) handleLogin;
  final VoidCallback handleForgotPassword;
  final VoidCallback handleContactUs;

  const MobileLoginView({
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
  State<MobileLoginView> createState() => _MobileLoginViewState();
}

class _MobileLoginViewState extends State<MobileLoginView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _slideController.forward();
    });
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagesConstants.kyLogin),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildLoginContent(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginContent() {
    return Consumer<LoginProvider>(
      builder: (context, model, _) => CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildWelcomeSection(),
                  const Spacer(flex: 1),
                  _buildLoginCard(model),
                  const SizedBox(height: 24),
                  _buildBottomActions(),
                  const Spacer(flex: 2),
                  _buildFooterSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Hero(
          tag: 'welcome_text',
          child: Material(
            color: Colors.transparent,
            child: Text(
              'login_your_account'.tr(),
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: StringConstant.fontName,
                height: 1.2,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 32),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  'مرحباً بك في منصة العلامات التجارية',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: StringConstant.fontName,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLoginCard(LoginProvider model) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('email'.tr(), Icons.email_rounded),
                  const SizedBox(height: 12.0),
                  _buildModernTextField(
                    controller: widget.emailController,
                    focusNode: _emailFocus,
                    hintText: 'enter_email'.tr(),
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  const SizedBox(height: 24.0),
                  _buildFieldLabel('password'.tr(), Icons.lock_rounded),
                  const SizedBox(height: 12.0),
                  _buildModernTextField(
                    controller: widget.passwordController,
                    focusNode: _passwordFocus,
                    hintText: 'password'.tr(),
                    obscureText: widget.obscureText,
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          widget.obscureText
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          key: ValueKey(widget.obscureText),
                          color: Colors.white.withOpacity(0.8),
                          size: 22,
                        ),
                      ),
                      onPressed: widget.togglePasswordVisibility,
                    ),
                    onSubmitted: (_) => widget.handleLogin(model),
                  ),
                  const SizedBox(height: 16.0),
                  _buildForgotPasswordButton(),
                  const SizedBox(height: 32.0),
                  _buildModernLoginButton(model),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.95),
            fontFamily: StringConstant.fontName,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    Function(String)? onSubmitted,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isFocused
                  ? Colors.white.withOpacity(0.8)
                  : Colors.white.withOpacity(0.3),
              width: isFocused ? 2.5 : 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(isFocused ? 0.3 : 0.15),
                Colors.white.withOpacity(isFocused ? 0.15 : 0.08),
              ],
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                obscureText: obscureText,
                keyboardType: keyboardType,
                onSubmitted: onSubmitted,
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontFamily: StringConstant.fontName,
                    fontSize: 16,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: InputBorder.none,
                  prefixIcon: prefixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16, right: 12),
                          child: Icon(
                            prefixIcon,
                            color: Colors.white.withOpacity(0.8),
                            size: 22,
                          ),
                        )
                      : null,
                  suffixIcon: suffixIcon != null 
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: suffixIcon,
                        )
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: TextButton(
          onPressed: widget.handleForgotPassword,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
          child: Text(
            "forget_password".tr(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
              fontSize: 14,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernLoginButton(LoginProvider model) {
    return SizedBox(
      width: double.infinity,
      height: 60.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: model.loading ? null : () => widget.handleLogin(model),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black87,
            elevation: model.loading ? 0 : 12,
            shadowColor: const Color(0xFFFFD700).withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.0),
              gradient: model.loading
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFFE55C),
                        Color(0xFFFFF176),
                      ],
                    ),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: model.loading
                    ? SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black87.withOpacity(0.8),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.login_rounded,
                            color: Colors.black87,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'login'.tr(),
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: StringConstant.fontName,
                              color: Colors.black87,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            "have_no_account".tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.95),
              fontFamily: StringConstant.fontName,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.support_agent_rounded,
                  label: "contact_us".tr(),
                  onPressed: widget.handleContactUs,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.assignment_rounded,
                  label: "or_ask".tr(),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddRequest(canBack: true),
                      ),
                    );
                  },
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 20,
          color: isPrimary
              ? Colors.black87
              : Colors.white.withOpacity(0.95),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isPrimary
                ? Colors.black87
                : Colors.white.withOpacity(0.95),
            fontFamily: StringConstant.fontName,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFFFFD700).withOpacity(0.95)
              : Colors.transparent,
          foregroundColor: isPrimary
              ? Colors.black87
              : Colors.white.withOpacity(0.95),
          elevation: isPrimary ? 8 : 0,
          side: isPrimary
              ? null
              : BorderSide(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildFooterSection() {
    return Column(
      children: [
        _buildTermsText(),
        const SizedBox(height: 16),
        _buildPaymentMethodsSection(),
      ],
    );
  }

  Widget _buildTermsText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Text(
        "agree_services".tr(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.85),
          fontWeight: FontWeight.w500,
          fontSize: 12,
          fontFamily: StringConstant.fontName,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.primary.withOpacity(0.25),
            ColorManager.primary.withOpacity(0.15),
          ],
        ),
        border: Border.all(
          color: ColorManager.primary.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.payment_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "payment_browse".tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.95),
                fontFamily: StringConstant.fontName,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentWays()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              "payment methods".tr(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: StringConstant.fontName,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
