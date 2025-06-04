import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kyuser/core/Constant/Api_Constant.dart';
import 'package:kyuser/presentation/Screens/home%20screen/HomeScreen.dart';

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
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 16 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(context),
                const SizedBox(height: 32),

                // Main Content
                isTablet
                    ? _buildTabletLayout(context)
                    : _buildDesktopLayout(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        // Brand Images Section - Full Width
        _buildBrandImagesCard(context),
        const SizedBox(height: 32),

        // User Info, Download, and Basic Details in Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Expanded(
              flex: 2,
              child: _buildUserInfoCard(context),
            ),
            const SizedBox(width: 20),

            // Download Button
            Expanded(
              flex: 2,
              child: _buildDownloadCard(context),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Brand Details Section
        _buildBrandDetailsSection(context),
        const SizedBox(height: 24),

        // Order Status Section
        _buildOrderStatusSection(context),
        const SizedBox(height: 24),

        // Status Timeline Section
        _buildStatusTimelineSection(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column - Brand Images & User Info
        Expanded(
          flex: 2,
          child: _buildLeftColumn(context),
        ),
        const SizedBox(width: 32),

        // Right Column - Brand Details & Status
        Expanded(
          flex: 3,
          child: _buildRightColumn(context),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.primary,
            ColorManager.primaryByOpacity,
            ColorManager.primary.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.business,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "تفاصيل العلامة".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFamily: StringConstant.fontName,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "معلومات شاملة عن العلامة التجارية وحالة الطلب",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontFamily: StringConstant.fontName,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // Tutorial Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTutorialTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.help_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "مساعدة",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: StringConstant.fontName,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      children: [
        // Brand Images - Clean Display
        _buildBrandImagesCard(context),
        const SizedBox(height: 32),

        // User Info Card
        _buildUserInfoCard(context),
        const SizedBox(height: 24),

        // Download Button
        _buildDownloadCard(context),
      ],
    );
  }

  Widget _buildBrandImagesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColorManager.primaryByOpacity, width: 1)),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: cachedImage(
              ApiConstant.imagePath + model.brandDetails!.images[0].image,
              fit: BoxFit.contain,
              height: 300,
              width: 300)),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
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
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // User Name
          Text(
            globalAccountData.getUsername() ?? 'المستخدم',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            globalAccountData.getEmail() ?? 'user@example.com',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF64748B),
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Verified Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ColorManager.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: ColorManager.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user,
                    color: ColorManager.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  "حساب موثق",
                  style: TextStyle(
                    color: ColorManager.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

  Widget _buildDownloadCard(BuildContext context) {
    return Container(
      key: downloadPdfKey,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary,
            ColorManager.primaryByOpacity,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDownloadTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.file_download_outlined,
                    color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text(
                  "download_pdf".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "تحميل ملف PDF بتفاصيل العلامة التجارية",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontFamily: StringConstant.fontName,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Column(
      children: [
        // Brand Details Section
        _buildBrandDetailsSection(context),
        const SizedBox(height: 24),

        // Order Status Section
        _buildOrderStatusSection(context),
        const SizedBox(height: 24),

        // Status Timeline Section
        _buildStatusTimelineSection(context),
      ],
    );
  }

  Widget _buildBrandDetailsSection(BuildContext context) {
    final brandData = _buildBrandData(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.info_outline, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "تفاصيل العلامة التجارية",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "معلومات أساسية ومفصلة عن العلامة التجارية",
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Brand Data List
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildModernDataGrid(context, brandData),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDataGrid(
      BuildContext context, List<List<String>> brandData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: brandData.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = brandData[index];
        final isLongText = item[1].length > 100;
        
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isTablet ? 20 : 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: ColorManager.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item[0],
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 16,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.primary,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                    ),
                    if (isLongText)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "نص مفصل",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.primary,
                            fontFamily: StringConstant.fontName,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: isLongText ? 80 : 60,
                  ),
                  padding: EdgeInsets.all(isLongText ? 20 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SelectableText(
                    item[1],
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                      fontFamily: StringConstant.fontName,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: BrandOrderFinishedOrTawkel(context: context, model: model),
      ),
    );
  }

  Widget _buildStatusTimelineSection(BuildContext context) {
    final statusData = model.brandDetails!.AllResult;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.timeline, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "brands_status".tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "brand_status_subTitle".tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
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
          Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: ListView.separated(
              key: brandStatusListKey,
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: statusData.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        _buildStatusWidget(context, statusData[index], index),
                  ),
                );
              },
            ),
          ),
        ],
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
        _getPowerOfAttorneyStatus(
            model.brandDetails!.brand.completedPowerOfAttorneyRequest),
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
      return RefusedWidget(
          brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "الطعن ضد التظلم") {
      return AppealGrivenceWidget(
          brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "التظلم") {
      return GrievanceWidget(
          brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "قرار لجنه التظلم") {
      return GrievanceTeamDecisionWidget(
          brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "التجديدات") {
      return RenovationsWidget(
          brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == "قبول مشترط") {
      return ConditionalAcceptanceWidget(
          brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == StringConstant.giveUp) {
      return GiveUpWidget(
          brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    if (data.states == StringConstant.appealBrandRegistration) {
      return AppealBrandRegistration(
          brandDetailsDataEntity: model.brandDetails!, number: index);
    }
    return const SizedBox.shrink();
  }
}
