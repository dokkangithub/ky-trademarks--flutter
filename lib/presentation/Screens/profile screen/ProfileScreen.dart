import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../resources/Color_Manager.dart';
import '../../Controllar/GetSuccessPartners.dart';
import '../../Controllar/userProvider.dart';
import '../home screen/HomeScreen.dart';
import 'widgets/mobile_profile_view.dart';
import 'widgets/web_profile_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  // Enhanced responsive breakpoints
  ScreenType _getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenType.mobile;
    } else if (width < 1024) {
      return ScreenType.tablet;
    } else if (width < 1440) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  bool _isWebView(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  @override
  void initState() {
    super.initState();
    // Initialize data providers
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetSuccessPartners>(context, listen: false).getSuccessPartners();
      Provider.of<GetUserProvider>(context, listen: false).getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenType = _getScreenType(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: !_isWebView(context) ? const CustomAppBar() : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8FAFE),
              Colors.white,
              ColorManager.primary.withOpacity(0.02),
            ],
          ),
        ),
        child: _isWebView(context)
            ? WebProfileView(screenType: screenType)
            : const MobileProfileView(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0,
      leadingWidth: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: ColorManager.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }
}

enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}