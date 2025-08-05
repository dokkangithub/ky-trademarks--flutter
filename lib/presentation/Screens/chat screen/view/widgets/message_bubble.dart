// lib/presentation/Screens/chat screen/view/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconly/iconly.dart';
import '../../model/message_model.dart';
import '../../../../../resources/Color_Manager.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final VoidCallback? onTap;

  const MessageBubble({
    Key? key,
    required this.message,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: message.isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: ColorManager.primary.withOpacity(0.1),
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.primary,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: 80,
              ),
              decoration: BoxDecoration(
                color: message.isFromCurrentUser
                    ? ColorManager.primary
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: message.isFromCurrentUser
                      ? Radius.circular(18)
                      : Radius.circular(4),
                  bottomRight: message.isFromCurrentUser
                      ? Radius.circular(4)
                      : Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!message.isFromCurrentUser && message.senderName.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            message.senderName,
                            style: TextStyle(
                              color: ColorManager.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      _buildMessageContent(context),
                      SizedBox(height: 4),
                      _buildMessageInfo(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (message.isFromCurrentUser) ...[
            SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildMessageStatusIcon(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage();

      case MessageType.image:
        return _buildImageMessage();

      case MessageType.video:
        return _buildVideoMessage();

      case MessageType.audio:
        return _buildAudioMessage();

      case MessageType.pdf:
        return _buildPdfMessage();

      case MessageType.file:
        return _buildFileMessage();

      default:
        return SizedBox();
    }
  }

  Widget _buildTextMessage() {
    return Text(
      message.text ?? '',
      style: TextStyle(
        color: message.isFromCurrentUser ? Colors.white : Colors.black87,
        fontSize: 16,
        height: 1.3,
      ),
    );
  }

  Widget _buildImageMessage() {
    if (message.mediaUrl == null) {
      return _buildErrorMessage('صورة غير متاحة');
    }
print('ddd${message.mediaUrl!}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.text?.isNotEmpty == true) ...[
          _buildTextMessage(),
          SizedBox(height: 8),
        ],
        Container(
          constraints: BoxConstraints(
            maxHeight: 250,
            maxWidth: 250,
            minHeight: 150,
            minWidth: 150,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: message.mediaUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          message.isFromCurrentUser ? Colors.white : ColorManager.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'جاري التحميل...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              errorWidget: (context, url, error) => _buildErrorMessage('فشل في تحميل الصورة'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoMessage() {
    return _buildMediaMessage(
      icon: Icons.play_circle_fill,
      color: Colors.red,
      title: message.fileName ?? 'فيديو',
      subtitle: 'اضغط للتشغيل',
    );
  }

  Widget _buildAudioMessage() {
    return _buildMediaMessage(
      icon: Icons.audiotrack,
      color: Colors.green,
      title: message.fileName ?? 'ملف صوتي',
      subtitle: 'اضغط للاستماع',
    );
  }

  Widget _buildPdfMessage() {
    return _buildMediaMessage(
      icon: Icons.picture_as_pdf,
      color: Colors.red,
      title: message.fileName ?? 'ملف PDF',
      subtitle: 'اضغط للفتح',
    );
  }

  Widget _buildFileMessage() {
    return _buildMediaMessage(
      icon: IconlyBroken.document,
      color: Colors.orange,
      title: message.fileName ?? 'ملف',
      subtitle: 'اضغط للتحميل',
    );
  }

  Widget _buildMediaMessage({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.text?.isNotEmpty == true) ...[
          _buildTextMessage(),
          SizedBox(height: 8),
        ],
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isFromCurrentUser
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: message.isFromCurrentUser ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: message.isFromCurrentUser
                            ? Colors.white70
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (message.fileSize != null)
                      Text(
                        _formatFileSize(message.fileSize!),
                        style: TextStyle(
                          color: message.isFromCurrentUser
                              ? Colors.white70
                              : Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String errorText) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            SizedBox(height: 4),
            Text(
              errorText,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInfo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          _formatTime(message.createdAt),
          style: TextStyle(
            color: message.isFromCurrentUser
                ? Colors.white70
                : Colors.grey.shade500,
            fontSize: 11,
          ),
        ),
        if (message.isFromCurrentUser) ...[
          SizedBox(width: 4),
          _buildMessageStatusIcon(),
        ],
      ],
    );
  }

  Widget _buildMessageStatusIcon() {
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = message.isFromCurrentUser ? Colors.white70 : Colors.grey;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = message.isFromCurrentUser ? Colors.white70 : Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = message.isFromCurrentUser ? Colors.white70 : Colors.grey;
        break;
      case MessageStatus.seen:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'أمس ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes بايت';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} ك.ب';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} م.ب';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} ج.ب';
  }
}