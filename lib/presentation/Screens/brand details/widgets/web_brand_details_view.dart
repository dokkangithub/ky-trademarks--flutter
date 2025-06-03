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

class WebBrandDetailsView extends StatelessWidget {
  final GetBrandDetailsProvider model;
  final ScrollController scrollController;
  final GlobalKey logoKey;
  final GlobalKey brandStatusListKey;
  final GlobalKey downloadPdfKey;
  final VoidCallback onTutorialTap;
  final VoidCallback onDownloadTap;

  const WebBrandDetailsView({
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.primary.withValues(alpha: 0.02),
            Colors.white,
            ColorManager.primaryByOpacity.withValues(alpha: 0.01),
          ],
        ),
      ),
      child: isTablet 
          ? _buildTabletLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header with Brand Images and User Info
          _buildTabletHeader(context),
          const SizedBox(height: 20),
          // Brand Details
          _buildWebBrandDetails(context, _buildBrandData(context)),
          const SizedBox(height: 20),
          // Order Status
          BrandOrderFinishedOrTawkel(context: context, model: model),
          const SizedBox(height: 20),
          // Status Timeline
          _buildWebStatusTimeline(context, model.brandDetails!.AllResult),
          const SizedBox(height: 20),
          // Download Button
          _buildWebDownloadButton(context),
        ],
      ),
    );
  }

  Widget _buildTabletHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Images
        Expanded(
          flex: 3,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BrandImages(model: model, tutorialKey: logoKey),
                ),
                // Tutorial Button
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: onTutorialTap,
                    child: Container(
                      padding: const EdgeInsets.all(12),
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
            ),
          ),
        ),
        const SizedBox(width: 20),
        // User Info
        Expanded(
          flex: 2,
          child: _buildWebUserInfo(context),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel - Brand Images & User Info
        Expanded(
          flex: 2,
          child: _buildWebLeftPanel(context),
        ),
        // Right Panel - Brand Details & Status
        Expanded(
          flex: 3,
          child: _buildWebRightPanel(context),
        ),
      ],
    );
  }

  Widget _buildWebLeftPanel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Brand Images with Tutorial
          _buildWebBrandImages(context),
          const SizedBox(height: 20),
          // User Info Card
          _buildWebUserInfo(context),
          const SizedBox(height: 20),
          // Download Button
          _buildWebDownloadButton(context),
        ],
      ),
    );
  }

  Widget _buildWebBrandImages(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BrandImages(model: model, tutorialKey: logoKey),
          ),
          // Tutorial Button
          Positioned(
            top: 15,
            right: 15,
            child: GestureDetector(
              onTap: onTutorialTap,
              child: Container(
                padding: const EdgeInsets.all(12),
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
          // Brand Gallery Label
          Positioned(
            bottom: 15,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library_outlined, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "brand_gallery".tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebUserInfo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: isTablet ? 60 : 80,
            height: isTablet ? 60 : 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary,
                  ColorManager.primaryByOpacity,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorManager.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: isTablet ? 30 : 40,
            ),
          ),
          SizedBox(height: isTablet ? 15 : 20),
          Text(
            globalAccountData.getUsername() ?? 'User',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: isTablet ? 18 : 22,
              color: ColorManager.primary,
              fontWeight: FontWeight.w700,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            globalAccountData.getEmail() ?? 'user@example.com',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: isTablet ? 14 : 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          SizedBox(height: isTablet ? 15 : 20),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 16, 
              vertical: isTablet ? 6 : 8
            ),
            decoration: BoxDecoration(
              color: ColorManager.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorManager.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_outlined, color: ColorManager.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Verified Account',
                  style: TextStyle(
                    color: ColorManager.primary,
                    fontSize: isTablet ? 11 : 12,
                    fontWeight: FontWeight.w500,
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

  Widget _buildWebDownloadButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    return Container(
      key: downloadPdfKey,
      width: double.infinity,
      height: isTablet ? 50 : 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary,
            ColorManager.primaryByOpacity.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 25 : 28),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDownloadTap,
          borderRadius: BorderRadius.circular(isTablet ? 25 : 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.file_download_outlined, color: Colors.white, size: isTablet ? 22 : 26),
              const SizedBox(width: 12),
              Text(
                "download_pdf".tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebRightPanel(BuildContext context) {
    final brandData = _buildBrandData(context);
    final statusData = model.brandDetails!.AllResult;

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 20, 20, 20),
      child: Column(
        children: [
          // Brand Details Table
          _buildWebBrandDetails(context, brandData),
          const SizedBox(height: 20),
          // Order Status
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: BrandOrderFinishedOrTawkel(context: context, model: model),
          ),
          const SizedBox(height: 20),
          // Status Timeline
          Expanded(
            child: _buildWebStatusTimeline(context, statusData),
          ),
        ],
      ),
    );
  }

  Widget _buildWebBrandDetails(BuildContext context, List<List<String>> brandData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary,
                  ColorManager.primaryByOpacity,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.info_outline, color: Colors.white, size: isTablet ? 20 : 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "brand_info".tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 18 : 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Detailed brand information and specifications",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: isTablet ? 12 : 14,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Data Grid
          Padding(
            padding: EdgeInsets.all(isTablet ? 16 : 20),
            child: _buildWebDataGrid(context, brandData),
          ),
        ],
      ),
    );
  }

  Widget _buildWebDataGrid(BuildContext context, List<List<String>> brandData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    // تحديد عدد الأعمدة حسب حجم الشاشة
    int crossAxisCount = isTablet ? 1 : 2;
    double childAspectRatio = isTablet ? 4 : 3;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: brandData.length,
      itemBuilder: (context, index) => _buildWebDataCard(context, brandData[index]),
    );
  }

  Widget _buildWebDataCard(BuildContext context, List<String> rowData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rowData[0],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorManager.primary,
              fontFamily: StringConstant.fontName,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            rowData[1],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontFamily: StringConstant.fontName,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWebStatusTimeline(BuildContext context, List<dynamic> statusData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary.withValues(alpha: 0.1),
                  ColorManager.primaryByOpacity.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.timeline, color: Colors.white, size: isTablet ? 20 : 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "brands_status".tr(),
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 20,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.primary,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "brand_status_subTitle".tr(),
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 14,
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
          // Status List
          Expanded(
            child: ListView.separated(
              key: brandStatusListKey,
              controller: scrollController,
              padding: EdgeInsets.all(isTablet ? 16 : 20),
              itemCount: statusData.length,
              separatorBuilder: (context, index) => SizedBox(height: isTablet ? 12 : 16),
              itemBuilder: (context, index) => _buildWebStatusCard(context, statusData[index], index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebStatusCard(BuildContext context, dynamic data, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildStatusWidget(context, data, index),
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