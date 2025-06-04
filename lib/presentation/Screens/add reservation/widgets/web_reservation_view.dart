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
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorManager.primary.withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 900) {
      // Mobile layout
      return _buildMobileLayout(context);
    } else {
      // Desktop layout
      return _buildDesktopLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            elevation: 6,
            shadowColor: ColorManager.primary.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorManager.primary.withValues(alpha: 0.1),
                        ColorManager.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: _buildHeader(context, isCompact: true),
                ),
                // Form
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildForm(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Header panel
          Container(
            width: 300,
            child: Card(
              elevation: 6,
              shadowColor: ColorManager.primary.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorManager.primary.withValues(alpha: 0.1),
                      ColorManager.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(25),
                child: _buildHeader(context),
              ),
            ),
          ),
          
          const SizedBox(width: 20),
          
          // Right side - Form panel
          Expanded(
            child: Card(
              elevation: 6,
              shadowColor: ColorManager.primary.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: _buildForm(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {bool isCompact = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Container(
          padding: EdgeInsets.all(isCompact ? 15 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ColorManager.primary.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: kIsWeb
              ? Image.asset(
                  'assets/images/doc.png',
                  height: isCompact ? 40 : 50,
                  width: isCompact ? 40 : 50,
                )
              : Lottie.asset(
                  ImagesConstants.document,
                  repeat: false,
                  height: isCompact ? 40 : 50,
                  width: isCompact ? 40 : 50,
                  fit: BoxFit.contain,
                ),
        ),
        SizedBox(height: isCompact ? 12 : 16),
        
        // Title
        Text(
          "add_reservation".tr(),
          style: TextStyle(
            fontFamily: StringConstant.fontName,
            fontSize: isCompact ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: ColorManager.primary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isCompact ? 6 : 8),
        
        // Subtitle
        Text(
          "fill_to_reservation".tr(),
          style: TextStyle(
            fontFamily: StringConstant.fontName,
            fontSize: isCompact ? 12 : 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        
        if (!isCompact) ...[
          const SizedBox(height: 20),
          _buildFeatures(),
        ],
      ],
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: [
        _buildFeatureItem(Icons.speed, "سريع وآمن"),
        const SizedBox(height: 8),
        _buildFeatureItem(Icons.support_agent, "دعم فني 24/7"),
        const SizedBox(height: 8),
        _buildFeatureItem(Icons.verified_user, "موثوق ومضمون"),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ColorManager.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ColorManager.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: ColorManager.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        key: descriptionKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form title
          Text(
            "تفاصيل الحجز",
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColorManager.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "يرجى ملء المعلومات أدناه",
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Personal Information Section
          _buildSectionTitle("المعلومات الشخصية", Icons.person_outline),
          const SizedBox(height: 40),
          
          // Name and Email row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: nameController,
                  label: "name".tr(),
                  icon: Icons.person_outline,
                  validator: _basicValidator,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: emailController,
                  label: "email".tr(),
                  icon: Icons.email_outlined,
                  validator: _emailValidator,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Phone field
          _buildTextField(
            controller: phoneController,
            label: "phone".tr(),
            icon: Icons.phone_outlined,
            validator: _basicValidator,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),


          // Nationality and City row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: nationalityController,
                  label: "nationality".tr(),
                  icon: Icons.flag_outlined,
                  validator: _basicValidator,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: cityController,
                  label: "city".tr(),
                  icon: Icons.location_city_outlined,
                  validator: _basicValidator,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Date field
          _buildTextField(
            controller: dateController,
            label: "visit_date".tr(),
            icon: Icons.calendar_today_outlined,
            validator: _dateValidator,
            keyboardType: TextInputType.datetime,
          ),
          const SizedBox(height: 30),

          // Submit Button
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary.withValues(alpha: 0.1),
            ColorManager.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorManager.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ColorManager.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: ColorManager.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorManager.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.05),
            blurRadius: 6,
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
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ColorManager.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: ColorManager.primary, size: 16),
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontFamily: StringConstant.fontName,
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorManager.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorManager.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.primary,
            ColorManager.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onSubmitReservation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_available_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "add_reservation".tr(),
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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