// lib/presentation/Screens/chat screen/view/screen/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyuser/presentation/Widget/loading_widget.dart';
import 'package:provider/provider.dart';
import '../../../../../resources/Color_Manager.dart';
import '../../model/message_model.dart';
import '../../view_model/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;

  const ChatScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: ChangeNotifierProvider(
        create: (_) => ChatViewModel(chatId),
        child: Consumer<ChatViewModel>(
          builder: (context, viewModel, child) {
            return Scaffold(
              backgroundColor: Colors.grey.shade50,
              appBar: _buildAppBar(context, viewModel),
              body: viewModel.isLoading
                  ? Center(child: LoadingWidget())
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.shade50,
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: ListView.builder(
                                reverse: true,
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                itemCount: viewModel.messages.length +
                                    (viewModel.isTyping ? 1 : 0),
                                itemBuilder: (context, index) {
                                  // Show typing indicator at the top (index 0 when reversed)
                                  if (viewModel.isTyping && index == 0) {
                                    return TypingIndicator(
                                      userName: viewModel.isAdmin ? 'User' : 'Admin',
                                    );
                                  }

                                  // Adjust index for messages
                                  final messageIndex = viewModel.isTyping
                                      ? index - 1
                                      : index;
                                  final message = viewModel.messages[messageIndex];

                                  return MessageBubble(
                                    message: message,
                                    onTap: () => _handleMessageTap(context, message, viewModel),
                                  );
                                },
                              ),
                            ),
                          ),
                          ChatInput(
                            onSendMessage: (text) => viewModel.sendMessage(text: text),
                            onSendAudio: (audioFile, fileName) => viewModel.sendMessage(
                              file: audioFile,
                              fileName: fileName,
                              type: MessageType.audio,
                            ),
                            onAttachmentSelected: (file, fileName, type) => viewModel.sendMessage(
                              file: file,
                              fileName: fileName,
                              type: _getMessageTypeFromString(type),
                            ),
                            onTypingChanged: viewModel.setTypingStatus,
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatViewModel viewModel) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 70,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorManager.primary,
              ColorManager.primaryByOpacity,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorManager.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  viewModel.isAdmin ? viewModel.userName ?? 'User' : 'Admin Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getStatusText(viewModel.otherUserStatus),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(viewModel.otherUserStatus),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(viewModel.otherUserStatus).withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.online:
        return 'Online';
      case UserStatus.typing:
        return 'Typing...';
      case UserStatus.offline:
        return 'Last seen recently';
    }
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.online:
      case UserStatus.typing:
        return Colors.green.shade400;
      case UserStatus.offline:
        return Colors.grey.shade400;
    }
  }

  MessageType _getMessageTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'pdf':
        return MessageType.pdf;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.file;
    }
  }

  void _handleMessageTap(BuildContext context, MessageModel message, ChatViewModel viewModel) {
    if (message.mediaUrl == null) return;

    switch (message.type) {
      case MessageType.image:
        _showImageViewer(context, message.mediaUrl!);
        break;
      case MessageType.video:
      case MessageType.pdf:
      case MessageType.file:
      case MessageType.audio:
        // These are now handled by their respective widgets
        break;
      default:
        break;
    }
  }

  void _showImageViewer(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.white, size: 50),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}