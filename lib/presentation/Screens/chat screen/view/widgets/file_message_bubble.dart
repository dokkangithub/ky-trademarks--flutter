import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../resources/Color_Manager.dart';

class FileMessageBubble extends StatelessWidget {
  final String fileUrl;
  final String fileName;
  final bool isFromCurrentUser;
  final String? caption;

  const FileMessageBubble({
    Key? key,
    required this.fileUrl,
    required this.fileName,
    required this.isFromCurrentUser,
    this.caption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (caption?.isNotEmpty == true) ...[
          Text(
            caption!,
            style: TextStyle(
              color: isFromCurrentUser ? Colors.white : Colors.black87,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 12),
        ],
        GestureDetector(
          onTap: () => _openFile(context),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFromCurrentUser
                    ? [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        ColorManager.primary.withOpacity(0.1),
                        ColorManager.primaryByOpacity.withOpacity(0.05),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFromCurrentUser
                    ? Colors.white.withOpacity(0.2)
                    : ColorManager.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade500,
                        Colors.orange.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade500.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    IconlyBroken.document,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                          color: isFromCurrentUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'file'.tr(),
                        style: TextStyle(
                          color: isFromCurrentUser 
                              ? Colors.white.withOpacity(0.8) 
                              : Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.open_in_new,
                            color: isFromCurrentUser 
                                ? Colors.white.withOpacity(0.8) 
                                : ColorManager.primary,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'tap_to_open'.tr(),
                            style: TextStyle(
                              color: isFromCurrentUser 
                                  ? Colors.white.withOpacity(0.8) 
                                  : ColorManager.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openFile(BuildContext context) async {
    try {
      final Uri url = Uri.parse(fileUrl);
      
      // محاولة فتح الملف في تطبيق خارجي أولاً
      if (await canLaunchUrl(url)) {
        final result = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        
        if (!result) {
          // إذا فشل، جرب فتح في متصفح خارجي
          await launchUrl(
            url,
            mode: LaunchMode.externalNonBrowserApplication,
          );
        }
      } else {
        // إذا لم يمكن فتح الرابط مباشرة، جرب فتح في متصفح
        try {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          // إذا فشل كل شيء، اعرض رسالة خطأ
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('could_not_open_file'.tr()),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error opening file: $e');
      
      // محاولة أخيرة بفتح في متصفح
      try {
        final Uri url = Uri.parse(fileUrl);
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } catch (finalError) {
        print('Final error opening file: $finalError');
        
        // إذا فشل كلاهما، اعرض رسالة خطأ
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('could_not_open_file'.tr()),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
} 