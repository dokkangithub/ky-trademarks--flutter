import 'dart:io';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:iconly/iconly.dart';
import 'package:kyuser/resources/StringManager.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../resources/Color_Manager.dart';
import 'AddReservation.dart';
import 'HomeScreen.dart';
import 'ProfileScreen.dart';
import 'SearchScreen.dart';
import 'contacts.dart';

class InnerMainTabs extends StatefulWidget {
  const InnerMainTabs({Key? key}) : super(key: key);

  @override
  _InnerMainTabsState createState() => _InnerMainTabsState();
}

class _InnerMainTabsState extends State<InnerMainTabs> {
  int _selectedIndex = 0;
  bool open = false;

  List<IconData> iconList = [
    IconlyBroken.home,
    IconlyBroken.search,
    IconlyBroken.document,
    IconlyBroken.profile
  ];

  List<String> iconLabels = ['home'.tr(), 'search'.tr(), 'add_reservation'.tr(), 'profile'.tr()];

  List<Widget> mainScreens = [];

  final contactUsKey = GlobalKey();

  List<SpeedDialMenuData> speedDialMenuItems = [
    SpeedDialMenuData(
      icon: IconlyBroken.calling,
      label: 'contact_us'.tr(),
      widget: const Contacts(canBack: false),
    ),
    SpeedDialMenuData(
      icon: Icons.android,
      label: 'download_for_android'.tr(),
      isExternalLink: true,
    ),
    SpeedDialMenuData(
      icon: Icons.apple,
      label: 'download_for_ios'.tr(),
      isExternalLink: true,
    ),
  ];

  void _launchAndroidDownload() {
    print('ssss');
    launch(
      "https://play.google.com/store/apps/details?id=com.kytrademarks",
    );
  }

  void _launchIOSDownload() {
    print('ssss');
    launch(
      "https://apps.apple.com/app/id1605389392",
    );
  }

  late List<Widget?> allScreens;

  @override
  void initState() {
    mainScreens.addAll([
      HomeScreen(contactUsKey: contactUsKey),
      const SearchScreen(),
      const AddReservation(),
      const ProfileScreen(),
    ]);

    allScreens = [
      ...mainScreens,
      ...speedDialMenuItems.map((item) => item.widget),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    return WillPopScope(
      onWillPop: () => handleWillPopScopeRoot(),
      child: isLargeScreen
          ? _buildWebLayout(context, screenWidth)
          : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: allScreens.map((widget) => widget ?? const SizedBox()).toList(),
      ),
      floatingActionButton: _buildSpeedDial(),
      floatingActionButtonLocation: open == true
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundGradient: LinearGradient(colors: [
          ColorManager.primary,
          ColorManager.primaryByOpacity.withOpacity(0.7),
          ColorManager.primary,
        ]),
        icons: iconList,
        activeIndex: _selectedIndex < mainScreens.length ? _selectedIndex : 0,
        inactiveColor: ColorManager.lightGrey.withOpacity(0.5),
        activeColor: ColorManager.white,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, double screenWidth) {
    return Row(
      children: [
        Container(
          width: screenWidth * 0.18,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorManager.primary,
                ColorManager.primaryByOpacity.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    IconlyBroken.work,
                    size: 40,
                    color: ColorManager.primary,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ...List.generate(iconList.length, (index) {
                      return _buildWebNavItem(
                        icon: iconList[index],
                        label: iconLabels[index],
                        isSelected: _selectedIndex == index,
                        onTap: () => setState(() => _selectedIndex = index),
                      );
                    }),
                    const Divider(color: Colors.white30, thickness: 1, height: 40),
                    ...speedDialMenuItems.asMap().entries.map((entry) {
                      int idx = entry.key + iconList.length;
                      SpeedDialMenuData item = entry.value;
                      return _buildWebNavItem(
                        icon: item.icon,
                        label: item.label,
                        isSelected: _selectedIndex == idx,
                        onTap: () {
                          if (item.isExternalLink) {
                            if (item.label == 'download_for_android'.tr()) {
                              _launchAndroidDownload();
                            } else if (item.label == 'download_for_ios'.tr()) {
                              _launchIOSDownload();
                            }
                          } else {
                            setState(() => _selectedIndex = idx);
                          }
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: allScreens.map((widget) => widget ?? const SizedBox()).toList(),
          ),
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
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: StringConstant.fontName,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  decoration: TextDecoration.none,
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
          radius: 0.7,
          colors: [
            ColorManager.primaryByOpacity,
            ColorManager.primary,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: SpeedDial(
        icon: IconlyBroken.chat,
        iconTheme: const IconThemeData(color: Colors.white, size: 32),
        activeIcon: IconlyBroken.lock,
        backgroundColor: Colors.transparent,
        activeBackgroundColor: Colors.transparent,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        onOpen: () => setState(() => open = true),
        onClose: () => setState(() => open = false),
        elevation: 8.0,
        animationCurve: Curves.elasticInOut,
        children: speedDialMenuItems.map((item) {
          return SpeedDialChild(
            child: Icon(item.icon),
            backgroundColor: ColorManager.primaryByOpacity,
            foregroundColor: Colors.white,
            label: item.label,
            labelBackgroundColor: Colors.white,
            labelStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14,fontFamily:  StringConstant.fontName,),
            onTap: () {
              if (item.isExternalLink) {
                if (item.label == 'Download for Android'.tr()) {
                  _launchAndroidDownload();
                } else if (item.label == 'Download for iOS'.tr()) {
                  _launchIOSDownload();
                }
              } else if (item.widget != null) {
                int index = mainScreens.length + speedDialMenuItems.indexOf(item);
                setState(() => _selectedIndex = index);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Future<bool> handleWillPopScopeRoot() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * .6,
          child: Text(
            "sure_logout_subtitle".tr(),
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 14, color: Colors.grey.shade500,fontFamily:StringConstant.fontName),
          ),
        ),
        title: Text(
          "sure_logout_title".tr(),
          style: Theme.of(context)
              .textTheme
              .displayLarge
              ?.copyWith(fontSize: 15, color: Colors.black,fontFamily:StringConstant.fontName),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 20),
              InkWell(
                onTap: () {
                  globalAccountData.setStateDialog(true);
                  exit(0);
                },
                child: Text(
                  "yes".tr(),
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 14,fontFamily:StringConstant.fontName),
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                      color: ColorManager.primaryByOpacity,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    "no".tr(),
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: Colors.white, fontSize: 14,fontFamily:StringConstant.fontName),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ) ?? false;
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