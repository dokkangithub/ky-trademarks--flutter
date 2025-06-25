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
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Simple Header
              _buildMobileHeaderRow(context),
              const SizedBox(height: 20),
              
              // Simple Search Type Tabs
              _buildMobileSearchTypeTabs(),
              const SizedBox(height: 16),
              
              // Simple Search Field
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
          "البحث",
          style: TextStyle(
            fontSize: 24,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
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
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(
          Icons.help_outline,
          size: 24,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildMobileSearchTypeTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: widget.searchTypeController,
        onTap: widget.onSearchTypeChanged,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: StringConstant.fontName,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          fontFamily: StringConstant.fontName,
        ),
        labelColor: Colors.black87,
        unselectedLabelColor: Colors.grey.shade600,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_center_outlined, size: 16),
                const SizedBox(width: 6),
                Text("العلامات"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gavel_outlined, size: 16),
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
    return Row(
      children: [
        // حقل البحث البسيط
        Expanded(
          child: TextFormField(
            key: widget.searchKey,
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.black87,
              fontSize: 16,
            ),
            controller: widget.searchController,
            validator: validateObjects(),
            decoration: _buildSearchFieldDecoration(),
            onChanged: (val) {
              setState(() {
                if (val.isEmpty) {
                  _hasSearched = false;
                }
              });
            },
            onFieldSubmitted: (val) {
              if (val.trim().length >= 2) {
                _performSearch();
              }
            },
          ),
        ),
        
        const SizedBox(width: 12),
        
        // زر البحث البسيط
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: widget.searchController.text.trim().length >= 2 ? _performSearch : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.searchController.text.trim().length >= 2
                  ? ColorManager.primary
                  : Colors.grey.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "بحث",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: StringConstant.fontName,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildSearchFieldDecoration() {
    return InputDecoration(
      hintText: widget.currentSearchType == 0 
          ? "ابحث عن اسم العلامة التجارية..."
          : "ابحث في القضايا...",
      hintStyle: TextStyle(
        fontFamily: StringConstant.fontName,
        color: Colors.grey.shade500,
        fontSize: 14,
      ),
      prefixIcon: null,
      suffixIcon: widget.searchController.text.isNotEmpty
          ? IconButton(
              onPressed: () {
                widget.searchController.clear();
                setState(() {
                  _hasSearched = false;
                });
              },
              icon: Icon(Icons.clear, color: Colors.grey.shade600),
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: ColorManager.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      color: Colors.grey.shade50,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple search icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.currentSearchType == 0 
                    ? Icons.business_center_outlined
                    : Icons.gavel_outlined,
                size: 48,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Simple title
            Text(
              widget.currentSearchType == 0 
                  ? "ابحث في العلامات التجارية"
                  : "ابحث في القضايا",
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Simple subtitle
            Text(
              "اكتب في الحقل أعلاه للبحث",
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
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        controller: widget.mainScrollController,
        child: Column(
          children: [
            Consumer<GetBrandBySearchProvider>(
              builder: (context, model, _) {
                return _buildBrandSearchResultsContent(context, model);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueSearchResults() {
    return Container(
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        controller: widget.mainScrollController,
        child: Column(
          children: [
            Consumer<SearchIssuesProvider>(
              builder: (context, model, _) {
                return _buildIssueSearchResultsContent(context, model);
              },
            ),
            const SizedBox(height: 20),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.gavel_outlined,
                  color: Colors.grey.shade600,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "${model.searchResults.length} قضية",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    color: Colors.black87,
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
                      color: Colors.grey.shade600,
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
                    padding: const EdgeInsets.all(10),
                    child: LoadingWidget()
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
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to issue details
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Simple Issue Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.gavel_outlined,
                  color: Colors.grey.shade600,
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
                        Expanded(
                          child: Text(
                            "قضية #${issue.id}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                              fontFamily: StringConstant.fontName,
                            ),
                          ),
                        ),
                        if (issue.refusedType.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              issue.refusedType,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
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
                        color: Colors.grey.shade700,
                        fontFamily: StringConstant.fontName,
                      ),
                      maxLines: 1,
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
              
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 60,
                  child: LoadingWidget()
                ),
                const SizedBox(width: 12),
                Text(
                  "جاري البحث...",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 40),
          const SizedBox(height: 12),
          Text(
            "حدث خطأ في البحث",
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.red.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "يرجى المحاولة مرة أخرى",
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "لا توجد نتائج",
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "جرب كلمات مختلفة للبحث",
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
                    padding: const EdgeInsets.all(10),
                    child: LoadingWidget()
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


  Widget _buildMobileBrandCard(BuildContext context, GetBrandBySearchProvider model, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
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