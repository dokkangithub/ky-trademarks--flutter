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
    return Stack(
      children: [
        _buildBackground(),
        _buildWebContent(context),
      ],
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: Image.asset(ImagesConstants.background, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildWebContent(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _buildWebFormContent(context),
      ),
    );
  }

  Widget _buildWebFormContent(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _buildWebHeader(context),
            const SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Form fields
                Expanded(
                  flex: 2,
                  child: _buildWebTextFields(context),
                ),
                const SizedBox(width: 40),
                // Right side - Images and Submit
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildWebImageSection(context),
                      const SizedBox(height: 30),
                      _buildWebSubmitButton(context),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary.withValues(alpha: 0.1),
            ColorManager.primaryByOpacity.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/registration.png',
              width: 120,
              height: 120,
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "submit_request".tr(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: StringConstant.fontName,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Please fill the form below",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: StringConstant.fontName,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebTextFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Basic Information",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontFamily: StringConstant.fontName,
            fontWeight: FontWeight.bold,
            color: ColorManager.primary,
          ),
        ),
        const SizedBox(height: 20),
        _buildWebTextField(
          context: context,
          controller: nameController,
          label: "name".tr() + " *",
          icon: Icons.person_outline,
          validator: (val) => val!.isEmpty ? "required_field".tr() : null,
        ),
        const SizedBox(height: 25),
        _buildWebTextField(
          context: context,
          controller: descriptionController,
          label: "activity_desc".tr(),
          icon: Icons.description_outlined,
          maxLines: 6,
          validator: (val) => val!.isEmpty ? "required_field".tr() : null,
        ),
      ],
    );
  }

  Widget _buildWebTextField({
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
        Row(
          children: [
            Icon(icon, color: ColorManager.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: StringConstant.fontName,
                fontWeight: FontWeight.w600,
                color: ColorManager.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 16,
            ),
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: ColorManager.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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

  Widget _buildWebImageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library_outlined, color: ColorManager.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              "images".tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: StringConstant.fontName,
                fontWeight: FontWeight.w600,
                color: ColorManager.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildWebImageGrid(),
      ],
    );
  }

  Widget _buildWebImageGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildWebImageSlot(1, 160.0)),
            const SizedBox(width: 15),
            Expanded(child: _buildWebImageSlot(2, 160.0)),
          ],
        ),
        if (image2 != null) ...[
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildWebImageSlot(3, 160.0)),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildWebImageSlot(int position, double size) {
    final image = position == 1 ? image1 : position == 2 ? image2 : image3;
    return image == null
        ? _buildWebAddImageButton(position, size)
        : _buildWebImagePreview(image, position, size);
  }

  Widget _buildWebAddImageButton(int position, double size) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () => _showWebImagePickerDialog(context, position),
        borderRadius: BorderRadius.circular(15),
        child: DottedBorder(
          color: ColorManager.primary,
          borderType: BorderType.RRect,
          radius: const Radius.circular(15),
          strokeWidth: 2,
          dashPattern: const [12, 6],
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: ColorManager.primary.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: ColorManager.primary,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  position == 1 ? "add_photo".tr() : "add_another_image".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorManager.primary,
                    fontFamily: StringConstant.fontName,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebImagePreview(dynamic image, int position, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                            child: Center(
                              child: CircularProgressIndicator(color: ColorManager.primary),
                            ),
                          ))
                : Image.file(File(image.path), fit: BoxFit.cover, width: size, height: size),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => onRemoveImage(position),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSubmitButton(BuildContext context) {
    return Consumer<RequestProvider>(
      builder: (context, provider, _) => provider.state == RequestState.loading
          ? Container(
              padding: const EdgeInsets.all(30),
              child: LoadingWidget(),
            )
          : Container(
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
                onPressed: () => onSubmitRequest(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_outlined, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      "submit_request".tr(),
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
            ),
    );
  }

  void _showWebImagePickerDialog(BuildContext context, int position) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(30),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Image Source",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.primary,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildWebImageSourceButton(
                      context: context,
                      icon: Icons.camera_alt_outlined,
                      title: "Camera",
                      onTap: () {
                        Navigator.pop(context);
                        onPickImage(position, ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildWebImageSourceButton(
                      context: context,
                      icon: Icons.photo_library_outlined,
                      title: "Gallery",
                      onTap: () {
                        Navigator.pop(context);
                        onPickImage(position, ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebImageSourceButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ColorManager.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
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
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorManager.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 