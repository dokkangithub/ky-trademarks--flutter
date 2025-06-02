import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/ImagesConstant.dart';
import 'package:kyuser/resources/StringManager.dart';

class HomeScreenSplach extends StatefulWidget {
  const HomeScreenSplach({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class ServiceItem {
  final String title;
  final String description;
  final String image;

  ServiceItem({
    required this.title,
    required this.description,
    required this.image,
  });
}

class _HomeScreenState extends State<HomeScreenSplach> with SingleTickerProviderStateMixin {
  late List<ServiceItem> services;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Responsive breakpoints
  static const double kMobileBreakpoint = 480;
  static const double kTabletBreakpoint = 768;
  static const double kDesktopBreakpoint = 1200;

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

// Initialize services data with consistent path formats:
    services = [
      ServiceItem(
        title: StringConstant.RegisterAndProductMark,
        description: StringConstant.RegisterAndProductMarkData,
        image: ImagesConstants.trademark_3,
      ),
      ServiceItem(
        title: StringConstant.IntellEctualPropertyProtection,
        description: StringConstant.IntellEctualPropertyProtectionData,
        image: ImagesConstants.secure_shield_4,
      ),
      ServiceItem(
        title: StringConstant.PatentsAndApplications,
        description: StringConstant.PatentsAndApplicationsData,
        image: ImagesConstants.settings_2,
      ),
      ServiceItem(
        title: StringConstant.industrialDesigns,
        description: StringConstant.industrialDesignsData,
        image: ImagesConstants.prototype_5,
      ),
      ServiceItem(
        title: StringConstant.EstablishmentOfLegalCompanies,
        description: StringConstant.EstablishmentOfLegalCompaniesData,
        image: ImagesConstants.prototype_5, // Use the constant instead of direct string
      ),
    ];

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Determine current screen type
  ScreenType _getScreenType(double width) {
    if (width < kMobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < kTabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < kDesktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      appBar: _buildResponsiveAppBar(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenType = _getScreenType(constraints.maxWidth);
            return screenType == ScreenType.desktop || screenType == ScreenType.largeDesktop
                ? _buildLargeScreenLayout(context, constraints)
                : _buildSmallScreenLayout(context, constraints);
          },
        ),
      ),
    );
  }

  // Responsive AppBar
  PreferredSizeWidget _buildResponsiveAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: MediaQuery.of(context).size.width < kTabletBreakpoint ? 56 : 70,
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
      title: Text(
        StringConstant.services,
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: MediaQuery.of(context).size.width < kTabletBreakpoint ? 16 : 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
            fontFamily:StringConstant.fontName
        ),
      ),
      centerTitle: true,
      actions: MediaQuery.of(context).size.width < kTabletBreakpoint
          ? null
          : [
        IconButton(
          icon: Icon(Icons.info_outline, color: Colors.white),
          onPressed: () => _showHelpDialog(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // Large screen layout (centered card)
  Widget _buildLargeScreenLayout(BuildContext context, BoxConstraints constraints) {
    const double maxCardWidth = 1000; // Max width for the centered card
    return Center(
      child: Container(
        width: constraints.maxWidth > maxCardWidth ? maxCardWidth : constraints.maxWidth * 0.9,
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _buildContent(context, constraints, ScreenType.desktop),
      ),
    );
  }

  // Small screen layout (full-width)
  Widget _buildSmallScreenLayout(BuildContext context, BoxConstraints constraints) {
    final screenType = _getScreenType(constraints.maxWidth);
    return Container(
      color: Colors.white,
      child: _buildContent(context, constraints, screenType),
    );
  }

  // Common content builder
  Widget _buildContent(BuildContext context, BoxConstraints constraints, ScreenType screenType) {
    return RefreshIndicator(
      color: ColorManager.primary,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {});
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: screenType == ScreenType.mobile ? 16 : 24)),
          if (screenType != ScreenType.mobile)
            SliverToBoxAdapter(child: _buildHeaderSection(context, screenType)),
          SliverToBoxAdapter(child: SizedBox(height: screenType == ScreenType.mobile ? 16 : 24)),
          _buildServicesLayout(context, screenType, constraints),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: screenType == ScreenType.mobile ? 20 : 30),
              child: _buildSuccessPartnerSection(context, screenType),
            ),
          ),
        ],
      ),
    );
  }

  // Header section for larger screens
  Widget _buildHeaderSection(BuildContext context, ScreenType screenType) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorManager.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: ColorManager.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Explore our comprehensive legal services tailored to protect your intellectual property",
              style: TextStyle(fontSize: screenType == ScreenType.tablet ? 14 : 16,fontFamily:StringConstant.fontName),
            ),
          ),
        ],
      ),
    );
  }

  // Services layout
  Widget _buildServicesLayout(BuildContext context, ScreenType screenType, BoxConstraints constraints) {
    if (screenType == ScreenType.mobile) {
      return SliverToBoxAdapter(child: _buildMobileServicesLayout(context));
    } else if (screenType == ScreenType.tablet) {
      return _buildTabletServicesLayout(context);
    } else {
      return _buildDesktopServicesLayout(context, screenType);
    }
  }

  // Mobile services layout (horizontal scroll)
  Widget _buildMobileServicesLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Our Services",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorManager.primary,fontFamily:StringConstant.fontName),
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: services.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(left: 16, right: index == services.length - 1 ? 16 : 0),
              child: _buildServiceCard(context, services[index], width: MediaQuery.of(context).size.width * 0.7),
            ),
          ),
        ),
      ],
    );
  }

  // Tablet services layout (2 columns)
  Widget _buildTabletServicesLayout(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => _buildServiceCard(context, services[index]),
          childCount: services.length,
        ),
      ),
    );
  }

  // Desktop services layout (3-4 columns)
  Widget _buildDesktopServicesLayout(BuildContext context, ScreenType screenType) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenType == ScreenType.largeDesktop ? 4 : 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => _buildServiceCard(context, services[index], showHoverEffect: true),
          childCount: services.length,
        ),
      ),
    );
  }

  // Service card widget
  Widget _buildServiceCard(BuildContext context, ServiceItem service, {double? width, bool showHoverEffect = false}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showServiceDetailDialog(context, service),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: ColorManager.primary.withOpacity(0.1),
                  child: Image.asset(service.image, width: 50, height: 50, color: ColorManager.primary),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 2,
                child: Text(
                  service.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ColorManager.primary,
                    fontWeight: FontWeight.w600,
                      fontFamily:StringConstant.fontName
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Success partner section
  Widget _buildSuccessPartnerSection(BuildContext context, ScreenType screenType) {
    final double width = screenType == ScreenType.mobile
        ? double.infinity
        : screenType == ScreenType.tablet
        ? MediaQuery.of(context).size.width * 0.7
        : 400;

    return Center(
      child: Container(
        width: width,
        height: screenType == ScreenType.mobile ? 180 : 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorManager.primary.withOpacity(0.8), ColorManager.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: ColorManager.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showSuccessPartnerModal(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: screenType == ScreenType.mobile ? 40 : 50,
                  backgroundColor: Colors.white24,
                  child: Image.asset(
                    ImagesConstants.successPartner,
                    width: screenType == ScreenType.mobile ? 50 : 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StringConstant.SuccessPartners,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenType == ScreenType.mobile ? 18 : 22,
                          fontWeight: FontWeight.bold,
                            fontFamily:StringConstant.fontName
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Join our network of successful partners and grow your business",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: screenType == ScreenType.mobile ? 12 : 14,
                            fontFamily:StringConstant.fontName
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "Learn More",
                          style: TextStyle(
                            color: ColorManager.primary,
                            fontWeight: FontWeight.bold,
                            fontFamily:StringConstant.fontName,
                            fontSize: screenType == ScreenType.mobile ? 12 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Service detail modal
  void _showServiceDetailDialog(BuildContext context, ServiceItem service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Get screen size
        final Size screenSize = MediaQuery.of(context).size;
        final bool isLargeScreen = screenSize.width > 600;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            width: isLargeScreen ? screenSize.width * 0.5 : screenSize.width * 0.9,
            height: isLargeScreen ? screenSize.height * 0.7 : screenSize.height * 0.8,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                // Drag handle replacement - close button for dialog
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          ImagesConstants.trademarkes,
                          width: isLargeScreen ? 200 : 150,
                          height: isLargeScreen ? 200 : 150,
                        ),
                        SizedBox(height: isLargeScreen ? 32 : 24),
                        Text(
                          service.title,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: ColorManager.primary,
                            fontFamily: StringConstant.fontName,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isLargeScreen ? 24 : 16),
                        Text(
                          service.description,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 18 : 16,
                            height: 1.5,
                            fontFamily: StringConstant.fontName,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // SizedBox(height: isLargeScreen ? 48 : 32),
                        // ElevatedButton(
                        //   onPressed: () => Navigator.pop(context),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: ColorManager.primary,
                        //     padding: EdgeInsets.symmetric(
                        //       horizontal: isLargeScreen ? 40 : 32,
                        //       vertical: isLargeScreen ? 16 : 12,
                        //     ),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(30),
                        //     ),
                        //   ),
                        //   child: Text(
                        //     "Request This Service",
                        //     style: TextStyle(
                        //       fontSize: isLargeScreen ? 18 : 16,
                        //       color: Colors.white,
                        //       fontFamily: StringConstant.fontName,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // Success partner modal
  void _showSuccessPartnerModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                StringConstant.SuccessPartners,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ColorManager.primary,fontFamily:StringConstant.fontName),
              ),
              const SizedBox(height: 16),
              Image.asset('assets/images/006-handshake.png', height: 150),
              const SizedBox(height: 16),
              Text(
                "Join our network of successful partners and benefit from our extensive expertise.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5,fontFamily:StringConstant.fontName),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close", style: TextStyle(color: ColorManager.primary,fontFamily:StringConstant.fontName)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: ColorManager.primary),
                    child: Text("Learn More", style: TextStyle(color: Colors.white,fontFamily:StringConstant.fontName)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Help dialog
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("About Our Services", style: TextStyle(color: ColorManager.primary, fontWeight: FontWeight.bold,fontFamily:StringConstant.fontName)),
        content: const Text("Tap any service to view details or explore partnership opportunities."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: ColorManager.primary,fontFamily:StringConstant.fontName)),
          ),
        ],
      ),
    );
  }
}

enum ScreenType { mobile, tablet, desktop, largeDesktop }