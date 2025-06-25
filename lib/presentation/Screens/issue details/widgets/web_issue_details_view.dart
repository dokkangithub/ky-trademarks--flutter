import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../domain/Issues/Entities/IssuesEntity.dart';
import '../../../../resources/Color_Manager.dart';
import '../../../../resources/StringManager.dart';

class WebIssueDetailsView extends StatelessWidget {
  final IssueDetailsEntity issueDetails;
  final ScrollController scrollController;
  final GlobalKey issueInfoKey;
  final GlobalKey brandInfoKey;
  final GlobalKey refusedDetailsKey;

  const WebIssueDetailsView({
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Issue Header
              _buildIssueHeader(context),
              
              const SizedBox(height: 32),
              
              // Main Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildIssueInfoCard(context),
                        const SizedBox(height: 24),
                        _buildBrandInfoCard(context),
                        const SizedBox(height: 24),
                        _buildRefusedDetailsCard(context),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 24),
                  
                  // Right Column
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildCustomerCompanyCard(context),
                        const SizedBox(height: 24),
                        _buildStatisticsCard(context),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.primary,
            ColorManager.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Issue Icon
          Container(
            width: 100,
            height: 100,
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
              size: 50,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Issue Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "قضية رقم ${issueDetails.id}",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _getIssueTypeText(issueDetails.refusedType),
                    style: TextStyle(
                      fontFamily: StringConstant.fontName,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  "تاريخ الإنشاء: ${_formatDate(issueDetails.createdAt)}",
                  style: TextStyle(
                    fontFamily: StringConstant.fontName,
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueInfoCard(BuildContext context) {
    return Container(
      key: issueInfoKey,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: ColorManager.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "معلومات القضية",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Issue Details Grid
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow("رقم القضية", issueDetails.id.toString()),
                    _buildInfoRow("نوع القضية", _getIssueTypeText(issueDetails.refusedType)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow("تاريخ الإنشاء", _formatDate(issueDetails.createdAt)),
                    _buildInfoRow("آخر تحديث", _formatDate(issueDetails.updatedAt)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandInfoCard(BuildContext context) {
    return Container(
      key: brandInfoKey,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_center_outlined,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "معلومات العلامة التجارية",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Brand Details Grid
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow("اسم العلامة", issueDetails.brand.brandName),
                    if (issueDetails.brand.brandDescription != null && issueDetails.brand.brandDescription!.isNotEmpty)
                      _buildInfoRow("وصف العلامة", issueDetails.brand.brandDescription!),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow("رقم العلامة", issueDetails.brand.brandNumber),
                    if (issueDetails.brand.brandDetails != null && issueDetails.brand.brandDetails!.isNotEmpty)
                      _buildInfoRow("تفاصيل العلامة", issueDetails.brand.brandDetails!),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCompanyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          // Customer Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "معلومات العميل",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildInfoRow("الاسم", issueDetails.customer.name),
          _buildInfoRow("البريد الإلكتروني", issueDetails.customer.email),
          _buildInfoRow("رقم الهاتف", issueDetails.customer.phone),
          if (issueDetails.customer.address != null && issueDetails.customer.address!.isNotEmpty)
            _buildInfoRow("العنوان", issueDetails.customer.address!),
          
          const SizedBox(height: 32),
          
          // Company Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_outlined,
                  color: Colors.orange.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "معلومات الشركة",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildInfoRow("اسم الشركة", issueDetails.company.companyName),
          if (issueDetails.company.address != null && issueDetails.company.address!.isNotEmpty)
            _buildInfoRow("عنوان الشركة", issueDetails.company.address!),
        ],
      ),
    );
  }

  Widget _buildRefusedDetailsCard(BuildContext context) {
    final refusedDetails = issueDetails.refusedDetails;
    
    return Container(
      key: refusedDetailsKey,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: Colors.red.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "تفاصيل القضية",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Refused Details Grid
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (refusedDetails.appealDate != null && refusedDetails.appealDate!.isNotEmpty)
                      _buildInfoRow("تاريخ الاستئناف", _formatDate(refusedDetails.appealDate!)),
                    if (refusedDetails.refusedDate != null && refusedDetails.refusedDate!.isNotEmpty)
                      _buildInfoRow("تاريخ الرفض", _formatDate(refusedDetails.refusedDate!)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    if (refusedDetails.appealNumber != null && refusedDetails.appealNumber!.isNotEmpty)
                      _buildInfoRow("رقم الاستئناف", refusedDetails.appealNumber!),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    final statistics = issueDetails.statistics;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: Colors.purple.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "الإحصائيات",
                style: TextStyle(
                  fontFamily: StringConstant.fontName,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.purple.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Statistics Grid
          Column(
            children: [
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
                  const SizedBox(width: 16),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "المكتملة",
                      statistics.completedSessions.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      "المعلقة",
                      statistics.pendingSessions.toString(),
                      Icons.pending,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: StringConstant.fontName,
              fontSize: 14,
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: StringConstant.fontName,
                fontSize: 16,
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
