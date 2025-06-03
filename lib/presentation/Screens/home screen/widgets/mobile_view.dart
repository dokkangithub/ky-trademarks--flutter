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
import '../../AddRequest.dart';
import '../../BrandDetails.dart';
import '../../NotificationScreen.dart';
import '../../PaymentWays.dart';
import '../../../../utilits/Local_User_Data.dart';

class AppConstants {
  static const double headerHeight = 200.0;
  static const double cardHeight = 120.0;
  static const double cardMargin = 8.0;
  static const double paddingHorizontal = 16.0;
  static const double paddingVertical = 8.0;
}

class MobileView extends StatelessWidget {
  final TabController tabController;
  final String byStatus;
  final ValueChanged<String> onFilterChanged;
  final ScrollController mainScrollController;
  final ScrollController listScrollController;
  final bool isLoadingMore;

  const MobileView({
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
          MobileHeader(
            tabController: tabController,
            byStatus: byStatus,
            onFilterChanged: onFilterChanged,
          ),
          Container(
            color: ColorManager.anotherTabBackGround,
            padding: const EdgeInsets.only(
                top: 15, left: AppConstants.paddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "latest_trademarks".tr(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: ColorManager.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      fontFamily: StringConstant.fontName),
                ),
                const SizedBox(height: 5),
                BrandUpdatesList(
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

class MobileHeader extends StatelessWidget {
  final TabController tabController;
  final String byStatus;
  final ValueChanged<String> onFilterChanged;

  const MobileHeader({
    required this.tabController,
    required this.byStatus,
    required this.onFilterChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    final companyProvider = Provider.of<GetCompanyProvider>(context);
    
    return Stack(
      children: [
        Container(
          height: AppConstants.headerHeight,
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
            const SizedBox(height: 10),
            MobileHeaderContent(),
            MobileActionRows(),
            const SizedBox(height: 10),
            // TabBar and Dropdowns for Mobile
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingHorizontal,
              ),
              child: Column(
                children: [
                  // TabBar
                  TabBar(
                    controller: tabController,
                    labelColor: ColorManager.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: ColorManager.primary,
                    tabs: [
                      Tab(child: Text('marks'.tr(), style: TextStyle(fontFamily: StringConstant.fontName))),
                      Tab(child: Text('models'.tr(), style: TextStyle(fontFamily: StringConstant.fontName))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Company and Filter Dropdowns in Column for mobile
                  Column(
                    children: [
                      // Company Dropdown
                      SizedBox(
                        width: double.infinity,
                        child: companyProvider.state == RequestState.loading
                            ? const CircularProgressIndicator()
                            : DropdownButton<CompanyEntity>(
                                value: companyProvider.selectedCompany,
                                hint: Text(
                                  'select_company'.tr(),
                                  style: TextStyle(
                                      color: ColorManager.primary,
                                      fontFamily: StringConstant.fontName),
                                ),
                                dropdownColor: ColorManager.chartColor,
                                style: TextStyle(color: ColorManager.primary, fontFamily: StringConstant.fontName),
                                icon: const SizedBox.shrink(),
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
                                      child: Text(
                                        company.companyName,
                                        style: TextStyle(fontFamily: StringConstant.fontName),
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
                                        Expanded(
                                          child: Text(
                                            company.companyName,
                                            style: TextStyle(
                                                color: ColorManager.primary,
                                                fontFamily: StringConstant.fontName),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
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
                      const SizedBox(height: 10),
                      // Filter Dropdown
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButton<String>(
                          value: byStatus.isEmpty ? null : byStatus,
                          hint: Text(
                            'brands_filter'.tr(),
                            style: TextStyle(
                                color: ColorManager.primary,
                                fontFamily: StringConstant.fontName),
                          ),
                          dropdownColor: ColorManager.chartColor,
                          style: TextStyle(
                              color: ColorManager.primary,
                              fontFamily: StringConstant.fontName),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: ColorManager.primary,
                          ),
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
                              child: Text(
                                'in_egypt'.tr(),
                                style: TextStyle(fontFamily: StringConstant.fontName),
                              ),
                            ),
                            DropdownMenuItem(
                              value: StringConstant.outsideEgypt,
                              child: Text(
                                'out_egypt'.tr(),
                                style: TextStyle(fontFamily: StringConstant.fontName),
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
              height: MediaQuery.of(context).size.height * 0.4,
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingHorizontal,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TabBarView(
                controller: tabController,
                children: provider.allBrands.isEmpty
                    ? List.generate(2, (_) => _NoDataView())
                    : ['marks'.tr(), 'models'.tr()].map((tab) {
                        final filteredData = provider.allBrands
                            .where((brand) => _filterBrands(brand, tab))
                            .toList();
                        return filteredData.isEmpty
                            ? _NoDataView()
                            : MobileListContent(brands: filteredData);
                      }).toList(),
              ),
            ),
          ],
        ),
      ],
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
  final List<BrandEntity> brands;

  const MobileListContent({required this.brands, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetBrandProvider>(context);
    return ListView.builder(
      itemCount: brands.length + (provider.isLoading ? 1 : 0),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Lottie.asset(ImagesConstants.noData, fit: BoxFit.contain),
          Text(
            'no_data'.tr(),
            style: TextStyle(
              color: ColorManager.primary,
              fontWeight: FontWeight.w500,
              fontSize: 22,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
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
