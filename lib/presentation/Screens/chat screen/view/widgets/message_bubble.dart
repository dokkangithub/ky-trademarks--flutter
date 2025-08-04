// lib/presentation/Screens/chat screen/view/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
              backgroundColor: Colors.grey.shade300,
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
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
              ),
              child: GestureDetector(
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
            _buildMessageStatus(),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.text ?? '',
          style: TextStyle(
            color: message.isFromCurrentUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        );

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

  Widget _buildImageMessage() {
    if (message.mediaUrl == null) return SizedBox();

    return Container(
      constraints: BoxConstraints(maxHeight: 200, maxWidth: 200),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: message.mediaUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 150,
            color: Colors.grey.shade300,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 150,
            color: Colors.grey.shade300,
            child: Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoMessage() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_fill,
            color: message.isFromCurrentUser ? Colors.white : Colors.blue,
            size: 32,
          ),
          SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'Video',
                  style: TextStyle(
                    color: message.isFromCurrentUser ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (message.fileSize != null)
                  Text(
                    _formatFileSize(message.fileSize!),
                    style: TextStyle(
                      color: message.isFromCurrentUser
                          ? Colors.white70
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.audiotrack,
            color: message.isFromCurrentUser ? Colors.white : Colors.green,
            size: 32,
          ),
          SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'Audio',
                  style: TextStyle(
                    color: message.isFromCurrentUser ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (message.fileSize != null)
                  Text(
                    _formatFileSize(message.fileSize!),
                    style: TextStyle(
                      color: message.isFromCurrentUser
                          ? Colors.white70
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfMessage() {
    return Container(
        padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(
    Icons.picture_as_pdf,
    color: message.isFromCurrentUser ? Colors.white : Colors.red,
    size: 32,
    ),
    SizedBox(width: 8),
    Flexible(
    child: Column(