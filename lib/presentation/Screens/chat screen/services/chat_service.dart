import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/chat_model.dart';
import '../model/message_model.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


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

  // Update chat last message with proper user info
  Future<void> _updateChatLastMessage(MessageModel message) async {
    try {
      // Get user info for better chat display
      String? userName = await globalAccountData.getUsername();
      String? userEmail = await globalAccountData.getEmail();

      final chatData = {
        'lastMessage': message.text ?? _getMediaTypeText(message.type),
        'lastMessageTime': message.createdAt.millisecondsSinceEpoch,
        'lastSenderId': message.senderId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'username': userName ?? 'User',
        'userId': message.senderId,
        'userEmail': userEmail,
      };

      await _firestore
          .collection('chats')
          .doc(message.chatId)
          .set(chatData, SetOptions(merge: true));

      print('Chat metadata updated with user info');
    } catch (e) {
      print('Error updating chat metadata: $e');
    }
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
        .limit(50)
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

  // Get chats stream for admin - FIXED to load all chats
  Stream<List<ChatModel>> getChatsStream() {
    return _firestore
        .collection('chats')
        .orderBy('updatedAt', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((snapshot) async {
      List<ChatModel> chats = [];

      for (var doc in snapshot.docs) {
        final chat = await _createChatModelFromDoc(doc);
        if (chat != null) {
          chats.add(chat);
        }
      }

      return chats;
    });
  }

  // Enhanced chat model creation with unread count calculation
  Future<ChatModel?> _createChatModelFromDoc(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      // Avoid per-chat unread queries here; rely on stored field or compute on-demand
      int unreadCount = data['unreadCount'] is int ? data['unreadCount'] as int : 0;

      return ChatModel(
        chatId: doc.id,
        username: data['username'] ?? data['userEmail'] ?? 'Unknown User',
        lastMessage: data['lastMessage'],
        lastMessageTime: data['lastMessageTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['lastMessageTime'])
            : null,
        userId: data['userId'] ?? doc.id,
        userStatus: UserStatus.offline, // Will be updated by real-time listener
        unreadCount: unreadCount,
        isRead: false,
      );
    } catch (e) {
      print('Error creating chat model: $e');
      return null;
    }
  }

  // Calculate unread messages count
  // Removed unused private helper _calculateUnreadCount to satisfy linter

  // Mark messages as seen
  Future<void> markMessagesAsSeen(String chatId, String currentUserId) async {
    try {
      final messagesQuery = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('status', whereIn: ['sent', 'delivered'])
          .get();

      final batch = _firestore.batch();

      for (final doc in messagesQuery.docs) {
        batch.update(doc.reference, {
          'status': MessageStatus.seen.toString().split('.').last,
          'seenAt': DateTime.now().millisecondsSinceEpoch,
        });
      }

      await batch.commit();

      // Reset stored counter if used
      await _firestore.collection('chats').doc(chatId).set({'unreadCount': 0}, SetOptions(merge: true));
    } catch (e) {
      print('Error marking messages as seen: $e');
    }
  }

  // Create or get user chat with proper user info
  Future<void> createUserChat(String userId, String username) async {
    try {
      // Get additional user info
      String? userEmail = await globalAccountData.getEmail();

      await _firestore.collection('chats').doc(userId).set({
        'userId': userId,
        'username': username,
        'userEmail': userEmail,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'lastMessage': null,
        'lastMessageTime': null,
        'lastSenderId': null,
        'unreadCount': 0,
      }, SetOptions(merge: true));

      print('User chat created with proper info');
    } catch (e) {
      print('Error creating user chat: $e');
    }
  }

  // Get unread messages count
  Future<int> getUnreadMessagesCount(String chatId, String currentUserId) async {
    try {
      final countSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('status', whereIn: ['sent', 'delivered'])
          .count()
          .get();

      return countSnapshot.count ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}