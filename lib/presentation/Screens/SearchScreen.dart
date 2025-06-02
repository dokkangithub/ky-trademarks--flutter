import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kyuser/presentation/Controllar/GetBrandBySearchProvider.dart';
import 'package:kyuser/presentation/Widget/BrandWidget.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../app/RequestState/RequestState.dart';
import '../../resources/ImagesConstant.dart';
import '../../network/RestApi/Comman.dart';
import '../../resources/Color_Manager.dart';
import '../../resources/StringManager.dart';
import '../Widget/SearchWidget/NoDataFound.dart';
import '../Widget/SearchWidget/SearchShimmer.dart';
import '../Widget/loading_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  static const PREFERENCES_IS_FIRST_LAUNCH_STRING =
      "PREFERENCES_IS_FIRST_LAUNCH_STRING_SEARCH_SCREEN";

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  final ScrollController _mainScrollController =
      ScrollController(); // For SingleChildScrollView

  final searchKey = GlobalKey();

  @override
  void dispose() {
    tutorialCoachMark?.finish();
    _mainScrollController.dispose();

    super.dispose();
  }

  TutorialCoachMark? tutorialCoachMark;

  startTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      onFinish: () {},
      targets: targetList,
      textSkip: "skip".tr(),
      colorShadow: ColorManager.accent,
      opacityShadow: 0.9,
      alignSkip: AlignmentDirectional.topStart,
      textStyleSkip: TextStyle(
          fontFamily: "Shahid",
          color: ColorManager.white,
          fontWeight: FontWeight.w600,
          fontSize: 16),
    );

    tutorialCoachMark!.show(context: context);
  }

  List<TargetFocus> targetList = [];

  addToturialTargets() {
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
                    bottom: MediaQuery.of(context).size.height * .5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "search".tr(),
                      style: TextStyle(
                          fontFamily:StringConstant.fontName,
                          color: ColorManager.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "search_by_brand".tr(),
                          style: TextStyle(
                              fontFamily:StringConstant.fontName,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ))
                  ],
                ))
          ],
        ),
      ]);
    });
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _mainScrollController.addListener(() {
        if (_mainScrollController.position.pixels >=
            _mainScrollController.position.maxScrollExtent - 100) {
          Provider.of<GetBrandBySearchProvider>(context, listen: false)
              .loadMoreBrands(searchController.text);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GetBrandBySearchProvider provider =
        Provider.of<GetBrandBySearchProvider>(context);

    return Scaffold(
      backgroundColor: ColorManager.anotherTabBackGround.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 130,
        leadingWidth: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorManager.primaryByOpacity.withOpacity(0.9),
                ColorManager.primary,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, top: 4),
            child: Column(
              children: [
                const SizedBox(
                  height: 30, // Space for the status bar
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 40),
                    Text(
                      "search".tr(),
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontSize: 20, color: Colors.white,fontFamily:StringConstant.fontName),
                    ),
                    InkWell(
                      onTap: () {
                        if (targetList.isEmpty) {
                          addToturialTargets();
                        }
                        startTutorial();
                      },
                      child: Lottie.asset(ImagesConstants.infoW,
                          height: 30, width: 30),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 6,
                        color: ColorManager.anotherTabBackGround,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextFormField(
                          key: searchKey,
                          style: TextStyle(
                              fontFamily: "Shahid",
                              color: ColorManager.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                          controller: searchController,
                          validator: validateObjects(),
                          decoration: decoration("search_brand".tr()),
                          onChanged: (val) {
                            // Provider.of<GetBrandBySearchProvider>(context,
                            //     listen: false)
                            //     .allBrands!
                            //     .brand
                            //     .clear();
                            // setState(() {
                            //   val = searchController.text;
                            // });
                          },
                          onFieldSubmitted: (val) {
                            Provider.of<GetBrandBySearchProvider>(context,
                                    listen: false)
                                .getAllBrandsBySearch(
                                    keyWord: searchController.text);
                            setState(() {});
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int _getCrossAxisCount(double width) {
            if (width > 1200) return 3;
            if (width > 900) return 2;
            if (width > 600) return 1;
            return 1;
          }
          int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

          double _getChildAspectRatio(double width) {
            if (width > 1400) return 4.1;
            if (width > 1200) return 3.2;
            if (width > 1000) return 4.0;
            if (width > 900) return 3.5;
            if (width > 800) return 6.5;
            if (width > 700) return 5.5;
            if (width > 600) return 4.5;
            if (width > 500) return 2.05;
            if (width > 400) return 1.5;
            return 2.5;
          }

          double childAspectRatio = _getChildAspectRatio(constraints.maxWidth);
          return searchController.text.isEmpty
              ? NoDataFound()
              : SingleChildScrollView(
                  controller: _mainScrollController,
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Consumer<GetBrandBySearchProvider>(
                        builder: (context, model, _) {
                          if (model.state == RequestState.loading) {
                            return SearchShimmer();
                          } else if (model.state == RequestState.failed) {
                            return Center(
                              child: Text("لا يوجد بيانات",style: TextStyle(fontFamily:StringConstant.fontName),),
                            );
                          }
                          if (model.state == RequestState.loaded) {
                            return model.allBrands.isEmpty
                                ? Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        start: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 50),
                                        NoDataFound(),
                                        SizedBox(
                                          child: Text(
                                            "search_not_found".tr(),
                                            style: TextStyle(
                                              fontFamily:StringConstant.fontName,
                                              color: ColorManager.accent
                                                  .withOpacity(0.6),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : GridView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      childAspectRatio: childAspectRatio,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemBuilder: (context, index) {
                                      // Only show loading if we're at the last item AND we have enough items to make loading meaningful
                                      // AND the provider indicates there's more data to load
                                      if (index == model.allBrands.length &&
                                          model.hasMoreData &&
                                          model.allBrands.length >= 6) {
                                        // Only show loading if we have at least 6 items
                                        return Center(child: LoadingWidget());
                                      }
                                      return Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              spreadRadius: 3,
                                              blurRadius: 3,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: BrandWidget(
                                          context: context,
                                          index: index,
                                          model: model,
                                          isSearch: true,
                                        ),
                                      );
                                    },
                                    itemCount: model.allBrands.length +
                                        (model.hasMoreData &&
                                                model.allBrands.length >= 6
                                            ? 1
                                            : 0),
                                  );
                          }
                          return Container();
                        },
                      ),
                      const SizedBox(
                        height: 40,
                      )
                    ],
                  ),
                );
        },
      ),
    );
  }
}
