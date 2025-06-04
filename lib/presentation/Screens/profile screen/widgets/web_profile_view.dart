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
import '../ProfileScreen.dart';

class WebProfileView extends StatefulWidget {
  final ScreenType screenType;
  
  const WebProfileView({super.key, required this.screenType});

  @override
  State<WebProfileView> createState() => _WebProfileViewState();
}

class _WebProfileViewState extends State<WebProfileView> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return _buildMobileLayout(context);
          } else {
            return _buildDesktopLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSimpleUserCard(context),
          const SizedBox(height: 24),
          _buildSimpleActionsCard(context),
          const SizedBox(height: 24),
          _buildSimplePartnersCard(context),

        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Card
          SizedBox(
            width: 320,
            child: _buildSimpleUserCard(context),
          ),
          const SizedBox(width: 32),
          
          // Main Content
          Expanded(
            child: Column(
              children: [

                // Actions Section
                _buildSimpleActionsCard(context),

                const SizedBox(height: 24),
                // Partners Section
                Expanded(
                  child: _buildSimplePartnersCard(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleUserCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Consumer<GetUserProvider>(
        builder: (context, userProvider, child) {
          return Column(
            children: [
              // User Avatar
              _buildUserAvatar(userProvider),
              const SizedBox(height: 20),
              
              // User Name
              Text(
                userProvider.state == RequestState.loaded && 
                       userProvider.userData != null
                    ? userProvider.userData!.name
                    : globalAccountData.getUsername().toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  fontFamily: StringConstant.fontName,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // User Email
              Text(
                userProvider.state == RequestState.loaded && 
                       userProvider.userData != null
                    ? userProvider.userData!.email
                    : globalAccountData.getEmail().toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontFamily: StringConstant.fontName,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green.shade500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "active".tr(),
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: StringConstant.fontName,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserAvatar(GetUserProvider userProvider) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 2),
            color: Colors.grey.shade50,
          ),
          child: ClipOval(
            child: userProvider.state == RequestState.loaded && 
                   userProvider.userData != null
                ? cachedImage(
                    ApiConstant.imagePathUser + userProvider.userData!.avatar,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _pickAndUpdateAvatar(userProvider),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimplePartnersCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.business_rounded,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  "success_partner".tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(
            height: 1,
            color: Colors.grey.shade200,
            indent: 20,
            endIndent: 20,
          ),
          
          // Partners Grid
          Expanded(
            child: Consumer<GetSuccessPartners>(
              builder: (context, model, _) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildPartnersGrid(context, model),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersGrid(BuildContext context, GetSuccessPartners model) {
    if (model.state == RequestState.loading) {
      return _buildLoadingGrid();
    } else if (model.state == RequestState.failed) {
      return _buildErrorState();
    } else if (model.allPartnerSuccess == null || model.allPartnerSuccess!.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildPartnersGridView(model.allPartnerSuccess!);
    }
  }

  Widget _buildPartnersGridView(List<BrandImages> partners) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: partners.length,
          itemBuilder: (context, index) {
            return _buildPartnerItem(partners[index]);
          },
        );
      },
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width < 400) return 3;
    if (width < 600) return 4;
    if (width < 800) return 5;
    if (width < 1000) return 6;
    return 7;
  }

  Widget _buildPartnerItem(BrandImages partner) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: cachedImage(
          ApiConstant.imagePathPartners + partner.image,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: crossAxisCount * 3,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.grey.shade400,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            "حدث خطأ في تحميل الشركاء",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            color: Colors.grey.shade400,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            "no_data".tr(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleActionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_rounded,
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                "help_center".tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Mobile layout - vertical
                return Column(
                  children: _buildActionButtons(),
                );
              } else {
                // Desktop layout - horizontal
                return Row(
                  children: _buildActionButtons().map((widget) {
                    if (widget is SizedBox) {
                      return const SizedBox(width: 16);
                    }
                    return Expanded(child: widget);
                  }).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    return [
      _buildActionButton(
        icon: Icons.support_agent_rounded,
        title: 'help'.tr(),
        onTap: _handleContactUs,
      ),
      const SizedBox(height: 16),
      _buildActionButton(
        icon: Icons.star_rate_rounded,
        title: 'rate_us'.tr(),
        onTap: _launchRateApp,
      ),
      const SizedBox(height: 16),
      _buildActionButton(
        icon: Icons.contact_phone_rounded,
        title: 'contact_us'.tr(),
        onTap: _handleContactUsTap,
      ),
      const SizedBox(height: 16),
      _buildActionButton(
        icon: Icons.logout_rounded,
        title: 'logout'.tr(),
        onTap: _handleLogoutTap,
        isDestructive: true,
      ),
    ];
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red.shade600 : Colors.grey.shade600;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                    fontFamily: StringConstant.fontName,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.5),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  Future<void> _pickAndUpdateAvatar(GetUserProvider userProvider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

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
      debugPrint('Error in contact us: $e');
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
      debugPrint('Error opening WhatsApp: $e');
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
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "note".tr(),
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'logoutCaught'.tr(),
            style: TextStyle(
              fontSize: 14,
              fontFamily: StringConstant.fontName,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'no'.tr(),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontFamily: StringConstant.fontName,
                  fontWeight: FontWeight.w500,
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
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontFamily: StringConstant.fontName,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 