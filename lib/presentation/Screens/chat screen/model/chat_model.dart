import 'message_model.dart';

class ChatModel {
  final String chatId;
  final String? username;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool? isRead;
  final int unreadCount;
  final String? profileImage;
  final String userId;
  final UserStatus userStatus;

  ChatModel({
    required this.chatId,
    this.username,
    this.lastMessage,
    this.lastMessageTime,
    this.isRead,
    this.unreadCount = 0,
    this.profileImage,
    required this.userId,
    this.userStatus = UserStatus.offline,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json, String id) {
    return ChatModel(
      chatId: id,
      username: json['username'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastMessageTime'])
          : null,
      lastMessage: json['lastMessage'],
      isRead: json['isRead'],
      unreadCount: json['unreadCount'] ?? 0,
      profileImage: json['profileImage'],
      userId: json['userId'],
      userStatus: UserStatus.values.firstWhere(
            (e) => e.toString() == json['userStatus'],
        orElse: () => UserStatus.offline,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'isRead': isRead,
      'unreadCount': unreadCount,
      'profileImage': profileImage,
      'userId': userId,
      'userStatus': userStatus.toString(),
    };
  }
}