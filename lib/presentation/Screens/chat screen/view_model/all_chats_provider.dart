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
  bool isAdmin = false;

  AllChatsViewModel() {
    _getUserData();
  }

  List<ChatModel> get chats => _chats;

  Future<void> _getUserData() async {
    userId = await globalAccountData.getId();
    userEmail = await globalAccountData.getEmail();
    isAdmin = userEmail == 'test@kytrademarks.com';

    if (isAdmin) {
      _fetchAllChats();
    } else {
      _createOrGetUserChat();
    }
  }

  void _fetchAllChats() {
    // Admin sees all chats
    FirebaseFirestore.instance
        .collection('chats')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _chats = snapshot.docs
          .map((doc) => _createChatModelFromDoc(doc))
          .where((chat) => chat != null)
          .cast<ChatModel>()
          .toList();

      isLoading = false;
      notifyListeners();
    });
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
        isRead: data['lastSenderId'] != userId, // If last sender is not admin, it's unread for admin
        userId: data['userId'] ?? doc.id,
        userStatus: UserStatus.offline, // Will be updated by real-time listener
      );
    } catch (e) {
      print('Error creating chat model: $e');
      return null;
    }
  }

  void _createOrGetUserChat() {
    // Regular user only sees their chat with admin
    final userChatId = userId!;

    FirebaseFirestore.instance
        .collection('chats')
        .doc(userChatId)
        .snapshots()
        .listen((snapshot) {
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
            isRead: data['lastSenderId'] == userId,
            userId: 'admin',
            userStatus: UserStatus.offline,
          )
        ];
      } else {
        // Create new chat document for user
        _createNewUserChat();
      }

      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _createNewUserChat() async {
    final userChatId = userId!;
    final username = await globalAccountData.getUsername();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(userChatId)
        .set({
      'userId': userId,
      'username': username,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'lastMessage': null,
      'lastMessageTime': null,
      'lastSenderId': null,
    });
  }

  Future<void> startChatWithAdmin() async {
    if (!isAdmin) {
      // This will trigger the creation of user chat if it doesn't exist
      await _createNewUserChat();
    }
  }
}