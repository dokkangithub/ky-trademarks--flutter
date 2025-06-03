import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';

class WebPaymentView extends StatelessWidget {
  const WebPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.primary.withValues(alpha: 0.02),
            Colors.white,
            ColorManager.primaryByOpacity.withValues(alpha: 0.01),
          ],
        ),
      ),
      child: isTablet 
          ? _buildTabletLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header Section with Animation and Title
          _buildTabletHeader(context),
          const SizedBox(height: 24),
          // Payment Options
          _buildPaymentOptionsSection(context, isTablet: true),
          const SizedBox(height: 20),
          // Footer
          _buildFooterSection(context, isTablet: true),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left Panel - Animation and Info
        Expanded(
          flex: 2,
          child: _buildLeftPanel(context),
        ),
        // Right Panel - Payment Options
        Expanded(
          flex: 3,
          child: _buildRightPanel(context),
        ),
      ],
    );
  }

  Widget _buildTabletHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animation
          Expanded(
            flex: 2,
            child: _buildPaymentIllustration(context, size: 200),
          ),
          const SizedBox(width: 32),
          // Text Content
          Expanded(
            flex: 3,
            child: _buildHeaderContent(context, isTablet: true),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Payment Animation Card
          _buildAnimationCard(context),
          const SizedBox(height: 24),
          // Payment Info Card
          _buildPaymentInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildAnimationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPaymentIllustration(context, size: 280),
          const SizedBox(height: 24),
          _buildHeaderContent(context, isTablet: false),
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
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: kIsWeb
          ? Container(
              padding: const EdgeInsets.all(40),
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

  Widget _buildHeaderContent(BuildContext context, {required bool isTablet}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "our_payment".tr(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: ColorManager.primary,
            fontWeight: FontWeight.bold,
            fontFamily: StringConstant.fontName,
            fontSize: isTablet ? 24 : 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "payment_methods".tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: ColorManager.accent,
            fontWeight: FontWeight.w600,
            fontFamily: StringConstant.fontName,
            fontSize: isTablet ? 16 : 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "bank_account_way".tr(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: ColorManager.primaryByOpacity,
            fontFamily: StringConstant.fontName,
            height: 1.4,
            fontSize: isTablet ? 14 : 15,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.security, color: ColorManager.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "الدفع الآمن",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.primary,
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildInfoItem("التشفير المتقدم", "حماية كاملة للبيانات", Icons.lock_outline),
          const SizedBox(height: 12),
          _buildInfoItem("دعم متعدد", "طرق دفع متنوعة", Icons.credit_card),
          const SizedBox(height: 12),
          _buildInfoItem("معالجة سريعة", "تأكيد فوري للدفع", Icons.flash_on),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  fontFamily: StringConstant.fontName,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 20, 20, 20),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary.withValues(alpha: 0.1),
                  ColorManager.primaryByOpacity.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorManager.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.payment, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "طرق الدفع المتاحة",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.primary,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "اختر الطريقة المناسبة لك",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Payment Options
          Expanded(
            child: _buildPaymentOptionsSection(context, isTablet: false),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionsSection(BuildContext context, {required bool isTablet}) {
    final paymentOptions = [
      {
        'text': "commercial_bank_account".tr(),
        'icon': Icons.account_balance,
        'color': Colors.blue.shade600,
        'description': "حساب البنك التجاري الدولي",
      },
      {
        'text': "qatar_bank_account".tr(),
        'icon': Icons.account_balance_wallet,
        'color': Colors.green.shade600,
        'description': "بنك قطر الوطني",
      },
      {
        'text': "ky_commercial_bank_account".tr(),
        'icon': Icons.business,
        'color': Colors.orange.shade600,
        'description': "حساب كي واي التجاري",
      },
      {
        'text': "commercial_bank_account".tr(),
        'icon': Icons.credit_card,
        'color': Colors.purple.shade600,
        'description': "حساب بنكي تجاري",
      },
      {
        'text': "pay_by_vc".tr(),
        'icon': Icons.payment,
        'color': Colors.red.shade600,
        'description': "الدفع بالفيزا أو الماستركارد",
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: paymentOptions.map((option) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildWebPaymentCard(
            context: context,
            text: option['text'] as String,
            description: option['description'] as String,
            icon: option['icon'] as IconData,
            color: option['color'] as Color,
            isTablet: isTablet,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildWebPaymentCard({
    required BuildContext context,
    required String text,
    required String description,
    required IconData icon,
    required Color color,
    required bool isTablet,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: isTablet ? 20 : 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          color: color,
                          fontSize: isTablet ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isTablet ? 12 : 14,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.arrow_forward_ios, color: color, size: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context, {required bool isTablet}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 24),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user, color: ColorManager.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "agree_services".tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ColorManager.primary,
                fontWeight: FontWeight.w500,
                fontFamily: StringConstant.fontName,
                height: 1.4,
                fontSize: isTablet ? 14 : 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 