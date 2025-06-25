import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../../../app/RequestState/RequestState.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../resources/Color_Manager.dart';
import '../../../resources/StringManager.dart';
import '../../../utilits/Local_User_Data.dart';
import '../../Controllar/GetBrandDetailsProvider.dart';
import '../../Widget/BrandDetailsWidget/ShimmerBrandDetails.dart';
import 'widgets/mobile_brand_details_view.dart';
import 'widgets/web_brand_details_view.dart';

class BranDetails extends StatefulWidget {
  final int brandId;
  static const String preferencesIsFirstLaunchString =
      "PREFERENCES_IS_FIRST_LAUNCH_STRING_ADD_RESERVATION_SCREEN";

  const BranDetails({super.key, required this.brandId});

  @override
  State<BranDetails> createState() => _BranDetailsState();
}

class _BranDetailsState extends State<BranDetails> {
  final _logoKey = GlobalKey();
  final _brandStatusListKey = GlobalKey();
  final _downloadPdfKey = GlobalKey();
  late final ScrollController _scrollController;
  TutorialCoachMark? _tutorialCoachMark;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchBrandDetails();
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

  Future<void> _fetchBrandDetails() async {
    await Provider.of<GetBrandDetailsProvider>(context, listen: false)
        .getBrandDetails(brandNumber: widget.brandId);
  }

  Future<void> _startTutorialIfFirstLaunch() async {
    if (!mounted) return;
    // Only show tutorial for mobile view, not for web
    if (!_isWebView(context)) {
      _addTutorialTargets();
      if (await _isFirstLaunch()) {
        _startTutorial();
      }
    }
  }

  Future<bool> _isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch =
        prefs.getBool(BranDetails.preferencesIsFirstLaunchString) ?? true;
    if (isFirstLaunch) {
      await prefs.setBool(BranDetails.preferencesIsFirstLaunchString, false);
    }
    return isFirstLaunch;
  }

  final List<TargetFocus> _targetList = [];

  void _addTutorialTargets() {
    _targetList.clear();
    _targetList.addAll([
      TargetFocus(
        keyTarget: _logoKey,
        radius: 10,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              bottom: MediaQuery.of(context).size.height * 0.5,
            ),
            child: const _TutorialText(
              title: "brand_gallery",
              subtitle: "brand_gallery_subTitle",
            ),
          ),
        ],
      ),
      TargetFocus(
        keyTarget: _brandStatusListKey,
        radius: 14,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: MediaQuery.of(context).size.height * 0.15,
            ),
            child: const _TutorialText(
              title: "brands_status",
              subtitle: "brand_status_subTitle",
            ),
          ),
        ],
      ),
      TargetFocus(
        keyTarget: _downloadPdfKey,
        radius: 30,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            customPosition: CustomTargetContentPosition(
              bottom: MediaQuery.of(context).size.height * 0.5,
            ),
            child: const _TutorialText(
              title: "download_pdf",
              subtitle: "download_pdf_details",
            ),
          ),
        ],
      ),
    ]);
  }

  void _startTutorial() {
    _tutorialCoachMark = TutorialCoachMark(
      targets: _targetList,
      textSkip: "skip".tr(),
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

  void _onDownloadTap() {
    if (_debounce?.isActive ?? false) return;
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final model = Provider.of<GetBrandDetailsProvider>(context, listen: false);
      if (model.brandDetails != null) {
        final url = Uri.parse(
          "${ApiConstant.baseUrl}pdf/${model.brandDetails!.brand.id}/${globalAccountData.getId()}?download=pdf",
        );
        launchUrl(url);
      }
    });
  }

  // Responsive breakpoint for web view detection
  bool _isWebView(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _CustomAppBar(),
      body: Consumer<GetBrandDetailsProvider>(
        builder: (context, model, _) => _buildBody(context, model),
      ),
    );
  }

  Widget _buildBody(BuildContext context, GetBrandDetailsProvider model) {
    switch (model.state) {
      case RequestState.loading:
        return const ShimmerBrandDetails();
      case RequestState.failed:
        return const Center(child: Text("There are some errors"));
      case RequestState.loaded:
        return model.brandDetails != null
            ? _isWebView(context)
                ? WebBrandDetailsView(
                    model: model,
                    scrollController: _scrollController,
                    logoKey: _logoKey,
                    brandStatusListKey: _brandStatusListKey,
                    downloadPdfKey: _downloadPdfKey,
                    onDownloadTap: _onDownloadTap,
                  )
                : MobileBrandDetailsView(
                    model: model,
                    scrollController: _scrollController,
                    logoKey: _logoKey,
                    brandStatusListKey: _brandStatusListKey,
                    downloadPdfKey: _downloadPdfKey,
                    onTutorialTap: _onTutorialTap,
                    onDownloadTap: _onDownloadTap,
                  )
            : const ShimmerBrandDetails();
      default:
        return const ShimmerBrandDetails();
    }
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CustomAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: const <Widget>[],
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorManager.primaryByOpacity.withValues(alpha: 0.9),
              ColorManager.primary,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(0);
}

class _TutorialText extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TutorialText({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.tr(),
          style: TextStyle(
            fontFamily: StringConstant.fontName,
            color: ColorManager.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle.tr(),
          style: TextStyle(
            fontFamily: StringConstant.fontName,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}