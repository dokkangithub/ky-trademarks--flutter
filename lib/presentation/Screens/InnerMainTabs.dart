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
import 'add reservation/AddReservation.dart';
import 'chat screen/view/screen/all_chats_screen.dart';
import 'chat screen/view/screen/chat_screen.dart';
import 'home screen/HomeScreen.dart';
import 'notification screen/NotificationScreen.dart';
import 'profile screen/ProfileScreen.dart';
import 'search screen/SearchScreen.dart';
import 'contacts/contacts.dart';

class InnerMainTabs extends StatefulWidget {
  const InnerMainTabs({Key? key}) : super(key: key);

  @override
  _InnerMainTabsState createState() => _InnerMainTabsState();

  // Method to access the state from outside
  static _InnerMainTabsState? of(BuildContext context) {
    return context.findAncestorStateOfType<_InnerMainTabsState>();
  }
}

class _InnerMainTabsState extends State<InnerMainTabs> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool open = false;
  bool isAdmin = false;
  String? userId;

  List<IconData> iconList = [
    IconlyBroken.home,
    IconlyBroken.search,
    IconlyBroken.document,
    IconlyBroken.profile
  ];

  List<String> iconLabels = ['home'.tr(), 'search'.tr(), 'add_reservation'.tr(), 'profile'.tr()];

  List<Widget> mainScreens = [];
  late List<Widget?> allScreens;

  final contactUsKey = GlobalKey();

  // Navigation items for the top header
  final List<NavTabItem> _navItems = [
    NavTabItem(
      icon: Icons.home,
      title: 'الرئيسية',
      isSpecial: false,
    ),
    NavTabItem(
      icon: Icons.search,
      title: 'البحث',
      isSpecial: false,
    ),
    NavTabItem(
      icon: Icons.add_box,
      title: 'إضافة حجز',
      isSpecial: false,
    ),
    NavTabItem(
      icon: Icons.person,
      title: 'الملف الشخصي',
      isSpecial: false,
    ),
    NavTabItem(
      icon: Icons.contact_support,
      title: 'تواصل معنا',
      isSpecial: false,
    ),
    NavTabItem(
      icon: Icons.android,
      title: 'تحميل على الأندرويد',
      isSpecial: true,
    ),
    NavTabItem(
      icon: Icons.apple,
      title: 'تحميل على الآيفون',
      isSpecial: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Get user data
    String userEmail = await globalAccountData.getEmail() ?? '';
    userId = await globalAccountData.getId();
    isAdmin = userEmail == 'test@kytrademarks.com';

    print('User initialized - ID: $userId, Email: $userEmail, IsAdmin: $isAdmin');

    // Initialize main screens
    mainScreens.addAll([
      HomeScreen(contactUsKey: contactUsKey),
      const SearchScreen(),
      const AddReservation(),
      const ProfileScreen(),
    ]);

    // Create all screens list including speed dial options
    allScreens = [
      ...mainScreens,
      // Chat screen - different for admin vs user
      isAdmin ? AllChatsScreen() : ChatScreen(chatId: userId ?? ''),
      const Contacts(canBack: false),
    ];

    if (mounted) {
      setState(() {});
    }
  }

  // Method to change tab from outside
  void changeTab(int index) {
    if (mounted && index >= 0 && index < allScreens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _handleTopNavTap(int index) {
    final item = _navItems[index];

    if (item.isSpecial) {
      // Handle special tabs (download links)
      if (item.title.contains('أندرويد')) {
        launch("https://play.google.com/store/apps/details?id=com.kytrademarks");
      } else if (item.title.contains('آيفون')) {
        launch("https://apps.apple.com/app/id1605389392");
      }
      return;
    }

    // Handle navigation tabs
    if (index < mainScreens.length) {
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 4) { // تواصل معنا
      setState(() {
        _selectedIndex = mainScreens.length + 1; // Index of contacts in allScreens
      });
    }
  }

  void _handleChatPressed() {
    print('Chat button pressed - IsAdmin: $isAdmin, UserId: $userId');
    setState(() {
      _selectedIndex = mainScreens.length; // Index of chat screen in allScreens
    });
  }

  void _launchAndroidDownload() {
    launch("https://play.google.com/store/apps/details?id=com.kytrademarks");
  }

  void _launchIOSDownload() {
    launch("https://apps.apple.com/app/id1605389392");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    if (allScreens.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Fixed Header for web view only
          if (isLargeScreen) _buildFixedHeader(),
          // Content area
          Expanded(
            child: isLargeScreen
                ? _buildWebContent()
                : _buildMobileLayout(),
          ),
        ],
      ),
      floatingActionButton: !isLargeScreen ? _buildChatFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: !isLargeScreen ? AnimatedBottomNavigationBar(
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
      ) : null,
    );
  }

  Widget _buildChatFAB() {
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
      child: FloatingActionButton(
        onPressed: _handleChatPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          IconlyBroken.chat,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary,
            ColorManager.primaryByOpacity.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top navigation bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // Logo/Brand
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'KY العلامات التجارية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                ),
                const Spacer(),
                // User info
                _buildUserInfo(),
              ],
            ),
          ),
          // Navigation tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // Main navigation tabs
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _navItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isSelected = _selectedIndex == index && index < mainScreens.length;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => _handleTopNavTap(index),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(color: Colors.white.withOpacity(0.3))
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item.icon,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontFamily: StringConstant.fontName,
                                    ),
                                  ),
                                  if (item.isSpecial) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.open_in_new,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 14,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Chat button for web
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: InkWell(
                    onTap: _handleChatPressed,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedIndex == mainScreens.length
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: _selectedIndex == mainScreens.length
                            ? Border.all(color: Colors.white.withOpacity(0.3))
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAdmin ? 'جميع المحادثات' : 'الدعم الفني',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: _selectedIndex == mainScreens.length ? FontWeight.bold : FontWeight.normal,
                              fontFamily: StringConstant.fontName,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            globalAccountData.getUsername() ?? 'مستخدم',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: StringConstant.fontName,
            ),
          ),
          if (isAdmin)
            Container(
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'مدير',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.notifications, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebContent() {
    return Container(
      color: ColorManager.anotherTabBackGround,
      child: IndexedStack(
        index: _selectedIndex,
        children: allScreens.map((widget) => widget ?? const SizedBox()).toList(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: allScreens.map((widget) => widget ?? const SizedBox()).toList(),
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

class NavTabItem {
  final IconData icon;
  final String title;
  final bool isSpecial;

  NavTabItem({
    required this.icon,
    required this.title,
    required this.isSpecial,
  });
}