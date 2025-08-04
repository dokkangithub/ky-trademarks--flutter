// lib/presentation/Screens/chat screen/view/screen/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyuser/presentation/Widget/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../../../../resources/Color_Manager.dart';
import '../../model/message_model.dart';
import '../../view_model/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input.dart';
import '../widgets/video_player.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;

  const ChatScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => ChatViewModel(chatId),
        child: Consumer<ChatViewModel>(
          builder: (context, viewModel, child) {
            return Scaffold(
              appBar: _buildAppBar(viewModel),
              body: viewModel.isLoading
                  ? Center(child: LoadingWidget())
                  : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      physics: BouncingScrollPhysics(),
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
                  ChatInput(
                    onSendMessage: (text) => viewModel.sendMessage(text: text),
                    onSendAudio: (audioFile, fileName) => viewModel.sendMessage(
                      file: audioFile,
                      fileName: fileName,
                      type: MessageType.audio,
                    ),
                    onAttachmentPressed: () => viewModel.handleAttachmentPressed(context),
                    onTypingChanged: viewModel.setTypingStatus,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatViewModel viewModel) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 60,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorManager.primaryByOpacity.withOpacity(0.9),
              ColorManager.primary,
            ],
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            viewModel.isAdmin ? 'User Chat' : 'Admin Support',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            _getStatusText(viewModel.otherUserStatus),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
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
        return Colors.green;
      case UserStatus.offline:
        return Colors.grey;
    }
  }

  void _handleMessageTap(BuildContext context, MessageModel message, ChatViewModel viewModel) {
    if (message.mediaUrl == null) return;

    switch (message.type) {
      case MessageType.image:
        _showImageViewer(context, message.mediaUrl!);
        break;
      case MessageType.video:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(videoUrl: message.mediaUrl!),
          ),
        );
        break;
      case MessageType.pdf:
      case MessageType.file:
      case MessageType.audio:
        _openFileUrl(message.mediaUrl!);
        break;
      default:
        break;
    }
  }

  void _showImageViewer(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.error, color: Colors.white, size: 50),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFileUrl(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}