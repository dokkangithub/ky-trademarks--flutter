import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../../../app/RequestState/RequestState.dart';
import '../../../../core/Constant/Api_Constant.dart';
import '../../../../data/Brand/DataSource/GetBrandRemotoData.dart';
import '../../../../domain/Brand/Entities/BrandEntity.dart';
import '../../../../network/RestApi/Comman.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';
import '../../../../utilits/Local_User_Data.dart';
import '../../../Controllar/GetSuccessPartners.dart';
import '../../../Controllar/userProvider.dart';
import '../../contacts/contacts.dart';

class WebProfileView extends StatefulWidget {
  const WebProfileView({super.key});

  @override
  State<WebProfileView> createState() => _WebProfileViewState();
}

class _WebProfileViewState extends State<WebProfileView> {

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
          // User Profile Header
          _buildTabletUserHeader(context),
          const SizedBox(height: 24),
          
          // Help Center and Partners Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Help Center
              Expanded(
                flex: 2,
                child: _buildWebHelpCenter(context, isTablet: true),
              ),
              const SizedBox(width: 20),
              
              // Partners Section
              Expanded(
                flex: 3,
                child: _buildWebPartnersSection(context, isTablet: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left Panel - User Profile and Help Center
        Expanded(
          flex: 2,
          child: _buildLeftPanel(context),
        ),
        // Right Panel - Partners and Stats
        Expanded(
          flex: 3,
          child: _buildRightPanel(context),
        ),
      ],
    );
  }

  Widget _buildTabletUserHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar and Basic Info
          Expanded(
            flex: 2,
            child: _buildUserProfileCard(context, isTablet: true),
          ),
          const SizedBox(width: 32),
          
          // User Stats and Status
          Expanded(
            flex: 3,
            child: _buildUserStatsCard(context, isTablet: true),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // User Profile Card
          _buildUserProfileCard(context, isTablet: false),
          const SizedBox(height: 24),
          
          // Help Center
          Expanded(
            child: _buildWebHelpCenter(context, isTablet: false),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 20, 20, 20),
      child: Column(
        children: [
          // User Stats
          _buildUserStatsCard(context, isTablet: false),
          const SizedBox(height: 24),
          
          // Partners Section
          Expanded(
            child: _buildWebPartnersSection(context, isTablet: false),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, {required bool isTablet}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primaryByOpacity.withValues(alpha: 0.9),
            ColorManager.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Consumer<GetUserProvider>(
        builder: (context, userProvider, child) {
          return Column(
            children: [
              // Enhanced Avatar
              _buildWebAvatar(userProvider, isTablet: isTablet),
              SizedBox(height: isTablet ? 20 : 24),
              
              // User Info
              _buildWebUserInfo(context, userProvider, isTablet: isTablet),
              SizedBox(height: isTablet ? 16 : 20),
              
              // Status Badge
              _buildWebStatusBadge(context, isTablet: isTablet),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWebAvatar(GetUserProvider userProvider, {required bool isTablet}) {
    final avatarSize = isTablet ? 100.0 : 120.0;
    
    return GestureDetector(
      onTap: () {
        if (userProvider.state == RequestState.loaded && userProvider.userData != null) {
          _showAvatarFullScreen(userProvider.userData!.avatar);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: userProvider.state == RequestState.loaded && userProvider.userData != null
                    ? cachedImage(
                        ApiConstant.imagePathUser + userProvider.userData!.avatar,
                        width: avatarSize,
                        height: avatarSize,
                        fit: BoxFit.cover,
                        placeHolderFit: BoxFit.cover,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: avatarSize * 0.5,
                          color: ColorManager.primary,
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: _buildWebCameraButton(userProvider, isTablet: isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebCameraButton(GetUserProvider userProvider, {required bool isTablet}) {
    return InkWell(
      onTap: () async {
        await _pickAndUpdateAvatar(userProvider);
      },
      child: Container(
        padding: EdgeInsets.all(isTablet ? 10 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.camera_alt,
          color: ColorManager.primary,
          size: isTablet ? 20 : 24,
        ),
      ),
    );
  }

  Widget _buildWebUserInfo(BuildContext context, GetUserProvider userProvider, {required bool isTablet}) {
    return Column(
      children: [
        Text(
          userProvider.state == RequestState.loaded && userProvider.userData != null
              ? userProvider.userData!.name
              : globalAccountData.getUsername().toString(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontSize: isTablet ? 24 : 28,
            fontWeight: FontWeight.w700,
            fontFamily: StringConstant.fontName,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          userProvider.state == RequestState.loaded && userProvider.userData != null
              ? userProvider.userData!.email
              : globalAccountData.getEmail().toString(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: isTablet ? 16 : 18,
            fontWeight: FontWeight.w500,
            fontFamily: StringConstant.fontName,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildWebStatusBadge(BuildContext context, {required bool isTablet}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 20,
        vertical: isTablet ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "active".tr(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontSize: isTablet ? 14 : 16,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatsCard(BuildContext context, {required bool isTablet}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 32),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.analytics, color: ColorManager.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                "إحصائيات الحساب",
                style: TextStyle(
                  fontSize: isTablet ? 18 : 22,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.primary,
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 24),
          
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "سنوات الخبرة",
                  "10+",
                  Icons.timeline,
                  Colors.blue.shade600,
                  isTablet: isTablet,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  "العلامات المسجلة",
                  "1000+",
                  Icons.verified,
                  Colors.green.shade600,
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "العملاء",
                  "500+",
                  Icons.people,
                  Colors.orange.shade600,
                  isTablet: isTablet,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  "التقييم",
                  "4.9★",
                  Icons.star,
                  Colors.amber.shade600,
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, {required bool isTablet}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isTablet ? 20 : 24),
          SizedBox(height: isTablet ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 16 : 20,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: StringConstant.fontName,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 11 : 12,
              color: Colors.grey.shade600,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWebHelpCenter(BuildContext context, {required bool isTablet}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                  ColorManager.primary.withValues(alpha: 0.1),
                  ColorManager.primaryByOpacity.withValues(alpha: 0.05),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.help_center, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  "help_center".tr(),
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 22,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.primary,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
              ],
            ),
          ),
          
          // Help Options
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 20),
              child: Column(
                children: [
                  _buildWebHelpOption(
                    context,
                    title: 'help'.tr(),
                    subtitle: 'تواصل معنا للحصول على المساعدة',
                    icon: Icons.support_agent,
                    color: Colors.blue.shade600,
                    onTap: _handleContactUs,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isTablet ? 12 : 16),
                  _buildWebHelpOption(
                    context,
                    title: 'rate_us'.tr(),
                    subtitle: 'قيم تجربتك معنا',
                    icon: Icons.star_rate,
                    color: Colors.orange.shade600,
                    onTap: _launchRateApp,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isTablet ? 12 : 16),
                  _buildWebHelpOption(
                    context,
                    title: 'contact_us'.tr(),
                    subtitle: 'طرق التواصل المختلفة',
                    icon: Icons.contact_phone,
                    color: Colors.green.shade600,
                    onTap: _handleContactUsTap,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isTablet ? 12 : 16),
                  _buildWebHelpOption(
                    context,
                    title: 'logout'.tr(),
                    subtitle: 'تسجيل الخروج من الحساب',
                    icon: Icons.logout,
                    color: Colors.red.shade600,
                    onTap: _handleLogoutTap,
                    isTablet: isTablet,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebHelpOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 10 : 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: isTablet ? 20 : 24),
            ),
            SizedBox(width: isTablet ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: isTablet ? 16 : 18,
                      color: ColorManager.accent,
                      fontWeight: FontWeight.w600,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: isTablet ? 13 : 14,
                      color: Colors.grey.shade600,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWebPartnersSection(BuildContext context, {required bool isTablet}) {
    return Consumer<GetSuccessPartners>(
      builder: (context, model, _) {
        if (model.state == RequestState.loading) {
          return _buildPartnersLoadingState(isTablet: isTablet);
        } else if (model.state == RequestState.failed) {
          return _buildPartnersErrorState(isTablet: isTablet);
        } else if (model.allPartnerSuccess == null || model.allPartnerSuccess!.isEmpty) {
          return _buildNoPartnersState(isTablet: isTablet);
        } else {
          return _buildPartnersContent(context, model, isTablet: isTablet);
        }
      },
    );
  }

  Widget _buildPartnersContent(BuildContext context, GetSuccessPartners model, {required bool isTablet}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Partners Header
          _buildWebPartnersHeader(context, model, isTablet: isTablet),
          
          // Partners Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 20),
              child: _buildPartnersGrid(context, model.allPartnerSuccess!, isTablet: isTablet),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebPartnersHeader(BuildContext context, GetSuccessPartners model, {required bool isTablet}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primaryByOpacity.withValues(alpha: 0.9),
            ColorManager.primary,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_center, color: Colors.white, size: isTablet ? 24 : 28),
          const SizedBox(width: 12),
          Text(
            "success_partner".tr(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontSize: isTablet ? 18 : 22,
              fontWeight: FontWeight.w700,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersGrid(BuildContext context, List<BrandImages> partners, {required bool isTablet}) {
    final crossAxisCount = isTablet ? 5 : 7;
    
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isTablet ? 12 : 16,
        mainAxisSpacing: isTablet ? 12 : 16,
        childAspectRatio: 1.0,
      ),
      itemCount: partners.length,
      itemBuilder: (context, index) {
        return _buildWebPartnerItem(partners[index], isTablet: isTablet);
      },
    );
  }

  Widget _buildWebPartnerItem(BrandImages partner, {required bool isTablet}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorManager.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: cachedImage(
          ApiConstant.imagePathPartners + partner.image,
          placeHolderFit: BoxFit.contain,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildPartnersLoadingState({required bool isTablet}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header shimmer
          Shimmer.fromColors(
            baseColor: ColorManager.primary.withValues(alpha: 0.3),
            highlightColor: ColorManager.primaryByOpacity.withValues(alpha: 0.1),
            child: Container(
              height: isTablet ? 60 : 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Grid shimmer
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 5 : 7,
                crossAxisSpacing: isTablet ? 12 : 16,
                mainAxisSpacing: isTablet ? 12 : 16,
                childAspectRatio: 1.0,
              ),
              itemCount: isTablet ? 15 : 21,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: ColorManager.primary.withValues(alpha: 0.3),
                  highlightColor: ColorManager.primaryByOpacity.withValues(alpha: 0.1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersErrorState({required bool isTablet}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: isTablet ? 48 : 64),
          SizedBox(height: isTablet ? 16 : 20),
          Text(
            "حدث خطأ في تحميل الشركاء",
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: isTablet ? 16 : 18,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoPartnersState({required bool isTablet}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, color: Colors.grey.shade600, size: isTablet ? 48 : 64),
          SizedBox(height: isTablet ? 16 : 20),
          Text(
            "no_data".tr(),
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: isTablet ? 16 : 18,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods (same as mobile)
  void _showAvatarFullScreen(String avatar) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(40),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: cachedImage(
                    ApiConstant.imagePathUser + avatar,
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpdateAvatar(GetUserProvider userProvider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await userProvider.updateUserAvatar(avatarFile: imageFile);
    }
  }

  void _handleContactUs() async {
    try {
      final getBrandRemoteData = GetBrandRemoteData();
      final String phoneNumber = await getBrandRemoteData.adminPhone();

      if (phoneNumber.isNotEmpty) {
        await _openWhatsappCrossPlatform(
          context: context,
          number: phoneNumber,
          text: "من فضلك , اريد انشاء حساب جديد",
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _openWhatsappCrossPlatform({
    required BuildContext context,
    required String number,
    required String text,
  }) async {
    String formattedNumber = number.replaceAll('+', '');
    String encodedText = Uri.encodeComponent(text);
    final String urlString = kIsWeb
        ? "https://web.whatsapp.com/send?phone=$formattedNumber&text=$encodedText"
        : "https://wa.me/$formattedNumber?text=$encodedText";
    final Uri url = Uri.parse(urlString);

    try {
      await launcher.launchUrl(
        url,
        mode: launcher.LaunchMode.externalApplication,
        webOnlyWindowName: kIsWeb ? '_blank' : null,
      );
    } catch (e) {
      // Handle error
    }
  }

  void _launchRateApp() {
    if (!kIsWeb) {
      final appId = Platform.isAndroid ? 'com.kytrademarkstrademarks' : '1605389392';
      final url = Uri.parse(
        Platform.isAndroid
            ? "market://details?id=$appId"
            : "https://apps.apple.com/app/id$appId",
      );
      launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      final playStoreUrl = Uri.parse("https://play.google.com/store/apps/details?id=com.kytrademarks");
      final appStoreUrl = Uri.parse("https://apps.apple.com/app/id1605389392");
      launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
      launchUrl(appStoreUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _handleContactUsTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Contacts(canBack: true),
      ),
    );
  }

  void _handleLogoutTap() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "note".tr(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'logoutCaught'.tr(),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: 14,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorManager.primary,
                    ColorManager.primaryByOpacity.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(45),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'no'.tr(),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                logOut().then((value) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/MainTabs",
                    (route) => false,
                  );
                });
              },
              child: Text(
                'yes'.tr(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 