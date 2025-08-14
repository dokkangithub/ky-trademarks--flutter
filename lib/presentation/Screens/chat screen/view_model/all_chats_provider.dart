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
  bool isAdmin = false; // Admin mode removed
  StreamSubscription? _chatsSubscription;
  final Map<String, StreamSubscription> _unreadCountSubscriptions = {};
  final Map<String, StreamSubscription> _userStatusSubscriptions = {};

  AllChatsViewModel() {
    _initializeChat();
  }

  List<ChatModel> get chats => _chats;

  Future<void> _initializeChat() async {
    await _getUserData();

    _fetchUserChat();
  }

  Future<void> _getUserData() async {
    userId = await globalAccountData.getId();
    userEmail = await globalAccountData.getEmail();
    userName = await globalAccountData.getUsername();
    isAdmin = false;

    print('User data: userId=$userId, email=$userEmail');
  }

  // Removed legacy admin listeners and unused helpers to reduce complexity and lints

  

  

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

      try {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;

          // Prefer stored counter if present, otherwise fall back to aggregation count.
          int? storedUnread = data['unreadForUser'] is int
              ? data['unreadForUser'] as int
              : (data['unreadCount'] is int ? data['unreadCount'] as int : null);

          int unreadCount;
          if (storedUnread != null) {
            unreadCount = storedUnread;
          } else {
            // Only compute when last message is from other party; otherwise it's 0 for the user
            final lastFromOther = data['lastSenderId'] != userId;
            unreadCount = lastFromOther ? await _getUserUnreadCount(userChatId) : 0;
          }

          _chats = [
            ChatModel(
              chatId: userChatId,
              username: 'الدعم الفني',
              lastMessage: data['lastMessage'],
              lastMessageTime: data['lastMessageTime'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(data['lastMessageTime'])
                  : null,
              isRead: data['lastSenderId'] == userId,
              unreadCount: unreadCount,
              userId: data['userId'] ?? userChatId,
              userStatus: UserStatus.online, // Set admin as online by default
            )
          ];
        } else {
          // Create empty chat for user if it doesn't exist
          _chats = [
            ChatModel(
              chatId: userChatId,
              username: 'الدعم الفني',
              lastMessage: null,
              lastMessageTime: null,
              isRead: true,
              unreadCount: 0,
              userId: userChatId,
              userStatus: UserStatus.online,
            )
          ];
        }

        isLoading = false;
        notifyListeners();
      } catch (e) {
        print('Error processing user chat: $e');
        isLoading = false;
        notifyListeners();
      }
    }, onError: (error) {
      print('Error fetching user chat: $error');
      isLoading = false;
      notifyListeners();
    });
  }

  

  

  Future<int> _getUserUnreadCount(String chatId) async {
    try {
      final currentUserId = userId;
      if (currentUserId == null) return 0;

      // Use Firestore aggregation query to avoid reading all matching documents
      final countSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('status', whereIn: ['sent', 'delivered'])
          .count()
          .get();

      return countSnapshot.count ?? 0;
    } catch (e) {
      print('Error getting user unread count for $chatId: $e');
      return 0;
    }
  }

  Future<void> startChatWithAdmin() async {
    // No-op: chat doc will be created on first message send
  }

  // Enhanced method to get unread count for a specific chat
  Future<int> getUnreadCount(String chatId) async {
    return await _getUserUnreadCount(chatId);
  }

  // Method to mark messages as read when opening a chat
  Future<void> markChatAsRead(String chatId) async {
    try {
      final currentUserId = userId!;

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

      // Also reset stored counter to zero for this user chat, if present
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .set({'unreadCount': 0}, SetOptions(merge: true));
    } catch (e) {
      print('Error marking chat as read: $e');
    }
  }

  // Method to refresh all chats data
  Future<void> refreshChats() async {
    isLoading = true;
    notifyListeners();

    // The stream listener will automatically refresh
    print('Refreshing user chat...');
  }

  // Method to get total unread count across all chats
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
  Future<void> deleteChat(String chatId) async {}

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