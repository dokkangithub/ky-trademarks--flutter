import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kyuser/presentation/Screens/chat%20screen/view/screen/chat_screen.dart';
import 'package:kyuser/presentation/Widget/loading_widget.dart';
import '../../../../../resources/Color_Manager.dart';
import '../../model/chat_model.dart';
import '../../model/message_model.dart';
import '../../view_model/all_chats_provider.dart';

class AllChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: ChangeNotifierProvider(
        create: (_) => AllChatsViewModel(),
        child: Consumer<AllChatsViewModel>(
          builder: (context, viewModel, child) {
            return Scaffold(
              backgroundColor: Colors.grey.shade50,
              appBar: AppBar(
                title: Text(
                  'chats'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                backgroundColor: ColorManager.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
              ),
              body: viewModel.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'loading_chats'.tr(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Search Bar
                        _buildSearchBar(),

                        // Chat List or Empty State
                        Expanded(
                          child: viewModel.chats.isEmpty
                              ? _buildEmptyState(viewModel)
                              : _buildChatList(viewModel),
                        ),
                      ],
                    ),
              floatingActionButton: !viewModel.isAdmin
                  ? Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: FloatingActionButton.extended(
                        onPressed: () => _startChatWithAdmin(context, viewModel),
                        backgroundColor: ColorManager.primary,
                        icon: Icon(Icons.chat, color: Colors.white),
                        label: Text(
                          'start_conversation'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'search_chats'.tr(),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AllChatsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: ColorManager.primary.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 24),
          Text(
            viewModel.isAdmin
                ? 'no_chats_yet'.tr()
                : 'start_chat_support'.tr(),
            style: TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            viewModel.isAdmin
                ? 'chats_will_appear'.tr()
                : 'press_chat_button'.tr(),
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(AllChatsViewModel viewModel) {
    return AnimationLimiter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: viewModel.chats.length,
        itemBuilder: (context, index) {
          final chat = viewModel.chats[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: ChatTile(
                  chat: chat,
                  onTap: () => _openChat(context, chat),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openChat(BuildContext context, ChatModel chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: chat.chatId),
      ),
    );
  }

  void _startChatWithAdmin(BuildContext context, AllChatsViewModel viewModel) async {
    await viewModel.startChatWithAdmin();
    // Navigate to chat screen with user's ID as chatId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: viewModel.userId!),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const ChatTile({Key? key, required this.chat, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Avatar
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: ColorManager.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: chat.profileImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.network(
                                chat.profileImage!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultAvatar();
                                },
                              ),
                            )
                          : _buildDefaultAvatar(),
                    ),
                    // Online status indicator
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getStatusColor(chat.userStatus),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor(chat.userStatus).withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 16),

                // Chat Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.username ?? 'unknown_user'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chat.lastMessageTime != null)
                            Text(
                              _formatTime(chat.lastMessageTime!),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.lastMessage ?? 'start_conversation_hint'.tr(),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chat.unreadCount > 0) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ColorManager.primary,
                                    ColorManager.primaryByOpacity,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorManager.primary.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${chat.unreadCount}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary,
            ColorManager.primaryByOpacity,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          chat.username?.isNotEmpty == true
              ? chat.username![0].toUpperCase()
              : 'م',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'yesterday'.tr();
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}