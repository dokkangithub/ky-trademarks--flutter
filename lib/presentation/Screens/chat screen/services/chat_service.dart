import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/Constant/Api_Constant.dart';
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
      bool isAdmin = userEmail == 'admin@KyTradeMarks.com';

      final chatData = {
        'lastMessage': message.text ?? _getMediaTypeText(message.type),
        'lastMessageTime': message.createdAt.millisecondsSinceEpoch,
        'lastSenderId': message.senderId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'username': isAdmin ? 'Admin' : (userName ?? 'User'),
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

      // Calculate actual unread count
      int unreadCount = await _calculateUnreadCount(doc.id, data['lastSenderId']);

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
        isRead: data['lastSenderId'] == 'admin', // For admin view
      );
    } catch (e) {
      print('Error creating chat model: $e');
      return null;
    }
  }

  // Calculate unread messages count
  Future<int> _calculateUnreadCount(String chatId, String? lastSenderId) async {
    try {
      // Get current user info
      String? userEmail = await globalAccountData.getEmail();
      bool isAdmin = userEmail == 'admin@KyTradeMarks.com';
      String? currentUserId = isAdmin ? 'admin' : await globalAccountData.getId();

      if (currentUserId == null) return 0;

      final query = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('status', isNotEqualTo: MessageStatus.seen.toString().split('.').last)
          .get();

      return query.docs.length;
    } catch (e) {
      print('Error calculating unread count: $e');
      return 0;
    }
  }

  // Set user status
  Future<void> setUserStatus(String userId, UserStatus status) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'status': status.toString(),
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error setting user status: $e');
    }
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
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('typing')
          .doc(userId)
          .set({
        'isTyping': isTyping,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error setting typing status: $e');
    }
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
    try {
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
      final query = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('status', isNotEqualTo: MessageStatus.seen.toString().split('.').last)
          .get();

      return query.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}