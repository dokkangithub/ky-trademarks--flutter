import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/RequestState/RequestState.dart';
import '../../core/Constant/Api_Constant.dart';
import '../../network/RestApi/Comman.dart';
import '../../resources/Color_Manager.dart';
import '../../resources/ImagesConstant.dart';
import '../../resources/StringManager.dart';
import '../../utilits/Local_User_Data.dart';
import '../Controllar/GetBrandDetailsProvider.dart';
import '../Widget/BrandDetailsWidget/BrandImages.dart';
import '../Widget/BrandDetailsWidget/BrandOrderFinishedOrTawkel.dart';
import '../Widget/BrandDetailsWidget/ShimmerBrandDetails.dart';
import '../Widget/BrandStatusWidget/AcceptWidget.dart';
import '../Widget/BrandStatusWidget/AppealBrandRegistration.dart';
import '../Widget/BrandStatusWidget/AppealGrivenceWidget.dart';
import '../Widget/BrandStatusWidget/ConditionalAcceptanceWidget.dart';
import '../Widget/BrandStatusWidget/GiveupWidget.dart';
import '../Widget/BrandStatusWidget/GrievanceTeamDecisionWidget.dart';
import '../Widget/BrandStatusWidget/GrievanceWidget.dart';
import '../Widget/BrandStatusWidget/RenovationsWidget.dart';
import '../Widget/BrandStatusWidget/RefusedWidget.dart';
import '../Widget/BrandStatusWidget/proccessingWidget.dart';
import 'dart:async'; // For debounce

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
    _scrollController.addListener(_handleScroll); // Monitor scroll events
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchBrandDetails();
      Future.delayed(const Duration(seconds: 2), _startTutorialIfFirstLaunch);
    });
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
    _addTutorialTargets();
    if (await _isFirstLaunch()) {
      _startTutorial();
    }
  }

  @override
  void dispose() {
    _tutorialCoachMark?.finish();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _startTutorial() {
    _tutorialCoachMark = TutorialCoachMark(
      targets: _targetList,
      textSkip: "skip".tr(),
      colorShadow: ColorManager.accent,
      opacityShadow: 0.9,
      alignSkip: AlignmentDirectional.topStart,
      textStyleSkip: TextStyle(
        fontFamily: "Shahid",
        color: ColorManager.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
    _tutorialCoachMark!.show(context: context);
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
            ? _LoadedContent(
          model: model,
          scrollController: _scrollController,
          logoKey: _logoKey,
          brandStatusListKey: _brandStatusListKey,
          downloadPdfKey: _downloadPdfKey,
          onTutorialTap: () {
            if (_debounce?.isActive ?? false) return;
            _debounce = Timer(const Duration(milliseconds: 300), () {
              _addTutorialTargets();
              _startTutorial();
            });
          },
          onDownloadTap: () {
            if (_debounce?.isActive ?? false) return;
            _debounce = Timer(const Duration(milliseconds: 300), () {
              launch(
                "${ApiConstant.baseUrl}pdf/${model.brandDetails!.brand.id}/${globalAccountData.getId()}?download=pdf",
              );
            });
          },
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
      actions: <Widget>[],
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorManager.primaryByOpacity.withOpacity(0.9),
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
            fontFamily: "Shahid",
            color: ColorManager.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle.tr(),
          style: const TextStyle(
            fontFamily: "Shahid",
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final GetBrandDetailsProvider model;
  final ScrollController scrollController;
  final GlobalKey logoKey;
  final GlobalKey brandStatusListKey;
  final GlobalKey downloadPdfKey;
  final VoidCallback onTutorialTap;
  final VoidCallback onDownloadTap;

  const _LoadedContent({
    required this.model,
    required this.scrollController,
    required this.logoKey,
    required this.brandStatusListKey,
    required this.downloadPdfKey,
    required this.onTutorialTap,
    required this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    final brandData = _buildBrandData(context);
    final statusData = model.brandDetails!.AllResult;

    return Stack(
      children: [
        CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  BrandImages(model: model, tutorialKey: logoKey),
                  PositionedDirectional(
                    top: 25,
                    end: 16,
                    child: InkWell(
                      onTap: onTutorialTap,
                      child: Lottie.asset(
                        ImagesConstants.infoW,
                        height: 35,
                        width: 35,
                        repeat: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Text(
                      globalAccountData.getUsername()!,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 23,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      globalAccountData.getEmail()!,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    ColoredTable(data: brandData),
                    BrandOrderFinishedOrTawkel(context: context, model: model),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              sliver: SliverList(
                key: brandStatusListKey,
                delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildStatusWidget(context, statusData[index], index),
                  ),
                  childCount: statusData.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
            child: GestureDetector(
              key: downloadPdfKey,
              onTap: onDownloadTap,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorManager.primary,
                      ColorManager.primaryByOpacity.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    "download_pdf".tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Shahid",
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<List<String>> _buildBrandData(BuildContext context) {
    return [
      [
        model.brandDetails!.brand.markOrModel == 1
            ? "model_desc".tr()
            : "brand_name".tr(),
        model.brandDetails!.brand.brandName ?? '',
      ],
      [
        model.brandDetails!.brand.markOrModel == 1
            ? "model_number".tr()
            : "brand_number".tr(),
        model.brandDetails!.brand.brandNumber ?? '',
      ],
      ["brand_category".tr(), model.brandDetails!.brand.brandDescription ?? ''],
      [
        model.brandDetails!.brand.markOrModel == 1
            ? "model_status".tr()
            : "brand_status".tr(),
        model.brandDetails!.brand.newCurrentState.isEmpty
            ? convertStateBrandNumberToString(
            model.brandDetails!.brand.currentStatus)
            : model.brandDetails!.brand.newCurrentState,
      ],
      [
        model.brandDetails!.brand.markOrModel == 1
            ? "model_details".tr()
            : "category_details".tr(),
        model.brandDetails!.brand.brandDetails.replaceAll('<br>', '') ?? '',
      ],
      ['اسم مقدم الطلب', model.brandDetails!.brand.applicant ?? ''],
      ['عنوان مقدم الطلب', model.brandDetails!.brand.customerAddress ?? ''],
      ["customer_name".tr(), model.brandDetails!.brand.customerName ?? ''],
      ["order_date".tr(), model.brandDetails!.brand.applicationDate ?? ''],
      ["notes".tr(), model.brandDetails!.brand.notes ?? ''],
      ["payment_status".tr(), model.brandDetails!.brand.paymentStatus ?? ''],
      [
        "in_out_egy".tr(),
        model.brandDetails!.brand.country == 0
            ? "in_egypt".tr()
            : '(${model.brandDetails!.brand.countryName})',
      ],
      [
        "complete_request".tr(),
        _getPowerOfAttorneyStatus(model.brandDetails!.brand.completedPowerOfAttorneyRequest),
      ],
      ["incoming_number".tr(), model.brandDetails!.brand.importNumber ?? ''],
      ["attorney_date".tr(), model.brandDetails!.brand.dateOfSupply ?? ''],
      [
        "recording_attorney_date".tr(),
        model.brandDetails!.brand.recordingDateOfSupply ?? ''
      ],
      [
        "date_undertaking_submit_attorney".tr(),
        model.brandDetails!.brand.dateOfUnderTaking ?? ''
      ],
    ].where((item) => item[1].isNotEmpty).toList();
  }

  String _getPowerOfAttorneyStatus(int status) {
    switch (status) {
      case 0:
        return "exists".tr();
      case 1:
        return "not_exists".tr();
      case 2:
        return "attorney_supply".tr();
      case 3:
        return "commitment_attorney_supply".tr();
      default:
        return "recording_attorney_supply".tr();
    }
  }

  Widget _buildStatusWidget(BuildContext context, dynamic data, int index) {
    if (data.name == StringConstant.processing) {
      return proccessingWidget(data: [data], index: 0);
    }
    if (data.name == StringConstant.accept) {
      return AcceptWidget(brandDetailsDataEntity: data);
    }
    if (data.states == "الرفض") {
      return RefusedWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "الطعن ضد التظلم") {
      return AppealGrivenceWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "التظلم") {
      return GrievanceWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "قرار لجنه التظلم") {
      return GrievanceTeamDecisionWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "التجديدات") {
      return RenovationsWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "قبول مشترط") {
      return ConditionalAcceptanceWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == StringConstant.giveUp) {
      return GiveUpWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == StringConstant.appealBrandRegistration) {
      return AppealBrandRegistration(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    return const SizedBox.shrink();
  }
}

class ColoredTable extends StatelessWidget {
  final List<List<String>> data;

  const ColoredTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Table(
        border: TableBorder.all(color: Colors.white70, width: 1),
        columnWidths: const {0: FixedColumnWidth(100)},
        children: List.generate(
          data.length,
              (index) => TableRow(
            decoration: BoxDecoration(
              color: index % 2 == 0 ? ColorManager.primary : ColorManager.primaryByOpacity,
            ),
            children: data[index].map((cell) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cell,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white,fontFamily:StringConstant.fontName),
              ),
            )).toList(),
          ),
        ),
      ),
    );
  }
}