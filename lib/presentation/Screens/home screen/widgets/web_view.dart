import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart' as s;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:simple_grid/simple_grid.dart';

import '../../../../app/RequestState/RequestState.dart';
import '../../../../core/Constant/Api_Constant.dart';
import '../../../../domain/Brand/Entities/BrandEntity.dart';
import '../../../../domain/Company/Entities/CompanyEntity.dart';
import '../../../../domain/Issues/Entities/IssuesEntity.dart' as issues_entities;
import '../../../../resources/ImagesConstant.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';
import '../../../../data/Brand/models/BrandDataModel.dart';
import '../../../Controllar/GetBrandProvider.dart';
import '../../../Controllar/GetCompanyProvider.dart';
import '../../../Controllar/Issues/GetIssuesProvider.dart';
import '../../../Controllar/Issues/GetIssuesSummaryProvider.dart';
import '../../../Widget/loading_widget.dart';
import '../../brand details/BrandDetails.dart';
import '../../notification screen/NotificationScreen.dart';
import '../../../../utilits/Local_User_Data.dart';
import '../../../../network/RestApi/Comman.dart';

class WebAppConstants {
  static const double headerHeight = 250.0;
  static const double cardHeight = 120.0;
  static const double cardMargin = 8.0;
  static const double paddingHorizontal = 24.0;
  static const double paddingVertical = 16.0;
}

// Enhanced Brand Status Helper Class
class BrandStatusHelper {
  static String getStatusText(int status) {
    switch (status) {
      case 1:
        return 'تحت الفحص الفني';
      case 2:
        return 'قبول';
      case 3:
        return 'رفض';
      case 4:
        return 'تظلم';
      case 5:
        return 'قرار لجنه التظلمات';
      case 6:
        return 'مجددة';
      case 7:
        return 'الطعن ضد التظلم';
      case 8:
        return 'قبول مشترط';
      case 9:
        return 'تنازل';
      case 10:
        return 'طعن في تسجيل العلامة';
      case 11:
        return 'تقرير';
      case 12:
        return 'معارضات';
      default:
        return 'غير محدد';
    }
  }

  static Color getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange.shade600;
      case 2:
        return Colors.green.shade600;
      case 3:
        return Colors.red.shade600;
      case 4:
        return Colors.blue.shade600;
      case 5:
        return Colors.purple.shade600;
      case 6:
        return Colors.teal.shade600;
      case 7:
        return Colors.indigo.shade600;
      case 8:
        return Colors.amber.shade600;
      case 9:
        return Colors.brown.shade600;
      case 10:
        return Colors.pink.shade600;
      case 11:
        return Colors.cyan.shade600;
      case 12:
        return Colors.deepOrange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  static Color getStatusLightColor(int status) {
    return getStatusColor(status).withOpacity(0.1);
  }
}

class WebView extends StatefulWidget {
  final String byStatus;
  final ValueChanged<String> onFilterChanged;
  final ScrollController mainScrollController;
  final ScrollController listScrollController;
  final bool isLoadingMore;
  final Function(int)? onTabChanged;

  const WebView({
    required this.byStatus,
    required this.onFilterChanged,
    required this.mainScrollController,
    required this.listScrollController,
    required this.isLoadingMore,
    this.onTabChanged,
    super.key,
  });

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> with TickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    // Tab controller for Marks, Models, and Issues
    tabController = TabController(length: 3, vsync: this);
    
    // Add listener to rebuild content when tab changes
    tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    
    _loadInitialData();
  }

  void _loadInitialData() {
    // Fetch issues data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    final companyProvider = Provider.of<GetCompanyProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    return Container(
      color: Colors.white,
      child: CustomScrollView(
        controller: widget.mainScrollController,
        slivers: [
          // Enhanced Control Panel
          SliverToBoxAdapter(
            child: Container(
              padding:
              EdgeInsets.all(isLargeScreen ? 24 : (isTablet ? 20 : 16)),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Row: Statistics (full width)
                  // Container(
                  //   width: double.infinity,
                  //   margin: const EdgeInsets.only(bottom: 20),
                  //   child: _buildQuickStats(provider),
                  // ),

                  // Second Row: Responsive Layout
                  isMobile
                      ? _buildMobileLayout(provider, companyProvider, context)
                      : (isTablet
                      ? _buildTabletLayout(
                      provider, companyProvider, context)
                      : _buildDesktopLayout(
                      provider, companyProvider, context)),

                  // Download PDF Button Section
                  const SizedBox(height: 16),
                  _buildWebDownloadButton(context, isLargeScreen),
                ],
              ),
            ),
          ),

          // Brand content area - Dynamic height based on content
          SliverToBoxAdapter(
            child: _buildDynamicTabContent(provider),
          ),

          // Latest updates section at the bottom
          if (provider.allBrandUpdates.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildLatestUpdatesSection(provider),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
      List<BrandEntity> allBrands, String tabType, int markOrModelFilter) {
    final filteredData =
    allBrands.where((brand) => _filterBrands(brand, tabType)).toList();

    return filteredData.isEmpty
        ? _WebNoDataView()
        : ImprovedBrandDataView(
      brands: filteredData,
      tabType: tabType,
      listScrollController: widget.listScrollController,
      isLoadingMore: widget.isLoadingMore,
    );
  }

  // Enhanced Issues content for web view
  Widget _buildIssuesContent(BuildContext context) {
    return Consumer2<GetIssuesProvider, GetIssuesSummaryProvider>(
      builder: (context, issuesProvider, summaryProvider, _) {
        if (issuesProvider.state == RequestState.loading) {
          return Container(
            color: Colors.white,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
        if (issuesProvider.allIssues.isEmpty) {
          return _WebNoDataView();
        }

        return WebIssuesDataView(
          issues: issuesProvider.allIssues,
          listScrollController: widget.listScrollController,
          isLoadingMore: widget.isLoadingMore,
        );
      },
    );
  }

  // Desktop Layout: Horizontal arrangement
  Widget _buildDesktopLayout(GetBrandProvider provider,
      GetCompanyProvider companyProvider, BuildContext context) {
    return Row(
      children: [
        // TabBar - Flexible width
        Flexible(
          flex: 3,
          child: Container(
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
            decoration: BoxDecoration(
              color: ColorManager.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              indicatorColor: Colors.white,
              labelStyle:
              TextStyle(fontSize: 14, fontFamily: StringConstant.fontName),
              tabs: [
                Tab(
                    child: Text('علامات',
                        style: TextStyle(fontFamily: StringConstant.fontName))),
                Tab(
                    child: Text('نماذج',
                        style: TextStyle(fontFamily: StringConstant.fontName))),
                Tab(
                    child: Text('قضايا',
                        style: TextStyle(fontFamily: StringConstant.fontName))),
              ],
            ),
          ),
        ),

        const SizedBox(width: 20),

        // Filters - Flexible width
        Flexible(
          flex: 2,
          child: Row(
            children: [
              // Company Dropdown
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: companyProvider.state == RequestState.loading
                      ? const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ))
                      : _buildCompanyDropdown(companyProvider, context),
                ),
              ),

              const SizedBox(width: 12),

              // Filter Dropdown
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: _buildFilterDropdown(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tablet Layout: Mixed arrangement
  Widget _buildTabletLayout(GetBrandProvider provider,
      GetCompanyProvider companyProvider, BuildContext context) {
    return Column(
      children: [
        // TabBar - Full width
        Container(
          decoration: BoxDecoration(
            color: ColorManager.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: Colors.white,
            labelStyle:
            TextStyle(fontSize: 15, fontFamily: StringConstant.fontName),
            tabs: [
              Tab(
                  child: Text('علامات',
                      style: TextStyle(fontFamily: StringConstant.fontName))),
              Tab(
                  child: Text('نماذج',
                      style: TextStyle(fontFamily: StringConstant.fontName))),
              Tab(
                  child: Text('قضايا',
                      style: TextStyle(fontFamily: StringConstant.fontName))),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Filters Row
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: companyProvider.state == RequestState.loading
                    ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ))
                    : _buildCompanyDropdown(companyProvider, context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: _buildFilterDropdown(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Mobile Layout: Vertical arrangement
  Widget _buildMobileLayout(GetBrandProvider provider,
      GetCompanyProvider companyProvider, BuildContext context) {
    return Column(
      children: [
        // TabBar
        Container(
          decoration: BoxDecoration(
            color: ColorManager.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: Colors.white,
            labelStyle:
            TextStyle(fontSize: 12, fontFamily: StringConstant.fontName),
            tabs: [
              Tab(
                  child: Text('علامات',
                      style: TextStyle(fontFamily: StringConstant.fontName))),
              Tab(
                  child: Text('نماذج',
                      style: TextStyle(fontFamily: StringConstant.fontName))),
              Tab(
                  child: Text('تحديث',
                      style: TextStyle(fontFamily: StringConstant.fontName))),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Company Dropdown
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: companyProvider.state == RequestState.loading
              ? const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ))
              : _buildCompanyDropdown(companyProvider, context),
        ),

        const SizedBox(height: 12),

        // Filter Dropdown
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: _buildFilterDropdown(),
        ),
      ],
    );
  }

  Widget _buildQuickStats(GetBrandProvider provider) {
    final statusStats = <int, int>{};
    for (var brand in provider.allBrands) {
      statusStats[brand.currentStatus] =
          (statusStats[brand.currentStatus] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary.withOpacity(0.05),
            ColorManager.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorManager.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isLarge = screenWidth > 1200;
          final isTablet = screenWidth > 768 && screenWidth <= 1200;
          final isMobile = screenWidth <= 768;

          return Column(
            children: [
              // Header with total count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assessment_outlined,
                      color: ColorManager.primary,
                      size: isLarge ? 28 : (isTablet ? 24 : 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي العلامات التجارية',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: isLarge ? 14 : (isTablet ? 13 : 12),
                          fontWeight: FontWeight.w500,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                      Text(
                        '${provider.totalMarks}',
                        style: TextStyle(
                          color: ColorManager.primary,
                          fontSize: isLarge ? 28 : (isTablet ? 24 : 20),
                          fontWeight: FontWeight.bold,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (statusStats.isNotEmpty) ...[
                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        ColorManager.primary.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Status indicators
                isMobile
                    ? _buildMobileStatsGrid(statusStats, isLarge)
                    : _buildDesktopStatsRow(statusStats, isLarge),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileStatsGrid(Map<int, int> statusStats, bool isLarge) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildEnhancedStatusIndicator(
            2, statusStats[2] ?? 0, "مقبولة", Colors.green, Icons.check_circle),
        _buildEnhancedStatusIndicator(1, statusStats[1] ?? 0, "تحت الفحص",
            Colors.orange, Icons.hourglass_empty),
        _buildEnhancedStatusIndicator(
            3, statusStats[3] ?? 0, "مرفوضة", Colors.red, Icons.cancel),
        if (statusStats[4] != null && statusStats[4]! > 0)
          _buildEnhancedStatusIndicator(
              4, statusStats[4]!, "تظلم", Colors.blue, Icons.gavel),
      ],
    );
  }

  Widget _buildDesktopStatsRow(Map<int, int> statusStats, bool isLarge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildEnhancedStatusIndicator(
            2, statusStats[2] ?? 0, "مقبولة", Colors.green, Icons.check_circle),
        _buildVerticalDivider(),
        _buildEnhancedStatusIndicator(1, statusStats[1] ?? 0, "تحت الفحص",
            Colors.orange, Icons.hourglass_empty),
        _buildVerticalDivider(),
        _buildEnhancedStatusIndicator(
            3, statusStats[3] ?? 0, "مرفوضة", Colors.red, Icons.cancel),
        if (statusStats[4] != null && statusStats[4]! > 0) ...[
          _buildVerticalDivider(),
          _buildEnhancedStatusIndicator(
              4, statusStats[4]!, "تظلم", Colors.blue, Icons.gavel),
        ],
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            ColorManager.primary.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatusIndicator(
      int status, int count, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: StringConstant.fontName,
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDropdown(GetCompanyProvider companyProvider, context) {
    return DropdownButton<CompanyEntity>(
      value: companyProvider.selectedCompany,
      hint: Row(
        children: [
          Icon(
            Icons.business,
            color: Colors.grey.shade600,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'select_company'.tr(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
      dropdownColor: Colors.white,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontFamily: StringConstant.fontName,
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: ColorManager.primary),
      underline: Container(),
      isExpanded: true,
      onChanged: (CompanyEntity? newValue) {
        if (newValue != null) {
          companyProvider.setSelectedCompany(newValue);
          Provider.of<GetBrandProvider>(context, listen: false)
              .getAllBrandsWidget(companyId: newValue.id);
        }
      },
      items: companyProvider.allCompanies.map<DropdownMenuItem<CompanyEntity>>(
            (CompanyEntity company) {
          return DropdownMenuItem<CompanyEntity>(
            value: company,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    company.companyName,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: StringConstant.fontName,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
      selectedItemBuilder: (BuildContext context) {
        return companyProvider.allCompanies
            .map<Widget>((CompanyEntity company) {
          return Row(
            children: [
              Icon(
                Icons.business,
                color: ColorManager.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  company.companyName,
                  style: TextStyle(
                    color: ColorManager.primary,
                    fontFamily: StringConstant.fontName,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }).toList();
      },
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: widget.byStatus.isEmpty ? null : widget.byStatus,
      hint: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: Colors.grey.shade600,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'brands_filter'.tr(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
      dropdownColor: Colors.white,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontFamily: StringConstant.fontName,
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: ColorManager.primary),
      underline: Container(),
      isExpanded: true,
      onChanged: (String? newValue) {
                  if (newValue != null) {
            widget.onFilterChanged(newValue);
          }
      },
      items: [
        DropdownMenuItem(
          value: StringConstant.inEgypt,
          child: Row(
            children: [
              Icon(
                Icons.flag,
                color: Colors.green.shade600,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'in_egypt'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: StringConstant.fontName,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: StringConstant.outsideEgypt,
          child: Row(
            children: [
              Icon(
                Icons.public,
                color: Colors.orange.shade600,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'out_egypt'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: StringConstant.fontName,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
      selectedItemBuilder: (BuildContext context) {
        final items = [
          {
            'value': StringConstant.inEgypt,
            'text': 'in_egypt'.tr(),
            'icon': Icons.flag,
            'color': Colors.green.shade600
          },
          {
            'value': StringConstant.outsideEgypt,
            'text': 'out_egypt'.tr(),
            'icon': Icons.public,
            'color': Colors.orange.shade600
          },
        ];

        return items.map<Widget>((item) {
          return Row(
            children: [
              Icon(
                Icons.filter_list,
                color: ColorManager.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['text'] as String,
                  style: TextStyle(
                    color: ColorManager.primary,
                    fontFamily: StringConstant.fontName,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }).toList();
      },
    );
  }

  bool _filterBrands(BrandEntity brand, String tab) {
    final isMark = tab == 'marks'.tr();
    final isInEgypt = brand.country == 0;
    if (brand.markOrModel != (isMark ? 0 : 1)) return false;

    if (widget.byStatus == StringConstant.accept) {
      return brand.currentStatus == 2;
    } else if (widget.byStatus == StringConstant.reject) {
      return brand.currentStatus == 3;
    } else if (widget.byStatus == StringConstant.inEgypt) {
      return isInEgypt;
    } else if (widget.byStatus == StringConstant.outsideEgypt) {
      return !isInEgypt;
    } else if (widget.byStatus == StringConstant.allStatus || widget.byStatus == "") {
      return true;
    }
    return false;
  }

  // Dynamic TabContent with calculated height based on content
  Widget _buildDynamicTabContent(GetBrandProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Helper function for spacing calculation
    double getSpacing(double screenWidth) {
      if (screenWidth > 1800) {
        return 24;
      } else if (screenWidth > 1440) {
        return 20;
      } else if (screenWidth > 1200) {
        return 16;
      } else {
        return 12;
      }
    }
    
    // Calculate dynamic height based on content
    double calculateContentHeight() {
      int contentCount = 0;
      
      // Get count based on current tab
      if (tabController.index == 0) {
        // Marks tab
        contentCount = provider.allBrands.where((brand) => 
          _filterBrands(brand, 'marks'.tr())).length;
      } else if (tabController.index == 1) {
        // Models tab  
        contentCount = provider.allBrands.where((brand) => 
          _filterBrands(brand, 'models'.tr())).length;
      } else {
        // Issues tab
        final issuesProvider = Provider.of<GetIssuesProvider>(context, listen: false);
        contentCount = issuesProvider.allIssues.length;
      }

      // Return minimum height if no content
      if (contentCount == 0) {
        return screenHeight * 0.3;
      }

      // Calculate rows needed based on screen width (matching SpGrid logic)
      int itemsPerRow;
      if (screenWidth > 1440) {
        itemsPerRow = 4; // xl: 3 means 4 items per row
      } else if (screenWidth > 1024) {
        itemsPerRow = 3; // lg: 4 means 3 items per row  
      } else if (screenWidth > 768) {
        itemsPerRow = 2; // md: 6 means 2 items per row
      } else {
        itemsPerRow = 1; // xs & sm: 12 means 1 item per row
      }

      int rows = (contentCount / itemsPerRow).ceil();
      double cardHeight = screenWidth <= 768 ? 320.0 : 180.0;
      double spacing = getSpacing(screenWidth);
      double headerHeight = 100.0; // For section header
      double paddingVertical = 20.0; // Top and bottom padding
      
      // Calculate base height
      double baseHeight = headerHeight + paddingVertical + 
                         (rows * cardHeight) + 
                         ((rows - 1) * spacing);
      
      // Dynamic constraints based on content amount
      double minHeight, maxHeight;
      
      if (contentCount <= 4) {
        // Few items - allow more space
        minHeight = screenHeight * 0.5;
        maxHeight = screenHeight * 0.8;
      } else if (contentCount <= 12) {
        // Medium amount - balanced space
        minHeight = screenHeight * 0.4;
        maxHeight = screenHeight * 0.7;
      } else {
        // Many items - compact space
        minHeight = screenHeight * 0.3;
        maxHeight = screenHeight * 0.6;
      }
      
      // Apply constraints but prefer calculated height
      return baseHeight.clamp(minHeight, maxHeight);
    }

    return Container(
      height: calculateContentHeight(),
      child: TabBarView(
        controller: tabController,
        children: provider.allBrands.isEmpty
            ? List.generate(3, (_) => _WebNoDataView())
            : [
          _buildTabContent(provider.allBrands, 'marks'.tr(), 0),
          _buildTabContent(provider.allBrands, 'models'.tr(), 1),
          _buildIssuesContent(context),
        ],
      ),
    );
  }

  // Latest updates section for web view (similar to mobile)
  Widget _buildLatestUpdatesSection(GetBrandProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isLargeScreen ? 24 : (isTablet ? 20 : 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: ColorManager.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "latest_trademarks".tr(),
                style: TextStyle(
                  color: ColorManager.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: isLargeScreen ? 20 : (isTablet ? 18 : 16),
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Latest updates content
          Container(
            constraints: BoxConstraints(
              maxHeight: isLargeScreen ? 400 : (isTablet ? 350 : 300),
            ),
            child: WebBrandUpdatesList(
              brands: provider.allBrandUpdates,
              allBrands: provider.allBrands,
              screenWidth: screenWidth,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebDownloadButton(BuildContext context, bool isLargeScreen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: () => launch(
          "${ApiConstant.baseUrl}pdfAll/${globalAccountData.getId()}?download=pdf",
        ),
        icon: Icon(
          Icons.download,
          color: Colors.white,
          size: isLargeScreen ? 20 : 18,
        ),
        label: Text(
          "download_full_pdf".tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: isLargeScreen ? 16 : 14,
            fontWeight: FontWeight.w600,
            fontFamily: StringConstant.fontName,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 32 : 24,
            vertical: isLargeScreen ? 16 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: ColorManager.primary.withOpacity(0.3),
        ),
      ),
    );
  }
}

// Improved Brand Data View with better scrolling and responsive grid
class ImprovedBrandDataView extends StatelessWidget {
  final List<BrandEntity> brands;
  final String tabType;
  final ScrollController listScrollController;
  final bool isLoadingMore;

  const ImprovedBrandDataView({
    required this.brands,
    required this.tabType,
    required this.listScrollController,
    required this.isLoadingMore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return CustomScrollView(
      controller: listScrollController,
      slivers: [
        // Enhanced Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tabType == 'marks'.tr()
                          ? 'العلامات التجارية'
                          : tabType == 'models'.tr()
                          ? 'النماذج الصناعية'
                          : tabType,
                      style: TextStyle(
                        fontSize: screenWidth > 1200 ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.primary,
                        fontFamily: StringConstant.fontName,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'استعراض شامل للبيانات المحدثة',
                      style: TextStyle(
                        fontSize: screenWidth > 1200 ? 14 : 12,
                        color: Colors.grey.shade600,
                        fontFamily: StringConstant.fontName,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.list, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'إجمالي: ${Provider.of<GetBrandProvider>(context,listen: false).totalMarks}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth > 1200 ? 14 : 12,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Responsive Brands Grid as Sliver
        SliverToBoxAdapter(
          child: Container(
            color: Colors.grey.shade50,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth > 1200 ? 20 : 16,
              vertical: 10,
            ),
            child: SpGrid(
              width: MediaQuery.of(context).size.width -
                  (screenWidth > 1200 ? 40 : 32),
              gridSize: SpGridSize(
                xs: 0,
                // موبايل صغير
                sm: 480,
                // موبايل كبير
                md: 768,
                // تابلت صغير
                lg: 1024,
                // تابلت كبير / لابتوب صغير
                xl: 1440, // شاشة كبيرة
              ),
              spacing: _getSpacing(screenWidth),
              runSpacing: _getSpacing(screenWidth),
              children: [
                // إضافة عناصر العلامات التجارية مع تخطيط متقدم
                ...brands.asMap().entries.map((entry) {
                  final index = entry.key;
                  final brand = entry.value;

                  return SpGridItem(
                    // تخطيط responsive تنازلي: 4 ← 3 ← 2 ← 1
                    xs: 12,
                    // 1 عنصر للموبايل الصغير (< 480px)
                    sm: 12,
                    // 1 عنصر للموبايل الكبير (480-768px)
                    md: 6,
                    // 2 عنصر للتابلت الصغير (768-1024px)
                    lg: 4,
                    // 3 عناصر للتابلت الكبير (1024-1440px)
                    xl: 3,
                    // 4 عناصر للشاشات الكبيرة (> 1440px)

                    // إضافة ترتيب مخصص للشاشات المختلفة
                    order: SpOrder(
                      xs: index,
                      // ترتيب طبيعي للموبايل
                      sm: index,
                      // ترتيب طبيعي للموبايل الكبير
                      md: index,
                      // ترتيب طبيعي للتابلت
                      lg: index,
                      // ترتيب طبيعي للابتوب
                      xl: index, // ترتيب طبيعي للشاشة الكبيرة
                    ),

                    child: ResponsiveBrandCard(
                      brand: brand,
                      isLargeScreen: screenWidth > 1200,
                      screenWidth: screenWidth, // إضافة عرض الشاشة للكارد
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BranDetails(brandId: brand.id),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),

        // عنصر التحميل كـ Sliver منفصل
        if (isLoadingMore)
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(screenWidth > 1200 ? 24 : 20),
              color: Colors.grey.shade50,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingWidget(),
                    const SizedBox(height: 12),
                    Text(
                      'جاري تحميل المزيد...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontFamily: StringConstant.fontName,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // إضافة مساحة إضافية في النهاية لضمان عمل pagination بشكل صحيح
        SliverToBoxAdapter(
          child: Container(
            height: 50,
            // مساحة إضافية لضمان إمكانية التمرير والوصول لنهاية القائمة
            color: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  double _getSpacing(double screenWidth) {
    if (screenWidth > 1800) {
      return 24;
    } else if (screenWidth > 1440) {
      return 20;
    } else if (screenWidth > 1200) {
      return 16;
    } else {
      return 12;
    }
  }
}

// Responsive Brand Card with full image and API status
class ResponsiveBrandCard extends StatelessWidget {
  final BrandEntity brand;
  final bool isLargeScreen;
  final double screenWidth;
  final VoidCallback onTap;

  const ResponsiveBrandCard({
    required this.brand,
    required this.isLargeScreen,
    required this.screenWidth,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final status = brand.currentStatus;
    final statusColor = BrandStatusHelper.getStatusColor(status);
    final statusText = brand.state;
    final statusLightColor = BrandStatusHelper.getStatusLightColor(status);

    final shouldUseVerticalLayout = screenWidth <= 768;

    double cardHeight;
    if (shouldUseVerticalLayout) {
      cardHeight = screenWidth <= 480 ? 320.0 : 300.0;
    } else {
      if (screenWidth > 1440) {
        cardHeight = 180.0;
      } else if (screenWidth > 1024) {
        cardHeight = 200.0;
      } else {
        cardHeight = 220.0;
      }
    }

    ImagesModel? mainImage;
    try {
      if (brand.images.isNotEmpty) {
        final imagesWithoutCondition = brand.images
            .whereType<ImagesModel>()
            .where((img) => img.conditionId == null)
            .toList();

        if (imagesWithoutCondition.isNotEmpty) {
          mainImage = imagesWithoutCondition.first;
        } else {
          final firstImage = brand.images.first;
          if (firstImage is ImagesModel) {
            mainImage = firstImage;
          }
        }
      }
    } catch (e) {
      print('Error processing brand images: $e');
      mainImage = null;
    }

    return Container(
      height: cardHeight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: statusColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: shouldUseVerticalLayout
              ? _buildVerticalLayout(mainImage, statusColor, statusLightColor,
              statusText, screenWidth)
              : _buildHorizontalLayout(mainImage, statusColor, statusLightColor,
              statusText, screenWidth),
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(ImagesModel? image, Color statusColor,
      Color statusLightColor, String statusText, double screenWidth) {
    final imageFlexRatio = screenWidth > 1600 ? 4 : 5;
    final contentFlexRatio = screenWidth > 1600 ? 8 : 7;

    return Row(
      children: [
        Expanded(
          flex: imageFlexRatio,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: _buildFullSizeImage(image, statusColor, statusLightColor),
          ),
        ),
        Expanded(
          flex: contentFlexRatio,
          child: Container(
            height: double.infinity,
            padding: EdgeInsets.all(
                screenWidth > 1600 ? 18 : (screenWidth > 1200 ? 16 : 12)),
            child:
            _buildBrandDetails(statusColor, statusText, screenWidth, false),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(ImagesModel? image, Color statusColor,
      Color statusLightColor, String statusText, double screenWidth) {
    final imageFlexRatio = screenWidth <= 480 ? 3 : 3;
    final contentFlexRatio = screenWidth <= 480 ? 2 : 2;

    return Column(
      children: [
        Expanded(
          flex: imageFlexRatio,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: _buildFullSizeImage(image, statusColor, statusLightColor),
          ),
        ),
        Expanded(
          flex: contentFlexRatio,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth > 600 ? 14 : 10),
            child:
            _buildBrandDetails(statusColor, statusText, screenWidth, true),
          ),
        ),
      ],
    );
  }

  Widget _buildFullSizeImage(
      ImagesModel? image, Color statusColor, Color statusLightColor) {
    if (image != null && image.image.isNotEmpty) {
      String imageUrl = ApiConstant.imagePath + image.image;

      return Container(
        width: double.infinity,
        height: double.infinity,
        child: cachedImage(
          imageUrl,
          fit: BoxFit.cover,
          placeHolderFit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            statusLightColor,
            statusColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image_not_supported_outlined,
              color: statusColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لا توجد صورة',
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandDetails(Color statusColor, String statusText,
      double screenWidth, bool isVertical) {
    // تحسين أحجام الخط بناءً على عرض الشاشة وطول النص
    double fontSize;
    double smallFontSize;

    if (screenWidth > 1440) {
      fontSize = 13.0;
      smallFontSize = 11.0;
    } else if (screenWidth > 1024) {
      fontSize = 14.0;
      smallFontSize = 12.0;
    } else if (screenWidth > 768) {
      fontSize = 15.0;
      smallFontSize = 13.0;
    } else {
      fontSize = 16.0;
      smallFontSize = 14.0;
    }

    // تحديد ما إذا كان النص طويل ويحتاج مساحة أكثر
    final isLongStatusText = statusText.length > 12; // تقليل الحد للنصوص العربية
    final shouldShowIndicators = (!isVertical || screenWidth > 400) &&
        !(screenWidth > 1440 && !isVertical && isLongStatusText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isVertical
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.spaceBetween,
      children: [
        // قسم اسم العلامة ورقمها
        Flexible(
          flex: isVertical ? 2 : 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم العلامة
              Text(
                brand.brandName ?? 'اسم غير محدد',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: StringConstant.fontName,
                  height: 1.2,
                ),
                maxLines: isVertical ? 2 : (screenWidth > 1600 ? 1 : 2),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // رقم العلامة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200, width: 0.5),
                ),
                child: Text(
                  '#${brand.brandNumber ?? 'غير محدد'}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: smallFontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
              ),
            ],
          ),
        ),

        // مؤشرات البلد والنوع - مع إدارة أفضل للمساحة
        if (shouldShowIndicators) ...[
          SizedBox(height: isVertical ? 6 : 8),
          Flexible(
            flex: 1,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _buildIndicator(
                  icon: brand.country == 0 ? Icons.flag : Icons.public,
                  color: brand.country == 0 ? Colors.green : Colors.orange,
                  text: brand.country == 0 ? 'مصر' : 'خارجي',
                  fontSize: smallFontSize,
                ),
                _buildIndicator(
                  icon: brand.markOrModel == 0
                      ? Icons.verified
                      : Icons.precision_manufacturing,
                  color: brand.markOrModel == 0 ? Colors.purple : Colors.teal,
                  text: brand.markOrModel == 0 ? 'علامة' : 'نموذج',
                  fontSize: smallFontSize,
                ),
              ],
            ),
          ),
        ],

        // مؤشر الحالة - مع تحسين للنصوص الطويلة
        SizedBox(height: isVertical ? 6 : 8),
        Flexible(
          flex: isLongStatusText ? 3 : 2,
          child: _buildStatusIndicator(
            statusText: statusText,
            statusColor: statusColor,
            fontSize: smallFontSize,
            isCompact: !isLongStatusText && (isVertical || screenWidth > 1440),
            isVertical: isVertical,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator({
    required IconData icon,
    required Color color,
    required String text,
    required double fontSize,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: fontSize + 1,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator({
    required String statusText,
    required Color statusColor,
    required double fontSize,
    required bool isCompact,
    required bool isVertical,
  }) {
    // تحسين منطق تحديد عدد السطور بناءً على طول النص ونوع التخطيط
    int maxLines;
    if (statusText.length > 25) {
      maxLines = isVertical ? 3 : 2; // نصوص طويلة جداً
    } else if (statusText.length > 15) {
      maxLines = isVertical ? 2 : 2; // نصوص متوسطة الطول مثل "تحت الفحص الفني"
    } else if (statusText.length > 8) {
      maxLines = 2; // نصوص قصيرة نسبياً
    } else {
      maxLines = 1; // نصوص قصيرة
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 8, // زيادة المسافة الجانبية
        vertical: maxLines > 1 ? 10 : 8, // زيادة المسافة العمودية
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // تغيير المحاذاة للوسط
        children: [
          // أيقونة الحالة
          Container(
            padding: const EdgeInsets.all(3), // زيادة padding الأيقونة
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.info_outline,
              size: fontSize + 2, // زيادة حجم الأيقونة قليلاً
              color: statusColor,
            ),
          ),
          const SizedBox(width: 8), // زيادة المسافة بين الأيقونة والنص

          // نص الحالة مع تحسين للنصوص الطويلة
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600, // تقليل سماكة الخط قليلاً
                fontFamily: StringConstant.fontName,
                height: 1.4, // تحسين المسافة بين السطور
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusFromAPI() {
    if (brand.newCurrentStatus.isNotEmpty) {
      return brand.newCurrentStatus;
    }
    return BrandStatusHelper.getStatusText(brand.currentStatus);
  }
}

class _WebNoDataView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Lottie.asset(ImagesConstants.noData,
                fit: BoxFit.contain, height: 200),
            Text(
              'no_data'.tr(),
              style: TextStyle(
                color: ColorManager.primary,
                fontWeight: FontWeight.w600,
                fontSize: 24,
                fontFamily: StringConstant.fontName,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Web Issues Data View with responsive grid similar to brands
class WebIssuesDataView extends StatelessWidget {
  final List<issues_entities.IssueEntity> issues;
  final ScrollController listScrollController;
  final bool isLoadingMore;

  const WebIssuesDataView({
    required this.issues,
    required this.listScrollController,
    required this.isLoadingMore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return CustomScrollView(
      controller: listScrollController,
      slivers: [
        // Enhanced Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'القضايا المسجلة',
                      style: TextStyle(
                        fontSize: screenWidth > 1200 ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.primary,
                        fontFamily: StringConstant.fontName,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'عرض جميع القضايا المتعلقة بالعلامات التجارية',
                      style: TextStyle(
                        fontSize: screenWidth > 1200 ? 14 : 12,
                        color: Colors.grey.shade600,
                        fontFamily: StringConstant.fontName,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gavel, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'إجمالي: ${issues.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth > 1200 ? 14 : 12,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Responsive Issues Grid as Sliver
        SliverToBoxAdapter(
          child: Container(
            color: Colors.grey.shade50,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth > 1200 ? 20 : 16,
              vertical: 10,
            ),
            child: SpGrid(
              width: MediaQuery.of(context).size.width - (screenWidth > 1200 ? 40 : 32),
              gridSize: SpGridSize(
                xs: 0,
                sm: 480,
                md: 768,
                lg: 1024,
                xl: 1440,
              ),
              spacing: _getSpacing(screenWidth),
              runSpacing: _getSpacing(screenWidth),
              children: [
                ...issues.asMap().entries.map((entry) {
                  final index = entry.key;
                  final issue = entry.value;

                  return SpGridItem(
                    xs: 12,  // 1 item for small mobile
                    sm: 12,  // 1 item for large mobile
                    md: 6,   // 2 items for small tablet
                    lg: 4,   // 3 items for large tablet
                    xl: 3,   // 4 items for large screens

                    order: SpOrder(
                      xs: index,
                      sm: index,
                      md: index,
                      lg: index,
                      xl: index,
                    ),

                    child: ResponsiveIssueCard(
                      issue: issue,
                      screenWidth: screenWidth,
                      onTap: () {
                        // TODO: Navigate to issue details
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),

        // Loading indicator
        if (isLoadingMore)
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(screenWidth > 1200 ? 24 : 20),
              color: Colors.grey.shade50,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingWidget(),
                    const SizedBox(height: 12),
                    Text(
                      'جاري تحميل المزيد...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontFamily: StringConstant.fontName,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Extra space for pagination
        SliverToBoxAdapter(
          child: Container(
            height: 50,
            color: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  double _getSpacing(double screenWidth) {
    if (screenWidth > 1800) {
      return 24;
    } else if (screenWidth > 1440) {
      return 20;
    } else if (screenWidth > 1200) {
      return 16;
    } else {
      return 12;
    }
  }
}

// Responsive Issue Card for web view
class ResponsiveIssueCard extends StatelessWidget {
  final issues_entities.IssueEntity issue;
  final double screenWidth;
  final VoidCallback onTap;

  const ResponsiveIssueCard({
    required this.issue,
    required this.screenWidth,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shouldUseVerticalLayout = screenWidth <= 768;
    
    double cardHeight = shouldUseVerticalLayout ? 200.0 : 160.0;

    return Container(
      height: cardHeight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: shouldUseVerticalLayout
              ? _buildVerticalLayout()
              : _buildHorizontalLayout(),
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      children: [
        // Issue Icon
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary.withOpacity(0.1),
                  ColorManager.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.gavel,
                size: 40,
                color: ColorManager.primary,
              ),
            ),
          ),
        ),
        // Issue details
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildIssueDetails(),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      children: [
        // Issue Icon
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary.withOpacity(0.1),
                  ColorManager.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.gavel,
                size: 40,
                color: ColorManager.primary,
              ),
            ),
          ),
        ),
        // Issue details
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _buildIssueDetails(),
          ),
        ),
      ],
    );
  }

  Widget _buildIssueDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand name
        Flexible(
          flex: 2,
          child: Text(
            issue.brand.brandName,
            style: TextStyle(
              fontSize: screenWidth > 1200 ? 15 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: StringConstant.fontName,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(height: 8),

        // Issue status
        Flexible(
          flex: 1,
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  issue.refusedType,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: screenWidth > 1200 ? 13 : 12,
                    fontFamily: StringConstant.fontName,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Sessions count
        Flexible(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade400,
                  Colors.orange.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${issue.sessionsCount} جلسة',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth > 1200 ? 12 : 11,
                fontWeight: FontWeight.w600,
                fontFamily: StringConstant.fontName,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Web Brand Updates List similar to mobile but responsive
class WebBrandUpdatesList extends StatelessWidget {
  final List<dynamic> brands;
  final List<BrandEntity> allBrands;
  final double screenWidth;

  const WebBrandUpdatesList({
    required this.brands,
    required this.allBrands,
    required this.screenWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = screenWidth > 1200;
    final isMobile = screenWidth <= 768;
    
    return SpGrid(
      width: screenWidth,
      gridSize: SpGridSize(
        xs: 0,
        sm: 480,
        md: 768,
        lg: 1024,
        xl: 1440,
      ),
      spacing: _getSpacing(),
      runSpacing: _getSpacing(),
      children: [
        ...brands.asMap().entries.map((entry) {
          final index = entry.key;
          final update = entry.value;
          final brand = allBrands.isNotEmpty && index < allBrands.length 
              ? allBrands[index] 
              : null;

          if (brand == null) {
            return SpGridItem(
              xs: 12,
              sm: 12,
              md: 6,
              lg: 4,
              xl: 3,
              child: const SizedBox.shrink(),
            );
          }

          return SpGridItem(
            xs: 12,  // 1 item for small mobile
            sm: 12,  // 1 item for large mobile
            md: 6,   // 2 items for small tablet
            lg: 4,   // 3 items for large tablet
            xl: 3,   // 4 items for large screens

            child: WebBrandUpdateCard(
              brand: brand,
              update: update,
              screenWidth: screenWidth,
            ),
          );
        }).toList(),
      ],
    );
  }

  double _getSpacing() {
    if (screenWidth > 1800) {
      return 20;
    } else if (screenWidth > 1440) {
      return 16;
    } else if (screenWidth > 1200) {
      return 12;
    } else {
      return 8;
    }
  }
}

// Web Brand Update Card
class WebBrandUpdateCard extends StatelessWidget {
  final BrandEntity brand;
  final dynamic update;
  final double screenWidth;

  const WebBrandUpdateCard({
    required this.brand,
    required this.update,
    required this.screenWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = screenWidth > 1200;
    final isMobile = screenWidth <= 768;
    
    final filteredImage = brand.images.isNotEmpty
        ? brand.images.firstWhere(
            (img) => img.conditionId == null,
            orElse: () => ImagesModel(image: '', conditionId: '', type: ''),
          )
        : null;

    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BranDetails(brandId: brand.id)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: isMobile ? 120 : (isLargeScreen ? 110 : 115),
          padding: EdgeInsets.all(isMobile ? 10 : (isLargeScreen ? 14 : 12)),
          child: Row(
            children: [
              // Brand Image
              if (filteredImage != null && filteredImage.image.isNotEmpty)
                Expanded(
                  flex: isMobile ? 2 : 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: cachedImage(
                      ApiConstant.imagePath + filteredImage.image,
                      fit: BoxFit.contain,
                      placeHolderFit: BoxFit.contain,
                    ),
                  ),
                ),
              
              if (filteredImage != null && filteredImage.image.isNotEmpty)
                const SizedBox(width: 8),

              // Brand Details
              Expanded(
                flex: isMobile ? 6 : 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Name
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          brand.brandName,
                          style: TextStyle(
                            fontSize: isMobile ? 13 : (isLargeScreen ? 15 : 14),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: StringConstant.fontName,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    
                    // Brand Status
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          BrandStatusHelper.getStatusText(brand.currentStatus),
                          style: TextStyle(
                            color: BrandStatusHelper.getStatusColor(brand.currentStatus),
                            fontSize: isMobile ? 11 : (isLargeScreen ? 12 : 11),
                            fontWeight: FontWeight.w600,
                            fontFamily: StringConstant.fontName,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    
                    // Update Date
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "تحديث: ${update.date?.toString().split(' ')[0] ?? 'غير محدد'}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isMobile ? 10 : (isLargeScreen ? 11 : 10),
                            fontFamily: StringConstant.fontName,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Status Icon
              Container(
                width: isMobile ? 28 : 32,
                height: isMobile ? 28 : 32,
                decoration: BoxDecoration(
                  color: BrandStatusHelper.getStatusLightColor(brand.currentStatus),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  brand.currentStatus == 2
                      ? Icons.check_circle
                      : brand.currentStatus == 3
                      ? Icons.cancel
                      : Icons.hourglass_empty,
                  color: BrandStatusHelper.getStatusColor(brand.currentStatus),
                  size: isMobile ? 18 : 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebLoadingShimmer extends StatelessWidget {
  const WebLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header shimmer
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 250,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 150,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 200,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content shimmer
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 8,
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 160,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}