import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'widgets/mobile_payment_view.dart';
import 'widgets/web_payment_view.dart';

class PaymentWays extends StatelessWidget {
  const PaymentWays({Key? key}) : super(key: key);

  // Responsive breakpoint for web view detection
  bool _isWebView(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _isWebView(context)?SizedBox.shrink():_buildHeaderImage(context),
          Expanded(
            child: _isWebView(context)
                ? const WebPaymentView()
                : const MobilePaymentView(),
          ),
        ],
      ),
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

  Widget _buildHeaderImage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary.withValues(alpha: 0.9),
            ColorManager.primary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 24),
            ),
            Image.asset(
              "assets/images/LogoSplash.png",
              height: 40,
              color: ColorManager.white,
            ),
          ],
        ),
      ),
    );
  }
}
