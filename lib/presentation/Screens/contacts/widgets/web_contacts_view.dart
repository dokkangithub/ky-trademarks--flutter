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
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(context),
            
            // Contact Section
            _buildContactSection(context),
            
            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Lottie.asset(
        "assets/images/lf30_editor_liiftrlk.json",
        width: 280,
        height: 280,
        fit: BoxFit.contain,
        controller: animationController,
        onLoaded: (composition) {
          animationController
            ..duration = composition.duration
            ..forward();
        },
      ),
    );
  }

  Widget _buildQuickContactBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: StringConstant.fontName,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? Colors.transparent : Colors.white,
        foregroundColor: isSecondary ? Colors.white : ColorManager.primary,
        side: isSecondary ? const BorderSide(color: Colors.white, width: 2) : null,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isSecondary ? 0 : 4,
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          // Section Title
          Text(
            "طرق التواصل",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              fontFamily: StringConstant.fontName,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "يمكنك التواصل معنا بأي من الطرق التالية",
            style: TextStyle(
              fontSize: 18,
              color: const Color(0xFF64748B),
              fontFamily: StringConstant.fontName,
            ),
          ),
          const SizedBox(height: 60),
          
          // Contact Cards Grid
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 3 : 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.1,
              children: [
                _buildModernContactCard(
                  icon: Icons.location_on,
                  title: "العنوان",
                  content: "فيلا 193 الحي الخامس\nالتجمع الخامس\nالقاهرة الجديدة",
                  color: const Color(0xFFEF4444),
                  onTap: () {},
                ),
                _buildModernContactCard(
                  icon: Icons.phone,
                  title: "الهاتف",
                  content: "+201004000856\n+0225608189",
                  color: const Color(0xFF10B981),
                  onTap: () => _launchPhoneCall("+201004000856"),
                ),
                _buildModernContactCard(
                  icon: Icons.email,
                  title: "البريد الإلكتروني",
                  content: "info@kytrademarks.com",
                  color: const Color(0xFF3B82F6),
                  onTap: () => _launchURL('mailto:info@kytrademarks.com'),
                ),
                _buildModernContactCard(
                  icon: Icons.language,
                  title: "الموقع الإلكتروني",
                  content: "kytrademarks.com",
                  color: const Color(0xFF8B5CF6),
                  onTap: () => _launchURL('https://kytrademarks.com/'),
                ),
                _buildModernContactCard(
                  icon: Icons.access_time,
                  title: "ساعات العمل",
                  content: "الأحد - الخميس\n9:00 ص - 6:00 م",
                  color: const Color(0xFFF59E0B),
                  onTap: () {},
                ),
                _buildModernContactCard(
                  icon: Icons.share,
                  title: "مواقع التواصل",
                  content: "Facebook\nInstagram",
                  color: const Color(0xFFEC4899),
                  onTap: () => _showSocialLinks(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernContactCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
                fontFamily: StringConstant.fontName,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF64748B),
                fontFamily: StringConstant.fontName,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSocialLinks(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "مواقع التواصل الاجتماعي",
          style: TextStyle(
            fontFamily: StringConstant.fontName,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSocialButton(
              icon: Icons.facebook,
              label: "Facebook",
              color: const Color(0xFF1877F2),
              onTap: () => _launchURL('https://facebook.com/ky.trademarks.eg'),
            ),
            const SizedBox(height: 12),
            _buildSocialButton(
              icon: Icons.camera_alt,
              label: "Instagram",
              color: const Color(0xFFE4405F),
              onTap: () => _launchURL('https://instagram.com/ky.trademarks.eg'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          label,
          style: TextStyle(
            fontFamily: StringConstant.fontName,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
      ),
      child: Center(
        child: Text(
          "© 2024 KY Trademarks. جميع الحقوق محفوظة",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontFamily: StringConstant.fontName,
          ),
        ),
      ),
    );
  }
} 