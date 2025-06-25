import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../domain/Issues/Entities/IssuesEntity.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';

class MobileIssueDetailsView extends StatelessWidget {
  final IssueDetailsEntity issueDetails;
  final ScrollController scrollController;
  final GlobalKey issueInfoKey;
  final GlobalKey brandInfoKey;
  final GlobalKey refusedDetailsKey;

  const MobileIssueDetailsView({
    super.key,
    required this.issueDetails,
    required this.scrollController,
    required this.issueInfoKey,
    required this.brandInfoKey,
    required this.refusedDetailsKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // Issue Header

            const SizedBox(height: 16),
            
            // Issue Info Card
           // _buildIssueInfoCard(context),
            
            const SizedBox(height: 16),
            
            // Brand Info Card
            _buildBrandInfoCard(context),
            
            const SizedBox(height: 16),
            
            // Customer & Company Info Card
            _buildCustomerCompanyCard(context),
            
            const SizedBox(height: 16),
            
            // Refused Details Card
            _buildRefusedDetailsCard(context),
            
            const SizedBox(height: 16),
            
            // Statistics Card
            _buildStatisticsCard(context),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.primary,
            ColorManager.primary.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Issue Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.gavel,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Issue Title
              Text(
                "قضية رقم ${issueDetails.id}",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Issue Type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getIssueTypeText(issueDetails.refusedType),
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueInfoCard(BuildContext context) {
    return Container(
      key: issueInfoKey,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: ColorManager.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "معلومات القضية",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Issue Details
          _buildInfoRow("رقم القضية", issueDetails.id.toString()),
          _buildInfoRow("نوع القضية", _getIssueTypeText(issueDetails.refusedType)),
          _buildInfoRow("تاريخ الإنشاء", _formatDate(issueDetails.createdAt)),
          _buildInfoRow("آخر تحديث", _formatDate(issueDetails.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildBrandInfoCard(BuildContext context) {
    return Container(
      key: brandInfoKey,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business_center_outlined,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "معلومات العلامة التجارية",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Brand Details
          _buildInfoRow("اسم العلامة", issueDetails.brand.brandName),
          _buildInfoRow("رقم العلامة", issueDetails.brand.brandNumber),
          if (issueDetails.brand.brandDescription != null && issueDetails.brand.brandDescription!.isNotEmpty)
            _buildInfoRow("وصف العلامة", issueDetails.brand.brandDescription!),
          if (issueDetails.brand.brandDetails != null && issueDetails.brand.brandDetails!.isNotEmpty)
            _buildInfoRow("تفاصيل العلامة", issueDetails.brand.brandDetails!),
        ],
      ),
    );
  }

  Widget _buildCustomerCompanyCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Info Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.green.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "معلومات العميل",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoRow("الاسم", issueDetails.customer.name),
          _buildInfoRow("البريد الإلكتروني", issueDetails.customer.email),
          _buildInfoRow("رقم الهاتف", issueDetails.customer.phone),
          if (issueDetails.customer.address != null && issueDetails.customer.address!.isNotEmpty)
            _buildInfoRow("العنوان", issueDetails.customer.address!),
          
          const SizedBox(height: 20),
          
          // Company Info Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business_outlined,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "معلومات الشركة",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoRow("اسم الشركة", issueDetails.company.companyName),
          if (issueDetails.company.address != null && issueDetails.company.address!.isNotEmpty)
            _buildInfoRow("عنوان الشركة", issueDetails.company.address!),
        ],
      ),
    );
  }

  Widget _buildRefusedDetailsCard(BuildContext context) {
    final refusedDetails = issueDetails.refusedDetails;
    final isOpposition = issueDetails.refusedType.toLowerCase().contains('opposition');
    
    return Container(
      key: refusedDetailsKey,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: Colors.red.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "تفاصيل القضية",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Basic refused details
          if (refusedDetails.appealDate != null && refusedDetails.appealDate!.isNotEmpty)
            _buildInfoRow("تاريخ الاستئناف", _formatDate(refusedDetails.appealDate!)),
          if (refusedDetails.appealNumber != null && refusedDetails.appealNumber!.isNotEmpty)
            _buildInfoRow("رقم الاستئناف", refusedDetails.appealNumber!),
          if (refusedDetails.refusedDate != null && refusedDetails.refusedDate!.isNotEmpty)
            _buildInfoRow("تاريخ الرفض", _formatDate(refusedDetails.refusedDate!)),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    final statistics = issueDetails.statistics;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: Colors.purple.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "إحصائيات القضية",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.purple.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Statistics Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "الجلسات",
                  statistics.sessionsCount.toString(),
                  Icons.event,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "التذكيرات",
                  statistics.remindersCount.toString(),
                  Icons.notification_important,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "الجلسات المكتملة",
                  statistics.completedSessions.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "الجلسات المعلقة",
                  statistics.pendingSessions.toString(),
                  Icons.pending,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIssueTypeText(String refusedType) {
    switch (refusedType.toLowerCase()) {
      case 'normal':
        return 'قضية عادية';
      case 'opposition':
        return 'قضية اعتراض';
      default:
        return refusedType;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString.split(' ')[0]; // Return date part only
    }
  }
} 