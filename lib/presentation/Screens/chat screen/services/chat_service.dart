import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/chat_model.dart';
import '../model/message_model.dart';
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String uploadEndpoint = 'https://clientarea.kytrademarks.com/v2/api/ky-upload';

  // Upload file to server
  Future<String?> uploadFile(File file, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadEndpoint));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['fileName'] = fileName;

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        return jsonResponse['url']; // Adjust based on your API response structure
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  // Send message
  Future<bool> sendMessage(MessageModel message) async {
    try {
      await _firestore
          .collection('chats')
          .doc(message.chatId)
          .collection('messages')
          .add(message.toJson());

      // Update chat metadata
      await _updateChatLastMessage(message);

      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Update chat last message
  Future<void> _updateChatLastMessage(MessageModel message) async {
    final chatData = {
      'lastMessage': message.text ?? _getMediaTypeText(message.type),
      'lastMessageTime': message.createdAt.millisecondsSinceEpoch,
      'lastSenderId': message.senderId,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    await _firestore
        .collection('chats')
        .doc(message.chatId)
        .set(chatData, SetOptions(merge: true));
  }

  String _getMediaTypeText(MessageType type) {
    switch (type) {
      case MessageType.image:
        return '📷 Image';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.pdf:
        return '📄 PDF';
      case MessageType.file:
        return '📎 File';
      default:
        return 'Message';
    }
  }

  // Get messages stream
  Stream<List<MessageModel>> getMessagesStream(String chatId, String currentUserId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final message = MessageModel.fromJson(doc.data(), doc.id);
      return message.copyWith(
        isFromCurrentUser: message.senderId == currentUserId,
      );
    })
        .toList());
  }

  // Get chats stream for admin
  Stream<List<ChatModel>> getChatsStream() {
    return _firestore
        .collection('chats')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => _createChatModelFromDoc(doc))
        .where((chat) => chat != null)
        .cast<ChatModel>()
        .toList());
  }

  ChatModel? _createChatModelFromDoc(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      return ChatModel(
        chatId: doc.id,
        username: data['username'] ?? 'Unknown User',
        lastMessage: data['lastMessage'],
        lastMessageTime: data['lastMessageTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['lastMessageTime'])
            : null,
        userId: data['userId'] ?? doc.id,
        userStatus: UserStatus.offline,
      );
    } catch (e) {
      print('Error creating chat model: $e');
      return null;
    }
  }

  // Set user status
  Future<void> setUserStatus(String userId, UserStatus status) async {
    await _firestore.collection('users').doc(userId).set({
      'status': status.toString(),
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  // Get user status stream
  Stream<UserStatus> getUserStatusStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return UserStatus.values.firstWhere(
              (e) => e.toString() == data['status'],
          orElse: () => UserStatus.offline,
        );
      }
      return UserStatus.offline;
    });
  }

  // Set typing status
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .doc(userId)
        .set({
      'isTyping': isTyping,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get typing status stream
  Stream<bool> getTypingStatusStream(String chatId, String currentUserId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .snapshots()
        .map((snapshot) {
      final typingUsers = snapshot.docs
          .where((doc) => doc.id != currentUserId && doc.data()['isTyping'] == true)
          .toList();
      return typingUsers.isNotEmpty;
    });
  }

  // Mark messages as seen
  Future<void> markMessagesAsSeen(String chatId, String currentUserId) async {
    final messagesQuery = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('status', isNotEqualTo: MessageStatus.seen.toString().split('.').last)
        .get();

    final batch = _firestore.batch();

    for (final doc in messagesQuery.docs) {
      batch.update(doc.reference, {
        'status': MessageStatus.seen.toString().split('.').last,
        'seenAt': DateTime.now().millisecondsSinceEpoch,
      });
    }

    await batch.commit();
  }

  // Create or get user chat
  Future<void> createUserChat(String userId, String username) async {
    await _firestore.collection('chats').doc(userId).set({
      'userId': userId,
      'username': username,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'lastMessage': null,
      'lastMessageTime': null,
      'lastSenderId': null,
    }, SetOptions(merge: true));
  }

  // Get unread messages count
  Future<int> getUnreadMessagesCount(String chatId, String currentUserId) async {
    final query = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('status', isNotEqualTo: MessageStatus.seen.toString().split('.').last)
        .get();

    return query.docs.length;
  }
}