import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../resources/Color_Manager.dart';
import '../../../resources/StringManager.dart';
import '../../Controllar/GetBrandBySearchProvider.dart';
import '../../Controllar/Issues/SearchIssuesProvider.dart';
import '../home screen/HomeScreen.dart';
import 'widgets/mobile_search_view.dart';
import 'widgets/web_search_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  static const PREFERENCES_IS_FIRST_LAUNCH_STRING =
      "PREFERENCES_IS_FIRST_LAUNCH_STRING_SEARCH_SCREEN";

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _mainScrollController = ScrollController();
  final searchKey = GlobalKey();
  
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targetList = [];
  
  // Search Type Controller
  late TabController _searchTypeController;
  int currentSearchType = 0; // 0 = Brands, 1 = Issues

  // Enhanced responsive breakpoint detection
  ScreenType _getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return ScreenType.desktop;
    if (width >= 900) return ScreenType.largeTablet;
    if (width >= 600) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  bool _isWebView(BuildContext context) {
    return _getScreenType(context) != ScreenType.mobile;
  }

  @override
  void initState() {
    super.initState();
    _searchTypeController = TabController(length: 2, vsync: this);
    _initializeScrollListener();
  }

  void _initializeScrollListener() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _mainScrollController.addListener(() {
        if (_mainScrollController.position.pixels >=
            _mainScrollController.position.maxScrollExtent - 100) {
          
          if (currentSearchType == 0) {
            // Brands search
            Provider.of<GetBrandBySearchProvider>(context, listen: false)
                .loadMoreBrands(searchController.text);
          } else {
            // Issues search
            final issuesProvider = Provider.of<SearchIssuesProvider>(context, listen: false);
            final customerId = 244; // Replace with actual customer ID
            issuesProvider.loadMoreSearchResults(customerId);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    tutorialCoachMark?.finish();
    _mainScrollController.dispose();
    _searchTypeController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenType = _getScreenType(context);
    
    return Scaffold(
      backgroundColor: ColorManager.anotherTabBackGround.withValues(alpha: 0.1),
      appBar: !_isWebView(context) ? const CustomAppBar() : null,
      body: _isWebView(context)
          ? WebSearchView(
              key: ValueKey(currentSearchType), // إعادة بناء عند تغيير نوع البحث
              searchController: searchController,
              mainScrollController: _mainScrollController,
              searchKey: searchKey,
              screenType: screenType,
              searchTypeController: _searchTypeController,
              currentSearchType: currentSearchType,
              onSearchTypeChanged: (index) {
                setState(() {
                  currentSearchType = index;
                });
                _clearSearchResults();
              },
            )
          : MobileSearchView(
              key: ValueKey(currentSearchType), // إعادة بناء عند تغيير نوع البحث
              searchController: searchController,
              mainScrollController: _mainScrollController,
              searchKey: searchKey,
              targetList: targetList,
              tutorialCoachMark: tutorialCoachMark,
              onTutorialStart: _startTutorial,
              onTutorialTargetsAdd: _addTutorialTargets,
              searchTypeController: _searchTypeController,
              currentSearchType: currentSearchType,
              onSearchTypeChanged: (index) {
                setState(() {
                  currentSearchType = index;
                });
                _clearSearchResults();
              },
              
            ),
    );
  }

  void _clearSearchResults() {
    Provider.of<GetBrandBySearchProvider>(context, listen: false).resetSearch();
    Provider.of<SearchIssuesProvider>(context, listen: false).clearSearch();
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorManager.primary,
      elevation: 0,
      toolbarHeight: 0,
      leadingWidth: 0,
      flexibleSpace:Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [ColorManager.primaryByOpacity,ColorManager.primary],stops: [0.3,0.8])
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: ColorManager.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _startTutorial() {
    if (tutorialCoachMark != null) {
      tutorialCoachMark?.finish();
    }
    
    tutorialCoachMark = TutorialCoachMark(
      onFinish: () {},
      targets: targetList,
      textSkip: "skip".tr(),
      colorShadow: ColorManager.accent,
      opacityShadow: 0.9,
      alignSkip: AlignmentDirectional.topStart,
      textStyleSkip: TextStyle(
        fontFamily: StringConstant.fontName,
        color: ColorManager.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );

    tutorialCoachMark!.show(context: context);
  }

  void _addTutorialTargets() {
    targetList.clear();
    setState(() {
      targetList.addAll([
        TargetFocus(
          keyTarget: searchKey,
          radius: 13,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                bottom: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "search".tr(),
                    style: TextStyle(
                      fontFamily: StringConstant.fontName,
                      color: ColorManager.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "search_by_brand".tr(),
                      style: TextStyle(
                        fontFamily: StringConstant.fontName,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]);
    });
  }
}

// Enhanced screen type enum for better responsive design
enum ScreenType {
  mobile,     // < 600px
  tablet,     // 600px - 899px
  largeTablet, // 900px - 1199px
  desktop,    // >= 1200px
}
