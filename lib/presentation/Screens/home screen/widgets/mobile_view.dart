import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart' as s;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/RequestState/RequestState.dart';
import '../../../../core/Constant/Api_Constant.dart';
import '../../../../data/Brand/models/BrandDataModel.dart';
import '../../../../domain/Brand/Entities/BrandEntity.dart' as brand_entity;
import '../../../../domain/Company/Entities/CompanyEntity.dart' as company_entity;
import '../../../../domain/Issues/Entities/IssuesEntity.dart';
import '../../../../resources/ImagesConstant.dart';
import '../../../../network/RestApi/Comman.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';
import '../../../Controllar/GetBrandProvider.dart';
import '../../../Controllar/GetCompanyProvider.dart';
import '../../../Controllar/Issues/GetIssuesProvider.dart';
import '../../../Controllar/Issues/GetIssuesSummaryProvider.dart';
import '../../../Widget/loading_widget.dart';
import '../../../Widget/BrandWidget.dart';
import '../../add request/AddRequest.dart';
import '../../brand details/BrandDetails.dart';
import '../../notification screen/NotificationScreen.dart';
import '../../payment ways/PaymentWays.dart';
import '../../../../utilits/Local_User_Data.dart';

class AppConstants {
  static const double headerHeight = 200.0;
  static const double cardHeight = 120.0;
  static const double cardMargin = 8.0;
  static const double paddingHorizontal = 16.0;
  static const double paddingVertical = 8.0;
}

// Converted to StatefulWidget to handle local state like TabController
class MobileView extends StatefulWidget {
  final String byStatus;
  final ValueChanged<String> onFilterChanged;
  final ScrollController mainScrollController;
  final ScrollController listScrollController;
  final bool isLoadingMore;

  const MobileView({
    required this.byStatus,
    required this.onFilterChanged,
    required this.mainScrollController,
    required this.listScrollController,
    required this.isLoadingMore,
    super.key,
  });

  @override
  State<MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Tab controller for Marks, Models, and Issues
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    // Fetch issues data when the widget is initialized
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final issuesProvider = Provider.of<GetIssuesProvider>(context, listen: false);
      final summaryProvider = Provider.of<GetIssuesSummaryProvider>(context, listen: false);
      final customerId = globalAccountData.getId();

      if (customerId != null) {
        issuesProvider.getIssues(customerId: int.parse(customerId));
        summaryProvider.getIssuesSummary(customerId: int.parse(customerId));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.mainScrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The header remains largely the same but will now control a 3-tab view
          MobileHeader(
            tabController: _tabController,
            byStatus: widget.byStatus,
            onFilterChanged: widget.onFilterChanged,
          ),
          // Latest updates section, as it was
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
                Consumer<GetBrandProvider>(
                  builder: (context, provider, _) => BrandUpdatesList(
                    controller: widget.listScrollController,
                    brands: provider.allBrandUpdates,
                  ),
                ),
                if (widget.isLoadingMore) LoadingWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MobileHeader extends StatelessWidget {
  final TabController tabController;
  final String byStatus;
  final ValueChanged<String> onFilterChanged;

  const MobileHeader({
    required this.tabController,
    required this.byStatus,
    required this.onFilterChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final companyProvider = Provider.of<GetCompanyProvider>(context);

    return Stack(
      children: [
        // Background Gradient
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
        // Content
        Column(
          children: [
            const SizedBox(height: 10),
            MobileHeaderContent(),
            MobileActionRows(),
            const SizedBox(height: 10),
            // UI for Tabs and Filters
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingHorizontal,
              ),
              child: Column(
                children: [
                  // Updated TabBar with 3 tabs
                  TabBar(
                    controller: tabController,
                    labelColor: ColorManager.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: ColorManager.primary,
                    tabs: [
                      Tab(child: Text('marks'.tr(), style: TextStyle(fontFamily: StringConstant.fontName))),
                      Tab(child: Text('models'.tr(), style: TextStyle(fontFamily: StringConstant.fontName))),
                      Tab(child: Text('issues'.tr(), style: TextStyle(fontFamily: StringConstant.fontName))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Dropdown filters remain the same
                  Row(
                    children: [
                      Expanded(child: _buildCompanyDropdown(context, companyProvider)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildFilterDropdown(context)),
                    ],
                  ),
                ],
              ),
            ),
            // The TabBarView is now wrapped to handle its own height
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingHorizontal,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                // This ensures the TabBarView takes the height of its content
                child: AnimatedBuilder(
                  animation: tabController.animation!,
                  builder: (context, child) {
                    return IndexedStack(
                      index: tabController.index,
                      children: [
                        // Each child must be a self-contained scrollable view or sized box
                        _buildBrandsContent(context, ContentType.brands),
                        _buildBrandsContent(context, ContentType.models),
                        _buildIssuesContent(context),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to build Company Dropdown
  Widget _buildCompanyDropdown(BuildContext context, GetCompanyProvider companyProvider) {
    return companyProvider.state == RequestState.loading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : DropdownButton<company_entity.CompanyEntity>(
            value: companyProvider.selectedCompany,
            hint: Text('select_company'.tr(), style: TextStyle(color: ColorManager.primary, fontFamily: StringConstant.fontName)),
            dropdownColor: ColorManager.chartColor,
            style: TextStyle(color: ColorManager.primary, fontFamily: StringConstant.fontName),
            icon: Icon(Icons.arrow_drop_down, color: ColorManager.primary),
            underline: Container(),
            isExpanded: true,
            onChanged: (company_entity.CompanyEntity? newValue) {
              if (newValue != null) {
                companyProvider.setSelectedCompany(newValue);
                Provider.of<GetBrandProvider>(context, listen: false).getAllBrandsWidget(companyId: newValue.id);
              }
            },
            items: companyProvider.allCompanies.map<DropdownMenuItem<company_entity.CompanyEntity>>((company_entity.CompanyEntity company) {
              return DropdownMenuItem<company_entity.CompanyEntity>(value: company, child: Text(company.companyName, overflow: TextOverflow.ellipsis));
            }).toList(),
          );
  }

  // Helper method to build Filter Dropdown
  Widget _buildFilterDropdown(BuildContext context) {
    return DropdownButton<String>(
      value: byStatus.isEmpty ? null : byStatus,
      hint: Text('brands_filter'.tr(), style: TextStyle(color: ColorManager.primary, fontFamily: StringConstant.fontName)),
      dropdownColor: ColorManager.chartColor,
      style: TextStyle(color: ColorManager.primary, fontFamily: StringConstant.fontName),
      icon: Icon(Icons.arrow_drop_down, color: ColorManager.primary),
      underline: Container(),
      isExpanded: true,
      onChanged: (String? newValue) {
        if (newValue != null) onFilterChanged(newValue);
      },
      items: [
        StringConstant.accept,
        StringConstant.reject,
        StringConstant.inEgypt,
        StringConstant.outsideEgypt,
        StringConstant.allStatus,
      ].map((value) => DropdownMenuItem(value: value, child: Text(value.tr()))).toList(),
    );
  }

  // Builds content for Brands and Models tabs
  Widget _buildBrandsContent(BuildContext context, ContentType type) {
    return Consumer<GetBrandProvider>(
      builder: (context, provider, _) {
        if (provider.state == RequestState.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final filteredData = provider.allBrands.where((brand) => _filterBrands(brand, type)).toList();

        if (filteredData.isEmpty) {
          return _NoDataView();
        }

        return MobileListContent(brands: filteredData);
      },
    );
  }

  // New method to build the Issues tab content
  Widget _buildIssuesContent(BuildContext context) {
    return Consumer2<GetIssuesProvider, GetIssuesSummaryProvider>(
      builder: (context, issuesProvider, summaryProvider, _) {
        if (issuesProvider.state == RequestState.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (issuesProvider.allIssues.isEmpty) {
          return _NoDataView(message: 'no_issues'.tr());
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Summary card
              if (summaryProvider.state == RequestState.loaded && summaryProvider.issuesSummary != null)
                _buildIssuesSummaryCard(summaryProvider.issuesSummary!),

              // List of issues
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: issuesProvider.allIssues.length,
                itemBuilder: (context, index) {
                  final issue = issuesProvider.allIssues[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(issue.brand.brandName, style: TextStyle(fontFamily: StringConstant.fontName, fontWeight: FontWeight.bold)),
                      subtitle: Text(issue.refusedType, style: TextStyle(fontFamily: StringConstant.fontName)),
                      trailing: Text('${issue.sessionsCount} ${'sessions'.tr()}', style: TextStyle(fontFamily: StringConstant.fontName)),
                      onTap: () {
                        // TODO: Navigate to issue details screen
                      },
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildIssuesSummaryCard(IssuesSummaryEntity summary) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('issues_summary'.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorManager.primary, fontFamily: StringConstant.fontName)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('total_issues'.tr(), summary.statistics.totalIssues.toString(), Icons.gavel, ColorManager.primary),
                _buildSummaryItem('normal_issues'.tr(), summary.statistics.normalIssues.toString(), Icons.description, Colors.blue),
                _buildSummaryItem('opposition_issues'.tr(), summary.statistics.oppositionIssues.toString(), Icons.warning, Colors.orange),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color, fontFamily: StringConstant.fontName)),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: StringConstant.fontName)),
      ],
    );
  }

  bool _filterBrands(brand_entity.BrandEntity brand, ContentType type) {
    final isMark = type == ContentType.brands;
    if (brand.markOrModel != (isMark ? 0 : 1)) return false;

    if (byStatus == StringConstant.accept) {
      return brand.currentStatus == 2;
    } else if (byStatus == StringConstant.reject) {
      return brand.currentStatus == 3;
    } else if (byStatus == StringConstant.inEgypt) {
      return brand.country == 0;
    } else if (byStatus == StringConstant.outsideEgypt) {
      return brand.country != 0;
    }
    return true; // For allStatus or empty
  }
}

enum ContentType { brands, models }

// Keeping existing widgets but they might need minor adjustments
class MobileHeaderContent extends StatelessWidget {
  const MobileHeaderContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MobileGreeting(),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        globalAccountData.getUsername() ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          fontFamily: StringConstant.fontName,
                          letterSpacing: 1,
                          color: ColorManager.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Lottie.asset(
                      ImagesConstants.hi,
                      height: 35,
                      width: 35,
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
                width: 40,
                height: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MobileGreeting extends StatelessWidget {
  const MobileGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    return Text(
      hour < 12 ? "good_morning".tr() : "good_night".tr(),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        fontFamily: StringConstant.fontName,
        letterSpacing: 1,
        color: ColorManager.white,
      ),
    );
  }
}

class MobileActionRows extends StatelessWidget {
  const MobileActionRows({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
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
                        style: TextStyle(
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
          // Mobile Action Buttons - Stack them vertically or use wrap
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentWays()),
                      ),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          "payment methods".tr(),
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.primary,
                            fontFamily: StringConstant.fontName,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddRequest(
                              canBack: true,
                            )),
                      ),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          "new_ask".tr(),
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: ColorManager.primary,
                            fontFamily: StringConstant.fontName,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Download Button - Full width for mobile
              MobileDownloadButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class MobileDownloadButton extends StatelessWidget {
  const MobileDownloadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launch(
          "${ApiConstant.baseUrl}pdfAll/${globalAccountData.getId()}?download=pdf"),
      child: Container(
        width: double.infinity,
        height: 40,
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ),
      ),
    );
  }
}

class MobileListContent extends StatelessWidget {
  final List<brand_entity.BrandEntity> brands;

  const MobileListContent({required this.brands, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: brands.length,
      shrinkWrap: true, // Important for nested lists
      physics: const NeverScrollableScrollPhysics(), // Important for nested lists
      padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
      itemBuilder: (context, index) => BrandWidget(
        context: context,
        model: Provider.of<GetBrandProvider>(context, listen: false),
        index: index,
        isFromHomeFiltering: true,
        brandsList: brands,
      ),
    );
  }
}

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
          height: brands.length * (AppConstants.cardHeight + AppConstants.cardMargin),
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
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 15,
                                fontFamily: StringConstant.fontName,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            convertStateBrandNumberToString(brand.currentStatus),
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.grey.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontFamily: StringConstant.fontName,
                            ),
                          ),
                          Text(
                            "${s.DateFormat('EEEE').format(DateTime.parse(update.date))} الموافق: ${s.DateFormat('yyyy-MM-dd').format(DateTime.parse(update.date))}",
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
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

class _NoDataView extends StatelessWidget {
  final String? message;
  const _NoDataView({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(ImagesConstants.noData, width: 150, height: 150, fit: BoxFit.contain),
            const SizedBox(height: 16),
            Text(
              message ?? 'no_data'.tr(),
              style: TextStyle(
                color: ColorManager.primary,
                fontWeight: FontWeight.w500,
                fontSize: 18,
                fontFamily: StringConstant.fontName,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileLoadingShimmer extends StatelessWidget {
  const MobileLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            _MobileShimmerRow(),
            const SizedBox(height: 20),
            _MobileShimmerItem(),
            const SizedBox(height: 10),
            _MobileShimmerStack(),
            const SizedBox(height: 20),
            _MobileShimmerStack(isSecond: true),
          ],
        ),
      ),
    );
  }
}

class _MobileShimmerRow extends StatelessWidget {
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

class _MobileShimmerItem extends StatelessWidget {
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

class _MobileShimmerStack extends StatelessWidget {
  final bool isSecond;

  const _MobileShimmerStack({this.isSecond = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: MediaQuery.of(context).size.width - (isSecond ? 40 : 0),
            height: MediaQuery.of(context).size.height * 0.3,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white,
          ),
        ),
        Column(
          children: List.generate(
            isSecond ? 2 : 3,
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