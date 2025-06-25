import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart' as s;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/RequestState/RequestState.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../data/Brand/models/BrandDataModel.dart';
import '../../../domain/Brand/Entities/BrandEntity.dart';
import '../../../domain/Company/Entities/CompanyEntity.dart';
import '../../../resources/ImagesConstant.dart';
import '../../../network/RestApi/Comman.dart';
import '../../../resources/Color_Manager.dart';
import '../../../resources/StringManager.dart';
import '../../Controllar/GetBrandProvider.dart';
import '../../Controllar/GetCompanyProvider.dart';
import '../../Widget/loading_widget.dart';
import '../../Widget/BrandWidget.dart';
import '../add request/AddRequest.dart';
import '../add reservation/AddReservation.dart';
import '../brand details/BrandDetails.dart';
import '../notification screen/NotificationScreen.dart';
import '../payment ways/PaymentWays.dart';
import '../../../utilits/Local_User_Data.dart';
import 'widgets/mobile_view.dart';
import 'widgets/web_view.dart';

class AppConstants {
  static const double headerHeight = 200.0;
  static const double cardHeight = 120.0;
  static const double cardMargin = 8.0;
  static const double paddingHorizontal = 16.0;
  static const double paddingVertical = 8.0;
}

class HomeScreen extends StatefulWidget {
  final GlobalKey? contactUsKey;

  const HomeScreen({this.contactUsKey, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _mainScrollController;
  late final ScrollController _listScrollController;
  String _byStatus = "";
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _mainScrollController = ScrollController();
    _listScrollController = ScrollController();

    _setupScrollListeners();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _setupScrollListeners() {
    _listScrollController.addListener(_handleScroll);
    _mainScrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_isLoadingMore) return;
    final controller = _listScrollController.hasClients
        ? _listScrollController
        : _mainScrollController;

    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _fetchInitialData() async {
    GetCompanyProvider companyProvider =
    Provider.of<GetCompanyProvider>(context, listen: false);
    await Provider.of<GetCompanyProvider>(context, listen: false)
        .getAllCompanies();
    await Provider.of<GetBrandProvider>(context, listen: false)
        .getAllBrandsWidget(companyId: companyProvider.allCompanies[0].id);
  }

  Future<void> _loadMoreData() async {
    GetCompanyProvider companyProvider =
    Provider.of<GetCompanyProvider>(context, listen: false);
    final provider = Provider.of<GetBrandProvider>(context, listen: false);
    if (!provider.isLoading && provider.hasMoreData && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      await provider.loadMoreBrands(companyProvider.allCompanies[0].id);
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mainScrollController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  bool _isWebView(BuildContext context) {
    // تحديد ما إذا كان يجب عرض الـ web view أم الـ mobile view
    final width = MediaQuery.of(context).size.width;
    return width > 600; // إذا كان العرض أكبر من 600 بكسل، عرض الـ web view
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.anotherTabBackGround,
      appBar: !_isWebView(context) ? const CustomAppBar() : null,
      body: Consumer<GetBrandProvider>(
        builder: (context, model, _) => _buildBody(context, model),
      ),
    );
  }

  Widget _buildBody(BuildContext context, GetBrandProvider model) {
    switch (model.state) {
      case RequestState.loading:
        return _isWebView(context)
            ? const WebLoadingShimmer()
            : const MobileLoadingShimmer();
      case RequestState.loaded:
        return _isWebView(context)
            ? WebView(
          tabController: _tabController,
          byStatus: _byStatus,
          onFilterChanged: (value) => setState(() => _byStatus = value),
          mainScrollController: _mainScrollController,
          listScrollController: _listScrollController,
          isLoadingMore: _isLoadingMore,
        )
            : MobileView(
          byStatus: _byStatus,
          onFilterChanged: (value) => setState(() => _byStatus = value),
          mainScrollController: _mainScrollController,
          listScrollController: _listScrollController,
          isLoadingMore: _isLoadingMore,
        );
      case RequestState.failed:
        return Center(
            child: Text(
              "There are Error",
              style: TextStyle(fontFamily: StringConstant.fontName),
            ));
      default:
        return _isWebView(context)
            ? const WebLoadingShimmer()
            : const MobileLoadingShimmer();
    }
  }
}

// Custom AppBar - مبسط ومحسن للموبايل فقط
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: ColorManager.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      flexibleSpace: Container(
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

  @override
  Size get preferredSize => const Size.fromHeight(0);
}
