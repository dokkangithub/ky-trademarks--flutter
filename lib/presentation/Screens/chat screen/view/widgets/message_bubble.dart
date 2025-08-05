// lib/presentation/Screens/chat screen/view/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconly/iconly.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../model/message_model.dart';
import '../../../../../resources/Color_Manager.dart';
import 'audio_message_bubble.dart';
import 'video_message_bubble.dart';
import 'pdf_message_bubble.dart';
import 'file_message_bubble.dart';

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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: message.isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isFromCurrentUser) ...[
            _buildAvatar(),
            SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
                minWidth: 100,
              ),
              decoration: BoxDecoration(
                color: message.isFromCurrentUser
                    ? ColorManager.primary
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: message.isFromCurrentUser
                      ? Radius.circular(2)
                      : Radius.circular(15),
                  bottomRight: message.isFromCurrentUser
                      ? Radius.circular(15)
                      : Radius.circular(2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
                border: message.isFromCurrentUser
                    ? null
                    : Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: GestureDetector(
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.all(message.text!=null? 8:4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (!message.isFromCurrentUser && message.senderName.isNotEmpty)
                      //   Padding(
                      //     padding: EdgeInsets.only(bottom: 6),
                      //     child: Text(
                      //       message.senderName,
                      //       style: TextStyle(
                      //         color: ColorManager.primary,
                      //         fontSize: 13,
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //   ),
                      _buildMessageContent(context),
                      SizedBox(height: 8),
                      _buildMessageInfo(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (message.isFromCurrentUser) ...[
            SizedBox(width: 12),
            _buildMessageStatus(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary.withOpacity(0.8),
            ColorManager.primaryByOpacity,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
        height: 1.4,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildImageMessage() {
    // Show loading state if message is sending or mediaUrl is null
    if (message.status == MessageStatus.sending || message.mediaUrl == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.text?.isNotEmpty == true) ...[
            _buildTextMessage(),
            SizedBox(height: 12),
          ],
          Container(
            constraints: BoxConstraints(
              maxHeight: 280,
              maxWidth: 280,
              minHeight: 160,
              minWidth: 160,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        message.isFromCurrentUser ? Colors.white : ColorManager.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    message.status == MessageStatus.sending ? 'uploading_image'.tr() : 'loading_image'.tr(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.text?.isNotEmpty == true) ...[
          _buildTextMessage(),
          SizedBox(height: 12),
        ],
        Container(
          constraints: BoxConstraints(
            maxHeight: 280,
            maxWidth: 280,
            minHeight: 160,
            minWidth: 160,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: message.mediaUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            message.isFromCurrentUser ? Colors.white : ColorManager.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'loading'.tr(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              errorWidget: (context, url, error) => _buildErrorMessage('failed_load_image'.tr()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoMessage() {
    // Show loading state if message is sending or mediaUrl is null
    if (message.status == MessageStatus.sending || message.mediaUrl == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.text?.isNotEmpty == true) ...[
            _buildTextMessage(),
            SizedBox(height: 12),
          ],
          Container(
            constraints: BoxConstraints(
              maxHeight: 280,
              maxWidth: 280,
              minHeight: 160,
              minWidth: 160,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        message.isFromCurrentUser ? Colors.white : ColorManager.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    message.status == MessageStatus.sending ? 'uploading_video'.tr() : 'loading_video'.tr(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return VideoMessageBubble(
      videoUrl: message.mediaUrl!,
      isFromCurrentUser: message.isFromCurrentUser,
      caption: message.text,
    );
  }

  Widget _buildAudioMessage() {
    // Show loading state if message is sending or mediaUrl is null
    if (message.status == MessageStatus.sending || message.mediaUrl == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.text?.isNotEmpty == true) ...[
            _buildTextMessage(),
            SizedBox(height: 12),
          ],
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  message.status == MessageStatus.sending ? 'uploading_audio'.tr() : 'loading_audio'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.text?.isNotEmpty == true) ...[
          _buildTextMessage(),
          SizedBox(height: 12),
        ],
        AudioMessageBubble(
          audioUrl: message.mediaUrl!,
          isFromCurrentUser: message.isFromCurrentUser,
          bubbleColor: message.isFromCurrentUser
              ? ColorManager.primary
              : Colors.grey.shade50,
          duration: message.fileSize != null
              ? Duration(milliseconds: message.fileSize!)
              : null,
          isEmbedded: true,
        ),
      ],
    );
  }

  Widget _buildPdfMessage() {
    // Show loading state if message is sending or mediaUrl is null
    if (message.status == MessageStatus.sending || message.mediaUrl == null) {
      return _buildMediaMessage(
        icon: IconlyBroken.document,
        color: Colors.red.shade500,
        title: message.fileName ?? 'document'.tr() + '.pdf',
        subtitle: message.status == MessageStatus.sending ? 'uploading'.tr() : 'loading'.tr(),
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        isLoading: true,
      );
    }

    return PdfMessageBubble(
      pdfUrl: message.mediaUrl!,
      fileName: message.fileName ?? 'document'.tr() + '.pdf',
      isFromCurrentUser: message.isFromCurrentUser,
      caption: message.text,
    );
  }

  Widget _buildFileMessage() {
    // Show loading state if message is sending or mediaUrl is null
    if (message.status == MessageStatus.sending || message.mediaUrl == null) {
      return _buildMediaMessage(
        icon: IconlyBroken.document,
        color: Colors.orange.shade500,
        title: message.fileName ?? 'file'.tr(),
        subtitle: message.status == MessageStatus.sending ? 'uploading'.tr() : 'loading'.tr(),
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        isLoading: true,
      );
    }

    return FileMessageBubble(
      fileUrl: message.mediaUrl!,
      fileName: message.fileName ?? 'file'.tr(),
      isFromCurrentUser: message.isFromCurrentUser,
      caption: message.text,
    );
  }

  Widget _buildMediaMessage({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Gradient gradient,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.text?.isNotEmpty == true) ...[
          _buildTextMessage(),
          SizedBox(height: 12),
        ],
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (message.fileSize != null && !isLoading) ...[
                      SizedBox(height: 4),
                      Text(
                        _formatFileSize(message.fileSize!),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
      height: 120,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 28),
            SizedBox(height: 8),
            Text(
              errorText,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
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
                ? Colors.white.withOpacity(0.8)
                : Colors.grey.shade500,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageStatus() {
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.grey.shade400;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey.shade400;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey.shade400;
        break;
      case MessageStatus.seen:
        icon = Icons.done_all;
        color = Colors.blue.shade400;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red.shade400;
        break;
    }

    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
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
      return 'yesterday'.tr() + ' ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}