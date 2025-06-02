import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import '../../network/RestApi/Comman.dart';
import '../../resources/Color_Manager.dart';
import '../../resources/StringManager.dart';
import '../Widget/loading_widget.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/presentation/Controllar/RequestProvider.dart';
import 'package:kyuser/resources/ImagesConstant.dart';

class AddRequest extends StatefulWidget {
  const AddRequest({super.key, required this.canBack});
  final bool canBack ;

  @override
  _AddRequestState createState() => _AddRequestState();
}

class _AddRequestState extends State<AddRequest> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  dynamic image1, image2, image3;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  // Image picker methods (unchanged from your implementation)
  Future<void> _pickImage(int position, ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        final imageData = kIsWeb ? image : File(image.path);
        if (position == 1) image1 = imageData;
        if (position == 2) image2 = imageData;
        if (position == 3) image3 = imageData;
      });
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e',style: TextStyle(fontFamily:StringConstant.fontName),)),
      );
    }
  }

  void _removeImage(int position) {
    setState(() {
      if (position == 1) {
        image1 = image2;
        image2 = image3;
        image3 = null;
      } else if (position == 2) {
        image2 = image3;
        image3 = null;
      } else {
        image3 = null;
      }
    });
  }

  void _submitRequest(BuildContext context) async {
    if (!_formKey.currentState!.validate() || image1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(image1 == null ? "photo_at_least".tr() : "enter_all_data".tr(),style: TextStyle(fontFamily:StringConstant.fontName),)),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();

    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    try {
      await requestProvider.sendRequest(
        {"name": _name.text, "description": _description.text},
        image1: image1,
        image2: image2,
        image3: image3,
      );

      if (requestProvider.state == RequestState.loaded) {
        _clearForm();
        _showSuccessDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('request_failed'.tr(),style: TextStyle(fontFamily:StringConstant.fontName),)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString(),style: TextStyle(fontFamily:StringConstant.fontName),)),
      );
    }
  }

  void _clearForm() {
    _name.clear();
    _description.clear();
    image1 = image2 = image3 = null;
  }

  void _showSuccessDialog(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 900;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.all(20),
        content: SizedBox(
          width: isLargeScreen ? 400 : 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/registration.png', width: 150, height: 150),
              SizedBox(height: 20),
              Text("تم تقديم الطلب بنجاح", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily:StringConstant.fontName)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: ColorManager.primary),
                child: Text('OK', style: TextStyle(color: Colors.white,fontFamily:StringConstant.fontName)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 900;
          return Stack(
            children: [
              _buildBackground(),
              isLargeScreen ? _buildLargeScreenLayout(context) : _buildSmallScreenLayout(context),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: widget.canBack? IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: ColorManager.white, size: 22),
        onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
      ):SizedBox.shrink(),
      title: Text("submit_request".tr(), style: TextStyle(color: Colors.white,fontFamily:StringConstant.fontName)),
      centerTitle: true,
      backgroundColor: ColorManager.primary,
      elevation: 0,
      flexibleSpace: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            ColorManager.primaryByOpacity.withValues(alpha: 0.9),
            ColorManager.primary,
          ]),
        ),
      ),
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

  Widget _buildLargeScreenLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: _buildFormContent(context, isLargeScreen: true),
      ),
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildFormContent(context, isLargeScreen: false),
    );
  }

  Widget _buildFormContent(BuildContext context, {required bool isLargeScreen}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = isLargeScreen ? 150.0 : screenWidth * 0.28;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeaderAnimation(),
            SizedBox(height: 24),
            isLargeScreen
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTextFields()),
                const SizedBox(width: 24),
                Expanded(child: _buildImageSection(imageSize)),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFields(),
                SizedBox(height: 24),
                _buildImageSection(imageSize),
              ],
            ),
            SizedBox(height: 24),
            _buildSubmitButton(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAnimation() {
    final size = MediaQuery.of(context).size.width > 900 ? 300.0 : 200.0;
    return Center(
      child: kIsWeb
          ? Image.asset('assets/images/registration.png', width: size, height: size)
          : Image.asset('assets/images/registration.png', width: size, height: size),
    );
  }

  Widget _buildTextFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _name,
          label: "name".tr() + " *",
          validator: (val) => val!.isEmpty ? "required_field".tr() : null,
        ),
        SizedBox(height: 20),
        _buildTextField(
          controller: _description,
          label: "activity_desc".tr(),
          maxLines: 5,
          validator: (val) => val!.isEmpty ? "required_field".tr() : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily:StringConstant.fontName)),
        SizedBox(height: 8),
        Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: TextFormField(
            controller: controller,
            style: TextStyle(fontFamily:StringConstant.fontName),
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              hintText: label,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(double imageSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("images".tr(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily:StringConstant.fontName)),
        SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildImageSlot(1, imageSize),
            if (image1 != null) _buildImageSlot(2, imageSize),
            if (image2 != null) _buildImageSlot(3, imageSize),
          ],
        ),
      ],
    );
  }

  Widget _buildImageSlot(int position, double size) {
    final image = position == 1 ? image1 : position == 2 ? image2 : image3;
    return image == null
        ? _buildAddImageButton(position, size)
        : _buildImagePreview(image, position, size);
  }

  Widget _buildAddImageButton(int position, double size) {
    return InkWell(
      onTap: () => _showImagePickerSheet(position),
      child: DottedBorder(
        color: ColorManager.primary,
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              position == 1 ? "add_photo".tr() : "add_another_image".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: ColorManager.primary,fontFamily:StringConstant.fontName),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(dynamic image, int position, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: kIsWeb
                ? FutureBuilder<Uint8List>(
                future: image.readAsBytes(),
                builder: (context, snapshot) =>
                snapshot.hasData ? Image.memory(snapshot.data!, fit: BoxFit.cover) : const CircularProgressIndicator())
                : Image.file(File(image.path), fit: BoxFit.cover),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _removeImage(position),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Consumer<RequestProvider>(
      builder: (context, provider, _) => provider.state == RequestState.loading
          ? LoadingWidget()
          : ElevatedButton(
        onPressed: () => _submitRequest(context),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(MediaQuery.of(context).size.width * 0.5, 50),
          backgroundColor: ColorManager.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text("submit_request".tr(), style: TextStyle(color: Colors.white,fontFamily:StringConstant.fontName)),
      ),
    );
  }

  void _showImagePickerSheet(int position) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera, color: ColorManager.primary),
              title: Text("pick_image".tr(),style: TextStyle(fontFamily:StringConstant.fontName),),
              onTap: () {
                Navigator.pop(context);
                _pickImage(position, ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo, color: ColorManager.primary),
              title: Text("choose_photo".tr(),style: TextStyle(fontFamily:StringConstant.fontName),),
              onTap: () {
                Navigator.pop(context);
                _pickImage(position, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}