import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';

class WebContactsView extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback? onBack;
  final bool canBack;

  const WebContactsView({
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
          // Header with Animation and Info
          _buildTabletHeader(context),
          const SizedBox(height: 24),
          // Contact Grid - 2 columns for tablet
          _buildContactGrid(context, crossAxisCount: 2),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left Panel - Animation and Company Info
        Expanded(
          flex: 2,
          child: _buildLeftPanel(context),
        ),
        // Right Panel - Contact Information
        Expanded(
          flex: 3,
          child: _buildRightPanel(context),
        ),
      ],
    );
  }

  Widget _buildTabletHeader(BuildContext context) {
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
          // Animation
          Expanded(
            flex: 2,
            child: _buildAnimationWidget(context, size: 200),
          ),
          const SizedBox(width: 32),
          // Company Info
          Expanded(
            flex: 3,
            child: _buildCompanyInfo(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation
          _buildAnimationCard(context),
          const SizedBox(height: 24),
          // Company Information
          _buildCompanyInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildAnimationCard(BuildContext context) {
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
      child: _buildAnimationWidget(context, size: 280),
    );
  }

  Widget _buildAnimationWidget(BuildContext context, {required double size}) {
    return Container(
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
    );
  }

  Widget _buildCompanyInfoCard(BuildContext context) {
    return Container(
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
      child: _buildCompanyInfo(context),
    );
  }

  Widget _buildCompanyInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Logo/Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorManager.primary,
                ColorManager.primaryByOpacity,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.business, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 16),
        
        Text(
          "call_us".tr(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 28,
            color: ColorManager.primary,
            fontWeight: FontWeight.w700,
            fontFamily: StringConstant.fontName,
          ),
        ),
        const SizedBox(height: 8),
        
        Text(
          "نحن هنا لمساعدتك في جميع احتياجاتك المتعلقة بالعلامات التجارية",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
            fontFamily: StringConstant.fontName,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        
        // Business Hours
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorManager.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorManager.primary.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, color: ColorManager.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Business Hours",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.primary,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "الأحد - الخميس: 9:00 صباحاً - 6:00 مساءً",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 20, 20, 20),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary.withValues(alpha: 0.1),
                  ColorManager.primaryByOpacity.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
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
                  child: Icon(Icons.contact_phone, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contact Information",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.primary,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Get in touch with us using any of the methods below",
                        style: TextStyle(
                          fontSize: 14,
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
          const SizedBox(height: 20),
          
          // Contact Grid
          Expanded(
            child: _buildContactGrid(context, crossAxisCount: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildContactGrid(BuildContext context, {required int crossAxisCount}) {
    final contactItems = [
      {
        'title': "address".tr(),
        'icon': Icons.location_on_outlined,
        'colors': [Colors.red.shade400, Colors.red.shade600],
        'widget': _buildAddressCard(context),
      },
      {
        'title': "by_phone".tr(),
        'icon': Icons.phone_outlined,
        'colors': [Colors.green.shade400, Colors.green.shade600],
        'widget': _buildPhoneCard(context),
      },
      {
        'title': "by_email".tr(),
        'icon': Icons.email_outlined,
        'colors': [Colors.blue.shade400, Colors.blue.shade600],
        'widget': _buildEmailCard(context),
      },
      {
        'title': "by_social".tr(),
        'icon': Icons.share_outlined,
        'colors': [Colors.purple.shade400, Colors.purple.shade600],
        'widget': _buildSocialCard(context),
      },
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: contactItems.length,
      itemBuilder: (context, index) {
        final item = contactItems[index];
        return _buildWebContactCard(
          context: context,
          title: item['title'] as String,
          icon: item['icon'] as IconData,
          gradientColors: item['colors'] as List<Color>,
          child: item['widget'] as Widget,
        );
      },
    );
  }

  Widget _buildWebContactCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required Widget child,
  }) {
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
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
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.home, color: Colors.red.shade600, size: 32),
        const SizedBox(height: 12),
        Flexible(
          child: Text(
            "فيلا 193 الحي الخامس التجمع الخامس القاهره الجديده",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 14,
              fontFamily: StringConstant.fontName,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneCard(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWebContactItem(
          context: context,
          icon: Icons.phone,
          text: "+201004000856",
          color: Colors.green.shade600,
          onTap: () => _launchPhoneCall("+201004000856"),
        ),
        const SizedBox(height: 8),
        _buildWebContactItem(
          context: context,
          icon: Icons.phone,
          text: "+0225608189",
          color: Colors.green.shade600,
          onTap: () => _launchPhoneCall("+0225608189"),
        ),
      ],
    );
  }

  Widget _buildEmailCard(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWebContactItem(
          context: context,
          icon: Icons.email,
          text: "info@kytrademarks.com",
          color: Colors.blue.shade600,
          onTap: () => _launchURL('mailto:info@kytrademarks.com'),
        ),
      ],
    );
  }

  Widget _buildSocialCard(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWebContactItem(
          context: context,
          icon: Icons.language,
          text: "Website",
          color: Colors.purple.shade600,
          onTap: () => _launchURL('https://kytrademarks.com/'),
        ),
        const SizedBox(height: 6),
        _buildWebContactItem(
          context: context,
          icon: Icons.camera_alt,
          text: "Instagram",
          color: Colors.purple.shade600,
          onTap: () => _launchURL('https://instagram.com/ky.trademarks.eg'),
        ),
        const SizedBox(height: 6),
        _buildWebContactItem(
          context: context,
          icon: Icons.facebook,
          text: "Facebook",
          color: Colors.purple.shade600,
          onTap: () => _launchURL('https://facebook.com/ky.trademarks.eg'),
        ),
      ],
    );
  }

  Widget _buildWebContactItem({
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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontFamily: StringConstant.fontName,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 