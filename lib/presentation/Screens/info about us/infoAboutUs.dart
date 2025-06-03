import 'package:flutter/material.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/StringManager.dart';
import 'widgets/mobile_info_view.dart';
import 'widgets/web_info_view.dart';

class InfoUs extends StatelessWidget {
  const InfoUs({super.key});

  // Responsive breakpoint for web view detection
  bool _isWebView(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _isWebView(context)
          ? const WebInfoView()
          : const MobileInfoView(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 60,
      centerTitle: true,
      title: Text(
        "من نحن",
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          color: Colors.white,
          fontFamily: StringConstant.fontName,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 22),
        onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
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