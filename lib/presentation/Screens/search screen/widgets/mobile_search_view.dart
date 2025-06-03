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

  const MobileSearchView({
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
  State<MobileSearchView> createState() => _MobileSearchViewState();
}

class _MobileSearchViewState extends State<MobileSearchView> {
  
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
          "search".tr(),
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
            // Optional: Add real-time search functionality here
          },
          onFieldSubmitted: (val) {
            _performSearch();
          },
        ),
      ),
    );
  }

  InputDecoration _buildSearchFieldDecoration() {
    return InputDecoration(
      hintText: "search_brand".tr(),
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
                setState(() {});
              },
              icon: Icon(Icons.clear, color: Colors.grey.shade600),
            )
          : IconButton(
              onPressed: _performSearch,
              icon: Icon(
                Icons.search,
                color: ColorManager.primary,
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

  Widget _buildMobileSearchBody(BuildContext context) {
    return widget.searchController.text.isEmpty
        ? _buildEmptySearchState()
        : _buildSearchResults();
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

  Widget _buildSearchResults() {
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
                return _buildSearchResultsContent(context, model);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsContent(BuildContext context, GetBrandBySearchProvider model) {
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

  void _performSearch() {
    if (widget.searchController.text.trim().isEmpty) return;
    
    Provider.of<GetBrandBySearchProvider>(context, listen: false)
        .getAllBrandsBySearch(keyWord: widget.searchController.text.trim());
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    setState(() {});
  }
} 