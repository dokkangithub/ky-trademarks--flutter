import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../resources/Color_Manager.dart';
import '../../resources/StringManager.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key, required this.canBack});
  final bool canBack ;

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      backgroundColor: Colors.grey[100], // Subtle background for large screens
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          return SafeArea(
            child: Center(
              child: isLargeScreen
                  ? _buildLargeScreenLayout(context, constraints)
                  : _buildSmallScreenLayout(context, constraints),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 60,
      centerTitle: true,
      title: Text(
        "call_us".tr(),
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: 16,
          color: Colors.white,
            fontFamily:StringConstant.fontName
        ),
      ),
      leading: widget.canBack? IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: ColorManager.white, size: 22),
        onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
      ):SizedBox.shrink(),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      flexibleSpace: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorManager.primaryByOpacity.withOpacity(0.9),
              ColorManager.primary,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context, BoxConstraints constraints) {
    return Container(
      width: 800, // Fixed width for large screens
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeaderAnimation(constraints),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildContactColumnLeft(context)),
                  const SizedBox(width: 32),
                  Expanded(child: _buildContactColumnRight(context)),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05, // 5% padding
          vertical: 16,
        ),
        child: Column(
          children: [
            _buildHeaderAnimation(constraints),
            const SizedBox(height: 24),
            _buildAddressSection(context),
            const SizedBox(height: 20),
            _buildPhoneSection(context),
            const SizedBox(height: 20),
            _buildEmailSection(context),
            const SizedBox(height: 20),
            _buildSocialSection(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAnimation(BoxConstraints constraints) {
    final size = constraints.maxWidth < 400 ? constraints.maxWidth * 0.6 : 300.0;
    return SizedBox(
      height: size,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: size / 2,
        child: Lottie.asset(
          "assets/images/lf30_editor_liiftrlk.json",
          width: size,
          height: size,
          fit: BoxFit.scaleDown,
          controller: _animationController,
          onLoaded: (composition) {
            _animationController
              ..duration = composition.duration
              ..forward();
          },
        ),
      ),
    );
  }

  Widget _buildContactColumnLeft(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAddressSection(context),
        const SizedBox(height: 20),
        _buildPhoneSection(context),
      ],
    );
  }

  Widget _buildContactColumnRight(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEmailSection(context),
        const SizedBox(height: 20),
        _buildSocialSection(context),
      ],
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: "address".tr(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ColorManager.anotherTabBackGround,
        ),
        child: Text(
          "فيلا 193 الحي الخامس التجمع الخامس القاهره الجديده",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 15,fontFamily:StringConstant.fontName),
        ),
      ),
    );
  }

  Widget _buildPhoneSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: "by_phone".tr(),
      child: Column(
        children: [
          _buildPhoneItem(context, "+201004000856"),
          const SizedBox(height: 8),
          _buildPhoneItem(context, "+0225608189"),
        ],
      ),
    );
  }

  Widget _buildEmailSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: "by_email".tr(),
      child: _buildContactItem(
        context: context,
        icon: Icons.email_outlined,
        text: "info@kytrademarks.com",
        onTap: () => _launchURL('mailto:info@kytrademarks.com'),
      ),
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: "by_social".tr(),
      child: Column(
        children: [
          _buildContactItem(
            context: context,
            icon: Icons.language,
            text: "kytrademarks",
            onTap: () => _launchURL('https://kytrademarks.com/'),
          ),
          const SizedBox(height: 8),
          _buildContactItem(
            context: context,
            icon: Icons.camera_alt,
            text: "Instagram",
            onTap: () => _launchURL('https://instagram.com/ky.trademarks.eg'),
          ),
          const SizedBox(height: 8),
          _buildContactItem(
            context: context,
            icon: Icons.facebook,
            text: "Facebook",
            onTap: () => _launchURL('https://facebook.com/ky.trademarks.eg'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 14,fontFamily:StringConstant.fontName),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildPhoneItem(BuildContext context, String phoneNumber) {
    return _buildContactItem(
      context: context,
      icon: Icons.phone,
      text: phoneNumber,
      onTap: () => _launchPhoneCall(phoneNumber),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ColorManager.anotherTabBackGround,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff155e7d), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 15,fontFamily:StringConstant.fontName),
              ),
            ),
          ],
        ),
      ),
    );
  }
}