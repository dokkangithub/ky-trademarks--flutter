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

class MobileAddRequestView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final dynamic image1;
  final dynamic image2;
  final dynamic image3;
  final Function(int, ImageSource) onPickImage;
  final Function(int) onRemoveImage;
  final Function(BuildContext) onSubmitRequest;

  const MobileAddRequestView({
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
    return Stack(
      children: [
        _buildBackground(),
        _buildMobileContent(context),
      ],
    );
  }

  Widget _buildBackground() {
    return Align(
      alignment: Alignment.center,
      child: Opacity(
        opacity: 0.1,
        child: Image.asset(ImagesConstants.background, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildMobileHeaderAnimation(),
              const SizedBox(height: 24),
              _buildMobileTextFields(context),
              const SizedBox(height: 24),
              _buildMobileImageSection(context),
              const SizedBox(height: 24),
              _buildMobileSubmitButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeaderAnimation() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorManager.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Image.asset(
          'assets/images/registration.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }

  Widget _buildMobileTextFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMobileTextField(
          context: context,
          controller: nameController,
          label: "name".tr() + " *",
          icon: Icons.person_outline,
          validator: (val) => val!.isEmpty ? "required_field".tr() : null,
        ),
        const SizedBox(height: 20),
        _buildMobileTextField(
          context: context,
          controller: descriptionController,
          label: "activity_desc".tr(),
          icon: Icons.description_outlined,
          maxLines: 4,
          validator: (val) => val!.isEmpty ? "required_field".tr() : null,
        ),
      ],
    );
  }

  Widget _buildMobileTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: StringConstant.fontName,
            fontWeight: FontWeight.w600,
            color: ColorManager.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 14,
            ),
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: ColorManager.primary, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              hintText: label,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontFamily: StringConstant.fontName,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileImageSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.28;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library_outlined, color: ColorManager.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              "images".tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: StringConstant.fontName,
                fontWeight: FontWeight.w600,
                color: ColorManager.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildMobileImageSlot(context, 1, imageSize),
            if (image1 != null) _buildMobileImageSlot(context, 2, imageSize),
            if (image2 != null) _buildMobileImageSlot(context, 3, imageSize),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileImageSlot(BuildContext context, int position, double size) {
    final image = position == 1 ? image1 : position == 2 ? image2 : image3;
    return image == null
        ? _buildMobileAddImageButton(context, position, size)
        : _buildMobileImagePreview(image, position, size);
  }

  Widget _buildMobileAddImageButton(BuildContext context, int position, double size) {
    return InkWell(
      onTap: () => _showMobileImagePickerSheet(context, position),
      child: DottedBorder(
        color: ColorManager.primary,
        borderType: BorderType.RRect,
        radius: const Radius.circular(15),
        strokeWidth: 2,
        dashPattern: const [8, 4],
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: ColorManager.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: ColorManager.primary,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                position == 1 ? "add_photo".tr() : "add_another_image".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorManager.primary,
                  fontFamily: StringConstant.fontName,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileImagePreview(dynamic image, int position, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: kIsWeb
                ? FutureBuilder<Uint8List>(
                    future: image.readAsBytes(),
                    builder: (context, snapshot) => snapshot.hasData
                        ? Image.memory(snapshot.data!, fit: BoxFit.cover, width: size, height: size)
                        : Container(
                            width: size,
                            height: size,
                            color: Colors.grey.shade200,
                            child: const Center(child: CircularProgressIndicator()),
                          ))
                : Image.file(File(image.path), fit: BoxFit.cover, width: size, height: size),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                onPressed: () => onRemoveImage(position),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSubmitButton(BuildContext context) {
    return Consumer<RequestProvider>(
      builder: (context, provider, _) => provider.state == RequestState.loading
          ? Container(
              padding: const EdgeInsets.all(20),
              child: LoadingWidget(),
            )
          : Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorManager.primary,
                    ColorManager.primaryByOpacity.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => onSubmitRequest(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_outlined, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "submit_request".tr(),
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
            ),
    );
  }

  void _showMobileImagePickerSheet(BuildContext context, int position) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Choose Image Source",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.primary,
                ),
              ),
              const SizedBox(height: 20),
              _buildMobileImageSourceTile(
                context,
                icon: Icons.camera_alt_outlined,
                title: "pick_image".tr(),
                onTap: () {
                  Navigator.pop(context);
                  onPickImage(position, ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              _buildMobileImageSourceTile(
                context,
                icon: Icons.photo_library_outlined,
                title: "choose_photo".tr(),
                onTap: () {
                  Navigator.pop(context);
                  onPickImage(position, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileImageSourceTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: ColorManager.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: ColorManager.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorManager.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorManager.primary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: ColorManager.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
} 