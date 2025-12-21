import 'dart:convert';

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

  /// المصنع القديم الخاص بفايربيز (محفوظ احتياطياً لو لسه فيه استخدامات داخلية).
  factory MessageModel.fromJson(Map<String, dynamic> json, String id) {
    return MessageModel(
      id: id,
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      chatId: json['chatId']?.toString() ?? '',
      text: json['text'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] is int ? json['fileSize'] as int : null,
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      seenAt: json['seenAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['seenAt'] as int)
          : null,
    );
  }

  /// مصنع خاص بالـ API الجديد:
  /// `/support/conversations/$conversation_id/messages`
  factory MessageModel.fromSupportApiJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final senderId = json['sender_id']?.toString() ?? '';
    final senderType = (json['sender_type']?.toString() ?? '').toLowerCase();
    final body = json['body'] as String?;
    final attachmentUrl = json['attachment_url'] as String?;
    final messageType =
        (json['message_type']?.toString() ?? 'text').toLowerCase();

    final isFromCurrentUser = senderType == 'customer' ||
        (currentUserId.isNotEmpty && senderId == currentUserId);

    final createdAtRaw = json['created_at']?.toString();
    final updatedAtRaw = json['updated_at']?.toString();

    DateTime createdAt;
    try {
      createdAt =
          createdAtRaw != null ? DateTime.parse(createdAtRaw) : DateTime.now();
    } catch (_) {
      createdAt = DateTime.now();
    }

    DateTime? seenAt;
    final isRead = json['is_read'] == true;
    if (isRead && updatedAtRaw != null) {
      try {
        seenAt = DateTime.parse(updatedAtRaw);
      } catch (_) {
        seenAt = null;
      }
    }

    return MessageModel(
      id: json['id']?.toString() ?? '',
      senderId: senderId,
      senderName: senderType == 'admin' ? 'الدعم الفني' : 'أنا',
      chatId: json['conversation_id']?.toString() ?? '',
      text: body,
      mediaUrl: attachmentUrl,
      fileName: null, // يمكن استخراج اسم الملف من الـ URL لو احتجنا بعدين
      fileSize: null,
      type: _mapApiTypeToMessageType(messageType, attachmentUrl),
      status: isRead ? MessageStatus.seen : MessageStatus.sent,
      createdAt: createdAt,
      seenAt: seenAt,
      isFromCurrentUser: isFromCurrentUser,
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
      // isFromCurrentUser بيتحدد محلياً وما بنبعتوش للسيرفر
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

  // ==================== HELPERS ====================

  static MessageType _mapApiTypeToMessageType(
      String apiType, String? attachmentUrl) {
    switch (apiType.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'pdf':
        return MessageType.pdf;
      case 'file':
        return MessageType.file;
      case 'text':
      default:
        // لو مفيش body وفيه attachment نعامله كملف
        if (attachmentUrl != null && attachmentUrl.isNotEmpty) {
          return MessageType.file;
        }
        return MessageType.text;
    }
  }

  /// Helper صغير عشان نعمل decode للـ JSON بأمان في أي مكان (بدون كراش).
  static Map<String, dynamic> safeJsonDecode(String source) {
    try {
      final decoded = json.decode(source);
      if (decoded is Map<String, dynamic>) return decoded;
      return const {};
    } catch (_) {
      return const {};
    }
  }

  static String toJsonString(Map<String, dynamic> data) {
    return json.encode(data);
  }
}
