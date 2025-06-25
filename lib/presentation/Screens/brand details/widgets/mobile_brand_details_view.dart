import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../network/RestApi/Comman.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';
import '../../../../utilits/Local_User_Data.dart';
import '../../../Controllar/GetBrandDetailsProvider.dart';
import '../../../Widget/BrandDetailsWidget/BrandImages.dart';
import '../../../Widget/BrandDetailsWidget/BrandOrderFinishedOrTawkel.dart';
import '../../../Widget/BrandStatusWidget/AcceptWidget.dart';
import '../../../Widget/BrandStatusWidget/AppealBrandRegistration.dart';
import '../../../Widget/BrandStatusWidget/AppealGrivenceWidget.dart';
import '../../../Widget/BrandStatusWidget/ConditionalAcceptanceWidget.dart';
import '../../../Widget/BrandStatusWidget/GiveupWidget.dart';
import '../../../Widget/BrandStatusWidget/GrievanceTeamDecisionWidget.dart';
import '../../../Widget/BrandStatusWidget/GrievanceWidget.dart';
import '../../../Widget/BrandStatusWidget/RenovationsWidget.dart';
import '../../../Widget/BrandStatusWidget/RefusedWidget.dart';
import '../../../Widget/BrandStatusWidget/proccessingWidget.dart';

class MobileBrandDetailsView extends StatelessWidget {
  final GetBrandDetailsProvider model;
  final ScrollController scrollController;
  final GlobalKey logoKey;
  final GlobalKey brandStatusListKey;
  final GlobalKey downloadPdfKey;
  final VoidCallback onTutorialTap;
  final VoidCallback onDownloadTap;

  const MobileBrandDetailsView({
    required this.model,
    required this.scrollController,
    required this.logoKey,
    required this.brandStatusListKey,
    required this.downloadPdfKey,
    required this.onTutorialTap,
    required this.onDownloadTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildMobileBackground(),
        _buildMobileScrollContent(context),
        _buildMobileFloatingButton(context),
      ],
    );
  }

  Widget _buildMobileBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorManager.primary.withValues(alpha: 0.03),
            Colors.white,
            ColorManager.primaryByOpacity.withValues(alpha: 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileScrollContent(BuildContext context) {
    final brandData = _buildBrandData(context);
    final statusData = model.brandDetails!.AllResult;

    return CustomScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Brand Images Header with Tutorial
        SliverToBoxAdapter(
          child: _buildMobileHeader(context),
        ),

        // User Info Section
        SliverToBoxAdapter(
          child: _buildMobileUserInfo(context),
        ),

        // Brand Details Table
        SliverToBoxAdapter(
          child: _buildMobileBrandTable(context, brandData),
        ),

        // Order Status Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: BrandOrderFinishedOrTawkel(context: context, model: model),
          ),
        ),

        // Status List Header
        SliverToBoxAdapter(
          child: _buildMobileStatusHeader(context),
        ),

        // Brand Status List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            key: brandStatusListKey,
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMobileStatusCard(context, statusData[index], index),
              ),
              childCount: statusData.length,
            ),
          ),
        ),

        // Bottom spacing for floating button
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BrandImages(model: model, tutorialKey: logoKey),
          ),
        ),
        // Back Button
        Positioned(
          top: 25,
          left: 25,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward,
                color: ColorManager.primary,
                size: 24,
              ),
            ),
          ),
        ),
        // Tutorial Button
        Positioned(
          top: 25,
          right: 25,
          child: GestureDetector(
            onTap: onTutorialTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.help_outline,
                color: ColorManager.primary,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileUserInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary,
                  ColorManager.primaryByOpacity,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            globalAccountData.getUsername() ?? 'User',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 20,
              color: ColorManager.primary,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            globalAccountData.getEmail() ?? 'user@example.com',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBrandTable(BuildContext context, List<List<String>> brandData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary,
                  ColorManager.primaryByOpacity,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  "تفاصيل العلامه".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: brandData.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildMobileTableRow(context, brandData[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTableRow(BuildContext context, List<String> rowData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rowData[0],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorManager.primary,
              fontFamily: StringConstant.fontName,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rowData[1],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatusHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary.withValues(alpha: 0.1),
            ColorManager.primaryByOpacity.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorManager.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorManager.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.timeline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "brands_status".tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.primary,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "brand_status_subTitle".tr(),
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
    );
  }

  Widget _buildMobileStatusCard(BuildContext context, dynamic data, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildStatusWidget(context, data, index),
      ),
    );
  }

  Widget _buildMobileFloatingButton(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        key: downloadPdfKey,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorManager.primary,
              ColorManager.primaryByOpacity.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: ColorManager.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onDownloadTap,
            borderRadius: BorderRadius.circular(28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.file_download_outlined, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  "download_pdf".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Brand data builder
  List<List<String>> _buildBrandData(BuildContext context) {
    return [
      [
        model.brandDetails!.brand.markOrModel == 1
            ? "model_desc".tr()
            : "brand_name".tr(),
        model.brandDetails!.brand.brandName ?? '',
      ],
      [
        model.brandDetails!.brand.markOrModel == 1
            ? "model_number".tr()
            : "brand_number".tr(),
        model.brandDetails!.brand.brandNumber ?? '',
      ],
      ["brand_category".tr(), model.brandDetails!.brand.brandDescription ?? ''],
      [
        model.brandDetails!.brand.markOrModel == 1
            ? "model_status".tr()
            : "brand_status".tr(),
        model.brandDetails!.brand.newCurrentState.isEmpty
            ? convertStateBrandNumberToString(
                model.brandDetails!.brand.currentStatus)
            : model.brandDetails!.brand.newCurrentState,
      ],
      [
        model.brandDetails!.brand.markOrModel == 1
            ? "model_details".tr()
            : "category_details".tr(),
        model.brandDetails!.brand.brandDetails.replaceAll('<br>', '') ?? '',
      ],
      ['اسم مقدم الطلب', model.brandDetails!.brand.applicant ?? ''],
      ['عنوان مقدم الطلب', model.brandDetails!.brand.customerAddress ?? ''],
      ["customer_name".tr(), model.brandDetails!.brand.customerName ?? ''],
      ["order_date".tr(), model.brandDetails!.brand.applicationDate ?? ''],
      ["notes".tr(), model.brandDetails!.brand.notes ?? ''],
      ["payment_status".tr(), model.brandDetails!.brand.paymentStatus ?? ''],
      [
        "in_out_egy".tr(),
        model.brandDetails!.brand.country == 0
            ? "in_egypt".tr()
            : '(${model.brandDetails!.brand.countryName})',
      ],
      [
        "complete_request".tr(),
        _getPowerOfAttorneyStatus(model.brandDetails!.brand.completedPowerOfAttorneyRequest),
      ],
      ["incoming_number".tr(), model.brandDetails!.brand.importNumber ?? ''],
      ["attorney_date".tr(), model.brandDetails!.brand.dateOfSupply ?? ''],
      [
        "recording_attorney_date".tr(),
        model.brandDetails!.brand.recordingDateOfSupply ?? ''
      ],
      [
        "date_undertaking_submit_attorney".tr(),
        model.brandDetails!.brand.dateOfUnderTaking ?? ''
      ],
    ].where((item) => item[1].isNotEmpty).toList();
  }

  String _getPowerOfAttorneyStatus(int status) {
    switch (status) {
      case 0:
        return "exists".tr();
      case 1:
        return "not_exists".tr();
      case 2:
        return "attorney_supply".tr();
      case 3:
        return "commitment_attorney_supply".tr();
      default:
        return "recording_attorney_supply".tr();
    }
  }

  Widget _buildStatusWidget(BuildContext context, dynamic data, int index) {
    if (data.name == StringConstant.processing) {
      return proccessingWidget(data: [data], index: 0);
    }
    if (data.name == StringConstant.accept) {
      return AcceptWidget(brandDetailsDataEntity: data);
    }
    if (data.states == "الرفض") {
      return RefusedWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "الطعن ضد التظلم") {
      return AppealGrivenceWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "التظلم") {
      return GrievanceWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "قرار لجنه التظلم") {
      return GrievanceTeamDecisionWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "التجديدات") {
      return RenovationsWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "قبول مشترط") {
      return ConditionalAcceptanceWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == StringConstant.giveUp) {
      return GiveUpWidget(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == StringConstant.appealBrandRegistration) {
      return AppealBrandRegistration(brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    return const SizedBox.shrink();
  }
} 