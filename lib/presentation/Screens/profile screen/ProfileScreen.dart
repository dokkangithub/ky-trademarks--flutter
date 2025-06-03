import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../resources/Color_Manager.dart';
import '../../Controllar/GetSuccessPartners.dart';
import '../../Controllar/userProvider.dart';
import 'widgets/mobile_profile_view.dart';
import 'widgets/web_profile_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  // Responsive breakpoint for web view detection
  bool _isWebView(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _isWebView(context)
          ? const WebProfileView()
          : const MobileProfileView(),
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