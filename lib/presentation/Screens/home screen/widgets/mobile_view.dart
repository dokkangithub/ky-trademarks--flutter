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
import '../../../../domain/Issues/Entities/IssuesEntity.dart' as issues_entities;
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
import '../../../../resources/Route_Manager.dart';

class AppConstants {
  static const double headerHeight = 220.0;
  static const double cardHeight = 140.0;
  static const double cardMargin = 12.0;
  static const double paddingHorizontal = 20.0;
  static const double paddingVertical = 12.0;
  static const double borderRadius = 20.0;
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
    return getStatusColor(status).withValues(alpha: 0.1);
  }
}

// Converted to StatefulWidget to handle local state like TabController
class MobileView extends StatefulWidget {
  final String byStatus;
  final String byBrandDescription;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onBrandDescriptionFilterChanged;
  final ScrollController mainScrollController;
  final ScrollController listScrollController;
  final bool isLoadingMore;

  const MobileView({
    required this.byStatus,
    required this.byBrandDescription,
    required this.onFilterChanged,
    required this.onBrandDescriptionFilterChanged,
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

  // Get unique brand descriptions from all brands
  static List<String> _getUniqueBrandDescriptions(List<brand_entity.BrandEntity> brands) {
    final descriptions = brands
        .map((brand) => _cleanBrandDescription(brand.brandDescription))
        .where((desc) => desc.isNotEmpty)
        .toSet()
        .toList();
    
    // Add "الكل" option at the beginning
    descriptions.insert(0, "");
    return descriptions;
  }

  // Helper function to clean HTML tags and escape characters from brand description
  static String _cleanBrandDescription(String text) {
    if (text.isEmpty) return text;
    
    // Replace HTML tags with space (to preserve word separation)
    String cleaned = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
    
    // Replace escape characters with space
    cleaned = cleaned.replaceAll(RegExp(r'\\r\\n|\\n|\\r|\r\n|\n|\r'), ' ');
    
    // Remove extra whitespaces and trim
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.mainScrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header with new design
          MobileHeader(
            tabController: _tabController,
            byStatus: widget.byStatus,
            byBrandDescription: widget.byBrandDescription,
            onFilterChanged: widget.onFilterChanged,
            onBrandDescriptionFilterChanged: widget.onBrandDescriptionFilterChanged,
          ),
          
          // Enhanced latest updates section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorManager.anotherTabBackGround,
                  Colors.grey.shade50,
                ],
              ),
            ),
            padding: const EdgeInsets.only(
                top: 20, left: AppConstants.paddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: ColorManager.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          fontFamily: StringConstant.fontName),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
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
  final String byBrandDescription;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onBrandDescriptionFilterChanged;

  const MobileHeader({
    required this.tabController,
    required this.byStatus,
    required this.byBrandDescription,
    required this.onFilterChanged,
    required this.onBrandDescriptionFilterChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final companyProvider = Provider.of<GetCompanyProvider>(context);

    return Stack(
      children: [
        // Enhanced Background Gradient
        Container(
          height: AppConstants.headerHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorManager.primaryByOpacity.withValues(alpha: 0.95),
                ColorManager.primary,
                ColorManager.primary.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: ColorManager.primary.withValues(alpha: 0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        // Content
        Column(
          children: [
            const SizedBox(height: 15),
            MobileHeaderContent(),
            const SizedBox(height: 10),
            MobileActionRows(),
            const SizedBox(height: 15),
            // Enhanced Tabs and Filters
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingHorizontal,
              ),
              child: Column(
                children: [
                  // Enhanced TabBar with modern design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: tabController,
                      labelColor: ColorManager.primary,
                      unselectedLabelColor: Colors.grey.shade600,
                      indicatorColor: ColorManager.primary,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: TextStyle(
                        fontFamily: StringConstant.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontFamily: StringConstant.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      tabs: [
                        Tab(child: Text('marks'.tr())),
                        Tab(child: Text('models'.tr())),
                        Tab(child: Text('issues'.tr())),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Enhanced dropdown filters
                  Row(
                    children: [
                      Expanded(child: _buildEnhancedCompanyDropdown(context, companyProvider)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildEnhancedFilterDropdown(context)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Brand description filter
                  _buildBrandDescriptionFilterDropdown(context),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // Enhanced TabBarView container
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingHorizontal,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: AnimatedBuilder(
                    animation: tabController.animation!,
                    builder: (context, child) {
                      return IndexedStack(
                        index: tabController.index,
                        children: [
                          _buildBrandsContent(context, ContentType.brands),
                          _buildBrandsContent(context, ContentType.models),
                          _buildIssuesContent(context),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Enhanced Company Dropdown
  Widget _buildEnhancedCompanyDropdown(BuildContext context, GetCompanyProvider companyProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: companyProvider.state == RequestState.loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : DropdownButton<company_entity.CompanyEntity>(
              value: companyProvider.selectedCompany,
              hint: Row(
                children: [
                  Icon(Icons.business, size: 16, color: ColorManager.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'select_company'.tr(), 
                      style: TextStyle(
                        color: ColorManager.primary, 
                        fontFamily: StringConstant.fontName,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              dropdownColor: Colors.white,
              style: TextStyle(color: ColorManager.primary, fontFamily: StringConstant.fontName),
              icon: Icon(Icons.keyboard_arrow_down, color: ColorManager.primary),
              underline: Container(),
              isExpanded: true,
              onChanged: (company_entity.CompanyEntity? newValue) {
                if (newValue != null) {
                  companyProvider.setSelectedCompany(newValue);
                  Provider.of<GetBrandProvider>(context, listen: false).getAllBrandsWidget(companyId: newValue.id);
                }
              },
              items: companyProvider.allCompanies.map<DropdownMenuItem<company_entity.CompanyEntity>>((company_entity.CompanyEntity company) {
                return DropdownMenuItem<company_entity.CompanyEntity>(
                  value: company, 
                  child: Text(company.companyName, overflow: TextOverflow.ellipsis)
                );
              }).toList(),
            ),
    );
  }

  // Enhanced Filter Dropdown
  Widget _buildEnhancedFilterDropdown(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButton<String>(
        value: byStatus.isEmpty ? null : byStatus,
              hint: Row(
        children: [
          Icon(Icons.location_on, size: 16, color: ColorManager.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'اختر الموقع', 
              style: TextStyle(
                color: ColorManager.primary, 
                fontFamily: StringConstant.fontName,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
        dropdownColor: Colors.white,
        style: TextStyle(color: ColorManager.primary, fontFamily: StringConstant.fontName),
        icon: Icon(Icons.keyboard_arrow_down, color: ColorManager.primary),
        underline: Container(),
        isExpanded: true,
        onChanged: (String? newValue) {
          if (newValue != null) onFilterChanged(newValue);
        },
        items: [
          DropdownMenuItem(
            value: "",
            child: Row(
              children: [
                Icon(Icons.all_inclusive, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text('الكل', style: TextStyle(fontFamily: StringConstant.fontName)),
              ],
            ),
          ),
          DropdownMenuItem(
            value: StringConstant.inEgypt,
            child: Row(
              children: [
                Icon(Icons.flag, size: 16, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text('in_egypt'.tr(), style: TextStyle(fontFamily: StringConstant.fontName)),
              ],
            ),
          ),
          DropdownMenuItem(
            value: StringConstant.outsideEgypt,
            child: Row(
              children: [
                Icon(Icons.public, size: 16, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text('out_egypt'.tr(), style: TextStyle(fontFamily: StringConstant.fontName)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Brand description filter dropdown
  Widget _buildBrandDescriptionFilterDropdown(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButton<String>(
        value: byBrandDescription.isEmpty ? null : byBrandDescription,
        hint: Row(
          children: [
            Icon(Icons.description, size: 16, color: ColorManager.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'اختر الوصف', 
                style: TextStyle(
                  color: ColorManager.primary, 
                  fontFamily: StringConstant.fontName,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        dropdownColor: Colors.white,
        style: TextStyle(color: ColorManager.primary, fontFamily: StringConstant.fontName),
        icon: Icon(Icons.keyboard_arrow_down, color: ColorManager.primary),
        underline: Container(),
        isExpanded: true,
        onChanged: (String? newValue) {
          if (newValue != null) onBrandDescriptionFilterChanged(newValue);
        },
                 items: _MobileViewState._getUniqueBrandDescriptions(Provider.of<GetBrandProvider>(context).allBrands).map<DropdownMenuItem<String>>((String description) {
           return DropdownMenuItem<String>(
             value: description,
             child: Row(
               children: [
                 Icon(
                   description.isEmpty ? Icons.all_inclusive : Icons.description_outlined, 
                   size: 16, 
                   color: description.isEmpty ? Colors.blue.shade600 : Colors.purple.shade600
                 ),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Text(
                     description.isEmpty ? 'الكل' : description, 
                     style: TextStyle(fontFamily: StringConstant.fontName),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
               ],
             ),
           );
         }).toList(),
      ),
    );
  }

  // Builds content for Brands and Models tabs
  Widget _buildBrandsContent(BuildContext context, ContentType type) {
    return Consumer<GetBrandProvider>(
      builder: (context, provider, _) {
        if (provider.state == RequestState.loading) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final filteredData = provider.allBrands.where((brand) => _filterBrands(brand, type)).toList();

        if (filteredData.isEmpty) {
          return _NoDataView();
        }

        return Column(
          children: [
            // Filtered count header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    type == ContentType.brands ? 'العلامات التجارية' : 'النماذج الصناعية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.primary,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColorManager.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.list, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'المعروض: ${filteredData.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
            // Content
            MobileListContent(brands: filteredData),
          ],
        );
      },
    );
  }

  // Enhanced Issues content with card design similar to brands
  Widget _buildIssuesContent(BuildContext context) {
    return Consumer2<GetIssuesProvider, GetIssuesSummaryProvider>(
      builder: (context, issuesProvider, summaryProvider, _) {
        if (issuesProvider.state == RequestState.loading) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (issuesProvider.allIssues.isEmpty) {
          return _NoDataView(message: 'no_issues'.tr());
        }

        return Column(
          children: [
            // Issues count header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'القضايا المسجلة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.primary,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColorManager.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gavel, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'المعروض: ${issuesProvider.allIssues.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
            // Issues content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
                             child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // List of issues with enhanced card design
                     ListView.separated(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       itemCount: issuesProvider.allIssues.length,
                       separatorBuilder: (context, index) => const SizedBox(height: 12),
                       itemBuilder: (context, index) {
                         final issue = issuesProvider.allIssues[index];
                         return _buildEnhancedIssueCard(context, issue, index);
                       },
                     ),
                     const SizedBox(height: 20),
                   ],
                 ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Enhanced Issue Card that looks similar to Brand cards
  Widget _buildEnhancedIssueCard(BuildContext context, issues_entities.IssueEntity issue, int index) {
    return Card(
      elevation: 8,
      shadowColor: ColorManager.primary.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          onTap: () {
            // Navigate to issue details screen
                                    Navigator.pushNamed(
                          context,
                          Routes.issueDetailsRoute,
              arguments: {
                'issueId': issue.id,
                'customerId': issue.customer.id,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Issue Icon/Image (similar to brand image)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorManager.primary.withValues(alpha: 0.1),
                        ColorManager.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorManager.primary.withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    Icons.gavel,
                    size: 35,
                    color: ColorManager.primary,
                  ),
                ),
                const SizedBox(width: 16),
                // Issue details (similar to brand details)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Issue title/brand name
                      Text(
                        issue.brand.brandName,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 16, 
                          fontWeight: FontWeight.w600,
                          fontFamily: StringConstant.fontName,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                                             const SizedBox(height: 6),
                       // Issue status only
                       Row(
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
                               style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                 color: Colors.grey.withValues(alpha: 0.8), 
                                 fontSize: 14,
                                 fontFamily: StringConstant.fontName
                               ),
                               overflow: TextOverflow.ellipsis,
                               maxLines: 1,
                             ),
                           ),
                         ],
                       ),
                      const SizedBox(height: 8),
                      // Status container (similar to brand status)
                      Container(
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
                          '${issue.sessionsCount} ${'sessions'.tr()}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: StringConstant.fontName,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        spreadRadius: 2,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _filterBrands(brand_entity.BrandEntity brand, ContentType type) {
    final isMark = type == ContentType.brands;
    if (brand.markOrModel != (isMark ? 0 : 1)) return false;

    // Apply brand description filter first - clean both for comparison
    if (byBrandDescription.isNotEmpty) {
      final cleanedBrandDesc = _MobileViewState._cleanBrandDescription(brand.brandDescription);
      final cleanedFilterDesc = _MobileViewState._cleanBrandDescription(byBrandDescription);
      if (cleanedBrandDesc != cleanedFilterDesc) {
        return false;
      }
    }

    // Apply location filter
    if (byStatus == StringConstant.inEgypt) {
      return brand.country == 0;
    } else if (byStatus == StringConstant.outsideEgypt) {
      return brand.country != 0;
    } else if (byStatus == "" || byStatus.isEmpty) {
      return true; // Show all for empty filter
    }
    return true; // For empty filter (show all)
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
    return ListView.separated(
      itemCount: brands.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => EnhancedMobileBrandCard(
        brand: brands[index],
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BranDetails(brandId: brands[index].id),
          ),
        ),
      ),
    );
  }
}

// Enhanced Mobile Brand Card similar to web view design
class EnhancedMobileBrandCard extends StatelessWidget {
  final brand_entity.BrandEntity brand;
  final VoidCallback onTap;

  const EnhancedMobileBrandCard({
    required this.brand,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final status = brand.currentStatus;
    final statusColor = BrandStatusHelper.getStatusColor(status);
    final statusText = brand.state;
    final statusLightColor = BrandStatusHelper.getStatusLightColor(status);

    // Find main image
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
      height: 180,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Image Section (1/3 of width)
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: _buildMobileImage(mainImage, statusColor, statusLightColor),
                ),
              ),
              // Content Section (2/3 of width)
              Expanded(
                flex: 3,
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: _buildMobileContent(statusColor, statusText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileImage(ImagesModel? image, Color statusColor, Color statusLightColor) {
    if (image != null && image.image.isNotEmpty) {
      String imageUrl = ApiConstant.imagePath + image.image;

      return Container(
        width: double.infinity,
        height: double.infinity,
        child: cachedImage(
          imageUrl,
          fit: BoxFit.contain,
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
            statusColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_not_supported_outlined,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'لا توجد صورة',
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContent(Color statusColor, String statusText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Name and Number Section
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Brand Name
              Flexible(
                child: Text(
                  brand.brandName ?? 'اسم غير محدد',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: StringConstant.fontName,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),

              // Brand Number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.shade200, width: 0.5),
                ),
                child: Text(
                  '#${brand.brandNumber ?? 'غير محدد'}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Indicators Section
        Expanded(
          flex: 1,
          child: Center(
            child: Wrap(
              spacing: 4,
              runSpacing: 2,
              children: [
                _buildMobileIndicator(
                  icon: brand.country == 0 ? Icons.flag : Icons.public,
                  color: brand.country == 0 ? Colors.green : Colors.orange,
                  text: brand.country == 0 ? 'مصر' : 'خارجي',
                ),
                _buildMobileIndicator(
                  icon: brand.markOrModel == 0
                      ? Icons.verified
                      : Icons.precision_manufacturing,
                  color: brand.markOrModel == 0 ? Colors.purple : Colors.teal,
                  text: brand.markOrModel == 0 ? 'علامة' : 'نموذج',
                ),
              ],
            ),
          ),
        ),

        // Status Section
        Expanded(
          flex: 1,
          child: _buildMobileStatusIndicator(statusText, statusColor),
        ),
      ],
    );
  }

  Widget _buildMobileIndicator({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatusIndicator(String statusText, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.1),
            statusColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Icon(
              Icons.info_outline,
              size: 12,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: StringConstant.fontName,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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