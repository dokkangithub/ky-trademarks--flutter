import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';

class MobilePaymentView extends StatelessWidget {
  const MobilePaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorManager.primary.withValues(alpha: 0.02),
            Colors.white,
            ColorManager.primaryByOpacity.withValues(alpha: 0.01),
          ],
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Payment Animation Header
          SliverToBoxAdapter(
            child: _buildMobileHeader(context),
          ),
          
          // Title Section
          SliverToBoxAdapter(
            child: _buildTitleSection(context),
          ),
          
          // Payment Options
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: _buildPaymentOptionsCard(context),
            ),
          ),
          
          // Footer
          SliverToBoxAdapter(
            child: _buildFooterSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Payment Animation
          _buildPaymentIllustration(context, size: 150),
          const SizedBox(height: 20),
          
          // Header Text
          Text(
            "our_payment".tr(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 24,
              color: ColorManager.primary,
              fontWeight: FontWeight.w700,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          Text(
            "payment_methods".tr(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 16,
              color: ColorManager.accent,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentIllustration(BuildContext context, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            ColorManager.primary.withValues(alpha: 0.1),
            ColorManager.primaryByOpacity.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: kIsWeb
          ? Container(
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/payment_image.png',
                fit: BoxFit.contain,
              ),
            )
          : Lottie.asset(
              "assets/images/final-payment.json",
              width: size,
              height: size,
              repeat: false,
              fit: BoxFit.contain,
            ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorManager.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorManager.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorManager.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.info_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "bank_account_way".tr(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 14,
                  color: ColorManager.primaryByOpacity,
                  fontFamily: StringConstant.fontName,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionsCard(BuildContext context) {
    final paymentOptions = [
      {
        'text': "commercial_bank_account".tr(),
        'icon': Icons.account_balance,
        'color': Colors.blue.shade600,
      },
      {
        'text': "qatar_bank_account".tr(),
        'icon': Icons.account_balance_wallet,
        'color': Colors.green.shade600,
      },
      {
        'text': "ky_commercial_bank_account".tr(),
        'icon': Icons.business,
        'color': Colors.orange.shade600,
      },
      {
        'text': "commercial_bank_account".tr(),
        'icon': Icons.credit_card,
        'color': Colors.purple.shade600,
      },
      {
        'text': "pay_by_vc".tr(),
        'icon': Icons.payment,
        'color': Colors.red.shade600,
      },
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary,
                  ColorManager.primaryByOpacity,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.payment, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "طرق الدفع المتاحة",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Payment Options List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: paymentOptions.map((option) => 
                _buildMobilePaymentItem(
                  context: context,
                  text: option['text'] as String,
                  icon: option['icon'] as IconData,
                  color: option['color'] as Color,
                )
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePaymentItem({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
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
                fontFamily: StringConstant.fontName,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary.withValues(alpha: 0.05),
            ColorManager.primaryByOpacity.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorManager.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: ColorManager.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "agree_services".tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ColorManager.primary,
                fontWeight: FontWeight.w500,
                fontFamily: StringConstant.fontName,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 