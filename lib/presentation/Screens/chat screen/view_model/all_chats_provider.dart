// lib/presentation/Screens/chat screen/view_model/all_chats_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';
import '../model/chat_model.dart';
import '../model/message_model.dart';
import 'dart:async';

class AllChatsViewModel extends ChangeNotifier {
  List<ChatModel> _chats = [];
  bool isLoading = true;
  String? userId;
  String? userEmail;
  String? userName;
  bool isAdmin = false;
  StreamSubscription? _chatsSubscription;
  final Map<String, StreamSubscription> _unreadCountSubscriptions = {};
  final Map<String, StreamSubscription> _userStatusSubscriptions = {};

  AllChatsViewModel() {
    _initializeChat();
  }

  List<ChatModel> get chats => _chats;

  Future<void> _initializeChat() async {
    await _getUserData();

    if (isAdmin) {
      _fetchAllChatsWithRealTime();
    } else {
      _fetchUserChat();
    }
  }

  Future<void> _getUserData() async {
    userId = await globalAccountData.getId();
    userEmail = await globalAccountData.getEmail();
    userName = await globalAccountData.getUsername();
    isAdmin = userEmail == 'admin@KyTradeMarks.com';

    print('User data: userId=$userId, email=$userEmail, isAdmin=$isAdmin');
  }

  void _fetchAllChatsWithRealTime() {
    print('Fetching all chats for admin with real-time updates');

    _chatsSubscription = FirebaseFirestore.instance
        .collection('chats')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) async {
      print('Admin received ${snapshot.docs.length} chats');

      List<ChatModel> newChats = [];

      for (var doc in snapshot.docs) {
        final chatModel = await _createChatModelFromDoc(doc);
        if (chatModel != null && chatModel.userId != 'admin') {
          newChats.add(chatModel);
        }
      }

      _chats = newChats;
      isLoading = false;
      notifyListeners();

      // Set up real-time unread count listeners for each chat
      _setupUnreadCountListeners();
      
      // Set up real-time user status listeners for each chat
      _setupUserStatusListeners();
    }, onError: (error) {
      print('Error fetching chats: $error');
      isLoading = false;
      notifyListeners();
    });
  }

  void _setupUnreadCountListeners() {
    // Cancel existing subscriptions
    _unreadCountSubscriptions.forEach((key, subscription) {
      subscription.cancel();
    });
    _unreadCountSubscriptions.clear();

    // Set up new subscriptions for each chat
    for (var chat in _chats) {
      _unreadCountSubscriptions[chat.chatId] = FirebaseFirestore.instance
          .collection('chats')
          .doc(chat.chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: 'admin')
          .where('status', whereIn: ['sent', 'delivered'])
          .snapshots()
          .listen((snapshot) {
        final unreadCount = snapshot.docs.length;

        // Update the specific chat's unread count
        final chatIndex = _chats.indexWhere((c) => c.chatId == chat.chatId);
        if (chatIndex != -1) {
          _chats[chatIndex] = ChatModel(
            chatId: _chats[chatIndex].chatId,
            username: _chats[chatIndex].username,
            lastMessage: _chats[chatIndex].lastMessage,
            lastMessageTime: _chats[chatIndex].lastMessageTime,
            isRead: _chats[chatIndex].isRead,
            unreadCount: unreadCount,
            profileImage: _chats[chatIndex].profileImage,
            userId: _chats[chatIndex].userId,
            userStatus: _chats[chatIndex].userStatus,
          );
          notifyListeners();
        }
      });
    }
  }

  void _setupUserStatusListeners() {
    // Cancel existing subscriptions
    _userStatusSubscriptions.forEach((key, subscription) {
      subscription.cancel();
    });
    _userStatusSubscriptions.clear();

    // Set up new subscriptions for each chat
    for (var chat in _chats) {
      _userStatusSubscriptions[chat.chatId] = FirebaseFirestore.instance
          .collection('users')
          .doc(chat.userId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final userData = snapshot.data() as Map<String, dynamic>;
          final newStatus = UserStatus.values.firstWhere(
            (e) => e.toString() == userData['status'],
            orElse: () => UserStatus.offline,
          );

          // Update the specific chat's user status
          final chatIndex = _chats.indexWhere((c) => c.chatId == chat.chatId);
          if (chatIndex != -1) {
            _chats[chatIndex] = ChatModel(
              chatId: _chats[chatIndex].chatId,
              username: _chats[chatIndex].username,
              lastMessage: _chats[chatIndex].lastMessage,
              lastMessageTime: _chats[chatIndex].lastMessageTime,
              isRead: _chats[chatIndex].isRead,
              unreadCount: _chats[chatIndex].unreadCount,
              profileImage: _chats[chatIndex].profileImage,
              userId: _chats[chatIndex].userId,
              userStatus: newStatus,
            );
            notifyListeners();
          }
        }
      });
    }
  }

  void _fetchUserChat() {
    print('Fetching user chat for user: $userId');

    // For regular users, we listen to their specific chat document
    final userChatId = userId!;

    _chatsSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(userChatId)
        .snapshots()
        .listen((snapshot) async {
      print('User chat snapshot exists: ${snapshot.exists}');

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        // Get unread count for user
        final unreadCount = await _getUserUnreadCount(userChatId);

        _chats = [
          ChatModel(
            chatId: userChatId,
            username: 'Admin Support',
            lastMessage: data['lastMessage'],
            lastMessageTime: data['lastMessageTime'] != null
                ? DateTime.fromMillisecondsSinceEpoch(data['lastMessageTime'])
                : null,
            isRead: data['lastSenderId'] == userId,
            unreadCount: unreadCount,
            userId: 'admin',
            userStatus: UserStatus.online, // Set admin as online by default
          )
        ];
      } else {
        // Create empty chat for user if it doesn't exist
        _chats = [
          ChatModel(
            chatId: userChatId,
            username: 'Admin Support',
            lastMessage: null,
            lastMessageTime: null,
            isRead: true,
            unreadCount: 0,
            userId: 'admin',
            userStatus: UserStatus.online,
          )
        ];
      }

      isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error fetching user chat: $error');
      isLoading = false;
      notifyListeners();
    });
  }

  Future<ChatModel?> _createChatModelFromDoc(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      // Get real-time unread count
      int unreadCount = 0;
      if (isAdmin) {
        unreadCount = await _getAdminUnreadCount(doc.id);
      }

      // Use default offline status - will be updated by real-time listener
      UserStatus userStatus = UserStatus.offline;

      return ChatModel(
        chatId: doc.id,
        username: data['username'] ?? 'Unknown User',
        lastMessage: data['lastMessage'],
        lastMessageTime: data['lastMessageTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['lastMessageTime'])
            : null,
        isRead: data['lastSenderId'] == (isAdmin ? 'admin' : userId),
        unreadCount: unreadCount,
        userId: data['userId'] ?? doc.id,
        userStatus: userStatus,
      );
    } catch (e) {
      print('Error creating chat model from doc ${doc.id}: $e');
      return null;
    }
  }

  Future<int> _getAdminUnreadCount(String chatId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: 'admin')
          .where('status', whereIn: ['sent', 'delivered'])
          .get();

      return query.docs.length;
    } catch (e) {
      print('Error getting admin unread count for $chatId: $e');
      return 0;
    }
  }

  Future<int> _getUserUnreadCount(String chatId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isEqualTo: 'admin')
          .where('status', whereIn: ['sent', 'delivered'])
          .get();

      return query.docs.length;
    } catch (e) {
      print('Error getting user unread count for $chatId: $e');
      return 0;
    }
  }

  Future<void> startChatWithAdmin() async {
    if (isAdmin) return;

    print('Starting chat with admin for user: $userId');

    final userChatId = userId!;

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(userChatId)
          .set({
        'userId': userId,
        'username': userName ?? 'User',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'lastMessage': null,
        'lastMessageTime': null,
        'lastSenderId': null,
        'unreadCount': 0,
      }, SetOptions(merge: true));

      print('Chat document created/updated successfully');
    } catch (e) {
      print('Error creating chat with admin: $e');
    }
  }

  // Enhanced method to get unread count for a specific chat
  Future<int> getUnreadCount(String chatId) async {
    if (isAdmin) {
      return await _getAdminUnreadCount(chatId);
    } else {
      return await _getUserUnreadCount(chatId);
    }
  }

  // Method to mark messages as read when opening a chat
  Future<void> markChatAsRead(String chatId) async {
    try {
      final currentUserId = isAdmin ? 'admin' : userId!;

      // Get all unread messages from the other user
      final query = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('status', whereIn: ['sent', 'delivered'])
          .get();

      if (query.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();

        for (var doc in query.docs) {
          batch.update(doc.reference, {
            'status': MessageStatus.seen.toString().split('.').last,
            'seenAt': DateTime.now().millisecondsSinceEpoch,
          });
        }

        await batch.commit();
        print('Marked ${query.docs.length} messages as read in chat $chatId');
      }
    } catch (e) {
      print('Error marking chat as read: $e');
    }
  }

  // Method to refresh all chats data
  Future<void> refreshChats() async {
    isLoading = true;
    notifyListeners();

    if (isAdmin) {
      // The stream listener will automatically refresh
      print('Refreshing admin chats...');
    } else {
      // The stream listener will automatically refresh
      print('Refreshing user chat...');
    }
  }

  // Method to get total unread count across all chats (for admin)
  int get totalUnreadCount {
    return _chats.fold(0, (total, chat) => total + chat.unreadCount);
  }

  // Method to search chats
  List<ChatModel> searchChats(String query) {
    if (query.isEmpty) return _chats;

    return _chats.where((chat) {
      return chat.username!.toLowerCase().contains(query.toLowerCase()) ||
          (chat.lastMessage?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  // Method to delete a chat (admin only)
  Future<void> deleteChat(String chatId) async {
    if (!isAdmin) return;

    try {
      // Delete all messages in the chat
      final messagesQuery = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in messagesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat document
      batch.delete(FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId));

      await batch.commit();

      print('Chat $chatId deleted successfully');
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }

  @override
  void dispose() {
    print('Disposing AllChatsViewModel');

    _chatsSubscription?.cancel();

    // Cancel all unread count subscriptions
    _unreadCountSubscriptions.forEach((key, subscription) {
      subscription.cancel();
    });
    _unreadCountSubscriptions.clear();

    // Cancel all user status subscriptions
    _userStatusSubscriptions.forEach((key, subscription) {
      subscription.cancel();
    });
    _userStatusSubscriptions.clear();

    super.dispose();
  }
}