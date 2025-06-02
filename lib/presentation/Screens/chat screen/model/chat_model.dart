import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String? username;
  final String? lastMessage;
  final String? lastMessageTime;
  final bool? isRead;

  ChatMessage({
    this.username,
    this.lastMessage,
    this.lastMessageTime,
    this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String id) {
    final author = types.User(id: json['author']);
    return ChatMessage(
      username: json['username'],
      lastMessageTime: json['lastMessageTime'],
      lastMessage: json['lastMessage'],
      isRead: json['isRead'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'lastMessageTime': lastMessageTime,
      'lastMessage': lastMessage,
      'isRead': isRead,

    };
  }
}
