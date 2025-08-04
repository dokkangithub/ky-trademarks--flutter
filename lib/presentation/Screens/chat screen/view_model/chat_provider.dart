// lib/presentation/Screens/chat screen/view_model/chat_provider.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/message_model.dart';
import '../model/chat_model.dart';

class ChatViewModel extends ChangeNotifier {
  final String chatId;
  List<MessageModel> _messages = [];
  bool isLoading = true;
  String? userId;
  String? userName;
  String? userEmail;
  bool isAdmin = false;
  UserStatus currentUserStatus = UserStatus.online;
  UserStatus otherUserStatus = UserStatus.offline;
  bool isTyping = false;
  String? typingUserId;

  ChatViewModel(this.chatId) {
    _getUserData();
    _fetchMessages();
    _listenToUserStatus();
    _listenToTypingStatus();
  }

  List<MessageModel> get messages => _messages;

  Future<void> _getUserData() async {
    userId = await globalAccountData.getId();
    userName = await globalAccountData.getUsername();
    userEmail = await globalAccountData.getEmail();
    isAdmin = userEmail == 'test@kytrademarks.com';

    // Set user online status
    await _setUserStatus(UserStatus.online);
  }

  void _fetchMessages() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _messages = snapshot.docs
          .map((doc) {
        final message = MessageModel.fromJson(doc.data(), doc.id);
        return message.copyWith(
          isFromCurrentUser: message.senderId == userId,
        );
      })
          .toList();

      // Mark messages as seen if they're not from current user
      _markMessagesAsSeen();

      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _markMessagesAsSeen() async {
    final unseenMessages = _messages
        .where((msg) =>
    !msg.isFromCurrentUser &&
        msg.status != MessageStatus.seen)
        .toList();

    for (final message in unseenMessages) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .update({
        'status': MessageStatus.seen.toString().split('.').last,
        'seenAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<void> _setUserStatus(UserStatus status) async {
    currentUserStatus = status;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({
      'status': status.toString(),
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));

    notifyListeners();
  }

  void _listenToUserStatus() {
    // Get the other user ID (admin or regular user)
    String otherUserId = isAdmin ? chatId : 'admin';

    FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        otherUserStatus = UserStatus.values.firstWhere(
              (e) => e.toString() == data['status'],
          orElse: () => UserStatus.offline,
        );
        notifyListeners();
      }
    });
  }

  void _listenToTypingStatus() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .snapshots()
        .listen((snapshot) {
      final typingUsers = snapshot.docs
          .where((doc) => doc.id != userId && doc.data()['isTyping'] == true)
          .toList();

      isTyping = typingUsers.isNotEmpty;
      typingUserId = isTyping ? typingUsers.first.id : null;
      notifyListeners();
    });
  }

  Future<void> setTypingStatus(bool typing) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .doc(userId)
        .set({
      'isTyping': typing,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<String?> _uploadFile(File file, String fileName) async {
    try {
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://clientarea.kytrademarks.com/v2/api/ky-upload')
      );

      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['fileName'] = fileName;

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        return jsonResponse['url']; // Assuming the API returns the file URL
      }
    } catch (e) {
      print('Upload error: $e');
    }
    return null;
  }

  Future<void> sendMessage({
    String? text,
    File? file,
    String? fileName,
    MessageType type = MessageType.text,
  }) async {
    String? mediaUrl;

    // Upload file if provided
    if (file != null) {
      mediaUrl = await _uploadFile(file, fileName ?? 'file');
      if (mediaUrl == null) {
        // Handle upload error
        return;
      }
    }

    final message = MessageModel(
      id: '',
      senderId: userId!,
      senderName: userName!,
      chatId: chatId,
      text: text,
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: file != null ? await file.length() : null,
      type: type,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
    );

    // Add to Firestore
    final docRef = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toJson());

    // Update message status to sent
    await docRef.update({
      'status': MessageStatus.sent.toString().split('.').last,
    });

    // Update chat metadata
    await _updateChatMetadata(message);

    // Stop typing
    await setTypingStatus(false);
  }

  Future<void> _updateChatMetadata(MessageModel message) async {
    final chatData = {
      'lastMessage': message.text ?? _getMediaTypeText(message.type),
      'lastMessageTime': message.createdAt.millisecondsSinceEpoch,
      'lastSenderId': message.senderId,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
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

  Future<void> handleAttachmentPressed(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Attachment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  context,
                  Icons.photo,
                  'Image',
                      () => _pickMedia(context, MessageType.image),
                ),
                _buildAttachmentOption(
                  context,
                  Icons.videocam,
                  'Video',
                      () => _pickMedia(context, MessageType.video),
                ),
                _buildAttachmentOption(
                  context,
                  Icons.audiotrack,
                  'Audio',
                      () => _pickMedia(context, MessageType.audio),
                ),
                _buildAttachmentOption(
                  context,
                  Icons.picture_as_pdf,
                  'PDF',
                      () => _pickMedia(context, MessageType.pdf),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
      BuildContext context,
      IconData icon,
      String label,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 30),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _pickMedia(BuildContext context, MessageType type) async {
    Navigator.pop(context);

    try {
      switch (type) {
        case MessageType.image:
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            await sendMessage(
              file: File(image.path),
              fileName: image.name,
              type: MessageType.image,
            );
          }
          break;

        case MessageType.video:
          final ImagePicker picker = ImagePicker();
          final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
          if (video != null) {
            await sendMessage(
              file: File(video.path),
              fileName: video.name,
              type: MessageType.video,
            );
          }
          break;

        case MessageType.audio:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.audio,
          );
          if (result != null) {
            final file = result.files.single;
            await sendMessage(
              file: File(file.path!),
              fileName: file.name,
              type: MessageType.audio,
            );
          }
          break;

        case MessageType.pdf:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );
          if (result != null) {
            final file = result.files.single;
            await sendMessage(
              file: File(file.path!),
              fileName: file.name,
              type: MessageType.pdf,
            );
          }
          break;

        default:
          break;
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }

  @override
  void dispose() {
    _setUserStatus(UserStatus.offline);
    super.dispose();
  }
}