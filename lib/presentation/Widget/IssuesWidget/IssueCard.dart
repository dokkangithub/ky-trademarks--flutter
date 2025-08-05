import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../domain/Issues/Entities/IssuesEntity.dart';
import '../../../resources/StringManager.dart';

class IssueCard extends StatelessWidget {
  final IssueEntity issue;
  final VoidCallback? onTap;
  final bool isCompact;

  const IssueCard({
    required this.issue,
    this.onTap,
    this.isCompact = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 4,
        vertical: 4,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with issue type and ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _getTypeColor().withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTypeIcon(),
                          size: 14,
                          color: _getTypeColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTypeText(),
                          style: TextStyle(
                            color: _getTypeColor(),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: StringConstant.fontName,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '#${issue.id}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: StringConstant.fontName,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Brand name
              Text(
                issue.brand.brandName,
                style: TextStyle(
                  fontSize: isCompact ? 13 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: StringConstant.fontName,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Company name
              Text(
                issue.company.companyName,
                style: TextStyle(
                  fontSize: isCompact ? 11 : 12,
                  color: Colors.grey.shade600,
                  fontFamily: StringConstant.fontName,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (!isCompact) ...[
                const SizedBox(height: 8),
                
                // Customer info
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        issue.customer.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontFamily: StringConstant.fontName,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Statistics
                Row(
                  children: [
                    _buildStatItem(
                      Icons.event_note_outlined,
                      '${issue.sessionsCount}',
                      'جلسات',
                    ),
                    const SizedBox(width: 12),
                    _buildStatItem(
                      Icons.notifications_outlined,
                      '${issue.remindersCount}',
                      'تذكيرات',
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Created date
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(issue.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontFamily: StringConstant.fontName,
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

  Widget _buildStatItem(IconData icon, String count, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 2),
        Text(
          count,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontFamily: StringConstant.fontName,
          ),
        ),
        Text(
          ' $label',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
            fontFamily: StringConstant.fontName,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor() {
    return issue.refusedType == 'opposition' 
        ? Colors.red.shade600 
        : Colors.orange.shade600;
  }

  IconData _getTypeIcon() {
    return issue.refusedType == 'opposition' 
        ? Icons.gavel 
        : Icons.assignment_outlined;
  }

  String _getTypeText() {
    return issue.refusedType == 'opposition' ? 'معارضة' : 'عادية';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd').format(date);
    } catch (e) {
      return dateStr;
    }
  }
} 