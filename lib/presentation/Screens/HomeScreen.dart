import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart' as s;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/RequestState/RequestState.dart';
import '../../core/Constant/Api_Constant.dart';
import '../../data/Brand/models/BrandDataModel.dart';
import '../../domain/Brand/Entities/BrandEntity.dart';
import '../../domain/Company/Entities/CompanyEntity.dart';
import '../../resources/ImagesConstant.dart';
import '../../network/RestApi/Comman.dart';
import '../../resources/Color_Manager.dart';
import '../../resources/StringManager.dart';
import '../Controllar/GetBrandProvider.dart';
import '../Controllar/GetCompanyProvider.dart';
import '../Widget/loading_widget.dart';
import '../Widget/BrandWidget.dart';
import 'AddRequest.dart';
import 'BrandDetails.dart';
import 'NotificationScreen.dart';
import 'PaymentWays.dart';
import '../../utilits/Local_User_Data.dart';

class AppConstants {
  static const double headerHeight = 200.0;
  static const double cardHeight = 120.0;
  static const double cardMargin = 8.0;
  static const double paddingHorizontal = 16.0;
  static const double paddingVertical = 8.0;
}

class HomeScreen extends StatefulWidget {
  final GlobalKey? contactUsKey;

  const HomeScreen({this.contactUsKey, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _mainScrollController;
  late final ScrollController _listScrollController;
  String _byStatus = "";
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _mainScrollController = ScrollController();
    _listScrollController = ScrollController();

    _setupScrollListeners();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _setupScrollListeners() {
    _listScrollController.addListener(_handleScroll);
    _mainScrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_isLoadingMore) return;
    final controller = _listScrollController.hasClients
        ? _listScrollController
        : _mainScrollController;

    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _fetchInitialData() async {
    GetCompanyProvider companyProvider =
        Provider.of<GetCompanyProvider>(context, listen: false);
    await Provider.of<GetCompanyProvider>(context, listen: false)
        .getAllCompanies();
    await Provider.of<GetBrandProvider>(context, listen: false)
        .getAllBrandsWidget(companyId: companyProvider.allCompanies[0].id);
  }

  Future<void> _loadMoreData() async {
    GetCompanyProvider companyProvider =
        Provider.of<GetCompanyProvider>(context, listen: false);
    final provider = Provider.of<GetBrandProvider>(context, listen: false);
    if (!provider.isLoading && provider.hasMoreData && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      await provider.loadMoreBrands(companyProvider.allCompanies[0].id);
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mainScrollController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.anotherTabBackGround,
      appBar: const CustomAppBar(),
      body: Consumer<GetBrandProvider>(
        builder: (context, model, _) => _buildBody(context, model),
      ),
    );
  }

  Widget _buildBody(BuildContext context, GetBrandProvider model) {
    switch (model.state) {
      case RequestState.loading:
        return const LoadingShimmer();
      case RequestState.loaded:
        return LoadedContent(
          tabController: _tabController,
          byStatus: _byStatus,
          onFilterChanged: (value) => setState(() => _byStatus = value),
          mainScrollController: _mainScrollController,
          listScrollController: _listScrollController,
          isLoadingMore: _isLoadingMore,
        );
      case RequestState.failed:
        return Center(
            child: Text(
          "There are Error",
          style: TextStyle(fontFamily:StringConstant.fontName),
        ));
      default:
        return const LoadingShimmer();
    }
  }
}

// Custom AppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 40,
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
  Size get preferredSize => const Size.fromHeight(10);
}

// Loading Shimmer Widget
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            _ShimmerRow(),
            const SizedBox(height: 20),
            _ShimmerItem(),
            const SizedBox(height: 10),
            _ShimmerStack(),
            const SizedBox(height: 20),
            _ShimmerStack(isSecond: true),
          ],
        ),
      ),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 140, height: 20, color: Colors.white),
                const SizedBox(height: 10),
                Container(width: 180, height: 20, color: Colors.white),
              ],
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ShimmerItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            width: 60,
            height: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 140, height: 20, color: Colors.white),
              const SizedBox(height: 10),
              Container(width: 60, height: 20, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShimmerStack extends StatelessWidget {
  final bool isSecond;

  const _ShimmerStack({this.isSecond = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: MediaQuery.of(context).size.width - (isSecond ? 40 : 0),
            height: MediaQuery.of(context).size.height * 0.4,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white,
          ),
        ),
        Column(
          children: List.generate(
            isSecond ? 2 : 4,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 140, height: 20, color: Colors.white),
                        const SizedBox(height: 10),
                        Container(width: 180, height: 20, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Main Content Widget
class LoadedContent extends StatelessWidget {
  final TabController tabController;
  final String byStatus;
  final ValueChanged<String> onFilterChanged;
  final ScrollController mainScrollController;
  final ScrollController listScrollController;
  final bool isLoadingMore;

  const LoadedContent({
    required this.tabController,
    required this.byStatus,
    required this.onFilterChanged,
    required this.mainScrollController,
    required this.listScrollController,
    required this.isLoadingMore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    return SingleChildScrollView(
      controller: mainScrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveHeader(
            tabController: tabController,
            byStatus: byStatus,
            onFilterChanged: onFilterChanged,
          ),
          Container(
            color: ColorManager.anotherTabBackGround,
            padding: const EdgeInsets.only(
                top: 15, left: AppConstants.paddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "latest_trademarks".tr(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: ColorManager.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      fontFamily: StringConstant.fontName),
                ),
                const SizedBox(height: 5),
                BrandUpdatesList(
                  controller: listScrollController,
                  brands: provider.allBrandUpdates,
                ),
                if (isLoadingMore) LoadingWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResponsiveHeader extends StatelessWidget {
  final TabController tabController;
  final String byStatus;
  final ValueChanged<String> onFilterChanged;

  const ResponsiveHeader({
    required this.tabController,
    required this.byStatus,
    required this.onFilterChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    final companyProvider =
        Provider.of<GetCompanyProvider>(context); // Access company provider
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final childAspectRatio = _getChildAspectRatio(constraints.maxWidth);

        return Stack(
          children: [
            Container(
              height: AppConstants.headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorManager.primaryByOpacity.withValues(alpha: 0.9),
                    ColorManager.primary,
                  ],
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 10),
                HeaderContent(
                  constraints: constraints,
                  isLargeScreen: isLargeScreen,
                ),
                ActionRows(isLargeScreen: isLargeScreen),
                const SizedBox(height: 10),
                // Add TabBar, Company Dropdown, and Filter Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingHorizontal,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // TabBar
                        SizedBox(
                          width: 200,
                          child: TabBar(
                            controller: tabController,
                            labelColor: ColorManager.primary,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: ColorManager.primary,
                            tabs: [
                              Tab(child: Text('marks'.tr(),style: TextStyle(fontFamily: StringConstant.fontName),),),
                              Tab(child: Text('models'.tr(),style: TextStyle(fontFamily: StringConstant.fontName),),),
                            ],
                          ),
                        ),
                        // Company Dropdown
                        companyProvider.state == RequestState.loading
                            ? const CircularProgressIndicator()
                            : DropdownButton<CompanyEntity>(
                                value: companyProvider.selectedCompany,
                                hint: Text(
                                  'select_company'.tr(),
                                  style: TextStyle(
                                      color: ColorManager.primary,
                                      fontFamily: StringConstant.fontName),
                                ),
                                dropdownColor: ColorManager.chartColor,
                                style: TextStyle(color: ColorManager.primary,fontFamily: StringConstant.fontName),
                                icon: const SizedBox.shrink(),
                                // Remove default icon
                                underline: Container(),
                                onChanged: (CompanyEntity? newValue) {
                                  if (newValue != null) {
                                    companyProvider
                                        .setSelectedCompany(newValue);
                                    Provider.of<GetBrandProvider>(context,
                                            listen: false)
                                        .getAllBrandsWidget(
                                            companyId: newValue.id);
                                  }
                                },
                                items: companyProvider.allCompanies
                                    .map<DropdownMenuItem<CompanyEntity>>(
                                  (CompanyEntity company) {
                                    return DropdownMenuItem<CompanyEntity>(
                                      value: company,
                                      child: Text(
                                        company.companyName,
                                        style: TextStyle(fontFamily: StringConstant.fontName),
                                      ),
                                    );
                                  },
                                ).toList(),
                                // Custom layout for the selected item with icon
                                selectedItemBuilder: (BuildContext context) {
                                  return companyProvider.allCompanies
                                      .map<Widget>((CompanyEntity company) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          company.companyName,
                                          style: TextStyle(
                                              color: ColorManager.primary,
                                              fontFamily: StringConstant.fontName),
                                        ),
                                        const SizedBox(width: 4),
                                        // Adjust this value to control spacing
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: ColorManager.primary,
                                        ),
                                      ],
                                    );
                                  }).toList();
                                },
                              ),
                        // Filter Dropdown
                        DropdownButton<String>(
                          value: byStatus.isEmpty ? null : byStatus,
                          hint: Text(
                            'brands_filter'.tr(),
                            style: TextStyle(
                                color: ColorManager.primary,
                                fontFamily: StringConstant.fontName),
                          ),
                          dropdownColor: ColorManager.chartColor,
                          style: TextStyle(
                              color: ColorManager.primary,
                              fontFamily: StringConstant.fontName),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: ColorManager.primary,
                          ),
                          underline: Container(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              onFilterChanged(newValue);
                            }
                          },
                          items: [
                            DropdownMenuItem(
                              value: StringConstant.inEgypt,
                              child: Text(
                                'in_egypt'.tr(),
                                style: TextStyle(fontFamily: StringConstant.fontName),
                              ),
                            ),
                            DropdownMenuItem(
                              value: StringConstant.outsideEgypt,
                              child: Text(
                                'out_egypt'.tr(),
                                style: TextStyle(fontFamily: StringConstant.fontName),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingHorizontal,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TabBarView(
                    controller: tabController,
                    children: provider.allBrands.isEmpty
                        ? List.generate(2, (_) => _NoDataView())
                        : ['marks'.tr(), 'models'.tr()].map((tab) {
                            final filteredData = provider.allBrands
                                .where((brand) => _filterBrands(brand, tab))
                                .toList();
                            return filteredData.isEmpty
                                ? _NoDataView()
                                : isLargeScreen
                                    ? GridContent(
                                        brands: filteredData,
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: childAspectRatio,
                                      )
                                    : ListContent(brands: filteredData);
                          }).toList(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  bool _filterBrands(BrandEntity brand, String tab) {
    final isMark = tab == 'marks'.tr();
    final isInEgypt = brand.country == 0;
    if (brand.markOrModel != (isMark ? 0 : 1)) return false;

    if (byStatus == StringConstant.accept) {
      return brand.currentStatus == 2;
    } else if (byStatus == StringConstant.reject) {
      return brand.currentStatus == 3;
    } else if (byStatus == StringConstant.inEgypt) {
      return isInEgypt;
    } else if (byStatus == StringConstant.outsideEgypt) {
      return !isInEgypt;
    } else if (byStatus == StringConstant.allStatus || byStatus == "") {
      return true;
    }
    return false;
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 3;
    if (width > 900) return 2;
    if (width > 600) return 1;
    return 1;
  }

  double _getChildAspectRatio(double width) {
    if (width > 1400) return 4.1;
    if (width > 1200) return 3.2;
    if (width > 1000) return 4.0;
    if (width > 900) return 3.5;
    if (width > 800) return 6.5;
    if (width > 700) return 5.5;
    if (width > 600) return 4.5;
    if (width > 500) return 2.05;
    if (width > 400) return 1.5;
    return 0.9;
  }
}

// Header Content Widget
class HeaderContent extends StatelessWidget {
  final BoxConstraints constraints;
  final bool isLargeScreen;

  const HeaderContent({
    required this.constraints,
    required this.isLargeScreen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Greeting(isLargeScreen: isLargeScreen),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        globalAccountData.getUsername() ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isLargeScreen ? 22 : 18,
                          fontFamily: StringConstant.fontName,
                          letterSpacing: 1,
                          color: ColorManager.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Lottie.asset(
                      ImagesConstants.hi,
                      height: isLargeScreen ? 45 : 35,
                      width: isLargeScreen ? 45 : 35,
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Image.asset(
                ImagesConstants.notification,
                width: isLargeScreen ? 50 : 40,
                height: isLargeScreen ? 40 : 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Greeting Widget
class Greeting extends StatelessWidget {
  final bool isLargeScreen;

  const Greeting({required this.isLargeScreen, super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    return Text(
      hour < 12 ? "good_morning".tr() : "good_night".tr(),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: isLargeScreen ? 20 : 18,
        fontFamily: StringConstant.fontName,
        letterSpacing: 1,
        color: ColorManager.white,
      ),
    );
  }
}

// Download Button Widget
class DownloadButton extends StatelessWidget {
  final BoxConstraints constraints;
  final bool isLargeScreen;

  const DownloadButton({
    required this.constraints,
    required this.isLargeScreen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () => launch(
            "${ApiConstant.baseUrl}pdfAll/${globalAccountData.getId()}?download=pdf"),
        child: Container(
          width: isLargeScreen
              ? constraints.maxWidth * 0.4
              : constraints.maxWidth * 0.4,
          height: isLargeScreen ? 50 : 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorManager.primary,
                ColorManager.primaryByOpacity.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(45),
          ),
          child: Center(
            child: Text(
              "download_full_pdf".tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: isLargeScreen ? 16 : 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: StringConstant.fontName,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

// Action Rows Widget
class ActionRows extends StatelessWidget {
  final bool isLargeScreen;

  const ActionRows({required this.isLargeScreen, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(ImagesConstants.wallet, width: 50, height: 50),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "total_trademarks".tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: StringConstant.fontName,
                        letterSpacing: 1,
                        color: ColorManager.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          provider.totalMarks.toString(),
                          style:  TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontFamily: StringConstant.fontName,
                            fontSize: 24,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 2),
                          child: Text(
                            "tm".tr(),
                            style: TextStyle(
                              fontFamily: StringConstant.fontName,
                              color: ColorManager.white.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (constraints.maxWidth > 600) SizedBox.shrink(),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentWays()),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "payment methods".tr(),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: isLargeScreen ? 16 : 14,
                                fontWeight: FontWeight.w700,
                                color: ColorManager.primary,
                                fontFamily: StringConstant.fontName,
                              ),
                    ),
                  ),
                ),
                DownloadButton(
                  constraints: constraints,
                  isLargeScreen: isLargeScreen,
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddRequest(
                              canBack: true,
                            )),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "new_ask".tr(),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: isLargeScreen ? 16 : 14,
                                fontWeight: FontWeight.w900,
                                color: ColorManager.primary,
                                fontFamily: StringConstant.fontName,
                              ),
                    ),
                  ),
                ),
                if (constraints.maxWidth > 600) SizedBox.shrink(),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// No Data View Widget
class _NoDataView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Lottie.asset(ImagesConstants.noData, fit: BoxFit.contain),
          Text(
            'no_data'.tr(),
            style: TextStyle(
              color: ColorManager.primary,
              fontWeight: FontWeight.w500,
              fontSize: 22,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }
}

// List Content Widget for Small Screens
class ListContent extends StatelessWidget {
  final List<BrandEntity> brands;

  const ListContent({required this.brands, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    return ListView.builder(
      itemCount: brands.length + (provider.isLoading ? 1 : 0),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
      itemBuilder: (context, index) => index == brands.length
          ? Center(child: LoadingWidget())
          : BrandWidget(
              context: context,
              model: provider,
              index: index,
              isFromHomeFiltering: true,
              brandsList: brands,
            ),
    );
  }
}

// Grid Content Widget for Large Screens
class GridContent extends StatelessWidget {
  final List<BrandEntity> brands;
  final int crossAxisCount;
  final double childAspectRatio;

  const GridContent({
    required this.brands,
    required this.crossAxisCount,
    required this.childAspectRatio,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: brands.length + (provider.isLoading ? 1 : 0),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
      itemBuilder: (context, index) => index == brands.length
          ? Center(child: LoadingWidget())
          : BrandWidget(
              context: context,
              model: provider,
              index: index,
              isFromHomeFiltering: true,
              brandsList: brands,
            ),
    );
  }
}

// Brand Updates List Widget
class BrandUpdatesList extends StatelessWidget {
  final ScrollController controller;
  final List<dynamic> brands;

  const BrandUpdatesList({
    required this.controller,
    required this.brands,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: brands.length *
              (AppConstants.cardHeight + AppConstants.cardMargin),
          color: ColorManager.anotherTabBackGround,
          padding: const EdgeInsets.only(top: 15),
          child: NumberStepper(
            alignment: Alignment.topRight,
            scrollingDisabled: true,
            lineLength: 80,
            stepPadding: 0,
            numberStyle: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
            lineColor: ColorManager.primaryByOpacity,
            stepColor: Colors.transparent,
            activeStepBorderColor: Colors.transparent,
            activeStepColor: Colors.transparent,
            enableNextPreviousButtons: false,
            direction: Axis.vertical,
            numbers: brands.map((e) => DateTime.parse(e.date).day).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
            itemCount: brands.length,
            itemBuilder: (context, index) => BrandUpdateItem(index: index),
          ),
        ),
      ],
    );
  }
}

// Brand Update Item Widget
class BrandUpdateItem extends StatelessWidget {
  final int index;

  const BrandUpdateItem({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    final brand = provider.allBrands[index];
    final update = provider.allBrandUpdates[index];
    final filteredImage = brand.images.isNotEmpty
        ? brand.images.firstWhere(
            (img) => img.conditionId == null,
            orElse: () => ImagesModel(image: '', conditionId: '', type: ''),
          )
        : null;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: AppConstants.cardMargin),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BranDetails(brandId: brand.id)),
        ),
        child: Container(
          height: AppConstants.cardHeight,
          padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
          child: Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (filteredImage != null && filteredImage.image.isNotEmpty)
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: cachedImage(
                            ApiConstant.imagePath + filteredImage.image,
                            fit: BoxFit.contain,
                            placeHolderFit: BoxFit.contain,
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 160,
                            child: Text(
                              brand.brandName,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontSize: 15,
                                    fontFamily: StringConstant.fontName,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            convertStateBrandNumberToString(
                                brand.currentStatus),
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  color: Colors.grey.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontFamily: StringConstant.fontName,
                                ),
                          ),
                          Text(
                            "${s.DateFormat('EEEE').format(DateTime.parse(update.date))} الموافق: ${s.DateFormat('yyyy-MM-dd').format(DateTime.parse(update.date))}",
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  color: Colors.grey.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontFamily: StringConstant.fontName,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 20, end: 10),
                child: SvgPicture.asset(
                  brand.currentStatus == 2
                      ? "assets/images/accept.svg"
                      : brand.currentStatus == 3
                          ? "assets/images/refused.svg"
                          : "assets/images/proccessing.svg",
                  width: 25,
                  height: 25,
                  color: ColorManager.primaryByOpacity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Alert Dialog (unchanged but can be optimized similarly)
class CustomAlertDialog extends StatelessWidget {
  final Color bgColor;
  final String title;
  final String message;
  final String positiveBtnText;
  final String negativeBtnText;
  final Function onPostivePressed;
  final Function onNegativePressed;
  final double circularBorderRadius;

  const CustomAlertDialog({
    required this.title,
    required this.message,
    this.circularBorderRadius = 15.0,
    this.bgColor = Colors.white,
    required this.positiveBtnText,
    required this.negativeBtnText,
    required this.onPostivePressed,
    required this.onNegativePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool checkedValue = false;
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.primary,
              ),
              child: const Center(
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 18,
                  fontFamily: StringConstant.fontName,
                ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          cachedImage(
            null,
            width: 300,
          ),
          const SizedBox(height: 45),
          Text(
            message,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: StringConstant.fontName,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          StatefulBuilder(
            builder: (context, state) => CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              checkColor: ColorManager.primary,
              title: Text(
                "عدم العرض مرة اخري",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 14,
                      fontFamily: StringConstant.fontName,
                    ),
              ),
              value: checkedValue,
              onChanged: (newValue) {
                state(() {
                  checkedValue = newValue!;
                });
                if (newValue == true) {
                  globalAccountData.setShowAgain(false);
                  Navigator.of(context).pop();
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ],
      ),
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(circularBorderRadius),
      ),
    );
  }
}
