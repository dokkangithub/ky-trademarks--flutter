// lib/presentation/Screens/chat screen/view_model/all_chats_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';
import '../model/chat_model.dart';
import '../model/message_model.dart';

class AllChatsViewModel extends ChangeNotifier {
  List<ChatModel> _chats = [];
  bool isLoading = true;
  String? userId;
  String? userEmail;
  String? userName;
  bool isAdmin = false;

  AllChatsViewModel() {
    _initializeChat();
  }

  List<ChatModel> get chats => _chats;

  Future<void> _initializeChat() async {
    await _getUserData();

    if (isAdmin) {
      _fetchAllChats();
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

  void _fetchAllChats() {
    print('Fetching all chats for admin');

    FirebaseFirestore.instance
        .collection('chats')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      print('Admin received ${snapshot.docs.length} chats');

      _chats = snapshot.docs
          .map((doc) => _createChatModelFromDoc(doc))
          .where((chat) => chat != null)
          .cast<ChatModel>()
          .where((chat) => chat.userId != 'admin') // Don't show admin's own chat
          .toList();

      isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error fetching chats: $error');
      isLoading = false;
      notifyListeners();
    });
  }

  void _fetchUserChat() {
    print('Fetching user chat for user: $userId');

    // For regular users, we listen to their specific chat document
    final userChatId = userId!;

    FirebaseFirestore.instance
        .collection('chats')
        .doc(userChatId)
        .snapshots()
        .listen((snapshot) {
      print('User chat snapshot exists: ${snapshot.exists}');

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        _chats = [
          ChatModel(
            chatId: userChatId,
            username: 'Admin Support',
            lastMessage: data['lastMessage'],
            lastMessageTime: data['lastMessageTime'] != null
                ? DateTime.fromMillisecondsSinceEpoch(data['lastMessageTime'])
                : null,
            isRead: data['lastSenderId'] == userId, // If last sender is current user, it's read
            unreadCount: data['unreadCount'] ?? 0,
            userId: 'admin',
            userStatus: UserStatus.offline,
          )
        ];
      } else {
        // Create empty state - chat will be created when user sends first message
        _chats = [];
      }

      isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error fetching user chat: $error');
      isLoading = false;
      notifyListeners();
    });
  }

  ChatModel? _createChatModelFromDoc(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      // Calculate unread count for admin (messages not sent by admin and not seen)
      int unreadCount = 0;
      if (isAdmin && data['lastSenderId'] != 'admin') {
        // This would need to be calculated from messages subcollection
        // For now, we'll use a placeholder
        unreadCount = data['unreadCount'] ?? 0;
      }

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
        userStatus: UserStatus.offline, // Will be updated by real-time listener
      );
    } catch (e) {
      print('Error creating chat model from doc ${doc.id}: $e');
      return null;
    }
  }

  Future<void> startChatWithAdmin() async {
    if (isAdmin) return; // Admin doesn't start chat with themselves

    print('Starting chat with admin for user: $userId');

    final userChatId = userId!;

    try {
      // Create or update the chat document
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

      // The snapshot listener will automatically update the UI
    } catch (e) {
      print('Error creating chat with admin: $e');
    }
  }

  // Method to get unread count for a specific chat
  Future<int> getUnreadCount(String chatId) async {
    if (isAdmin) {
      // For admin, count messages not sent by admin and not seen
      final query = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: 'admin')
          .where('status', isNotEqualTo: MessageStatus.seen.toString().split('.').last)
          .get();

      return query.docs.length;
    } else {
      // For user, count messages not sent by user and not seen
      final query = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('status', isNotEqualTo: MessageStatus.seen.toString().split('.').last)
          .get();

      return query.docs.length;
    }
  }

  // Method to update unread counts for all chats (for admin)
  Future<void> updateUnreadCounts() async {
    if (!isAdmin) return;

    for (int i = 0; i < _chats.length; i++) {
      final chat = _chats[i];
      final unreadCount = await getUnreadCount(chat.chatId);

      if (unreadCount != chat.unreadCount) {
        _chats[i] = ChatModel(
          chatId: chat.chatId,
          username: chat.username,
          lastMessage: chat.lastMessage,
          lastMessageTime: chat.lastMessageTime,
          isRead: chat.isRead,
          unreadCount: unreadCount,
          profileImage: chat.profileImage,
          userId: chat.userId,
          userStatus: chat.userStatus,
        );
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}