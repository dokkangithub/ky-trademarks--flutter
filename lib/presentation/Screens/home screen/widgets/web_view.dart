import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
import '../../../../domain/Brand/Entities/BrandEntity.dart';
import '../../../../domain/Company/Entities/CompanyEntity.dart';
import '../../../../resources/ImagesConstant.dart';
import '../../../../network/RestApi/Comman.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';
import '../../../Controllar/GetBrandProvider.dart';
import '../../../Controllar/GetCompanyProvider.dart';
import '../../../Widget/loading_widget.dart';
import '../../../Widget/BrandWidget.dart';
import '../../add request/AddRequest.dart';
import '../../BrandDetails.dart';
import '../../NotificationScreen.dart';
import '../../PaymentWays.dart';
import '../../../../utilits/Local_User_Data.dart';

class WebAppConstants {
  static const double headerHeight = 250.0;
  static const double cardHeight = 120.0;
  static const double cardMargin = 8.0;
  static const double paddingHorizontal = 24.0;
  static const double paddingVertical = 16.0;
}

class WebView extends StatelessWidget {
  final TabController tabController;
  final String byStatus;
  final ValueChanged<String> onFilterChanged;
  final ScrollController mainScrollController;
  final ScrollController listScrollController;
  final bool isLoadingMore;

  const WebView({
    required this.tabController,
    required this.byStatus,
    required this.onFilterChanged,
    required this.mainScrollController,
    required this.listScrollController,
    required this.isLoadingMore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    return SingleChildScrollView(
      controller: mainScrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebHeader(
            tabController: tabController,
            byStatus: byStatus,
            onFilterChanged: onFilterChanged,
          ),
          Container(
            color: ColorManager.anotherTabBackGround,
            padding: const EdgeInsets.only(
                top: 25, left: WebAppConstants.paddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "latest_trademarks".tr(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: ColorManager.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      fontFamily: StringConstant.fontName),
                ),
                const SizedBox(height: 15),
                WebBrandUpdatesList(
                  controller: listScrollController,
                  brands: provider.allBrandUpdates,
                ),
                if (isLoadingMore) LoadingWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WebHeader extends StatelessWidget {
  final TabController tabController;
  final String byStatus;
  final ValueChanged<String> onFilterChanged;

  const WebHeader({
    required this.tabController,
    required this.byStatus,
    required this.onFilterChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    final companyProvider = Provider.of<GetCompanyProvider>(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final childAspectRatio = _getChildAspectRatio(constraints.maxWidth);
        
        return Stack(
          children: [
            Container(
              height: WebAppConstants.headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorManager.primaryByOpacity.withValues(alpha: 0.9),
                    ColorManager.primary,
                  ],
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 15),
                WebHeaderContent(constraints: constraints),
                WebActionRows(constraints: constraints),
                const SizedBox(height: 20),
                // Web Layout for TabBar and Dropdowns
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: WebAppConstants.paddingHorizontal,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // TabBar
                      SizedBox(
                        width: 250,
                        child: TabBar(
                          controller: tabController,
                          labelColor: ColorManager.primary,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: ColorManager.primary,
                          labelStyle: TextStyle(fontSize: 16, fontFamily: StringConstant.fontName),
                          tabs: [
                            Tab(child: Text('marks'.tr(), style: TextStyle(fontFamily: StringConstant.fontName))),
                            Tab(child: Text('models'.tr(), style: TextStyle(fontFamily: StringConstant.fontName))),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          // Company Dropdown
                          Container(
                            constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
                            child: companyProvider.state == RequestState.loading
                                ? const CircularProgressIndicator()
                                : DropdownButton<CompanyEntity>(
                                    value: companyProvider.selectedCompany,
                                    hint: Text(
                                      'select_company'.tr(),
                                      style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: 16,
                                          fontFamily: StringConstant.fontName),
                                    ),
                                    dropdownColor: ColorManager.chartColor,
                                    style: TextStyle(
                                        color: ColorManager.primary, 
                                        fontSize: 16,
                                        fontFamily: StringConstant.fontName),
                                    icon: const SizedBox.shrink(),
                                    underline: Container(),
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
                                          child: Text(
                                            company.companyName,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: StringConstant.fontName),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                    selectedItemBuilder: (BuildContext context) {
                                      return companyProvider.allCompanies
                                          .map<Widget>((CompanyEntity company) {
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              company.companyName,
                                              style: TextStyle(
                                                  color: ColorManager.primary,
                                                  fontSize: 16,
                                                  fontFamily: StringConstant.fontName),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: ColorManager.primary,
                                            ),
                                          ],
                                        );
                                      }).toList();
                                    },
                                  ),
                          ),
                          const SizedBox(width: 20),
                          // Filter Dropdown
                          Container(
                            constraints: BoxConstraints(minWidth: 180, maxWidth: 250),
                            child: DropdownButton<String>(
                              value: byStatus.isEmpty ? null : byStatus,
                              hint: Text(
                                'brands_filter'.tr(),
                                style: TextStyle(
                                    color: ColorManager.primary,
                                    fontSize: 16,
                                    fontFamily: StringConstant.fontName),
                              ),
                              dropdownColor: ColorManager.chartColor,
                              style: TextStyle(
                                  color: ColorManager.primary,
                                  fontSize: 16,
                                  fontFamily: StringConstant.fontName),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: ColorManager.primary,
                              ),
                              underline: Container(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  onFilterChanged(newValue);
                                }
                              },
                              items: [
                                DropdownMenuItem(
                                  value: StringConstant.inEgypt,
                                  child: Text(
                                    'in_egypt'.tr(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: StringConstant.fontName),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: StringConstant.outsideEgypt,
                                  child: Text(
                                    'out_egypt'.tr(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: StringConstant.fontName),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  margin: const EdgeInsets.symmetric(
                    horizontal: WebAppConstants.paddingHorizontal,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBarView(
                    controller: tabController,
                    children: provider.allBrands.isEmpty
                        ? List.generate(2, (_) => _WebNoDataView())
                        : ['marks'.tr(), 'models'.tr()].map((tab) {
                            final filteredData = provider.allBrands
                                .where((brand) => _filterBrands(brand, tab))
                                .toList();
                            return filteredData.isEmpty
                                ? _WebNoDataView()
                                : WebGridContent(
                                    brands: filteredData,
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: childAspectRatio,
                                  );
                          }).toList(),
                  ),
                ),
              ],
            ),
          ],
        );
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

  int _getCrossAxisCount(double width) {
    if (width > 1400) return 4;
    if (width > 1200) return 3;
    if (width > 900) return 2;
    return 1;
  }

  double _getChildAspectRatio(double width) {
    if (width > 1400) return 4.5;
    if (width > 1200) return 3.8;
    if (width > 1000) return 4.2;
    if (width > 900) return 3.8;
    if (width > 800) return 6.5;
    if (width > 700) return 5.5;
    return 4.5;
  }
}

class WebHeaderContent extends StatelessWidget {
  final BoxConstraints constraints;

  const WebHeaderContent({
    required this.constraints,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WebGreeting(),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        globalAccountData.getUsername() ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          fontFamily: StringConstant.fontName,
                          letterSpacing: 1,
                          color: ColorManager.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Lottie.asset(
                      ImagesConstants.hi,
                      height: 50,
                      width: 50,
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
                width: 60,
                height: 50,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WebGreeting extends StatelessWidget {
  const WebGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    return Text(
      hour < 12 ? "good_morning".tr() : "good_night".tr(),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 22,
        fontFamily: StringConstant.fontName,
        letterSpacing: 1,
        color: ColorManager.white,
      ),
    );
  }
}

class WebActionRows extends StatelessWidget {
  final BoxConstraints constraints;

  const WebActionRows({required this.constraints, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(ImagesConstants.wallet, width: 60, height: 60),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "total_trademarks".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
                          fontSize: 28,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 4),
                        child: Text(
                          "tm".tr(),
                          style: TextStyle(
                            fontFamily: StringConstant.fontName,
                            color: ColorManager.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Web Action Buttons - Horizontal layout with better spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              WebActionButton(
                text: "payment methods".tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentWays()),
                ),
                isSecondary: true,
              ),
              const SizedBox(width: 20),
              WebDownloadButton(constraints: constraints),
              const SizedBox(width: 20),
              WebActionButton(
                text: "new_ask".tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddRequest(canBack: true)),
                ),
                isSecondary: true,
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class WebActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isSecondary;

  const WebActionButton({
    required this.text,
    required this.onTap,
    this.isSecondary = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorManager.primary,
                fontFamily: StringConstant.fontName,
              ),
        ),
      ),
    );
  }
}

class WebDownloadButton extends StatelessWidget {
  final BoxConstraints constraints;

  const WebDownloadButton({
    required this.constraints,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launch(
          "${ApiConstant.baseUrl}pdfAll/${globalAccountData.getId()}?download=pdf"),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorManager.primary,
              ColorManager.primaryByOpacity.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          "download_full_pdf".tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: StringConstant.fontName,
              ),
        ),
      ),
    );
  }
}

class WebGridContent extends StatelessWidget {
  final List<BrandEntity> brands;
  final int crossAxisCount;
  final double childAspectRatio;

  const WebGridContent({
    required this.brands,
    required this.crossAxisCount,
    required this.childAspectRatio,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: brands.length + (provider.isLoading ? 1 : 0),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(WebAppConstants.paddingHorizontal),
      itemBuilder: (context, index) => index == brands.length
          ? Center(child: LoadingWidget())
          : BrandWidget(
              context: context,
              model: provider,
              index: index,
              isFromHomeFiltering: true,
              brandsList: brands,
            ),
    );
  }
}

class WebBrandUpdatesList extends StatelessWidget {
  final ScrollController controller;
  final List<dynamic> brands;

  const WebBrandUpdatesList({
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
          width: 80,
          height: brands.length * (WebAppConstants.cardHeight + WebAppConstants.cardMargin),
          color: ColorManager.anotherTabBackGround,
          padding: const EdgeInsets.only(top: 20),
          child: NumberStepper(
            alignment: Alignment.topRight,
            scrollingDisabled: true,
            lineLength: 90,
            stepPadding: 0,
            numberStyle: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
            padding: const EdgeInsets.all(WebAppConstants.paddingHorizontal),
            itemCount: brands.length,
            itemBuilder: (context, index) => WebBrandUpdateItem(index: index),
          ),
        ),
      ],
    );
  }
}

class WebBrandUpdateItem extends StatelessWidget {
  final int index;

  const WebBrandUpdateItem({required this.index, super.key});

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
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: WebAppConstants.cardMargin),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BranDetails(brandId: brand.id)),
        ),
        child: Container(
          height: WebAppConstants.cardHeight + 20,
          padding: const EdgeInsets.all(WebAppConstants.paddingHorizontal),
          child: Row(
            spacing: 12,
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
                          borderRadius: BorderRadius.circular(8),
                          child: cachedImage(
                            ApiConstant.imagePath + filteredImage.image,
                            fit: BoxFit.contain,
                            placeHolderFit: BoxFit.contain,
                          ),
                        ),
                      ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                              brand.brandName,
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: StringConstant.fontName,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            convertStateBrandNumberToString(brand.currentStatus),
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.grey.withValues(alpha: 0.9),
                                  fontSize: 15,
                                  fontFamily: StringConstant.fontName,
                                ),
                          ),
                          Text(
                            "${s.DateFormat('EEEE').format(DateTime.parse(update.date))} الموافق: ${s.DateFormat('yyyy-MM-dd').format(DateTime.parse(update.date))}",
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.grey.withValues(alpha: 0.9),
                                  fontSize: 13,
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
                padding: const EdgeInsetsDirectional.only(top: 25, end: 15),
                child: SvgPicture.asset(
                  brand.currentStatus == 2
                      ? "assets/images/accept.svg"
                      : brand.currentStatus == 3
                          ? "assets/images/refused.svg"
                          : "assets/images/proccessing.svg",
                  width: 30,
                  height: 30,
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
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: WebAppConstants.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            _WebShimmerRow(),
            const SizedBox(height: 30),
            _WebShimmerItem(),
            const SizedBox(height: 20),
            _WebShimmerGrid(),
            const SizedBox(height: 30),
            _WebShimmerGrid(isSecond: true),
          ],
        ),
      ),
    );
  }
}

class _WebShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 180, height: 25, color: Colors.white),
                const SizedBox(height: 15),
                Container(width: 220, height: 25, color: Colors.white),
              ],
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _WebShimmerItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: 80,
            height: 80,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 15),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 180, height: 25, color: Colors.white),
              const SizedBox(height: 15),
              Container(width: 120, height: 25, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}

class _WebShimmerGrid extends StatelessWidget {
  final bool isSecond;

  const _WebShimmerGrid({this.isSecond = false});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 4.0,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: isSecond ? 3 : 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.all(15),
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 140, height: 20, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    Container(width: 100, height: 20, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
