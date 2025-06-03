import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:kyuser/resources/ImagesConstant.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../../../../resources/StringManager.dart';
import 'package:provider/provider.dart';
import 'package:kyuser/presentation/Controllar/LoginProvider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:ui';
import '../../add request/AddRequest.dart';
import '../../payment ways/PaymentWays.dart';
import '../../info about us/infoAboutUs.dart';
import '../../HomeScreenSplach.dart';
import '../../add reservation/AddReservation.dart';

class WebLoginView extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscureText;
  final VoidCallback togglePasswordVisibility;
  final Function(LoginProvider) handleLogin;
  final VoidCallback handleForgotPassword;
  final VoidCallback handleContactUs;

  const WebLoginView({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.obscureText,
    required this.togglePasswordVisibility,
    required this.handleLogin,
    required this.handleForgotPassword,
    required this.handleContactUs,
  }) : super(key: key);

  @override
  State<WebLoginView> createState() => _WebLoginViewState();
}

class _WebLoginViewState extends State<WebLoginView> with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  int _selectedIndex = 0;

  final List<String> _menuItems = [
    'التسجيل',
    'الحجوزات',
    'التواصل معنا من خلال موقعنا أو الاتصال بنا',
    'تقديم طلب الآن',
    'قم بتقييمنا',
    'الخدمات التي نقدمها لك',
    'من نحن وما مهمتنا و رؤيتنا',
  ];

  // أيقونات العناصر المطابقة للصورة
  final List<IconData> _menuIcons = [
    Icons.app_registration,
    Icons.calendar_today,
    Icons.contact_phone,
    Icons.add_task,
    Icons.star,
    Icons.miscellaneous_services,
    Icons.info,
  ];

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoPlayerController = VideoPlayerController.asset('assets/ky_video.mp4');
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      showControls: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );

    setState(() {
      _isVideoInitialized = true;
    });

    _videoPlayerController.play();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 1200;
    final isMediumScreen = size.width > 900 && size.width <= 1200;
    final isSmallScreen = size.width <= 900;
    final isVerySmallScreen = size.width <= 600;

    return Stack(
      children: [
        // Background Video
        _isVideoInitialized
            ? SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoPlayerController.value.size.width,
              height: _videoPlayerController.value.size.height,
              child: Chewie(controller: _chewieController!),
            ),
          ),
        )
            : Expanded(child: Image(image: AssetImage(ImagesConstants.appIcon),fit: BoxFit.cover,)),

        // Top Navigation Menu
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: isSmallScreen 
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo for small screens
                      Image.asset(
                        ImagesConstants.appIcon,
                        height: 35,
                        fit: BoxFit.contain,
                      ),
                      // Hamburger menu for small screens
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                        onPressed: () {
                          _showMobileMenu(context);
                        },
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo for larger screens
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Image.asset(
                            ImagesConstants.appIcon,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Menu Items with responsive sizing
                        ...List.generate(
                          _menuItems.length,
                          (index) => _buildMenuItem(index, isVerySmallScreen),
                        ),
                      ],
                    ),
                  ),
          ),
        ),

        // Login Form Card
        Align(
          alignment: isSmallScreen ? Alignment.center : Alignment.centerLeft,
          child: Container(
            width: isSmallScreen ? size.width * 0.9 : size.width * 0.45,
            margin: EdgeInsets.only(
              left: isSmallScreen ? 20 : 50,
              right: isSmallScreen ? 20 : 0,
              top: 80, // Space for Navigation Menu
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Consumer<LoginProvider>(
                      builder: (context, model, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Center(
                            child: Image.asset(
                              ImagesConstants.appIcon,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Heading
                          Text(
                            'login_your_account'.tr(),
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: StringConstant.fontName,
                            ),
                          ),
                          const SizedBox(height: 30.0),

                          // Email Input
                          _buildFormLabel('email'.tr()),
                          const SizedBox(height: 10.0),
                          _buildTextField(
                            controller: widget.emailController,
                            hintText: 'enter_email'.tr(),
                            keyboardType: TextInputType.emailAddress,
                            height: 50.0,
                          ),
                          const SizedBox(height: 20.0),

                          // Password Input
                          _buildFormLabel('password'.tr()),
                          const SizedBox(height: 10.0),
                          _buildTextField(
                            controller: widget.passwordController,
                            hintText: 'password'.tr(),
                            obscureText: widget.obscureText,
                            height: 50.0,
                            suffixIcon: IconButton(
                              icon: Icon(
                                widget.obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: widget.togglePasswordVisibility,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: widget.handleForgotPassword,
                              child: Text(
                                "forget_password".tr(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: StringConstant.fontName,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30.0),

                          // Submit Button with LoginProvider
                          SizedBox(
                            width: double.infinity,
                            height: 50.0,
                            child: ElevatedButton(
                              onPressed: model.loading
                                  ? null
                                  : () => widget.handleLogin(model),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                elevation: 0,
                              ),
                              child: model.loading
                                  ? const CircularProgressIndicator(
                                  color: Colors.black87)
                                  : Text(
                                'login'.tr(),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: StringConstant.fontName,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30.0),

                          // Have no account section and Apply now section in one row
                          Column(
                            children: [
                              Text(
                                "have_no_account".tr(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontFamily: StringConstant.fontName,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton(
                                    style: ButtonStyle(
                                      side: WidgetStateProperty.all(
                                        const BorderSide(color: Colors.white70),
                                      ),
                                    ),
                                    onPressed: widget.handleContactUs,
                                    child: Text(
                                      "contact_us".tr(),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        fontFamily: StringConstant.fontName,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  OutlinedButton(
                                    style: ButtonStyle(
                                      side: WidgetStateProperty.all(
                                        const BorderSide(color: Colors.white70),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => AddRequest(
                                            canBack: true,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "or_ask".tr(),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontFamily: StringConstant.fontName,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _buildTermsText(),
                          _buildPaymentMethodsSection(isLargeScreen),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(int index, bool isVerySmallScreen) {
    bool isSelected = _selectedIndex == index;
    
    // تقصير النص الطويل للعرض في القائمة بناءً على حجم الشاشة
    String displayText = _menuItems[index];
    int maxLength = isVerySmallScreen ? 10 : 15;
    if (displayText.length > maxLength) {
      displayText = displayText.substring(0, maxLength) + '...';
    }
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        // التنقل بين الصفحات بناءً على العنصر المختار
        _navigateToPage(index);
      },
      child: Tooltip(
        message: _menuItems[index],
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: isVerySmallScreen ? 4 : 8),
          padding: EdgeInsets.symmetric(
            vertical: 5, 
            horizontal: isVerySmallScreen ? 4 : 8
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_menuIcons.isNotEmpty && index < _menuIcons.length)
                Icon(
                  _menuIcons[index],
                  color: Colors.white,
                  size: isVerySmallScreen ? 14 : 16,
                ),
              SizedBox(width: isVerySmallScreen ? 3 : 5),
              Flexible(
                child: Text(
                  displayText.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: isVerySmallScreen ? 12 : 14,
                    fontFamily: StringConstant.fontName,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // التحقق مما إذا كانت الشاشة صغيرة
  bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= 900;
  }

  // التنقل إلى الصفحة المناسبة بناءً على العنصر المختار
  void _navigateToPage(int index) {
    switch (index) {
      case 0: // التسجيل
        // نحن بالفعل في صفحة التسجيل
        break;
      case 1: // الحجوزات
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddReservation(),
          ),
        );
        break;
      case 2: // التواصل معنا من خلال موقعنا أو الاتصال بنا
        widget.handleContactUs();
        break;
      case 3: // تقديم طلب الآن
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddRequest(
              canBack: true,
            ),
          ),
        );
        break;
      case 4: // قم بتقييمنا
        _launchRateUrl();
        break;
      case 5: // الخدمات التي نقدمها لك
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreenSplach(),
          ),
        );
        break;
      case 6: // من نحن وما مهمتنا و رؤيتنا
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InfoUs(),
          ),
        );
        break;
    }
  }

  // فتح صفحة التقييم
  Future<void> _launchRateUrl() async {
    if (!kIsWeb) {
      final appId = Platform.isAndroid ? 'com.kytrademarkstrademarks' : '1605389392';
      final Uri url = Uri.parse(
        Platform.isAndroid
            ? "market://details?id=$appId"
            : "https://apps.apple.com/app/id$appId",
      );
      try {
        await launcher.launchUrl(
          url,
          mode: launcher.LaunchMode.externalApplication,
        );
      } catch (e) {
        print('Error launching URL: $e');
      }
    } else {
      try {
        await launcher.launchUrl(
          Uri.parse("https://play.google.com/store/apps/details?id=com.kytrademarks"),
          mode: launcher.LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
        await launcher.launchUrl(
          Uri.parse("https://apps.apple.com/app/id1605389392"),
          mode: launcher.LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
      } catch (e) {
        print('Error launching URL: $e');
      }
    }
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.8),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ...List.generate(
                  _menuItems.length,
                  (index) => ListTile(
                    leading: Icon(_menuIcons[index], color: Colors.white, size: 20),
                    title: Text(
                      _menuItems[index].tr(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                        fontFamily: StringConstant.fontName,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      Navigator.pop(context);
                      // التنقل بين الصفحات
                      _navigateToPage(index);
                    },
                    selected: _selectedIndex == index,
                    selectedTileColor: Colors.white.withOpacity(0.1),
                    dense: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        fontFamily: StringConstant.fontName,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    double height = 50.0,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: StringConstant.fontName,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white70,
            fontFamily: StringConstant.fontName,
          ),
          contentPadding: const EdgeInsets.all(15.0),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          "agree_services".tr(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 11.5,
            fontFamily: StringConstant.fontName,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection(bool isLargeScreen) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              "payment_browse".tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isLargeScreen ? 14 : 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: StringConstant.fontName,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: isLargeScreen ? 10 : 8),
          OutlinedButton(
            style: ButtonStyle(
              side: MaterialStateProperty.all(
                const BorderSide(color: Colors.white70),
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentWays()),
            ),
            child: Text(
              "payment methods".tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isLargeScreen ? 14 : 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: StringConstant.fontName,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
