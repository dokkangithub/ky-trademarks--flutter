import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../resources/Color_Manager.dart';
import '../../../resources/StringManager.dart';
import 'widgets/mobile_contacts_view.dart';
import 'widgets/web_contacts_view.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key, required this.canBack});
  final bool canBack;

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

  // Responsive breakpoint for web view detection
  bool _isWebView(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isWebView(context)?null:_buildAppBar(context),
      body: _isWebView(context)
          ? WebContactsView(
              animationController: _animationController,
              canBack: widget.canBack,
              onBack: widget.canBack ? () => Navigator.pop(context) : null,
            )
          : MobileContactsView(
              animationController: _animationController,
              canBack: widget.canBack,
              onBack: widget.canBack ? () => Navigator.pop(context) : null,
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
          fontFamily: StringConstant.fontName,
        ),
      ),
      leading: widget.canBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color: ColorManager.white, size: 22),
              onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
            )
          : const SizedBox.shrink(),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      flexibleSpace: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorManager.primaryByOpacity.withValues(alpha: 0.9),
              ColorManager.primary,
            ],
          ),
        ),
      ),
    );
  }
} 