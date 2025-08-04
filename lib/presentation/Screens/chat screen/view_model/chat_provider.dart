// lib/presentation/Screens/chat screen/view_model/chat_provider.dart
import 'dart:async';
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
  Timer? _typingTimer;

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

    if (unseenMessages.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();

    for (final message in unseenMessages) {
      final docRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id);

      batch.update(docRef, {
        'status': MessageStatus.seen.toString().split('.').last,
        'seenAt': DateTime.now().millisecondsSinceEpoch,
      });
    }

    try {
      await batch.commit();
    } catch (e) {
      print('Error marking messages as seen: $e');
    }
  }

  Future<void> _setUserStatus(UserStatus status) async {
    currentUserStatus = status;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
        'status': status.toString(),
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error setting user status: $e');
    }

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
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('typing')
          .doc(userId)
          .set({
        'isTyping': typing,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Clear typing after 3 seconds of inactivity
      if (typing) {
        _typingTimer?.cancel();
        _typingTimer = Timer(Duration(seconds: 3), () {
          setTypingStatus(false);
        });
      } else {
        _typingTimer?.cancel();
      }
    } catch (e) {
      print('Error setting typing status: $e');
    }
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

        // Handle different possible response structures
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse['url'] ?? jsonResponse['file_url'] ?? jsonResponse['path'];
        }

        return null;
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> sendMessage({
    String? text,
    File? file,
    String? fileName,
    MessageType type = MessageType.text,
  }) async {
    if ((text?.trim().isEmpty ?? true) && file == null) return;

    String? mediaUrl;

    // Show loading state for file upload
    if (file != null) {
      // You might want to show a loading indicator here
    }

    // Upload file if provided
    if (file != null) {
      mediaUrl = await _uploadFile(file, fileName ?? 'file');
      if (mediaUrl == null) {
        // Show error message to user
        print('Failed to upload file');
        return;
      }
    }

    final message = MessageModel(
      id: '',
      senderId: userId!,
      senderName: userName ?? 'User',
      chatId: chatId,
      text: text?.trim(),
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: file != null ? await file.length() : null,
      type: type,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
    );

    try {
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
    } catch (e) {
      print('Error sending message: $e');
      // You might want to show an error message to the user
    }
  }

  Future<void> _updateChatMetadata(MessageModel message) async {
    final chatData = {
      'lastMessage': message.text ?? _getMediaTypeText(message.type),
      'lastMessageTime': message.createdAt.millisecondsSinceEpoch,
      'lastSenderId': message.senderId,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'username': userName ?? 'User',
      'userId': userId,
    };

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .set(chatData, SetOptions(merge: true));
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
            Wrap(
              spacing: 20,
              runSpacing: 20,
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
                _buildAttachmentOption(
                  context,
                  Icons.insert_drive_file,
                  'File',
                      () => _pickMedia(context, MessageType.file),
                ),
              ],
            ),
            SizedBox(height: 20),
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
          final XFile? image = await picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1920,
            maxHeight: 1080,
            imageQuality: 85,
          );
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
          final XFile? video = await picker.pickVideo(
            source: ImageSource.gallery,
            maxDuration: Duration(minutes: 5),
          );
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
            allowMultiple: false,
          );
          if (result != null && result.files.isNotEmpty) {
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
            allowMultiple: false,
          );
          if (result != null && result.files.isNotEmpty) {
            final file = result.files.single;
            await sendMessage(
              file: File(file.path!),
              fileName: file.name,
              type: MessageType.pdf,
            );
          }
          break;

        case MessageType.file:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: false,
          );
          if (result != null && result.files.isNotEmpty) {
            final file = result.files.single;
            await sendMessage(
              file: File(file.path!),
              fileName: file.name,
              type: MessageType.file,
            );
          }
          break;

        default:
          break;
      }
    } catch (e) {
      print('Error picking media: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select file: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _setUserStatus(UserStatus.offline);
    super.dispose();
  }
}