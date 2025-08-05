import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../app/RequestState/RequestState.dart';
import '../../../../network/RestApi/Comman.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';
import '../../../Controllar/GetBrandBySearchProvider.dart';
import '../../../Controllar/Issues/SearchIssuesProvider.dart';
import '../../../../utilits/Local_User_Data.dart';
import '../../../Widget/BrandWidget.dart';
import '../../../Widget/loading_widget.dart';
import '../../../../resources/Route_Manager.dart';

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
        // Enhanced Search Header (Blue part only)
        _buildMobileSearchHeader(context),

        // Search Controls (Tabs and Search Field)
        _buildMobileSearchControls(context),

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
              ColorManager.primaryByOpacity.withValues(alpha: 0.9),
              ColorManager.primary,
            ],
            stops: [0.2,0.7]
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: _buildMobileHeaderRow(context),
        ),
      ),
    );
  }

  Widget _buildMobileSearchControls(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Search Type Tabs
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildMobileSearchTypeTabs(),
          ),

          // Search Field
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildMobileSearchField(context),
          ),
        ],
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
            fontSize: 20,
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
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Icon(
          Icons.help_outline,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMobileSearchTypeTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: widget.searchTypeController,
        onTap: widget.onSearchTypeChanged,
        padding: EdgeInsets.zero,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              ColorManager.primary,
              ColorManager.primary.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: ColorManager.primary.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
        labelColor: Colors.white,
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
        // Enhanced search field
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
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
        ),

        const SizedBox(width: 12),

        // Enhanced search button
        Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.searchController.text.trim().length >= 2
                  ? [ColorManager.primary, ColorManager.primary.withValues(alpha: 0.8)]
                  : [Colors.grey.shade300, Colors.grey.shade400],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.searchController.text.trim().length >= 2 ? [
              BoxShadow(
                color: ColorManager.primary.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ] : [],
          ),
          child: ElevatedButton(
            onPressed: widget.searchController.text.trim().length >= 2 ? _performSearch : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 22, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  "بحث",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: StringConstant.fontName,
                    color: Colors.white,
                  ),
                ),
              ],
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
        fontSize: 12,
      ),
      prefixIcon: Icon(
        widget.currentSearchType == 0 ? Icons.business_center_outlined : Icons.gavel_outlined,
        color: Colors.grey.shade400,
        size: 20,
      ),
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
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ColorManager.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Enhanced animated search illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorManager.primary.withValues(alpha: 0.1),
                      ColorManager.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorManager.primary.withValues(alpha: 0.1),
                      spreadRadius: 4,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.currentSearchType == 0
                          ? Icons.business_center_outlined
                          : Icons.gavel_outlined,
                      size: 40,
                      color: ColorManager.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Enhanced title with gradient text effect
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.currentSearchType == 0
                      ? "اكتشف عالم العلامات التجارية"
                      : "استكشف قاعدة بيانات القضايا",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.primary,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Enhanced subtitle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  widget.currentSearchType == 0
                      ? "ابحث عن العلامات التجارية المسجلة واستكشف تفاصيلها الكاملة"
                      : "ابحث في قاعدة بيانات القضايا والملفات القانونية",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTip({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: ColorManager.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: ColorManager.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
          ),
        ),
      ],
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

  Widget _buildResultsGrid(GetBrandBySearchProvider model) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Results Counter for Brands
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary.withValues(alpha: 0.1),
                  ColorManager.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorManager.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.business_center_outlined,
                    color: ColorManager.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${model.allBrands.length} علامة تجارية",
                        style: TextStyle(
                          fontFamily: StringConstant.fontName,
                          color: ColorManager.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "نتائج البحث عن: \"${widget.searchController.text}\"",
                        style: TextStyle(
                          fontFamily: StringConstant.fontName,
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (model.hasMoreData) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "المزيد متاح",
                      style: TextStyle(
                        fontFamily: StringConstant.fontName,
                        color: Colors.orange.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
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

  Widget _buildIssueResultsGrid(SearchIssuesProvider model) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Results Counter for Issues
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary.withValues(alpha: 0.1),
                  ColorManager.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorManager.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.gavel_outlined,
                    color: ColorManager.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${model.searchResults.length} قضية",
                        style: TextStyle(
                          fontFamily: StringConstant.fontName,
                          color: ColorManager.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "نتائج البحث عن: \"${widget.searchController.text}\"",
                        style: TextStyle(
                          fontFamily: StringConstant.fontName,
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (model.hasMoreData) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "المزيد متاح",
                      style: TextStyle(
                        fontFamily: StringConstant.fontName,
                        color: Colors.orange.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
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
          // Navigate to issue details
                                    Navigator.pushNamed(
                            context,
                            Routes.issueDetailsRoute,
            arguments: {
              'issueId': issue.id,
              'customerId': 1, // Default customer ID for search results
            },
          );
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary.withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorManager.primary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Loading animation
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ColorManager.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "جاري البحث...",
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: ColorManager.primary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "يرجى الانتظار قليلاً",
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "حدث خطأ في البحث",
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.red.shade700,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "يرجى التحقق من الاتصال والمحاولة مرة أخرى",
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.red.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Retry button
          ElevatedButton(
            onPressed: _performSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 18),
                const SizedBox(width: 8),
                Text(
                  "إعادة المحاولة",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
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

  Widget _buildNoResultsState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // No results icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 40,
              color: Colors.orange.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "لا توجد نتائج",
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "لم نتمكن من العثور على نتائج مطابقة لبحثك",
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.orange.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Search suggestions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: Colors.orange.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "اقتراحات للبحث",
                      style: TextStyle(
                        fontFamily: StringConstant.fontName,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "• جرب كلمات مختلفة أو أقصر\n• تأكد من الإملاء\n• استخدم مصطلحات أكثر عمومية",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    color: Colors.orange.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
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