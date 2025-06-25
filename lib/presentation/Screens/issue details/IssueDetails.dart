import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'dart:async';

import '../../../app/RequestState/RequestState.dart';
import '../../../resources/Color_Manager.dart';
import '../../../resources/StringManager.dart';
import '../../../utilits/Local_User_Data.dart';
import '../../Controllar/Issues/GetIssueDetailsProvider.dart';
import '../../Widget/loading_widget.dart';
import 'widgets/mobile_issue_details_view.dart';
import 'widgets/web_issue_details_view.dart';

class IssueDetails extends StatefulWidget {
  final int issueId;
  static const String preferencesIsFirstLaunchString =
      "PREFERENCES_IS_FIRST_LAUNCH_STRING_ISSUE_DETAILS_SCREEN";

  const IssueDetails({super.key, required this.issueId});

  @override
  State<IssueDetails> createState() => _IssueDetailsState();
}

class _IssueDetailsState extends State<IssueDetails> {
  final _issueInfoKey = GlobalKey();
  final _brandInfoKey = GlobalKey();
  final _refusedDetailsKey = GlobalKey();
  late final ScrollController _scrollController;
  TutorialCoachMark? _tutorialCoachMark;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchIssueDetails();
      Future.delayed(const Duration(seconds: 2), _startTutorialIfFirstLaunch);
    });
  }

  @override
  void dispose() {
    _tutorialCoachMark?.finish();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Optional: Add pagination if needed
    }
  }

  Future<void> _fetchIssueDetails() async {
    int customerId = globalAccountData.getId() != null 
        ? int.parse(globalAccountData.getId()!) 
        : 0;
    await Provider.of<GetIssueDetailsProvider>(context, listen: false)
        .getIssueDetails(issueId: widget.issueId, customerId: customerId);
  }

  Future<void> _startTutorialIfFirstLaunch() async {
    if (!mounted) return;
    _addTutorialTargets();
    if (await _isFirstLaunch()) {
      _startTutorial();
    }
  }

  Future<bool> _isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch =
        prefs.getBool(IssueDetails.preferencesIsFirstLaunchString) ?? true;
    if (isFirstLaunch) {
      await prefs.setBool(IssueDetails.preferencesIsFirstLaunchString, false);
    }
    return isFirstLaunch;
  }

  final List<TargetFocus> _targetList = [];

  void _addTutorialTargets() {
    _targetList.clear();
    _targetList.addAll([
      TargetFocus(
        keyTarget: _issueInfoKey,
        radius: 10,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              bottom: MediaQuery.of(context).size.height * 0.5,
            ),
            child: const _TutorialText(
              title: "معلومات القضية",
              subtitle: "عرض تفاصيل القضية ونوعها وتاريخ الإنشاء",
            ),
          ),
        ],
      ),
      TargetFocus(
        keyTarget: _brandInfoKey,
        radius: 14,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: MediaQuery.of(context).size.height * 0.15,
            ),
            child: const _TutorialText(
              title: "معلومات العلامة التجارية",
              subtitle: "تفاصيل العلامة التجارية المرتبطة بالقضية",
            ),
          ),
        ],
      ),
      TargetFocus(
        keyTarget: _refusedDetailsKey,
        radius: 30,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            customPosition: CustomTargetContentPosition(
              bottom: MediaQuery.of(context).size.height * 0.5,
            ),
            child: const _TutorialText(
              title: "تفاصيل القضية",
              subtitle: "عرض تفاصيل الاستئناف والمواعيد المهمة",
            ),
          ),
        ],
      ),
    ]);
  }

  void _startTutorial() {
    _tutorialCoachMark = TutorialCoachMark(
      targets: _targetList,
      textSkip: "تخطي",
      colorShadow: ColorManager.accent,
      opacityShadow: 0.9,
      alignSkip: AlignmentDirectional.topStart,
      textStyleSkip: TextStyle(
        fontFamily: StringConstant.fontName,
        color: ColorManager.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
    _tutorialCoachMark!.show(context: context);
  }

  void _onTutorialTap() {
    if (_debounce?.isActive ?? false) return;
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _addTutorialTargets();
      _startTutorial();
    });
  }

  // Responsive breakpoint for web view detection
  bool _isWebView(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<GetIssueDetailsProvider>(
        builder: (context, model, _) => _buildBody(context, model),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ColorManager.primary,
      elevation: 0,
      title: Text(
        "تفاصيل القضية",
        style: TextStyle(
          fontFamily: StringConstant.fontName,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 22,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _onTutorialTap,
          icon: Icon(
            Icons.help_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, GetIssueDetailsProvider model) {
    switch (model.state) {
      case RequestState.loading:
        return _buildLoadingState();
      case RequestState.loaded:
        return _buildLoadedState(context, model);
      case RequestState.failed:
        return _buildErrorState();
      default:
        return _buildLoadingState();
    }
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.grey.shade50,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: LoadingWidget(),
            ),
            const SizedBox(height: 16),
            Text(
              "جاري تحميل تفاصيل القضية...",
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                color: ColorManager.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.grey.shade50,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "حدث خطأ في تحميل تفاصيل القضية",
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                color: Colors.red.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchIssueDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "إعادة المحاولة",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, GetIssueDetailsProvider model) {
    if (model.issueDetails == null) {
      return _buildErrorState();
    }

    if (_isWebView(context)) {
      return WebIssueDetailsView(
        issueDetails: model.issueDetails!,
        scrollController: _scrollController,
        issueInfoKey: _issueInfoKey,
        brandInfoKey: _brandInfoKey,
        refusedDetailsKey: _refusedDetailsKey,
      );
    } else {
      return MobileIssueDetailsView(
        issueDetails: model.issueDetails!,
        scrollController: _scrollController,
        issueInfoKey: _issueInfoKey,
        brandInfoKey: _brandInfoKey,
        refusedDetailsKey: _refusedDetailsKey,
      );
    }
  }
}

class _TutorialText extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TutorialText({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ColorManager.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
} 