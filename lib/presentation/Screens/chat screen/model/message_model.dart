enum MessageType { text, image, video, audio, pdf, file }
enum MessageStatus { sending, sent, delivered, seen, failed }
enum UserStatus { online, offline, typing }

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String chatId;
  final String? text;
  final String? mediaUrl;
  final String? fileName;
  final int? fileSize;
  final MessageType type;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? seenAt;
  final bool isFromCurrentUser;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.chatId,
    this.text,
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    required this.type,
    this.status = MessageStatus.sending,
    required this.createdAt,
    this.seenAt,
    this.isFromCurrentUser = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String id) {
    return MessageModel(
      id: id,
      senderId: json['senderId'],
      senderName: json['senderName'],
      chatId: json['chatId'],
      text: json['text'],
      mediaUrl: json['mediaUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      type: MessageType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      seenAt: json['seenAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['seenAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'chatId': chatId,
      'text': text,
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'seenAt': seenAt?.millisecondsSinceEpoch,
      // Note: isFromCurrentUser is not included as it's determined locally
    };
  }

  MessageModel copyWith({
    MessageStatus? status,
    DateTime? seenAt,
    bool? isFromCurrentUser,
  }) {
    return MessageModel(
      id: id,
      senderId: senderId,
      senderName: senderName,
      chatId: chatId,
      text: text,
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: fileSize,
      type: type,
      status: status ?? this.status,
      createdAt: createdAt,
      seenAt: seenAt ?? this.seenAt,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
    );
  }
}