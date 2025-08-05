import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../resources/Color_Manager.dart';
import '../../../resources/StringManager.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/presentation/Controllar/RequestProvider.dart';
import 'widgets/mobile_add_request_view.dart';
import 'widgets/web_add_request_view.dart';

class AddRequest extends StatefulWidget {
  const AddRequest({super.key, required this.canBack});
  final bool canBack;

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

  bool _isWebView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 900; // إذا كان العرض أكبر من 900 بكسل، عرض الـ web view
  }

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
        SnackBar(
          content: Text(
            'Failed to pick image: $e',
            style: TextStyle(fontFamily: StringConstant.fontName),
          ),
        ),
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
        SnackBar(
          content: Text(
            image1 == null ? "photo_at_least".tr() : "enter_all_data".tr(),
            style: TextStyle(fontFamily: StringConstant.fontName),
          ),
        ),
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
          SnackBar(
            content: Text(
              'request_failed'.tr(),
              style: TextStyle(fontFamily: StringConstant.fontName),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: TextStyle(fontFamily: StringConstant.fontName),
          ),
        ),
      );
    }
  }

  void _clearForm() {
    _name.clear();
    _description.clear();
    setState(() {
      image1 = image2 = image3 = null;
    });
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
              Text(
                "تم تقديم الطلب بنجاح",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: StringConstant.fontName,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: ColorManager.primary),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
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
      body: _isWebView(context)
          ? WebAddRequestView(
              formKey: _formKey,
              nameController: _name,
              descriptionController: _description,
              image1: image1,
              image2: image2,
              image3: image3,
              onPickImage: _pickImage,
              onRemoveImage: _removeImage,
              onSubmitRequest: _submitRequest,
            )
          : MobileAddRequestView(
              formKey: _formKey,
              nameController: _name,
              descriptionController: _description,
              image1: image1,
              image2: image2,
              image3: image3,
              onPickImage: _pickImage,
              onRemoveImage: _removeImage,
              onSubmitRequest: _submitRequest,
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: widget.canBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color: ColorManager.white, size: 22),
              onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
            )
          : SizedBox.shrink(),
      title: Text(
        "submit_request".tr(),
        style: TextStyle(
          color: Colors.white,
          fontFamily: StringConstant.fontName,
        ),
      ),
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
}