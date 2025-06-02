import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:kyuser/resources/ImagesConstant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../resources/Color_Manager.dart';
import '../../resources/StringManager.dart';
import '../Controllar/ReservationProvider.dart';

class AddReservation extends StatefulWidget {
  const AddReservation({super.key});
  static const String preferencesFirstLaunch =
      "PREFERENCES_IS_FIRST_LAUNCH_STRING_ADD_RESERVATION_SCREEN";

  @override
  State<AddReservation> createState() => _AddReservationState();
}

class _AddReservationState extends State<AddReservation> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _nationality = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey _descriptionKey = GlobalKey();

  TutorialCoachMark? _tutorialCoachMark;
  List<TargetFocus> _tutorialTargets = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), _initTutorial);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _nationality.dispose();
    _city.dispose();
    _date.dispose();
    _tutorialCoachMark?.finish();
    super.dispose();
  }

  Future<void> _initTutorial() async {
    _addTutorialTargets();
    final isFirstLaunch = await _isFirstLaunch();
    if (isFirstLaunch && mounted) {
      _startTutorial();
    }
  }

  Future<bool> _isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool(AddReservation.preferencesFirstLaunch) ?? true;
    if (isFirst) {
      await prefs.setBool(AddReservation.preferencesFirstLaunch, false);
    }
    return isFirst;
  }

  void _addTutorialTargets() {
    _tutorialTargets = [
      TargetFocus(
        identify: "description",
        keyTarget: _descriptionKey,
        shape: ShapeLightFocus.RRect,
        radius: 13,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "add_reservation".tr(),
                  style: TextStyle(
                    fontFamily:StringConstant.fontName,
                    color: ColorManager.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "fill_to_reservation".tr(),
                  style: TextStyle(
                    fontFamily:StringConstant.fontName,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  void _startTutorial() {
    _tutorialCoachMark = TutorialCoachMark(
      targets: _tutorialTargets,
      colorShadow: ColorManager.accent,
      textSkip: "skip".tr(),
      alignSkip: Alignment.topRight,
      opacityShadow: 0.9,
      textStyleSkip: TextStyle(
        fontFamily:StringConstant.fontName,
        color: ColorManager.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    )..show(context: context);
  }

  void _submitReservation() {
    if (_formKey.currentState?.validate() != true) return;
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();

    final data = {
      "city": _city.text,
      "name": _name.text,
      "email": _email.text,
      "date_of_visit": _date.text,
      "nationality": _nationality.text,
      "phone": _phone.text,
    };

    showAlertDialog(context);
    Provider.of<ReservationProvider>(context, listen: false)
        .sendReservation(data)
        .then((_) => _clearForm());
  }

  void _clearForm() {
    _city.clear();
    _date.clear();
    _email.clear();
    _name.clear();
    _nationality.clear();
    _phone.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 700;
          return isLargeScreen
              ? _buildLargeScreenLayout(constraints)
              : _buildSmallScreenLayout(constraints);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorManager.primaryByOpacity.withOpacity(0.9),
              ColorManager.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Text(
                  "add_reservation".tr(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                      fontFamily:StringConstant.fontName,
                    fontSize: MediaQuery.sizeOf(context).width > 700 ? 22 : 18,
                  ),
                ),
                InkWell(
                  onTap: _initTutorial,
                  child: Lottie.asset(ImagesConstants.infoW, height: 30, width: 30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout(BoxConstraints constraints) {
    return Center(
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 900,
          height: constraints.maxHeight * 0.9,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: kIsWeb
                    ? Image.asset('assets/images/doc.png', fit: BoxFit.contain)
                    : Lottie.asset(
                  ImagesConstants.document,
                  repeat: false,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildFormContent(), // Now scrollable
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallScreenLayout(BoxConstraints constraints) {
    return Stack(
      children: [
        _buildBackgroundImage(),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Center(
                    child: kIsWeb
                        ? Image.asset('assets/images/doc.png', height: 150)
                        : Lottie.asset(
                      ImagesConstants.document,
                      repeat: false,
                      height: 150,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                _buildFormContent(),
                const SizedBox(height: 60), // Extra padding to avoid clipping
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          key: _descriptionKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_name, "name".tr(), _basicValidator),
            _buildTextField(_email, "email".tr(), _emailValidator),
            _buildTextField(_phone, "phone".tr(), _basicValidator, TextInputType.phone),
            _buildTextField(_nationality, "nationality".tr(), _basicValidator),
            _buildTextField(_city, "city".tr(), _basicValidator),
            _buildTextField(_date, "visit_date".tr(), _dateValidator),
            const SizedBox(height: 30),
            _buildSubmitButton(),
            const SizedBox(height: 40), // Ensure enough padding at the bottom
          ],
        ),
      ),
    );
  }
  Widget _buildBackgroundImage() {
    return Align(
      alignment: Alignment.center,
      child: Opacity(
        opacity: 0.1,
        child: Image.asset(ImagesConstants.background, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String? Function(String?) validator, [
        TextInputType? keyboardType,
      ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
                fontFamily:StringConstant.fontName,
              fontSize: MediaQuery.sizeOf(context).width > 700 ? 18 : 16,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: TextFormField(
              controller: controller,
              decoration: _inputDecoration(label),
              keyboardType: keyboardType,
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final width = MediaQuery.sizeOf(context).width;
    final buttonWidth = width > 700 ? width * 0.2 : width * 0.6;

    return Center(
      child: ElevatedButton(
        onPressed: _submitReservation,
        style: ElevatedButton.styleFrom(
          fixedSize: Size(buttonWidth, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
          backgroundColor: ColorManager.primary,
        ),
        child: Text(
          "add_reservation".tr(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: ColorManager.white,
            fontSize: width > 700 ? 16 : 14,
              fontFamily:StringConstant.fontName
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      hintText: label,
      hintStyle: Theme.of(context).textTheme.displayMedium,
      fillColor: ColorManager.anotherTabBackGround,
      filled: true,
    );
  }

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

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: MediaQuery.sizeOf(context).width > 700 ? 300 : null,
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset("assets/images/done.json", width: 150, height: 150, repeat: false),
              const SizedBox(height: 30),
              Text(
                "تم اضافة الحجز بنجاح",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontFamily:StringConstant.fontName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}