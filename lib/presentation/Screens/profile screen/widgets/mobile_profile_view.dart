import 'dart:io';
import 'package:dots_indicator/dots_indicator.dart';
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

class MobileProfileView extends StatefulWidget {
  const MobileProfileView({super.key});

  @override
  State<MobileProfileView> createState() => _MobileProfileViewState();
}

class _MobileProfileViewState extends State<MobileProfileView> {
  final PageController _partnersController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorManager.primary.withValues(alpha: 0.02),
            Colors.white,
            ColorManager.primaryByOpacity.withValues(alpha: 0.01),
          ],
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // User Profile Header
          SliverToBoxAdapter(
            child: _buildMobileUserHeader(context),
          ),
          
          // Help Center Section
          SliverToBoxAdapter(
            child: _buildMobileHelpCenter(context),
          ),
          
          // Partners Section
          SliverToBoxAdapter(
            child: _buildMobilePartnersSection(context),
          ),
          
          // Footer Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileUserHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Consumer<GetUserProvider>(
          builder: (context, userProvider, child) {
            return Column(
              children: [
                // Profile Avatar with enhanced design
                _buildEnhancedAvatar(userProvider),
                const SizedBox(height: 20),
                
                // User Info
                _buildMobileUserInfo(context, userProvider),
                const SizedBox(height: 16),
                
                // Status Badge
                _buildMobileStatusBadge(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEnhancedAvatar(GetUserProvider userProvider) {
    return GestureDetector(
      onTap: () {
        if (userProvider.state == RequestState.loaded && userProvider.userData != null) {
          _showAvatarFullScreen(userProvider.userData!.avatar);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.3),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: userProvider.state == RequestState.loaded && userProvider.userData != null
                    ? cachedImage(
                        ApiConstant.imagePathUser + userProvider.userData!.avatar,
                        width: 100,
                        height: 100,
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
                          size: 50,
                          color: ColorManager.primary,
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: _buildEnhancedCameraButton(userProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCameraButton(GetUserProvider userProvider) {
    return InkWell(
      onTap: () async {
        await _pickAndUpdateAvatar(userProvider);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.camera_alt,
          color: ColorManager.primary,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildMobileUserInfo(BuildContext context, GetUserProvider userProvider) {
    return Column(
      children: [
        Text(
          userProvider.state == RequestState.loaded && userProvider.userData != null
              ? userProvider.userData!.name
              : globalAccountData.getUsername().toString(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontSize: 22,
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
            fontSize: 16,
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

  Widget _buildMobileStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "active".tr(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHelpCenter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
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
            padding: const EdgeInsets.all(20),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.help_center, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  "help_center".tr(),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 18,
                    color: ColorManager.primary,
                    fontWeight: FontWeight.w700,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
              ],
            ),
          ),
          
          // Help Options
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMobileHelpOption(
                  context,
                  title: 'help'.tr(),
                  subtitle: 'تواصل معنا للحصول على المساعدة',
                  icon: Icons.support_agent,
                  color: Colors.blue.shade600,
                  onTap: _handleContactUs,
                ),
                _buildMobileHelpOption(
                  context,
                  title: 'rate_us'.tr(),
                  subtitle: 'قيم تجربتك معنا',
                  icon: Icons.star_rate,
                  color: Colors.orange.shade600,
                  onTap: _launchRateApp,
                ),
                _buildMobileHelpOption(
                  context,
                  title: 'contact_us'.tr(),
                  subtitle: 'طرق التواصل المختلفة',
                  icon: Icons.contact_phone,
                  color: Colors.green.shade600,
                  onTap: _handleContactUsTap,
                ),
                _buildMobileHelpOption(
                  context,
                  title: 'logout'.tr(),
                  subtitle: 'تسجيل الخروج من الحساب',
                  icon: Icons.logout,
                  color: Colors.red.shade600,
                  onTap: _handleLogoutTap,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHelpOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 16,
                          color: ColorManager.accent,
                          fontWeight: FontWeight.w600,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
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
        ),
        if (!isLast) const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildMobilePartnersSection(BuildContext context) {
    return Consumer<GetSuccessPartners>(
      builder: (context, model, _) {
        if (model.state == RequestState.loading) {
          return _buildPartnersLoadingState();
        } else if (model.state == RequestState.failed) {
          return _buildPartnersErrorState();
        } else if (model.allPartnerSuccess == null || model.allPartnerSuccess!.isEmpty) {
          return _buildNoPartnersState();
        } else {
          return _buildPartnersContent(context, model);
        }
      },
    );
  }

  Widget _buildPartnersContent(BuildContext context, GetSuccessPartners model) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Partners Header
          _buildPartnersHeader(context, model),
          const SizedBox(height: 20),
          
          // Partners PageView
          _buildPartnersPageView(context, model.allPartnerSuccess!),
        ],
      ),
    );
  }

  Widget _buildPartnersHeader(BuildContext context, GetSuccessPartners model) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primaryByOpacity.withValues(alpha: 0.9),
            ColorManager.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business_center, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                "success_partner".tr(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ],
          ),
          if (model.allPartnerSuccess != null && model.allPartnerSuccess!.isNotEmpty) ...[
            const SizedBox(height: 16),
            DotsIndicator(
              dotsCount: (model.allPartnerSuccess!.length / 3).ceil(),
              position: _currentPage.toDouble(),
              decorator: DotsDecorator(
                size: const Size.square(8.0),
                activeColor: Colors.white,
                color: Colors.white.withValues(alpha: 0.5),
                activeSize: const Size(24.0, 8.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartnersPageView(BuildContext context, List<BrandImages> partners) {
    return Container(
      height: MediaQuery.of(context).size.width * 0.32,
      margin: const EdgeInsets.only(top: 10, bottom: 40),
      child: PageView.builder(
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        controller: _partnersController,
        physics: const BouncingScrollPhysics(),
        itemCount: (partners.length / 3).ceil(),
        itemBuilder: (BuildContext context, int pageIndex) {
          int startIndex = pageIndex * 3;
          int endIndex = (startIndex + 3 < partners.length)
              ? startIndex + 3
              : partners.length;

          List<BrandImages> pageItems = partners.sublist(startIndex, endIndex);

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: pageItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.28,
                child: _buildPartnerItem(pageItems[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPartnerItem(BrandImages partner) {
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
            blurRadius: 10,
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

  Widget _buildPartnersLoadingState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: ColorManager.primary.withValues(alpha: 0.3),
            highlightColor: ColorManager.primaryByOpacity.withValues(alpha: 0.1),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: ColorManager.primary.withValues(alpha: 0.3),
                  highlightColor: ColorManager.primaryByOpacity.withValues(alpha: 0.1),
                  child: Container(
                    width: 100,
                    height: 100,
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

  Widget _buildPartnersErrorState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
            "حدث خطأ في تحميل الشركاء",
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPartnersState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.business_outlined, color: Colors.grey.shade600, size: 48),
          const SizedBox(height: 12),
          Text(
            "no_data".tr(),
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _showAvatarFullScreen(String avatar) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: cachedImage(
                    ApiConstant.imagePathUser + avatar,
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.9,
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.close, color: Colors.white),
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