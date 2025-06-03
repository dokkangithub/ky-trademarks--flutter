import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';

class MobileContactsView extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback? onBack;
  final bool canBack;

  const MobileContactsView({
    required this.animationController,
    required this.canBack,
    this.onBack,
    super.key,
  });

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel://$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch phone call to $phoneNumber');
    }
  }

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
          // Header Animation
          SliverToBoxAdapter(
            child: _buildMobileHeader(context),
          ),
          
          // Contact Sections
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMobileContactCard(
                  context: context,
                  title: "address".tr(),
                  icon: Icons.location_on_outlined,
                  gradientColors: [Colors.red.shade400, Colors.red.shade600],
                  child: _buildAddressContent(context),
                ),
                const SizedBox(height: 16),
                
                _buildMobileContactCard(
                  context: context,
                  title: "by_phone".tr(),
                  icon: Icons.phone_outlined,
                  gradientColors: [Colors.green.shade400, Colors.green.shade600],
                  child: _buildPhoneContent(context),
                ),
                const SizedBox(height: 16),
                
                _buildMobileContactCard(
                  context: context,
                  title: "by_email".tr(),
                  icon: Icons.email_outlined,
                  gradientColors: [Colors.blue.shade400, Colors.blue.shade600],
                  child: _buildEmailContent(context),
                ),
                const SizedBox(height: 16),
                
                _buildMobileContactCard(
                  context: context,
                  title: "by_social".tr(),
                  icon: Icons.share_outlined,
                  gradientColors: [Colors.purple.shade400, Colors.purple.shade600],
                  child: _buildSocialContent(context),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = screenWidth * 0.5;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      padding: const EdgeInsets.all(24),
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
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary.withValues(alpha: 0.1),
                  ColorManager.primaryByOpacity.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Lottie.asset(
              "assets/images/lf30_editor_liiftrlk.json",
              width: size,
              height: size,
              fit: BoxFit.scaleDown,
              controller: animationController,
              onLoaded: (composition) {
                animationController
                  ..duration = composition.duration
                  ..forward();
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "call_us".tr(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 24,
              color: ColorManager.primary,
              fontWeight: FontWeight.w700,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "contact_subtitle".tr(),
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

  Widget _buildMobileContactCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
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
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorManager.anotherTabBackGround,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.home, color: Colors.red.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "فيلا 193 الحي الخامس التجمع الخامس القاهره الجديده",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 14,
                fontFamily: StringConstant.fontName,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneContent(BuildContext context) {
    return Column(
      children: [
        _buildMobileContactItem(
          context: context,
          icon: Icons.phone,
          text: "+201004000856",
          color: Colors.green.shade600,
          onTap: () => _launchPhoneCall("+201004000856"),
        ),
        const SizedBox(height: 12),
        _buildMobileContactItem(
          context: context,
          icon: Icons.phone,
          text: "+0225608189",
          color: Colors.green.shade600,
          onTap: () => _launchPhoneCall("+0225608189"),
        ),
      ],
    );
  }

  Widget _buildEmailContent(BuildContext context) {
    return _buildMobileContactItem(
      context: context,
      icon: Icons.email,
      text: "info@kytrademarks.com",
      color: Colors.blue.shade600,
      onTap: () => _launchURL('mailto:info@kytrademarks.com'),
    );
  }

  Widget _buildSocialContent(BuildContext context) {
    return Column(
      children: [
        _buildMobileContactItem(
          context: context,
          icon: Icons.language,
          text: "kytrademarks.com",
          color: Colors.purple.shade600,
          onTap: () => _launchURL('https://kytrademarks.com/'),
        ),
        const SizedBox(height: 12),
        _buildMobileContactItem(
          context: context,
          icon: Icons.camera_alt,
          text: "Instagram",
          color: Colors.purple.shade600,
          onTap: () => _launchURL('https://instagram.com/ky.trademarks.eg'),
        ),
        const SizedBox(height: 12),
        _buildMobileContactItem(
          context: context,
          icon: Icons.facebook,
          text: "Facebook",
          color: Colors.purple.shade600,
          onTap: () => _launchURL('https://facebook.com/ky.trademarks.eg'),
        ),
      ],
    );
  }

  Widget _buildMobileContactItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ColorManager.anotherTabBackGround,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 14,
                    fontFamily: StringConstant.fontName,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
} 