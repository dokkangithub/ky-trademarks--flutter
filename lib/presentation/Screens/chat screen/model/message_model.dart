import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String type;
  final types.User author;
  final String? text;
  final String? uri;
  final String? name;
  final int? size;
  final bool? isRead;
  final int? createdAt;

  ChatMessage({
    required this.id,
    required this.type,
    required this.author,
    this.text,
    this.uri,
    this.name,
    this.size,
    this.isRead,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String id) {
    final author = types.User(id: json['author']);
    return ChatMessage(
      id: id,
      type: json['type'],
      author: author,
      text: json['text'],
      uri: json['uri'],
      name: json['name'],
      size: json['size'],
      isRead: json['isRead'],
      createdAt: json['createdAt'] is int
          ? json['createdAt'] as int
          : (json['createdAt'] as Timestamp?)?.millisecondsSinceEpoch,);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'author': author.id,
      'text': text,
      'uri': uri,
      'name': name,
      'size': size,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}
