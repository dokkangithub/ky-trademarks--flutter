import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../app/RequestState/RequestState.dart';
import '../../../../network/RestApi/Comman.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/ImagesConstant.dart';
import '../../../../resources/StringManager.dart';
import '../../../Controllar/GetBrandBySearchProvider.dart';
import '../../../Controllar/Issues/SearchIssuesProvider.dart';
import '../../../../domain/Issues/Entities/IssuesEntity.dart' as issues_entities;
import '../../../../utilits/Local_User_Data.dart';
import '../../../Widget/BrandWidget.dart';
import '../../../Widget/SearchWidget/NoDataFound.dart';
import '../../../Widget/SearchWidget/SearchShimmer.dart';
import '../../../Widget/loading_widget.dart';

class MobileSearchView extends StatefulWidget {
  final TextEditingController searchController;
  final ScrollController mainScrollController;
  final GlobalKey searchKey;
  final List<TargetFocus> targetList;
  final TutorialCoachMark? tutorialCoachMark;
  final VoidCallback onTutorialStart;
  final VoidCallback onTutorialTargetsAdd;
  final TabController searchTypeController;
  final int currentSearchType;
  final ValueChanged<int> onSearchTypeChanged;

  const MobileSearchView({
    super.key,
    required this.searchController,
    required this.mainScrollController,
    required this.searchKey,
    required this.targetList,
    required this.tutorialCoachMark,
    required this.onTutorialStart,
    required this.onTutorialTargetsAdd,
    required this.searchTypeController,
    required this.currentSearchType,
    required this.onSearchTypeChanged,
  });

  @override
  State<MobileSearchView> createState() => _MobileSearchViewState();
}

class _MobileSearchViewState extends State<MobileSearchView> {
  bool _hasSearched = false; // متغير لتتبع ما إذا كان البحث قد تم تنفيذه
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Enhanced Search Header
        _buildMobileSearchHeader(context),
        
        // Search Results Body
        Expanded(
          child: _buildMobileSearchBody(context),
        ),
      ],
    );
  }

  Widget _buildMobileSearchHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primaryByOpacity.withOpacity(0.9),
            ColorManager.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
          child: Column(
            children: [
              // Header Row with Title and Tutorial Button
              _buildMobileHeaderRow(context),
              const SizedBox(height: 16),
              
              // Search Type Tabs
              _buildMobileSearchTypeTabs(),
              const SizedBox(height: 20),
              
              // Enhanced Search Field
              _buildMobileSearchField(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 40),
        Text(
          "البحث المتقدم",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontFamily: StringConstant.fontName,
          ),
        ),
        _buildMobileTutorialButton(),
      ],
    );
  }

  Widget _buildMobileTutorialButton() {
    return InkWell(
      onTap: () {
        if (widget.targetList.isEmpty) {
          widget.onTutorialTargetsAdd();
        }
        widget.onTutorialStart();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Lottie.asset(
          ImagesConstants.infoW,
          height: 32,
          width: 32,
        ),
      ),
    );
  }

  Widget _buildMobileSearchTypeTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TabBar(
        controller: widget.searchTypeController,
        onTap: widget.onSearchTypeChanged,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          fontFamily: StringConstant.fontName,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          fontFamily: StringConstant.fontName,
        ),
        labelColor: ColorManager.primary,
        unselectedLabelColor: Colors.white.withOpacity(0.9),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_center, size: 18),
                const SizedBox(width: 6),
                Text("العلامات"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gavel, size: 18),
                const SizedBox(width: 6),
                Text("القضايا"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextFormField(
          key: widget.searchKey,
          style: TextStyle(
            fontFamily: StringConstant.fontName,
            color: ColorManager.accent,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          controller: widget.searchController,
          validator: validateObjects(),
          decoration: _buildSearchFieldDecoration(),
          onChanged: (val) {
            setState(() {
              if (val.isEmpty) {
                _hasSearched = false; // إعادة تعيين البحث عند مسح النص
              }
            }); // لتحديث حالة زر البحث
          },
          onFieldSubmitted: (val) {
            // تنبيه المستخدم لاستخدام زر البحث
            if (val.trim().length >= 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'اضغط على زر البحث للحصول على النتائج',
                          style: TextStyle(
                            fontFamily: StringConstant.fontName,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  InputDecoration _buildSearchFieldDecoration() {
    return InputDecoration(
      hintText: widget.currentSearchType == 0 
          ? "ابحث عن اسم العلامة التجارية (حرفين على الأقل)..."
          : "ابحث في القضايا (حرفين على الأقل)...",
      hintStyle: TextStyle(
        fontFamily: StringConstant.fontName,
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ColorManager.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          Icons.search,
          color: ColorManager.primary,
          size: 24,
        ),
      ),
      suffixIcon: widget.searchController.text.isNotEmpty
          ? IconButton(
              onPressed: () {
                widget.searchController.clear();
                setState(() {
                  _hasSearched = false; // إعادة تعيين البحث عند مسح النص
                });
              },
              icon: Icon(Icons.clear, color: Colors.grey.shade600),
            )
          : IconButton(
              onPressed: widget.searchController.text.trim().length >= 2 ? _performSearch : null,
              icon: Icon(
                Icons.search,
                color: widget.searchController.text.trim().length >= 2 
                    ? ColorManager.primary 
                    : Colors.grey.shade400,
              ),
            ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: ColorManager.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

  Widget _buildMobileSearchBody(BuildContext context) {
    if (widget.searchController.text.isEmpty || !_hasSearched) {
      return _buildEmptySearchState();
    }
    
    return widget.currentSearchType == 0
        ? _buildBrandSearchResults()
        : _buildIssueSearchResults();
  }

  Widget _buildEmptySearchState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            ColorManager.primary.withOpacity(0.02),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ColorManager.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 64,
                color: ColorManager.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "search_brands_hint".tr(),
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorManager.accent.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "type_brand_name".tr(),
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSearchResults() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            ColorManager.primary.withOpacity(0.01),
          ],
        ),
      ),
      child: SingleChildScrollView(
        controller: widget.mainScrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Consumer<GetBrandBySearchProvider>(
              builder: (context, model, _) {
                return _buildBrandSearchResultsContent(context, model);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueSearchResults() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            ColorManager.primary.withOpacity(0.01),
          ],
        ),
      ),
      child: SingleChildScrollView(
        controller: widget.mainScrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Consumer<SearchIssuesProvider>(
              builder: (context, model, _) {
                return _buildIssueSearchResultsContent(context, model);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSearchResultsContent(BuildContext context, GetBrandBySearchProvider model) {
    if (model.state == RequestState.loading) {
      return _buildLoadingState();
    } else if (model.state == RequestState.failed) {
      return _buildErrorState();
    } else if (model.state == RequestState.loaded) {
      if (model.allBrands.isEmpty) {
        return _buildNoResultsState();
      } else {
        return _buildResultsGrid(model);
      }
    }
    return Container();
  }

  Widget _buildIssueSearchResultsContent(BuildContext context, SearchIssuesProvider model) {
    if (model.state == RequestState.loading && model.searchResults.isEmpty) {
      return _buildLoadingState();
    } else if (model.state == RequestState.failed) {
      return _buildErrorState();
    } else if (model.state == RequestState.loaded) {
      if (model.searchResults.isEmpty) {
        return _buildNoResultsState();
      } else {
        return _buildIssueResultsGrid(model);
      }
    }
    return Container();
  }

  Widget _buildIssueResultsGrid(SearchIssuesProvider model) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results Counter for Issues
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.gavel,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "${model.searchResults.length} قضية",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (model.hasMoreData) ...[
                  const Spacer(),
                  Text(
                    "المزيد متاح",
                    style: TextStyle(
                      fontFamily: StringConstant.fontName,
                      color: Colors.orange.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Issues Grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              // Show loading indicator if we're at the end and there's more data
              if (index == model.searchResults.length &&
                  model.hasMoreData &&
                  model.searchResults.length >= 6) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                    ),
                  ),
                );
              }
              
              return _buildMobileIssueCard(context, model, index);
            },
            itemCount: model.searchResults.length +
                (model.hasMoreData && model.searchResults.length >= 6 ? 1 : 0),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileIssueCard(BuildContext context, SearchIssuesProvider model, int index) {
    final issue = model.searchResults[index];
    final issueColor = _getIssueTypeColor(issue.refusedType);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: issueColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to issue details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Issue Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: issueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.gavel,
                  color: issueColor,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Issue Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Issue ID and Type
                    Row(
                      children: [
                        Text(
                          "قضية #${issue.id}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: StringConstant.fontName,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: issueColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            issue.refusedType.isNotEmpty ? issue.refusedType : "غير محدد",
                            style: TextStyle(
                              fontSize: 12,
                              color: issueColor,
                              fontWeight: FontWeight.w600,
                              fontFamily: StringConstant.fontName,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Brand Name
                    Text(
                      "العلامة: ${issue.brandName.isNotEmpty ? issue.brandName : 'غير محدد'}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: StringConstant.fontName,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Date
                    Text(
                      "تاريخ الإنشاء: ${issue.createdAt.isNotEmpty ? issue.createdAt.split(' ')[0] : 'غير محدد'}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: ColorManager.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "searching".tr(),
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    color: ColorManager.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SearchShimmer(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 48),
          const SizedBox(height: 12),
          Text(
            "search_error".tr(),
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.red.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "try_again_later".tr(),
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.red.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          NoDataFound(),
          const SizedBox(height: 20),
          Text(
            "search_not_found".tr(),
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: ColorManager.accent.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "try_different_keywords".tr(),
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid(GetBrandBySearchProvider model) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results Counter
          _buildResultsCounter(model),
          const SizedBox(height: 16),
          
          // Results Grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 2.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              // Show loading indicator if we're at the end and there's more data
              if (index == model.allBrands.length &&
                  model.hasMoreData &&
                  model.allBrands.length >= 6) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
                    ),
                  ),
                );
              }
              
              return _buildMobileBrandCard(context, model, index);
            },
            itemCount: model.allBrands.length +
                (model.hasMoreData && model.allBrands.length >= 6 ? 1 : 0),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCounter(GetBrandBySearchProvider model) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorManager.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorManager.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_outlined,
            color: ColorManager.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            "${model.allBrands.length} ${"results_found".tr()}",
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: ColorManager.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (model.hasMoreData) ...[
            const Spacer(),
            Text(
              "more_available".tr(),
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                color: ColorManager.primary.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileBrandCard(BuildContext context, GetBrandBySearchProvider model, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: ColorManager.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: BrandWidget(
        context: context,
        index: index,
        model: model,
        isSearch: true,
      ),
    );
  }


} 