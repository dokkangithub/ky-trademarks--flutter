import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../resources/Color_Manager.dart';
import '../../../../resources/ImagesConstant.dart';
import '../../../../resources/StringManager.dart';

class WebReservationView extends StatelessWidget {
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

  const WebReservationView({
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
        _buildWebBackground(),
        _buildWebContent(context),
      ],
    );
  }

  Widget _buildWebBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorManager.primary.withValues(alpha: 0.03),
              Colors.white,
              ColorManager.primaryByOpacity.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Opacity(
          opacity: 0.05,
          child: Image.asset(ImagesConstants.background, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildWebContent(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 700),
        margin: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _buildWebMainContent(context),
      ),
    );
  }

  Widget _buildWebMainContent(BuildContext context) {
    return Row(
      children: [
        // Left side - Animation and header
        Expanded(
          flex: 2,
          child: _buildWebLeftSide(context),
        ),
        // Right side - Form
        Expanded(
          flex: 3,
          child: _buildWebRightSide(context),
        ),
      ],
    );
  }

  Widget _buildWebLeftSide(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorManager.primary.withValues(alpha: 0.1),
            ColorManager.primaryByOpacity.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorManager.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: kIsWeb
                ? Image.asset('assets/images/doc.png', height: 120, width: 120)
                : Lottie.asset(
                    ImagesConstants.document,
                    repeat: false,
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                  ),
          ),
          const SizedBox(height: 40),
          Text(
            "add_reservation".tr(),
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ColorManager.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            "fill_to_reservation".tr(),
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: ColorManager.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_outlined, color: ColorManager.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Quick & Easy",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebRightSide(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Form(
        key: formKey,
        child: Column(
          key: descriptionKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reservation Details",
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorManager.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please fill in your information below",
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),
            _buildWebSection(
              title: "Personal Information",
              icon: Icons.person_outline,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildWebTextField(
                        controller: nameController,
                        label: "name".tr(),
                        icon: Icons.person_outline,
                        validator: _basicValidator,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildWebTextField(
                        controller: emailController,
                        label: "email".tr(),
                        icon: Icons.email_outlined,
                        validator: _emailValidator,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildWebTextField(
                  controller: phoneController,
                  label: "phone".tr(),
                  icon: Icons.phone_outlined,
                  validator: _basicValidator,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildWebSection(
              title: "Visit Information",
              icon: Icons.location_on_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildWebTextField(
                        controller: nationalityController,
                        label: "nationality".tr(),
                        icon: Icons.flag_outlined,
                        validator: _basicValidator,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildWebTextField(
                        controller: cityController,
                        label: "city".tr(),
                        icon: Icons.location_city_outlined,
                        validator: _basicValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildWebTextField(
                  controller: dateController,
                  label: "visit_date".tr(),
                  icon: Icons.calendar_today_outlined,
                  validator: _dateValidator,
                  keyboardType: TextInputType.datetime,
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildWebSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorManager.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: ColorManager.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorManager.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildWebTextField({
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
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
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
              fontSize: 16,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: ColorManager.primary, size: 22),
              hintText: label,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontFamily: StringConstant.fontName,
                fontSize: 16,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorManager.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebSubmitButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary,
            ColorManager.primaryByOpacity.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onSubmitReservation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_outlined, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Text(
              "add_reservation".tr(),
              style: TextStyle(
                color: Colors.white,
                fontFamily: StringConstant.fontName,
                fontSize: 18,
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