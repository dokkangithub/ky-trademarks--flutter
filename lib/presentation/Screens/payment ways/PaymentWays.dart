import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import '../../../resources/ImagesConstant.dart';
import '../../../resources/StringManager.dart';

class PaymentWays extends StatelessWidget {
  const PaymentWays({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeaderImage(context),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isLargeScreen
                      ? _LargeScreenLayout()
                      : _SmallScreenLayout(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
            ColorManager.primary.withOpacity(0.9),
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

// Large Screen Layout
class _LargeScreenLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildPaymentIllustration(),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleSection(context),
              const SizedBox(height: 20),
              _buildPaymentOptions(context),
              const SizedBox(height: 20),
              _buildFooterText(context),
            ],
          ),
        ),
      ],
    );
  }
}

// Small Screen Layout
class _SmallScreenLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildPaymentIllustration(),
        const SizedBox(height: 20),
        _buildTitleSection(context),
        const SizedBox(height: 20),
        _buildPaymentOptions(context),
        const SizedBox(height: 20),
        _buildFooterText(context),
      ],
    );
  }
}

// Reusable Widgets
Widget _buildPaymentIllustration() {
  return kIsWeb
      ? Image.asset('assets/images/payment_image.png', fit: BoxFit.contain)
      : Lottie.asset(
          "assets/images/final-payment.json",
          width: 150,
          height: 150,
          repeat: false,
          fit: BoxFit.contain,
        );
}

Widget _buildTitleSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "our_payment".tr(),
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: ColorManager.primary,
              fontWeight: FontWeight.bold,
            fontFamily:StringConstant.fontName
            ),
      ),
      const SizedBox(height: 10),
      Text(
        "payment_methods".tr(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ColorManager.accent,
              fontWeight: FontWeight.w600,
            fontFamily:StringConstant.fontName
            ),
      ),
      Text(
        "bank_account_way".tr(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ColorManager.primaryByOpacity,
            fontFamily:StringConstant.fontName
            ),
      ),
    ],
  );
}

Widget _buildPaymentOptions(BuildContext context) {
  final paymentOptions = [
    "commercial_bank_account".tr(),
    "qatar_bank_account".tr(),
    "ky_commercial_bank_account".tr(),
    "commercial_bank_account".tr(),
    "pay_by_vc".tr(),
  ];

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: paymentOptions
            .map((text) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _PaymentRow(text: text),
                ))
            .toList(),
      ),
    ),
  );
}

Widget _buildFooterText(BuildContext context) {
  return Center(
    child: Text(
      "agree_services".tr(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ColorManager.primary,
            fontWeight: FontWeight.w500,
          fontFamily:StringConstant.fontName
          ),
      textAlign: TextAlign.center,
    ),
  );
}

class _PaymentRow extends StatelessWidget {
  final String text;

  const _PaymentRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: ColorManager.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ColorManager.accent,
                  height: 1.5,
                fontFamily:StringConstant.fontName
                ),
          ),
        ),
      ],
    );
  }
}
