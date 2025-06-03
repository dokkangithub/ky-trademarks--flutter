import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart' as s;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/RequestState/RequestState.dart';
import '../../../../core/Constant/Api_Constant.dart';
import '../../../../domain/Brand/Entities/BrandEntity.dart';
import '../../../../domain/Company/Entities/CompanyEntity.dart';
import '../../../../resources/ImagesConstant.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';
import '../../../../data/Brand/models/BrandDataModel.dart';
import '../../../Controllar/GetBrandProvider.dart';
import '../../../Controllar/GetCompanyProvider.dart';
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
      case 1: return 'تحت الفحص الفني';
      case 2: return 'قبول';
      case 3: return 'رفض';
      case 4: return 'تظلم';
      case 5: return 'قرار لجنه التظلمات';
      case 6: return 'مجددة';
      case 7: return 'الطعن ضد التظلم';
      case 8: return 'قبول مشترط';
      case 9: return 'تنازل';
      case 10: return 'طعن في تسجيل العلامة';
      case 11: return 'تقرير';
      case 12: return 'معارضات';
      default: return 'غير محدد';
    }
  }

  static Color getStatusColor(int status) {
    switch (status) {
      case 1: return Colors.orange.shade600;
      case 2: return Colors.green.shade600;
      case 3: return Colors.red.shade600;
      case 4: return Colors.blue.shade600;
      case 5: return Colors.purple.shade600;
      case 6: return Colors.teal.shade600;
      case 7: return Colors.indigo.shade600;
      case 8: return Colors.amber.shade600;
      case 9: return Colors.brown.shade600;
      case 10: return Colors.pink.shade600;
      case 11: return Colors.cyan.shade600;
      case 12: return Colors.deepOrange.shade600;
      default: return Colors.grey.shade600;
    }
  }

  static Color getStatusLightColor(int status) {
    return getStatusColor(status).withOpacity(0.1);
  }
}

class WebView extends StatelessWidget {
  final TabController tabController;
  final String byStatus;
  final ValueChanged<String> onFilterChanged;
  final ScrollController mainScrollController;
  final ScrollController listScrollController;
  final bool isLoadingMore;
  final Function(int)? onTabChanged;

  const WebView({
    required this.tabController,
    required this.byStatus,
    required this.onFilterChanged,
    required this.mainScrollController,
    required this.listScrollController,
    required this.isLoadingMore,
    this.onTabChanged,
    super.key,
  });

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
        controller: mainScrollController,
        slivers: [
          // Enhanced Control Panel
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(isLargeScreen ? 24 : (isTablet ? 20 : 16)),
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
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: _buildQuickStats(provider),
                  ),
                  
                  // Second Row: Responsive Layout
                  isMobile 
                      ? _buildMobileLayout(provider, companyProvider, context)
                      : (isTablet 
                          ? _buildTabletLayout(provider, companyProvider, context)
                          : _buildDesktopLayout(provider, companyProvider, context)),
                ],
              ),
            ),
          ),
          
          // Brand content area
          SliverFillRemaining(
            child: TabBarView(
              controller: tabController,
              children: provider.allBrands.isEmpty
                  ? List.generate(3, (_) => _WebNoDataView())
                  : [
                      _buildTabContent(provider.allBrands, 'marks'.tr(), 0),
                      _buildTabContent(provider.allBrands, 'models'.tr(), 1),
                      _buildRecentUpdatesTab(provider.allBrands),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<BrandEntity> allBrands, String tabType, int markOrModelFilter) {
    final filteredData = allBrands
        .where((brand) => _filterBrands(brand, tabType))
        .toList();
    
    return filteredData.isEmpty
        ? _WebNoDataView()
        : ImprovedBrandDataView(
            brands: filteredData,
            tabType: tabType,
            listScrollController: listScrollController,
            isLoadingMore: isLoadingMore,
          );
  }

  Widget _buildRecentUpdatesTab(List<BrandEntity> allBrands) {
    // نستخدم id كبديل للترتيب (الأرقام الأعلى = الأحدث)
    final recentlyUpdated = [...allBrands];
    recentlyUpdated.sort((a, b) => b.id.compareTo(a.id)); // الأحدث أولاً
    
    // أخذ آخر 50 عنصر محدث
    final recentItems = recentlyUpdated.take(50).toList();
    
    return recentItems.isEmpty
        ? _WebNoDataView()
        : ImprovedBrandDataView(
            brands: recentItems,
            tabType: 'آخر تحديث',
            listScrollController: listScrollController,
            isLoadingMore: isLoadingMore,
          );
  }

  // Desktop Layout: Horizontal arrangement
  Widget _buildDesktopLayout(GetBrandProvider provider, GetCompanyProvider companyProvider, BuildContext context) {
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
              labelStyle: TextStyle(fontSize: 14, fontFamily: StringConstant.fontName),
              tabs: [
                Tab(child: Text('علامات', style: TextStyle(fontFamily: StringConstant.fontName))),
                Tab(child: Text('نماذج', style: TextStyle(fontFamily: StringConstant.fontName))),
                Tab(child: Text('آخر تحديث', style: TextStyle(fontFamily: StringConstant.fontName))),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: companyProvider.state == RequestState.loading
                      ? const Center(child: SizedBox(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
  Widget _buildTabletLayout(GetBrandProvider provider, GetCompanyProvider companyProvider, BuildContext context) {
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
            labelStyle: TextStyle(fontSize: 15, fontFamily: StringConstant.fontName),
                          tabs: [
              Tab(child: Text('علامات', style: TextStyle(fontFamily: StringConstant.fontName))),
              Tab(child: Text('نماذج', style: TextStyle(fontFamily: StringConstant.fontName))),
              Tab(child: Text('آخر تحديث', style: TextStyle(fontFamily: StringConstant.fontName))),
                          ],
                        ),
                      ),
        
        const SizedBox(height: 16),
        
        // Filters Row
                      Row(
                        children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: companyProvider.state == RequestState.loading
                    ? const Center(child: SizedBox(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
  Widget _buildMobileLayout(GetBrandProvider provider, GetCompanyProvider companyProvider, BuildContext context) {
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
            labelStyle: TextStyle(fontSize: 12, fontFamily: StringConstant.fontName),
            tabs: [
              Tab(child: Text('علامات', style: TextStyle(fontFamily: StringConstant.fontName))),
              Tab(child: Text('نماذج', style: TextStyle(fontFamily: StringConstant.fontName))),
              Tab(child: Text('تحديث', style: TextStyle(fontFamily: StringConstant.fontName))),
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
              ? const Center(child: SizedBox(
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
      statusStats[brand.currentStatus] = (statusStats[brand.currentStatus] ?? 0) + 1;
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
        _buildEnhancedStatusIndicator(2, statusStats[2] ?? 0, "مقبولة", Colors.green, Icons.check_circle),
        _buildEnhancedStatusIndicator(1, statusStats[1] ?? 0, "تحت الفحص", Colors.orange, Icons.hourglass_empty),
        _buildEnhancedStatusIndicator(3, statusStats[3] ?? 0, "مرفوضة", Colors.red, Icons.cancel),
        if (statusStats[4] != null && statusStats[4]! > 0)
          _buildEnhancedStatusIndicator(4, statusStats[4]!, "تظلم", Colors.blue, Icons.gavel),
      ],
    );
  }

  Widget _buildDesktopStatsRow(Map<int, int> statusStats, bool isLarge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildEnhancedStatusIndicator(2, statusStats[2] ?? 0, "مقبولة", Colors.green, Icons.check_circle),
        _buildVerticalDivider(),
        _buildEnhancedStatusIndicator(1, statusStats[1] ?? 0, "تحت الفحص", Colors.orange, Icons.hourglass_empty),
        _buildVerticalDivider(),
        _buildEnhancedStatusIndicator(3, statusStats[3] ?? 0, "مرفوضة", Colors.red, Icons.cancel),
        if (statusStats[4] != null && statusStats[4]! > 0) ...[
          _buildVerticalDivider(),
          _buildEnhancedStatusIndicator(4, statusStats[4]!, "تظلم", Colors.blue, Icons.gavel),
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

  Widget _buildEnhancedStatusIndicator(int status, int count, String label, Color color, IconData icon) {
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
                                    items: companyProvider.allCompanies
                                        .map<DropdownMenuItem<CompanyEntity>>(
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
        return companyProvider.allCompanies.map<Widget>((CompanyEntity company) {
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
                              value: byStatus.isEmpty ? null : byStatus,
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
                                  onFilterChanged(newValue);
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
          {'value': StringConstant.inEgypt, 'text': 'in_egypt'.tr(), 'icon': Icons.flag, 'color': Colors.green.shade600},
          {'value': StringConstant.outsideEgypt, 'text': 'out_egypt'.tr(), 'icon': Icons.public, 'color': Colors.orange.shade600},
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
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tabType == 'marks'.tr() ? 'العلامات التجارية' :
                      tabType == 'models'.tr() ? 'النماذج الصناعية' : tabType,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        'إجمالي: ${brands.length}',
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
          // Responsive Brands Grid
          Container(
            color: Colors.grey.shade50,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth > 1200 ? 20 : 16,
              vertical: 10,
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(), // إزالة scroll منفصل
              shrinkWrap: true, // ليأخذ المساحة المطلوبة فقط
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(screenWidth), // 4 عناصر للشاشات الكبيرة
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: _getChildAspectRatio(screenWidth), // نسبة محسنة
              ),
              itemCount: brands.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == brands.length) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: Center(child: LoadingWidget()),
                  );
                }

                return ResponsiveBrandCard(
                  brand: brands[index],
                  isLargeScreen: screenWidth > 1200,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BranDetails(brandId: brands[index].id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // تحديد عدد الأعمدة حسب حجم الشاشة
  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1400) {
      return 4; // 4 عناصر للشاشات الكبيرة جداً
    } else if (screenWidth > 1200) {
      return 4; // 4 عناصر للشاشات الكبيرة
    } else if (screenWidth > 900) {
      return 3; // 3 عناصر للشاشات المتوسطة
    } else if (screenWidth > 600) {
      return 2; // عنصرين للتابلت
    } else {
      return 1; // عنصر واحد للموبايل
    }
  }
  
  // تحديد نسبة العرض للارتفاع حسب حجم الشاشة
  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth > 600) {
      // التخطيط الأفقي للشاشات الكبيرة
      if (screenWidth > 1400) {
        return 2.8; // نسبة أوسع للشاشات الكبيرة جداً مع التخطيط الأفقي
      } else if (screenWidth > 1200) {
        return 2.5; // نسبة أوسع للشاشات الكبيرة مع 4 عناصر والتخطيط الأفقي
      } else if (screenWidth > 900) {
        return 2.6; // نسبة للشاشات المتوسطة مع التخطيط الأفقي
      } else {
        return 2.8; // نسبة للتابلت مع التخطيط الأفقي
      }
    } else {
      // التخطيط العمودي للشاشات الصغيرة
      return 1.8; // نسبة مناسبة للتخطيط العمودي
    }
  }
}

// Responsive Brand Card with full image and API status
class ResponsiveBrandCard extends StatelessWidget {
  final BrandEntity brand;
  final bool isLargeScreen;
  final VoidCallback onTap;

  const ResponsiveBrandCard({
    required this.brand,
    required this.isLargeScreen,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final status = brand.currentStatus;
    final statusColor = BrandStatusHelper.getStatusColor(status);
    final statusText = _getStatusFromAPI(); // استخدام النص من الـ API
    final statusLightColor = BrandStatusHelper.getStatusLightColor(status);
    final screenWidth = MediaQuery.of(context).size.width;
    final shouldUseHorizontalLayout = screenWidth > 600; // أفقي للشاشات أكبر من 600px
    
    // Safe image handling
    ImagesModel? mainImage;
    try {
      if (brand.images.isNotEmpty) {
        final imagesWithoutCondition = brand.images.whereType<ImagesModel>().where((img) => 
          img.conditionId == null).toList();
        
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: statusColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: shouldUseHorizontalLayout 
              ? _buildHorizontalLayout(mainImage, statusColor, statusLightColor, statusText, screenWidth)
              : _buildVerticalLayout(mainImage, statusColor, statusLightColor, statusText, screenWidth),
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(ImagesModel? image, Color statusColor, Color statusLightColor, String statusText, double screenWidth) {
    // تخطيط أفقي يناسب الـ 4 عناصر في السطر
    return Row(
      children: [
        // صورة العلامة - تأخذ الجانب الأيمن
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: _buildFullSizeImage(image, statusColor, statusLightColor),
          ),
        ),
        // تفاصيل العلامة - تأخذ الجانب الأيسر
        Expanded(
          flex: 3,
          child: Container(
            height: double.infinity,
            padding: EdgeInsets.all(screenWidth > 1200 ? 12 : 8),
            child: _buildCompactBrandDetails(statusColor, statusText, screenWidth),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(ImagesModel? image, Color statusColor, Color statusLightColor, String statusText, double screenWidth) {
    // تخطيط عمودي يناسب الـ 4 عناصر في السطر
    return Column(
      children: [
        // صورة العلامة - تأخذ الجانب الأعلى
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: _buildFullSizeImage(image, statusColor, statusLightColor),
          ),
        ),
        // تفاصيل العلامة - تأخذ الجانب الأسفل
        Expanded(
          flex: 3,
          child: Container(
            height: double.infinity,
            padding: EdgeInsets.all(screenWidth > 1200 ? 12 : 8),
            child: _buildCompactBrandDetails(statusColor, statusText, screenWidth),
          ),
        ),
      ],
    );
  }

  Widget _buildFullSizeImage(ImagesModel? image, Color statusColor, Color statusLightColor) {
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
      color: statusLightColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            color: statusColor,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'لا توجد صورة',
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBrandDetails(Color statusColor, String statusText, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // اسم العلامة ورقمها
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              brand.brandName ?? 'اسم غير محدد',
              style: TextStyle(
                fontSize: screenWidth > 1200 ? 14 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: StringConstant.fontName,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '#${brand.brandNumber ?? 'غير محدد'}',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: screenWidth > 1200 ? 11 : 10,
                fontWeight: FontWeight.bold,
                fontFamily: StringConstant.fontName,
              ),
            ),
          ],
        ),
        
        // المؤشرات المضغوطة
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            // Country indicator
            _buildCompactIndicator(
              icon: brand.country == 0 ? Icons.flag : Icons.public,
              color: brand.country == 0 ? Colors.green : Colors.orange,
              fontSize: screenWidth > 1200 ? 10 : 9,
              text: brand.country == 0 ? 'مصر' : 'خارج مصر',
            ),
            // Type indicator
            _buildCompactIndicator(
              icon: brand.markOrModel == 0 ? Icons.verified : Icons.precision_manufacturing,
              color: brand.markOrModel == 0 ? Colors.purple : Colors.teal,
              fontSize: screenWidth > 1200 ? 10 : 9,
              text: brand.markOrModel == 0 ? 'علامة' : 'نموذج',
            ),
          ],
        ),
        
        // Status indicator مضغوط
        _buildCompactStatusIndicator(
          statusText: statusText,
          statusColor: statusColor,
          fontSize: screenWidth > 1200 ? 10 : 9,
        ),
      ],
    );
  }

  Widget _buildCompactIndicator({
    required IconData icon,
    required Color color,
    required double fontSize,
    String? text,
  }) {
    final darkColor = Color.lerp(color, Colors.black, 0.3) ?? color;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: fontSize + 3,
            color: darkColor,
          ),
          if (text != null) ...[
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: darkColor,
                fontWeight: FontWeight.w600,
                fontFamily: StringConstant.fontName,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactStatusIndicator({
    required String statusText,
    required Color statusColor,
    required double fontSize,
  }) {
    // اختصار النص بحكمة أكثر للتخطيط الأفقي
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: fontSize + 2,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                fontFamily: StringConstant.fontName,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusFromAPI() {
    // استخدام النص من newCurrentStatus إذا كان متوفر، وإلا استخدام الحالة الافتراضية
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Lottie.asset(ImagesConstants.noData, fit: BoxFit.contain, height: 200),
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
