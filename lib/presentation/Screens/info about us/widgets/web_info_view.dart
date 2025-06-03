import 'package:flutter/material.dart';

import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';

class WebInfoView extends StatelessWidget {
  const WebInfoView({super.key});

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
          // Header Section
          _buildWebHeader(context, isTablet: true),
          const SizedBox(height: 24),
          // Info Cards - Single column for tablet
          _buildInfoCardsColumn(context, isTablet: true),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left Panel - Header and Company Info
        Expanded(
          flex: 2,
          child: _buildLeftPanel(context),
        ),
        // Right Panel - Info Cards
        Expanded(
          flex: 3,
          child: _buildRightPanel(context),
        ),
      ],
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Company Header Card
          _buildWebHeader(context, isTablet: false),
          const SizedBox(height: 24),
          // Company Stats Card
          _buildCompanyStatsCard(context),
        ],
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context, {required bool isTablet}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 32),
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
          // Company Logo/Icon
          Container(
            width: isTablet ? 100 : 120,
            height: isTablet ? 100 : 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary,
                  ColorManager.primaryByOpacity,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorManager.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.business,
              color: Colors.white,
              size: isTablet ? 50 : 60,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 24),
          
          // Company Name
          Text(
            "من نحن",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: isTablet ? 28 : 32,
              color: ColorManager.primary,
              fontWeight: FontWeight.w700,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Company Description
          Text(
            "شركة رائدة في مجال العلامات التجارية والملكية الفكرية",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: isTablet ? 16 : 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
              fontFamily: StringConstant.fontName,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 20 : 24),
          
          // Decorative Element
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary,
                  ColorManager.primaryByOpacity,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyStatsCard(BuildContext context) {
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
                child: Icon(Icons.analytics_outlined, color: ColorManager.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "إحصائيات الشركة",
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
          
          _buildStatItem("سنوات الخبرة", "10+", Icons.timeline),
          const SizedBox(height: 12),
          _buildStatItem("العملاء", "500+", Icons.people_outline),
          const SizedBox(height: 12),
          _buildStatItem("العلامات المسجلة", "1000+", Icons.verified_outlined),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontFamily: StringConstant.fontName,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorManager.primary,
            fontFamily: StringConstant.fontName,
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
                  child: Icon(Icons.info_outline, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "معلومات الشركة",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.primary,
                          fontFamily: StringConstant.fontName,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "تعرف على مهمتنا ورؤيتنا وقيمنا",
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
          
          // Info Cards
          Expanded(
            child: _buildInfoCardsColumn(context, isTablet: false),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardsColumn(BuildContext context, {required bool isTablet}) {
    final infoItems = [
      {
        'title': "نـبـذة عنــا",
        'content': StringConstant.aboutOur,
        'icon': Icons.info_outline,
        'colors': [Colors.blue.shade400, Colors.blue.shade600],
      },
      {
        'title': "مهمتنــــــا",
        'content': StringConstant.ourRole,
        'icon': Icons.flag_outlined,
        'colors': [Colors.green.shade400, Colors.green.shade600],
      },
      {
        'title': "رؤيتنـــــــــا",
        'content': StringConstant.ourVision,
        'icon': Icons.visibility_outlined,
        'colors': [Colors.purple.shade400, Colors.purple.shade600],
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: infoItems.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: _buildWebInfoCard(
            context: context,
            title: item['title'] as String,
            content: item['content'] as String,
            icon: item['icon'] as IconData,
            gradientColors: item['colors'] as List<Color>,
            isTablet: isTablet,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildWebInfoCard({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    required List<Color> gradientColors,
    required bool isTablet,
  }) {
    return Container(
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
          // Header
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: isTablet ? 22 : 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 24),
            child: Text(
              content,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: isTablet ? 15 : 16,
                fontFamily: StringConstant.fontName,
                height: 1.6,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
} 