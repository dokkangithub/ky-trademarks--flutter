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
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildPaymentOptionsSection(context),
            _buildSecuritySection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth < 1024;
    
    return Container(
      margin: EdgeInsets.all(screenWidth < 768 ? 16 : 32),
      padding: EdgeInsets.all(screenWidth < 768 ? 24 : 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isTablet ? _buildTabletHeroLayout(context) : _buildDesktopHeroLayout(context),
    );
  }

  Widget _buildTabletHeroLayout(BuildContext context) {
    return Column(
      children: [
        // Illustration
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorManager.primary.withValues(alpha: 0.05),
                ColorManager.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: kIsWeb
              ? Image.asset(
                  'assets/images/payment_image.png',
                  fit: BoxFit.contain,
                )
              : Lottie.asset(
                  "assets/images/final-payment.json",
                  fit: BoxFit.contain,
                ),
        ),
        const SizedBox(height: 32),
        // Content
        _buildHeroContent(context, isTablet: true),
      ],
    );
  }

  Widget _buildDesktopHeroLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - Text Content
        Expanded(
          flex: 3,
          child: _buildHeroContent(context, isTablet: false),
        ),
        const SizedBox(width: 48),
        // Right side - Illustration
        Expanded(
          flex: 2,
          child: Container(
            height: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorManager.primary.withValues(alpha: 0.05),
                  ColorManager.primary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: kIsWeb
                ? Image.asset(
                    'assets/images/payment_image.png',
                    fit: BoxFit.contain,
                  )
                : Lottie.asset(
                    "assets/images/final-payment.json",
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroContent(BuildContext context, {required bool isTablet}) {
    return Column(
      crossAxisAlignment: isTablet ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: ColorManager.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            "طرق الدفع",
            style: TextStyle(
              color: ColorManager.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "اختر طريقة الدفع المناسبة لك",
          style: TextStyle(
            fontSize: isTablet ? 28 : 36,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
            fontFamily: StringConstant.fontName,
            height: 1.2,
          ),
          textAlign: isTablet ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 16),
        Text(
          "نوفر لك طرق دفع متعددة وآمنة لإتمام عملياتك بكل سهولة وثقة",
          style: TextStyle(
            fontSize: isTablet ? 16 : 18,
            color: const Color(0xFF64748B),
            fontFamily: StringConstant.fontName,
            height: 1.6,
          ),
          textAlign: isTablet ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          alignment: isTablet ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _buildFeatureItem(Icons.security, "آمن ومحمي"),
            _buildFeatureItem(Icons.flash_on, "سريع ومباشر"),
            _buildFeatureItem(Icons.support_agent, "دعم 24/7"),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorManager.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ColorManager.primary, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF475569),
            fontFamily: StringConstant.fontName,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptionsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth < 768 ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "طرق الدفع المتاحة",
            style: TextStyle(
              fontSize: screenWidth < 768 ? 24 : 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              fontFamily: StringConstant.fontName,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "اختر من بين الطرق التالية لإتمام عملية الدفع",
            style: TextStyle(
              fontSize: screenWidth < 768 ? 14 : 16,
              color: const Color(0xFF64748B),
              fontFamily: StringConstant.fontName,
            ),
          ),
          const SizedBox(height: 32),
          _buildPaymentGrid(context),
        ],
      ),
    );
  }

  Widget _buildPaymentGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Determine columns and spacing based on screen size
    int crossAxisCount = 1;
    double spacing = 16;
    double childAspectRatio = 4.5;
    
    if (screenWidth >= 1200) {
      crossAxisCount = 2;
      spacing = 24;
      childAspectRatio = 4.5;
    } else if (screenWidth >= 768) {
      crossAxisCount = 2;
      spacing = 20;
      childAspectRatio = 3.5;
    } else {
      crossAxisCount = 1;
      spacing = 16;
      childAspectRatio = 5.5;
    }

    final paymentOptions = [
      {
        'title': "commercial_bank_account".tr(),
        'subtitle': "البنك التجاري الدولي",
        'icon': Icons.account_balance,
        'gradient': [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
        'code': 'CIB',
      },
      {
        'title': "qatar_bank_account".tr(),
        'subtitle': "بنك قطر الوطني",
        'icon': Icons.account_balance_wallet,
        'gradient': [const Color(0xFF10B981), const Color(0xFF047857)],
        'code': 'QNB',
      },
      {
        'title': "ky_commercial_bank_account".tr(),
        'subtitle': "حساب كي واي التجاري",
        'icon': Icons.business,
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        'code': 'KY',
      },
      {
        'title': "commercial_bank_account".tr(),
        'subtitle': "حساب بنكي تجاري",
        'icon': Icons.credit_card,
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
        'code': 'BANK',
      },
      {
        'title': "pay_by_vc".tr(),
        'subtitle': "فيزا وماستركارد",
        'icon': Icons.payment,
        'gradient': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
        'code': 'CARD',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: paymentOptions.length,
      itemBuilder: (context, index) {
        return _buildPaymentCard(paymentOptions[index], screenWidth);
      },
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> option, double screenWidth) {
    final isSmallScreen = screenWidth < 768;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Handle payment option selection
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: option['gradient'] as List<Color>,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  option['icon'] as IconData,
                  color: Colors.white,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option['title'] as String,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                        fontFamily: StringConstant.fontName,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option['subtitle'] as String,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: const Color(0xFF64748B),
                        fontFamily: StringConstant.fontName,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 768;
    
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 32),
      padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.primary.withValues(alpha: 0.05),
            ColorManager.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorManager.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorManager.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.verified_user, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                "الأمان والحماية",
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.primary,
                  fontFamily: StringConstant.fontName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "نحن نضمن أعلى مستويات الأمان لحماية معلوماتك المالية والشخصية. جميع المعاملات محمية بتشفير عالي المستوى ومعايير الأمان الدولية.",
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: const Color(0xFF64748B),
              fontFamily: StringConstant.fontName,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _buildSecurityFeature(Icons.lock, "تشفير SSL"),
              _buildSecurityFeature(Icons.shield, "حماية البيانات"),
              _buildSecurityFeature(Icons.verified, "معتمد دولياً"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: ColorManager.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorManager.primary,
            fontFamily: StringConstant.fontName,
          ),
        ),
      ],
    );
  }
} 