import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import '../../../resources/Route_Manager.dart';
import '../../resources/ImagesConstant.dart';
import '../../utilits/Local_User_Data.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _animationDuration = Duration(seconds: 1);
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    globalAccountData.setStateDialog(true);
    _startNavigation();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _startNavigation() {
    _navigationTimer = Timer(_animationDuration, _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    final isLoggedIn = globalAccountData.getLoginInState() ?? false;
    Navigator.pushReplacementNamed(
      context,
      isLoggedIn ? Routes.tabBarRoute : Routes.mainRoute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildResponsiveLayout(context, constraints);
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(BuildContext context, BoxConstraints constraints) {
    final isLargeScreen = constraints.maxWidth > 600;
    final size = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background animations
        _buildBackgroundStars(size, isLargeScreen),
        // Main content
        isLargeScreen
            ? _buildLargeScreenLayout(size)
            : _buildSmallScreenLayout(size),
      ],
    );
  }

  Widget _buildBackgroundStars(Size size, bool isLargeScreen) {
    final starSize = isLargeScreen ? size.width * 0.3 : size.width * 0.15;

    return Stack(
      children: [
        Positioned(
          top: size.height * 0.1,
          left: isLargeScreen ? size.width * 0.2 : size.width * 0.05,
          child: Transform(
            transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
            alignment: Alignment.center,
            child: SizedBox(
              width: starSize,
              height: starSize,
              child: Lottie.asset(ImagesConstants.stars),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.1,
          right: isLargeScreen ? size.width * 0.2 : size.width * 0.05,
          child: SizedBox(
            width: starSize,
            height: starSize,
            child: Lottie.asset(ImagesConstants.stars),
          ),
        ),
      ],
    );
  }

  Widget _buildLargeScreenLayout(Size size) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: _buildLogo(size.width * 0.4),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallScreenLayout(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: _buildLogo(size.width * 0.6),
        ),
          Expanded(
          child: _buildBottomImage(size.width * 0.35),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLogo(double width) {
    return Shimmer.fromColors(
      baseColor: ColorManager.primaryByOpacity,
      highlightColor: ColorManager.anotherTabBackGround,
      child: Image.asset(
        'assets/images/LogoSplash.png',
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildBottomImage(double width) {
    return Shimmer.fromColors(
      baseColor: ColorManager.primaryByOpacity,
      highlightColor: ColorManager.anotherTabBackGround,
      child: Image.asset(
        'assets/images/dokkan.png',
        width: width,
        color: const Color(0xff155e7d),
        fit: BoxFit.contain,
      ),
    );
  }
}