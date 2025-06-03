import 'dart:io';
import 'dart:math';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:iconly/iconly.dart';
import 'package:kyuser/presentation/Screens/AddRequest.dart';
import 'package:kyuser/presentation/Screens/login/Login.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/Brand/DataSource/GetBrandRemotoData.dart';
import '../../resources/Color_Manager.dart';
import '../../resources/ImagesConstant.dart';
import '../../resources/StringManager.dart';
import 'AddReservation.dart';
import 'HomeScreenSplach.dart';
import 'contacts.dart';
import 'infoAboutUs.dart';

class OuterMainTabs extends StatefulWidget {
  const OuterMainTabs({super.key});

  @override
  _OuterMainTabsState createState() => _OuterMainTabsState();
}

class _OuterMainTabsState extends State<OuterMainTabs> {
  int _selectedIndex = 0; // Unified index for both nav items and speed dial items
  bool open = false;

  List<IconData> iconList = [IconlyBroken.profile, IconlyBroken.document];
  List<String> iconLabels = ['التسجيل', 'الحجوزات'];
  List<Widget> mainScreens = [
    const LoginScreen(),
    const AddReservation(),
  ];

  List<SpeedDialMenuData> speedDialMenuItems = [
    SpeedDialMenuData(
      icon: IconlyBroken.info_square,
      label: 'من نحن وما مهمتنا و رؤيتنا',
      widget: InfoUs(),
    ),
    SpeedDialMenuData(
      icon: IconlyBroken.calling,
      label: 'التواصل معنا من خلال موقعنا او الاتصال بنا',
      widget: Contacts(canBack: false,),
    ),
    SpeedDialMenuData(
      icon: IconlyBroken.document,
      label: 'تقديم طلب الان',
      widget: AddRequest(canBack: false,),
    ),
    SpeedDialMenuData(
      icon: IconlyBroken.star,
      label: 'قم بتقييمنا',
      isExternalLink: true,
    ),
    SpeedDialMenuData(
      icon: IconlyBroken.buy,
      label: 'الخدمات التى نقدمها لك',
      widget: HomeScreenSplach(),
    ),
  ];

  // Combine all screens into one list for easier management
  late List<Widget?> allScreens;

  @override
  void initState() {
    super.initState();
    allScreens = [
      ...mainScreens,
      ...speedDialMenuItems.map((item) => item.widget),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1000;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: isLargeScreen
          ? _buildWebLayout(context, screenWidth)
          : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: _selectedIndex < mainScreens.length
          ? mainScreens[_selectedIndex]
          : speedDialMenuItems[_selectedIndex - mainScreens.length].widget ?? const SizedBox(),
      floatingActionButton: _buildSpeedDial(),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: open == true
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _selectedIndex,
        backgroundGradient: LinearGradient(colors: [
          ColorManager.primary,
          ColorManager.primaryByOpacity.withValues(alpha: 0.7),
        ]),
        backgroundColor: ColorManager.primary,
        inactiveColor: ColorManager.lightGrey.withValues(alpha: 0.5),
        activeColor: ColorManager.lightGrey,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, double screenWidth) {
    return Row(
      children: [
        // Container(
        //   width: screenWidth * 0.18,
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       begin: Alignment.topCenter,
        //       end: Alignment.bottomCenter,
        //       colors: [
        //         ColorManager.primary,
        //         ColorManager.primaryByOpacity.withValues(alpha: 0.7),
        //       ],
        //     ),
        //   ),
        //   child: Column(
        //     children: [
        //       const SizedBox(height: 40),
        //       Container(
        //         height: 80,
        //         width: 80,
        //         decoration: BoxDecoration(
        //           color: Colors.white,
        //           shape: BoxShape.circle,
        //         ),
        //         child: Center(
        //           child: Icon(
        //             IconlyBroken.work,
        //             size: 40,
        //             color: ColorManager.primary,
        //           ),
        //         ),
        //       ),
        //       const SizedBox(height: 30),
        //       Expanded(
        //         child: ListView(
        //           padding: EdgeInsets.zero,
        //           children: [
        //             ...List.generate(iconList.length, (index) {
        //               return _buildWebNavItem(
        //                 icon: iconList[index],
        //                 label: iconLabels[index],
        //                 isSelected: _selectedIndex == index,
        //                 onTap: () {
        //                   setState(() => _selectedIndex = index);
        //                 },
        //               );
        //             }),
        //             const Divider(color: Colors.white30, thickness: 1, height: 40),
        //             ...speedDialMenuItems.asMap().entries.map((entry) {
        //               int idx = entry.key + iconList.length; // Offset by main nav items
        //               SpeedDialMenuData item = entry.value;
        //               return _buildWebNavItem(
        //                 icon: item.icon,
        //                 label: item.label,
        //                 isSelected: _selectedIndex == idx,
        //                 onTap: () {
        //                   if (item.isExternalLink) {
        //                     _launchRateApp();
        //                   } else {
        //                     setState(() => _selectedIndex = idx);
        //                   }
        //                 },
        //               );
        //             }).toList(),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        Expanded(
          child: allScreens[_selectedIndex] ?? const SizedBox(), // Display selected screen
        ),
      ],
    );
  }

  Widget _buildWebNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily:StringConstant.fontName,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedDial() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.45,
          colors: [
            ColorManager.primaryByOpacity,
            ColorManager.primary,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: SpeedDial(
        icon: IconlyBroken.work,
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 32,
        ),
        activeIcon: IconlyBroken.lock,
        backgroundColor: Colors.transparent,
        activeBackgroundColor: Colors.transparent,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        onOpen: () {
          setState(() => open = true);
        },
        onClose: () {
          setState(() => open = false);
        },
        tooltip: 'Open Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        elevation: 8.0,
        animationCurve: Curves.elasticInOut,
        isOpenOnStart: false,
        children: speedDialMenuItems.map((item) {
          return SpeedDialChild(
            child: Icon(item.icon),
            elevation: 0,
            backgroundColor: ColorManager.primaryByOpacity,
            foregroundColor: Colors.white,
            label: item.label,
            labelBackgroundColor: ColorManager.anotherTabBackGround,
            labelStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14),
            onTap: () {
              if (item.isExternalLink) {
                _launchRateApp();
              } else if (item.widget != null) {
                // Instead of navigating to a new route, update the screen in-place
                int index = mainScreens.length + speedDialMenuItems.indexOf(item);
                setState(() => _selectedIndex = index);
                // Don't push a new route; let the Scaffold show the correct screen
              }
            },
          );
        }).toList(),
      ),
    );
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
    }else{
      launch(
        "https://play.google.com/store/apps/details?id=com.kytrademarks",
      );
      launch(
        "https://apps.apple.com/app/id1605389392",
      );
    }
  }
}

class SpeedDialMenuData {
  final IconData icon;
  final String label;
  final Widget? widget;
  final bool isExternalLink;

  SpeedDialMenuData({
    required this.icon,
    required this.label,
    this.widget,
    this.isExternalLink = false,
  });
}