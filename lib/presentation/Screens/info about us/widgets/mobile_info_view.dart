import 'package:flutter/material.dart';

import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';

class MobileInfoView extends StatelessWidget {
  const MobileInfoView({super.key});

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
          // Header Section
          SliverToBoxAdapter(
            child: _buildMobileHeader(context),
          ),
          
          // Info Sections
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMobileInfoCard(
                  context: context,
                  title: "نـبـذة عنــا",
                  content: StringConstant.aboutOur,
                  icon: Icons.info_outline,
                  gradientColors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                const SizedBox(height: 20),
                
                _buildMobileInfoCard(
                  context: context,
                  title: "مهمتنــــــا",
                  content: StringConstant.ourRole,
                  icon: Icons.flag_outlined,
                  gradientColors: [Colors.green.shade400, Colors.green.shade600],
                ),
                const SizedBox(height: 20),
                
                _buildMobileInfoCard(
                  context: context,
                  title: "رؤيتنـــــــــا",
                  content: StringConstant.ourVision,
                  icon: Icons.visibility_outlined,
                  gradientColors: [Colors.purple.shade400, Colors.purple.shade600],
                ),
                const SizedBox(height: 24),
              ]),
            ),
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
          // Company Icon
          Container(
            width: 80,
            height: 80,
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
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.business,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            "من نحن",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 24,
              color: ColorManager.primary,
              fontWeight: FontWeight.w700,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            "تعرف على شركتنا ومهمتنا ورؤيتنا",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
              fontFamily: StringConstant.fontName,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileInfoCard({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Container(
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
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
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
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              content,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 15,
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