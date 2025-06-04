import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../../../app/RequestState/RequestState.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';
import '../../../../resources/ImagesConstant.dart';
import '../../../Controllar/RequestProvider.dart';
import '../../../Widget/loading_widget.dart';

class WebAddRequestView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final dynamic image1;
  final dynamic image2;
  final dynamic image3;
  final Function(int, ImageSource) onPickImage;
  final Function(int) onRemoveImage;
  final Function(BuildContext) onSubmitRequest;

  const WebAddRequestView({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.image1,
    required this.image2,
    required this.image3,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onSubmitRequest,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(context),
                const SizedBox(height: 40),
                
                // Main Content
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Form Fields
                    Expanded(
                      flex: 2,
                      child: _buildFormSection(context),
                    ),
                    const SizedBox(width: 40),
                    
                    // Right Column - Images
                    Expanded(
                      flex: 1,
                      child: _buildImageSection(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Submit Button Section
                _buildSubmitSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.primary,
            ColorManager.primaryByOpacity,
            ColorManager.primary.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.assignment_add,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "تقديم طلب",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    fontFamily: StringConstant.fontName,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "قم بملء النموذج أدناه لتقديم طلب جديد للعلامة التجارية",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontFamily: StringConstant.fontName,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorManager.primary.withValues(alpha: 0.1),
                    ColorManager.primaryByOpacity.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorManager.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.edit_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "معلومات الطلب",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                            fontFamily: StringConstant.fontName,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "أدخل البيانات الأساسية للطلب",
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                            fontFamily: StringConstant.fontName,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Form Fields
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  _buildModernTextField(
                    context: context,
                    controller: nameController,
                    label: "الاسم",
                    icon: Icons.person_outline,
                    hint: "أدخل اسم العلامة التجارية",
                    validator: (val) => val!.isEmpty ? "هذا الحقل مطلوب" : null,
                  ),
                  const SizedBox(height: 32),
                  _buildModernTextField(
                    context: context,
                    controller: descriptionController,
                    label: "وصف النشاط بالتفصيل",
                    icon: Icons.description_outlined,
                    hint: "أدخل وصفاً مفصلاً للنشاط التجاري",
                    maxLines: 5,
                    validator: (val) => val!.isEmpty ? "هذا الحقل مطلوب" : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
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
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
                fontFamily: StringConstant.fontName,
              ),
            ),
            Text(
              " *",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
                fontFamily: StringConstant.fontName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 15,
              height: 1.4,
            ),
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: ColorManager.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade400, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: maxLines > 1 ? 20 : 18,
                horizontal: 20,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFF94A3B8),
                fontFamily: StringConstant.fontName,
                fontSize: 15,
              ),
              filled: true,
              fillColor: const Color(0xFFFAFBFC),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Images Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorManager.primary.withValues(alpha: 0.1),
                  ColorManager.primaryByOpacity.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.photo_library_outlined, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "الصور",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "أضف صور العلامة التجارية",
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Images Grid
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildImageSlot(context, 1),
                if (image1 != null) ...[
                  const SizedBox(height: 20),
                  _buildImageSlot(context, 2),
                ],
                if (image2 != null) ...[
                  const SizedBox(height: 20),
                  _buildImageSlot(context, 3),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlot(BuildContext context, int position) {
    final image = position == 1 ? image1 : position == 2 ? image2 : image3;
    
    return Container(
      width: double.infinity,
      height: 200,
      child: image == null
          ? _buildAddImageCard(context, position)
          : _buildImagePreview(context, image, position),
    );
  }

  Widget _buildAddImageCard(BuildContext context, int position) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showImagePickerDialog(context, position),
        borderRadius: BorderRadius.circular(16),
        child: DottedBorder(
          color: ColorManager.primary,
          borderType: BorderType.RRect,
          radius: const Radius.circular(16),
          strokeWidth: 2,
          dashPattern: const [8, 4],
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: ColorManager.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: ColorManager.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  position == 1 ? "إضافة صورة" : "إضافة صورة أخرى",
                  style: TextStyle(
                    color: ColorManager.primary,
                    fontFamily: StringConstant.fontName,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "اضغط لاختيار صورة",
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontFamily: StringConstant.fontName,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, dynamic image, int position) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: kIsWeb
                ? FutureBuilder<Uint8List>(
                    future: image.readAsBytes(),
                    builder: (context, snapshot) => snapshot.hasData
                        ? Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          )
                        : Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(color: ColorManager.primary),
                            ),
                          ),
                  )
                : Image.file(
                    File(image.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
          ),
          
          // Remove Button
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => onRemoveImage(position),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
          ),
          
          // Image Info Overlay
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "صورة ${position}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.send_outlined,
            color: ColorManager.primary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            "جاهز لإرسال الطلب؟",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              fontFamily: StringConstant.fontName,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "تأكد من صحة جميع البيانات قبل الإرسال",
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF64748B),
              fontFamily: StringConstant.fontName,
            ),
          ),
          const SizedBox(height: 32),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Consumer<RequestProvider>(
      builder: (context, provider, _) => provider.state == RequestState.loading
          ? Container(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(color: ColorManager.primary),
            )
          : Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorManager.primary,
                    ColorManager.primaryByOpacity,
                    ColorManager.primary.withValues(alpha: 0.9),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSubmitRequest(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        "تقديم الطلب",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: StringConstant.fontName,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _showImagePickerDialog(BuildContext context, int position) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  color: ColorManager.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "اختيار مصدر الصورة",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "اختر من أين تريد إضافة الصورة",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildImageSourceButton(
                      context: context,
                      icon: Icons.camera_alt_outlined,
                      title: "الكاميرا",
                      onTap: () {
                        Navigator.pop(context);
                        onPickImage(position, ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageSourceButton(
                      context: context,
                      icon: Icons.photo_library_outlined,
                      title: "المعرض",
                      onTap: () {
                        Navigator.pop(context);
                        onPickImage(position, ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "إلغاء",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    color: const Color(0xFF64748B),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorManager.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorManager.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorManager.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 