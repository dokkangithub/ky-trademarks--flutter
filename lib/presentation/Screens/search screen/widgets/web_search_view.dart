import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:simple_grid/simple_grid.dart';

import '../../../../app/RequestState/RequestState.dart';
import '../../../../core/Constant/Api_Constant.dart';
import '../../../../domain/Brand/Entities/BrandEntity.dart';
import '../../../../network/RestApi/Comman.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';
import '../../../../data/Brand/models/BrandDataModel.dart';
import '../../../Controllar/GetBrandBySearchProvider.dart';
import '../../../Controllar/Issues/SearchIssuesProvider.dart';
import '../../../../domain/Issues/Entities/IssuesEntity.dart' as issues_entities;
import '../../../../utilits/Local_User_Data.dart';
import '../../../Widget/SearchWidget/NoDataFound.dart';
import '../../brand details/BrandDetails.dart';
import '../SearchScreen.dart';

class WebSearchView extends StatefulWidget {
  final TextEditingController searchController;
  final ScrollController mainScrollController;
  final GlobalKey searchKey;
  final List<TargetFocus> targetList;
  final TutorialCoachMark? tutorialCoachMark;
  final VoidCallback onTutorialStart;
  final VoidCallback onTutorialTargetsAdd;
  final ScreenType screenType;
  final TabController searchTypeController;
  final int currentSearchType;
  final ValueChanged<int> onSearchTypeChanged;

  const WebSearchView({
    super.key,
    required this.searchController,
    required this.mainScrollController,
    required this.searchKey,
    required this.targetList,
    required this.tutorialCoachMark,
    required this.onTutorialStart,
    required this.onTutorialTargetsAdd,
    required this.screenType,
    required this.searchTypeController,
    required this.currentSearchType,
    required this.onSearchTypeChanged,
  });

  @override
  State<WebSearchView> createState() => _WebSearchViewState();
}

class _WebSearchViewState extends State<WebSearchView> {
  bool _hasSearched = false; // متغير لتتبع ما إذا كان البحث قد تم تنفيذه
  
  // Simplified responsive values for header only
  double get _containerWidth {
    switch (widget.screenType) {
      case ScreenType.desktop:
        return 1200;
      case ScreenType.largeTablet:
        return 900;
      case ScreenType.tablet:
        return 700;
      default:
        return double.infinity;
    }
  }

  double get _contentPadding {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 40;
    if (width >= 900) return 32;
    if (width >= 600) return 24;
    return 16;
  }

  @override
  void initState() {
    super.initState();
    // إضافة scroll listener للـ pagination
    widget.mainScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.mainScrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // التحقق من الوصول لنهاية الصفحة لتحميل المزيد
    if (widget.mainScrollController.position.pixels >=
        widget.mainScrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<GetBrandBySearchProvider>(context, listen: false);
      if (provider.hasMoreData && 
          !provider.isLoading &&
          widget.searchController.text.trim().isNotEmpty) {
        provider.loadMoreBrands(widget.searchController.text.trim());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Simple Clean Header
          _buildSimpleHeader(context),
          
          // Main Content - استخدام Expanded لأخذ المساحة الكاملة
          Expanded(
            child: CustomScrollView(
              controller: widget.mainScrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _buildMainContent(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: _contentPadding,
        vertical: _contentPadding * 0.6,
      ),
      child: Column(
        children: [
          // Title
          Text(
            "البحث المتقدم",
            style: TextStyle(
              fontSize: _getTitleFontSize(),
              fontWeight: FontWeight.w700,
              color: ColorManager.primary,
              fontFamily: StringConstant.fontName,
            ),
          ),
          SizedBox(height: _contentPadding * 0.6),
          
          // Search Type Tabs
          _buildSearchTypeTabs(),
          SizedBox(height: _contentPadding * 0.8),
          
          // Simple Search Field
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: _getSearchFieldWidth()),
              child: _buildSimpleSearchField(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTypeTabs() {
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TabBar(
        controller: widget.searchTypeController,
        onTap: widget.onSearchTypeChanged,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ColorManager.primary,
          boxShadow: [
            BoxShadow(
              color: ColorManager.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          fontFamily: StringConstant.fontName,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          fontFamily: StringConstant.fontName,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_center, size: 20),
                const SizedBox(width: 8),
                Text("العلامات التجارية"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gavel, size: 20),
                const SizedBox(width: 8),
                Text("القضايا"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getTitleFontSize() {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 32;
    if (width >= 900) return 28;
    if (width >= 600) return 24;
    return 22;
  }

  double _getSearchFieldWidth() {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 800;
    if (width >= 900) return 600;
    if (width >= 600) return 500;
    return double.infinity;
  }

  Widget _buildSimpleSearchField() {
    return Row(
      children: [
        // حقل البحث
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              key: widget.searchKey,
              controller: widget.searchController,
              style: TextStyle(
                fontSize: 16,
                fontFamily: StringConstant.fontName,
                color: Colors.grey.shade800,
              ),
              decoration: InputDecoration(
                hintText: widget.currentSearchType == 0 
                    ? "ابحث عن اسم العلامة التجارية..."
                    : "ابحث في القضايا...",
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                  fontFamily: StringConstant.fontName,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: ColorManager.primary,
                  size: 24,
                ),
                suffixIcon: widget.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                        onPressed: () {
                          widget.searchController.clear();
                          setState(() {
                            _hasSearched = false; // إعادة تعيين البحث عند مسح النص
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _hasSearched = false; // إعادة تعيين البحث عند مسح النص
                  }
                }); // لتحديث حالة زر البحث
              },
              onFieldSubmitted: (value) {
                // تنبيه المستخدم لاستخدام زر البحث
                if (value.trim().length >= 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'اضغط على زر البحث للحصول على النتائج',
                            style: TextStyle(
                              fontFamily: StringConstant.fontName,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: ColorManager.primary,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        
        // مسافة بين حقل البحث والزر
        const SizedBox(width: 16),
        
                  // زر البحث منفصل
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: widget.searchController.text.trim().length >= 2 ? [
                BoxShadow(
                  color: ColorManager.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : [],
            ),
            child: ElevatedButton(
              onPressed: widget.searchController.text.trim().length >= 2 ? _performSearch : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.searchController.text.trim().length >= 2 
                    ? ColorManager.primary 
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "بحث",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _performSearch() {
    if (widget.searchController.text.trim().length >= 2) {
      setState(() {
        _hasSearched = true;
      });
      
      if (widget.currentSearchType == 0) {
        // بحث العلامات التجارية
        Provider.of<GetBrandBySearchProvider>(context, listen: false)
            .getAllBrandsBySearch(keyWord: widget.searchController.text.trim());
      } else {
        // بحث القضايا
        int customerId = globalAccountData.getId() != null 
            ? int.parse(globalAccountData.getId()!) 
            : 0;
        Provider.of<SearchIssuesProvider>(context, listen: false)
            .searchIssues(
              query: widget.searchController.text.trim(),
              customerId: customerId,
            );
      }
    }
  }

  Widget _buildMainContent(BuildContext context) {
    if (widget.searchController.text.isEmpty || !_hasSearched) {
      return _buildEmptyState();
    }
    
    return widget.currentSearchType == 0
        ? _buildBrandSearchResults()
        : _buildIssueSearchResults();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: _containerWidth),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ColorManager.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 60,
                color: ColorManager.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "ابدأ البحث",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontFamily: StringConstant.fontName,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "ابحث عن العلامات التجارية باستخدام اسم العلامة أو رقم التسجيل",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontFamily: StringConstant.fontName,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSearchResults() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_contentPadding),
      child: Consumer<GetBrandBySearchProvider>(
        builder: (context, model, _) {
          if (model.state == RequestState.loading && model.allBrands.isEmpty) {
            return _buildLoadingState();
          } else if (model.state == RequestState.failed) {
            return _buildErrorState();
          } else if (model.state == RequestState.loaded || model.allBrands.isNotEmpty) {
            if (model.allBrands.isEmpty) {
              return _buildNoResultsState();
            } else {
              return _buildResultsGrid(model);
            }
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildIssueSearchResults() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_contentPadding),
      child: Consumer<SearchIssuesProvider>(
        builder: (context, model, _) {
          if (model.state == RequestState.loading && model.searchResults.isEmpty) {
            return _buildLoadingState();
          } else if (model.state == RequestState.failed) {
            return _buildErrorState();
          } else if (model.state == RequestState.loaded || model.searchResults.isNotEmpty) {
            if (model.searchResults.isEmpty) {
              return _buildNoResultsState();
            } else {
              return _buildIssueResultsGrid(model);
            }
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                "جاري البحث...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.primary,
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _getSpacing(MediaQuery.of(context).size.width) * 1.5),
        _buildShimmerGrid(),
      ],
    );
  }

  Widget _buildShimmerGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return SpGrid(
      width: double.infinity, // أخذ العرض الكامل
      gridSize: SpGridSize(
        xs: 0,       // موبايل صغير
        sm: 480,     // موبايل كبير  
        md: 768,     // تابلت صغير
        lg: 1024,    // تابلت كبير / لابتوب صغير
        xl: 1440,    // شاشة كبيرة
      ),
      spacing: _getSpacing(screenWidth),
      runSpacing: _getSpacing(screenWidth),
      children: List.generate(6, (index) {
        // تحديد الارتفاع بناءً على نوع التخطيط
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

        return SpGridItem(
          // تخطيط responsive تنازلي: 4 ← 3 ← 2 ← 1
          xs: 12,      // 1 عنصر للموبايل الصغير (< 480px)
          sm: 12,      // 1 عنصر للموبايل الكبير (480-768px)
          md: 6,       // 2 عنصر للتابلت الصغير (768-1024px)
          lg: 4,       // 3 عناصر للتابلت الكبير (1024-1440px)
          xl: 3,       // 4 عناصر للشاشات الكبيرة (> 1440px)

          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: cardHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_contentPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade600,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "حدث خطأ في البحث",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.red.shade700,
              fontFamily: StringConstant.fontName,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "يرجى المحاولة مرة أخرى أو التحقق من اتصال الإنترنت",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontFamily: StringConstant.fontName,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_contentPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          NoDataFound(),
          const SizedBox(height: 24),
          Text(
            "لا توجد نتائج",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
              fontFamily: StringConstant.fontName,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "جرب البحث بكلمات مختلفة أو تأكد من كتابة اسم العلامة التجارية بشكل صحيح",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontFamily: StringConstant.fontName,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid(GetBrandBySearchProvider model) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Advanced Responsive Results Grid using SpGrid
        SpGrid(
          width: double.infinity, // أخذ العرض الكامل
          gridSize: SpGridSize(
            xs: 0,       // موبايل صغير
            sm: 480,     // موبايل كبير  
            md: 768,     // تابلت صغير
            lg: 1024,    // تابلت كبير / لابتوب صغير
            xl: 1440,    // شاشة كبيرة
          ),
          spacing: _getSpacing(screenWidth),
          runSpacing: _getSpacing(screenWidth),
          children: [
            // إضافة عناصر نتائج البحث مع تخطيط متقدم
            ...model.allBrands.asMap().entries.map((entry) {
              final index = entry.key;
              final brand = entry.value;

              return SpGridItem(
                // تخطيط responsive تنازلي: 4 ← 3 ← 2 ← 1
                xs: 12,      // 1 عنصر للموبايل الصغير (< 480px)
                sm: 12,      // 1 عنصر للموبايل الكبير (480-768px)
                md: 6,       // 2 عنصر للتابلت الصغير (768-1024px)
                lg: 4,       // 3 عناصر للتابلت الكبير (1024-1440px)
                xl: 3,       // 4 عناصر للشاشات الكبيرة (> 1440px)

                // ترتيب طبيعي لجميع الشاشات
                order: SpOrder(
                  xs: index,
                  sm: index,
                  md: index,
                  lg: index,
                  xl: index,
                ),

                child: SearchBrandCard(
                  brand: brand,
                  isLargeScreen: screenWidth > 1200,
                  screenWidth: screenWidth,
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
        
        // مؤشر التحميل للمزيد من البيانات
        if (model.isLoading && model.allBrands.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(_contentPadding),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "جاري تحميل المزيد من النتائج...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.primary,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // مساحة إضافية في النهاية
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildIssueResultsGrid(SearchIssuesProvider model) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.gavel, color: ColorManager.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                "نتائج البحث في القضايا",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.primary,
                  fontFamily: StringConstant.fontName,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorManager.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "إجمالي: ${model.totalResults}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Issues Results Grid
        SpGrid(
          width: double.infinity,
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
            ...model.searchResults.asMap().entries.map((entry) {
              final index = entry.key;
              final issue = entry.value;

              return SpGridItem(
                xs: 12,
                sm: 12,
                md: 6,
                lg: 4,
                xl: 3,

                order: SpOrder(
                  xs: index,
                  sm: index,
                  md: index,
                  lg: index,
                  xl: index,
                ),

                child: SearchIssueCard(
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
        
        // Loading indicator for more data
        if (model.isLoading && model.searchResults.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(_contentPadding),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "جاري تحميل المزيد من النتائج...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.primary,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Extra space at the end
        const SizedBox(height: 100),
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

  Widget _buildBrandCard(
    BuildContext context,
    GetBrandBySearchProvider model,
    int index,
  ) {
    // هذه الدالة لم تعد مُستخدمة، استُبدلت بـ ResponsiveBrandCard في SpGrid
    return Container();
  }

  Widget _buildAdvancedLoadingItem(double screenWidth) {
    // تحديد الارتفاع بناءً على نوع التخطيط
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

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth > 1200 ? 28 : 24,
              height: screenWidth > 1200 ? 28 : 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
              ),
            ),
            SizedBox(height: screenWidth > 1200 ? 16 : 12),
            Text(
              "تحميل المزيد...",
              style: TextStyle(
                fontSize: screenWidth > 1200 ? 14 : 13,
                fontWeight: FontWeight.w500,
                color: ColorManager.primary,
                fontFamily: StringConstant.fontName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingItem() {
    // دالة قديمة، تم استبدالها بـ _buildAdvancedLoadingItem
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "تحميل المزيد...",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ColorManager.primary,
                fontFamily: StringConstant.fontName,
              ),
            ),
          ],
        ),
      ),
    );
  }


}

// Search Brand Card Widget for Search Results
class SearchBrandCard extends StatelessWidget {
  final BrandEntity brand;
  final bool isLargeScreen;
  final double screenWidth;
  final VoidCallback onTap;

  const SearchBrandCard({
    required this.brand,
    required this.isLargeScreen,
    required this.screenWidth,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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

    // Get main image
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
      mainImage = null;
    }

    final statusColor = _getStatusColor(brand.currentStatus);
    final statusText = convertStateBrandNumberToString(brand.currentStatus);

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
              ? _buildVerticalLayout(mainImage, statusColor, statusText)
              : _buildHorizontalLayout(mainImage, statusColor, statusText),
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(ImagesModel? image, Color statusColor, String statusText) {
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
            child: _buildImage(image, statusColor),
          ),
        ),
        Expanded(
          flex: contentFlexRatio,
          child: Container(
            height: double.infinity,
            padding: EdgeInsets.all(
                screenWidth > 1600 ? 18 : (screenWidth > 1200 ? 16 : 12)),
            child: _buildBrandDetails(statusColor, statusText, false),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(ImagesModel? image, Color statusColor, String statusText) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: _buildImage(image, statusColor),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth > 600 ? 14 : 10),
            child: _buildBrandDetails(statusColor, statusText, true),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(ImagesModel? image, Color statusColor) {
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
            statusColor.withOpacity(0.1),
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

  Widget _buildBrandDetails(Color statusColor, String statusText, bool isVertical) {
    double fontSize = screenWidth > 1440 ? 13.0 : 14.0;
    double smallFontSize = screenWidth > 1440 ? 11.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isVertical
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.spaceBetween,
      children: [
        // Brand name and number
        Flexible(
          flex: isVertical ? 2 : 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                brand.brandName ?? 'اسم غير محدد',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: StringConstant.fontName,
                  height: 1.2,
                ),
                maxLines: isVertical ? 2 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
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

        // Country and type indicators
        if (!isVertical || screenWidth > 400) ...[
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

        // Status indicator
        SizedBox(height: isVertical ? 6 : 8),
        Flexible(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    _getStatusIcon(brand.currentStatus),
                    size: smallFontSize + 2,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: smallFontSize,
                      fontWeight: FontWeight.w600,
                      fontFamily: StringConstant.fontName,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
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

  Color _getStatusColor(int status) {
    switch (status) {
      case 2:
        return Colors.green.shade600;
      case 3:
        return Colors.red.shade600;
      case 1:
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 2:
        return Icons.check_circle;
      case 3:
        return Icons.cancel;
      case 1:
        return Icons.hourglass_empty;
      default:
        return Icons.help_outline;
    }
  }
}

// Search Issue Card Widget for Issue Search Results
class SearchIssueCard extends StatelessWidget {
  final issues_entities.IssueSearchEntity issue;
  final double screenWidth;
  final VoidCallback onTap;

  const SearchIssueCard({
    required this.issue,
    required this.screenWidth,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = screenWidth > 1200;
    
    return Container(
      height: isLargeScreen ? 160 : 180,
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
              color: _getIssueTypeColor(issue.refusedType).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 16 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Issue Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getIssueTypeColor(issue.refusedType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.gavel,
                        color: _getIssueTypeColor(issue.refusedType),
                        size: isLargeScreen ? 20 : 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "قضية #${issue.id}",
                            style: TextStyle(
                              fontSize: isLargeScreen ? 16 : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: StringConstant.fontName,
                            ),
                          ),
                          Text(
                            issue.refusedType.isNotEmpty ? issue.refusedType : "نوع غير محدد",
                            style: TextStyle(
                              fontSize: isLargeScreen ? 12 : 11,
                              color: _getIssueTypeColor(issue.refusedType),
                              fontWeight: FontWeight.w600,
                              fontFamily: StringConstant.fontName,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Brand Name
                Text(
                  "العلامة: ${issue.brandName.isNotEmpty ? issue.brandName : 'غير محدد'}",
                  style: TextStyle(
                    fontSize: isLargeScreen ? 14 : 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: StringConstant.fontName,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                
                // Status and Date
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getIssueTypeColor(issue.refusedType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getIssueTypeColor(issue.refusedType).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: isLargeScreen ? 14 : 12,
                        color: _getIssueTypeColor(issue.refusedType),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        issue.createdAt.isNotEmpty 
                            ? issue.createdAt.split(' ')[0]
                            : 'غير محدد',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 12 : 11,
                          color: _getIssueTypeColor(issue.refusedType),
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Color _getIssueTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'معارضة':
      case 'opposition':
        return Colors.red.shade600;
      case 'عادي':
      case 'normal':
        return Colors.blue.shade600;
      case 'تجديد':
      case 'renewal':
        return Colors.green.shade600;
      default:
        return Colors.orange.shade600;
    }
  }
} 