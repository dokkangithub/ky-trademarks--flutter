import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../resources/Color_Manager.dart';
import '../../../resources/StringManager.dart';
import '../../Controllar/ReservationProvider.dart';
import 'widgets/mobile_reservation_view.dart';
import 'widgets/web_reservation_view.dart';

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
    // Only show tutorial for mobile view, not for web
    if (!_isWebView(context)) {
      _addTutorialTargets();
      final isFirstLaunch = await _isFirstLaunch();
      if (isFirstLaunch && mounted) {
        _startTutorial();
      }
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
                    fontFamily: StringConstant.fontName,
                    color: ColorManager.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "fill_to_reservation".tr(),
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
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
        fontFamily: StringConstant.fontName,
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

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: _isWebView(context) ? 300 : null,
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/images/done.json",
                width: 150,
                height: 150,
                repeat: false,
              ),
              const SizedBox(height: 30),
              Text(
                "تم اضافة الحجز بنجاح",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isWebView(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _isWebView(context)?null:_buildAppBar(),
      body: _isWebView(context)
          ? WebReservationView(
        formKey: _formKey,
        descriptionKey: _descriptionKey,
        nameController: _name,
        emailController: _email,
        phoneController: _phone,
        nationalityController: _nationality,
        cityController: _city,
        dateController: _date,
        onSubmitReservation: _submitReservation,
        tutorialTargets: _tutorialTargets,
      )
          : MobileReservationView(
        formKey: _formKey,
        descriptionKey: _descriptionKey,
        nameController: _name,
        emailController: _email,
        phoneController: _phone,
        nationalityController: _nationality,
        cityController: _city,
        dateController: _date,
        onSubmitReservation: _submitReservation,
        tutorialTargets: _tutorialTargets,
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
              ColorManager.primaryByOpacity.withValues(alpha: 0.9),
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
                    fontFamily: StringConstant.fontName,
                    fontSize: _isWebView(context) ? 22 : 18,
                  ),
                ),
                InkWell(
                  onTap: _initTutorial,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: _isWebView(context) ? 26 : 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}