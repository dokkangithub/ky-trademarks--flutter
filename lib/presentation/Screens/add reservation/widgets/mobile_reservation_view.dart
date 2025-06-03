import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../resources/Color_Manager.dart';
import '../../../../resources/ImagesConstant.dart';
import '../../../../resources/StringManager.dart';

class MobileReservationView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final GlobalKey descriptionKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController nationalityController;
  final TextEditingController cityController;
  final TextEditingController dateController;
  final VoidCallback onSubmitReservation;
  final List<TargetFocus> tutorialTargets;

  const MobileReservationView({
    required this.formKey,
    required this.descriptionKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.nationalityController,
    required this.cityController,
    required this.dateController,
    required this.onSubmitReservation,
    required this.tutorialTargets,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildMobileBackground(),
        _buildMobileContent(context),
      ],
    );
  }

  Widget _buildMobileBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorManager.primary.withValues(alpha: 0.05),
              Colors.white,
              ColorManager.primaryByOpacity.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: Opacity(
          opacity: 0.08,
          child: Image.asset(ImagesConstants.background, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildMobileHeader(),
            const SizedBox(height: 30),
            _buildMobileForm(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: ColorManager.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: kIsWeb
                  ? Image.asset('assets/images/doc.png', height: 80, width: 80)
                  : Lottie.asset(
                      ImagesConstants.document,
                      repeat: false,
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(height: 15),
            Text(
              "add_reservation".tr(),
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorManager.primary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "fill_to_reservation".tr(),
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          key: descriptionKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "personal_info".tr(),
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorManager.primary,
              ),
            ),
            const SizedBox(height: 20),
            _buildMobileTextField(
              controller: nameController,
              label: "name".tr(),
              icon: Icons.person_outline,
              validator: _basicValidator,
            ),
            const SizedBox(height: 16),
            _buildMobileTextField(
              controller: emailController,
              label: "email".tr(),
              icon: Icons.email_outlined,
              validator: _emailValidator,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildMobileTextField(
              controller: phoneController,
              label: "phone".tr(),
              icon: Icons.phone_outlined,
              validator: _basicValidator,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            Text(
              "visit_info".tr(),
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorManager.primary,
              ),
            ),
            const SizedBox(height: 20),
            _buildMobileTextField(
              controller: nationalityController,
              label: "nationality".tr(),
              icon: Icons.flag_outlined,
              validator: _basicValidator,
            ),
            const SizedBox(height: 16),
            _buildMobileTextField(
              controller: cityController,
              label: "city".tr(),
              icon: Icons.location_city_outlined,
              validator: _basicValidator,
            ),
            const SizedBox(height: 16),
            _buildMobileTextField(
              controller: dateController,
              label: "visit_date".tr(),
              icon: Icons.calendar_today_outlined,
              validator: _dateValidator,
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 30),
            _buildMobileSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: StringConstant.fontName,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorManager.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: ColorManager.primary, size: 20),
              hintText: label,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontFamily: StringConstant.fontName,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: ColorManager.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSubmitButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary,
            ColorManager.primaryByOpacity.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onSubmitReservation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_outlined, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              "add_reservation".tr(),
              style: TextStyle(
                color: Colors.white,
                fontFamily: StringConstant.fontName,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Validation functions
  String? _basicValidator(String? value) {
    return (value == null || value.isEmpty) ? "required_field".tr() : null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return "required_field".tr();
    if (!value.contains("@")) return "incorrect_email".tr();
    return null;
  }

  String? _dateValidator(String? value) {
    if (value == null || value.isEmpty) return "required_field".tr();
    if (!value.contains("/")) return "enter_date_in".tr();
    return null;
  }
} 