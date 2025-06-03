import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../app/RequestState/RequestState.dart';
import '../../../../network/RestApi/Comman.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/ImagesConstant.dart';
import '../../../../resources/StringManager.dart';
import '../../../Controllar/GetBrandBySearchProvider.dart';
import '../../../Widget/BrandWidget.dart';
import '../../../Widget/SearchWidget/NoDataFound.dart';

class WebSearchView extends StatefulWidget {
  final TextEditingController searchController;
  final ScrollController mainScrollController;
  final GlobalKey searchKey;
  final List<TargetFocus> targetList;
  final TutorialCoachMark? tutorialCoachMark;
  final VoidCallback onTutorialStart;
  final VoidCallback onTutorialTargetsAdd;

  const WebSearchView({
    super.key,
    required this.searchController,
    required this.mainScrollController,
    required this.searchKey,
    required this.targetList,
    required this.tutorialCoachMark,
    required this.onTutorialStart,
    required this.onTutorialTargetsAdd,
  });

  @override
  State<WebSearchView> createState() => _WebSearchViewState();
}

class _WebSearchViewState extends State<WebSearchView> {
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Column(
      children: [
        // Enhanced Web Search Header
        _buildWebSearchHeader(context, isTablet: isTablet),
        
        // Search Results Body
        Expanded(
          child: _buildWebSearchBody(context, isTablet: isTablet),
        ),
      ],
    );
  }

  Widget _buildWebSearchHeader(BuildContext context, {required bool isTablet}) {
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
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 24 : 32,
            isTablet ? 20 : 24,
            isTablet ? 24 : 32,
            isTablet ? 25 : 32,
          ),
          child: Column(
            children: [
              // Header Row with Title and Tutorial Button
              _buildWebHeaderRow(context, isTablet: isTablet),
              SizedBox(height: isTablet ? 20 : 24),
              
              // Enhanced Search Field
              _buildWebSearchField(context, isTablet: isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebHeaderRow(BuildContext context, {required bool isTablet}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 60),
        Text(
          "search".tr(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: isTablet ? 24 : 28,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontFamily: StringConstant.fontName,
          ),
        ),
        _buildWebTutorialButton(isTablet: isTablet),
      ],
    );
  }

  Widget _buildWebTutorialButton({required bool isTablet}) {
    return InkWell(
      onTap: () {
        if (widget.targetList.isEmpty) {
          widget.onTutorialTargetsAdd();
        }
        widget.onTutorialStart();
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              ImagesConstants.infoW,
              height: isTablet ? 28 : 32,
              width: isTablet ? 28 : 32,
            ),
            const SizedBox(width: 8),
            Text(
              "help".tr(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 14 : 16,
                fontFamily: StringConstant.fontName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSearchField(BuildContext context, {required bool isTablet}) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isTablet ? 600 : 800,
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        child: TextFormField(
          key: widget.searchKey,
          style: TextStyle(
            fontFamily: StringConstant.fontName,
            color: ColorManager.accent,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 16 : 18,
          ),
          controller: widget.searchController,
          validator: validateObjects(),
          decoration: _buildWebSearchFieldDecoration(isTablet: isTablet),
          onChanged: (val) {
            setState(() {});
          },
          onFieldSubmitted: (val) {
            _performSearch();
          },
        ),
      ),
    );
  }

  InputDecoration _buildWebSearchFieldDecoration({required bool isTablet}) {
    return InputDecoration(
      hintText: "search_brand_web".tr(),
      hintStyle: TextStyle(
        fontFamily: StringConstant.fontName,
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w500,
        fontSize: isTablet ? 15 : 16,
      ),
      prefixIcon: Container(
        margin: EdgeInsets.all(isTablet ? 12 : 16),
        padding: EdgeInsets.all(isTablet ? 10 : 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorManager.primary,
              ColorManager.primaryByOpacity,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.search,
          color: Colors.white,
          size: isTablet ? 20 : 24,
        ),
      ),
      suffixIcon: widget.searchController.text.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    widget.searchController.clear();
                    setState(() {});
                  },
                  icon: Icon(Icons.clear, color: Colors.grey.shade600),
                  tooltip: "clear".tr(),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 20,
                        vertical: isTablet ? 8 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "search".tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 14 : 16,
                        fontFamily: StringConstant.fontName,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 20,
                    vertical: isTablet ? 8 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "search".tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 14 : 16,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
              ),
            ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(35),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(35),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(35),
        borderSide: BorderSide(
          color: ColorManager.primary.withOpacity(0.4),
          width: 3,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 28,
        vertical: isTablet ? 16 : 20,
      ),
    );
  }

  Widget _buildWebSearchBody(BuildContext context, {required bool isTablet}) {
    return widget.searchController.text.isEmpty
        ? _buildWebEmptySearchState(isTablet: isTablet)
        : _buildWebSearchResults(isTablet: isTablet);
  }

  Widget _buildWebEmptySearchState({required bool isTablet}) {
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
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 500 : 600,
          ),
          padding: EdgeInsets.all(isTablet ? 32 : 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 32 : 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorManager.primary.withOpacity(0.1),
                      ColorManager.primaryByOpacity.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorManager.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.search,
                  size: isTablet ? 80 : 100,
                  color: ColorManager.primary.withOpacity(0.7),
                ),
              ),
              SizedBox(height: isTablet ? 32 : 40),
              Text(
                "welcome_to_search".tr(),
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: isTablet ? 24 : 28,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.accent,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 16 : 20),
              Text(
                "search_description".tr(),
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: isTablet ? 16 : 18,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 24 : 32),
              _buildSearchTips(isTablet: isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTips({required bool isTablet}) {
    final tips = [
      "tip_brand_name".tr(),
      "tip_registration_number".tr(),
      "tip_company_name".tr(),
    ];

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: ColorManager.primary,
                size: isTablet ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                "search_tips".tr(),
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: isTablet ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 16),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontFamily: StringConstant.fontName,
                      fontSize: isTablet ? 14 : 15,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildWebSearchResults({required bool isTablet}) {
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
        padding: EdgeInsets.all(isTablet ? 20 : 24),
        child: Consumer<GetBrandBySearchProvider>(
          builder: (context, model, _) {
            return _buildWebSearchResultsContent(context, model, isTablet: isTablet);
          },
        ),
      ),
    );
  }

  Widget _buildWebSearchResultsContent(
    BuildContext context,
    GetBrandBySearchProvider model, {
    required bool isTablet,
  }) {
    if (model.state == RequestState.loading) {
      return _buildWebLoadingState(isTablet: isTablet);
    } else if (model.state == RequestState.failed) {
      return _buildWebErrorState(isTablet: isTablet);
    } else if (model.state == RequestState.loaded) {
      if (model.allBrands.isEmpty) {
        return _buildWebNoResultsState(isTablet: isTablet);
      } else {
        return _buildWebResultsGrid(model, isTablet: isTablet);
      }
    }
    return Container();
  }

  Widget _buildWebLoadingState({required bool isTablet}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 16 : 20,
            horizontal: isTablet ? 20 : 24,
          ),
          decoration: BoxDecoration(
            color: ColorManager.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isTablet ? 24 : 28,
                height: isTablet ? 24 : 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 20),
              Text(
                "searching_brands".tr(),
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  color: ColorManager.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 16 : 18,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 24 : 32),
        _buildWebShimmerGrid(isTablet: isTablet),
      ],
    );
  }

  Widget _buildWebShimmerGrid({required bool isTablet}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 3,
        childAspectRatio: isTablet ? 3.5 : 4.0,
        crossAxisSpacing: isTablet ? 16 : 20,
        mainAxisSpacing: isTablet ? 16 : 20,
      ),
      itemCount: isTablet ? 6 : 9,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildWebErrorState({required bool isTablet}) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isTablet ? 500 : 600,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(isTablet ? 32 : 40),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: isTablet ? 64 : 80,
          ),
          SizedBox(height: isTablet ? 20 : 24),
          Text(
            "search_error".tr(),
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.red.shade700,
              fontSize: isTablet ? 20 : 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 12 : 16),
          Text(
            "search_error_description".tr(),
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.red.shade600,
              fontSize: isTablet ? 14 : 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWebNoResultsState({required bool isTablet}) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isTablet ? 500 : 600,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(isTablet ? 32 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          NoDataFound(),
          SizedBox(height: isTablet ? 24 : 32),
          Text(
            "no_results_found".tr(),
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: ColorManager.accent,
              fontSize: isTablet ? 20 : 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 12 : 16),
          Text(
            "try_different_search".tr(),
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.grey.shade600,
              fontSize: isTablet ? 14 : 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWebResultsGrid(GetBrandBySearchProvider model, {required bool isTablet}) {
    final crossAxisCount = _getCrossAxisCount(MediaQuery.of(context).size.width);
    final childAspectRatio = _getChildAspectRatio(MediaQuery.of(context).size.width);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Header
        _buildWebResultsHeader(model, isTablet: isTablet),
        SizedBox(height: isTablet ? 20 : 24),
        
        // Results Grid
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: isTablet ? 16 : 20,
            mainAxisSpacing: isTablet ? 16 : 20,
          ),
          itemBuilder: (context, index) {
            if (index == model.allBrands.length &&
                model.hasMoreData &&
                model.allBrands.length >= 6) {
              return _buildWebLoadingItem(isTablet: isTablet);
            }
            
            return _buildWebBrandCard(context, model, index, isTablet: isTablet);
          },
          itemCount: model.allBrands.length +
              (model.hasMoreData && model.allBrands.length >= 6 ? 1 : 0),
        ),
      ],
    );
  }

  Widget _buildWebResultsHeader(GetBrandBySearchProvider model, {required bool isTablet}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary.withOpacity(0.1),
            ColorManager.primaryByOpacity.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorManager.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 10 : 12),
            decoration: BoxDecoration(
              color: ColorManager.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.search_outlined,
              color: Colors.white,
              size: isTablet ? 20 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${model.allBrands.length} ${"results_found".tr()}",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    color: ColorManager.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 18 : 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${"for".tr()} \"${widget.searchController.text}\"",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    color: Colors.grey.shade600,
                    fontSize: isTablet ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
          if (model.hasMoreData)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 16,
                vertical: isTablet ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: ColorManager.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "more_available".tr(),
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  color: ColorManager.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 12 : 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebLoadingItem({required bool isTablet}) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
            ),
            SizedBox(height: isTablet ? 12 : 16),
            Text(
              "loading_more".tr(),
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                color: ColorManager.primary,
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebBrandCard(
    BuildContext context,
    GetBrandBySearchProvider model,
    int index, {
    required bool isTablet,
  }) {
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

  // Responsive grid calculations
  int _getCrossAxisCount(double width) {
    if (width > 1200) return 3;
    if (width > 900) return 2;
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
    return 4.0;
  }

  void _performSearch() {
    if (widget.searchController.text.trim().isEmpty) return;
    
    Provider.of<GetBrandBySearchProvider>(context, listen: false)
        .getAllBrandsBySearch(keyWord: widget.searchController.text.trim());
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    setState(() {});
  }
} 