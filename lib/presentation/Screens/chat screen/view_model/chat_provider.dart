import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/Constant/Api_Constant.dart';
import '../model/message_model.dart';
import 'package:mime/mime.dart'; // لـ lookupMimeType
import 'package:http_parser/http_parser.dart'; // لـ MediaType


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
  Timer? _statusTimer;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _userStatusSubscription;
  StreamSubscription? _typingSubscription;

  ChatViewModel(this.chatId) {
    _initializeChat();
  }

  List<MessageModel> get messages => _messages;

  Future<void> _initializeChat() async {
    await _getUserData();
    await _createChatIfNotExists();
    _fetchMessages();
    _listenToUserStatus();
    _listenToTypingStatus();
    _startStatusTimer();
  }

  Future<void> _getUserData() async {
    userId = await globalAccountData.getId();
    userName = await globalAccountData.getUsername();
    userEmail = await globalAccountData.getEmail();
    isAdmin = userEmail == 'admin@KyTradeMarks.com';

    print('Chat initialized - User: $userId, Admin: $isAdmin, ChatId: $chatId');

    // Set user online status
    await _setUserStatus(UserStatus.online);
  }

  Future<void> _createChatIfNotExists() async {
    if (isAdmin) return; // Admin doesn't need to create chat

    try {
      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get();

      if (!chatDoc.exists) {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .set({
          'userId': userId,
          'username': userName ?? 'User',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'lastMessage': null,
          'lastMessageTime': null,
          'lastSenderId': null,
          'unreadCount': 0,
        });
        print('Chat document created for user: $chatId');
      }
    } catch (e) {
      print('Error creating chat: $e');
    }
  }

  void _fetchMessages() {
    print('Fetching messages for chat: $chatId');

    _messagesSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      print('Received ${snapshot.docs.length} messages');

      _messages = snapshot.docs
          .map((doc) {
        final message = MessageModel.fromJson(doc.data(), doc.id);
        return message.copyWith(
          isFromCurrentUser: message.senderId == (isAdmin ? 'admin' : userId),
        );
      })
          .toList();

      // Mark messages as seen if they're not from current user
      _markMessagesAsSeen();

      isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error fetching messages: $error');
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _markMessagesAsSeen() async {
    final currentUserId = isAdmin ? 'admin' : userId!;

    final unseenMessages = _messages
        .where((msg) =>
    msg.senderId != currentUserId &&
        msg.status != MessageStatus.seen)
        .toList();

    if (unseenMessages.isEmpty) return;

    print('Marking ${unseenMessages.length} messages as seen');

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
    final currentUserId = isAdmin ? 'admin' : userId!;
    currentUserStatus = status;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .set({
        'status': status.toString(),
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));

      print('User status set to: $status');
    } catch (e) {
      print('Error setting user status: $e');
    }

    notifyListeners();
  }

  void _listenToUserStatus() {
    // Get the other user ID (admin or regular user)
    String otherUserId = isAdmin ? chatId : 'admin';

    print('Listening to status for user: $otherUserId');

    _userStatusSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final newStatus = UserStatus.values.firstWhere(
              (e) => e.toString() == data['status'],
          orElse: () => UserStatus.offline,
        );

        if (newStatus != otherUserStatus) {
          otherUserStatus = newStatus;
          print('Other user status changed to: $newStatus');
          notifyListeners();
        }
      }
    }, onError: (error) {
      print('Error listening to user status: $error');
    });
  }

  void _listenToTypingStatus() {
    final currentUserId = isAdmin ? 'admin' : userId!;

    _typingSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .snapshots()
        .listen((snapshot) {
      final typingUsers = snapshot.docs
          .where((doc) => doc.id != currentUserId && doc.data()['isTyping'] == true)
          .toList();

      final wasTyping = isTyping;
      isTyping = typingUsers.isNotEmpty;
      typingUserId = isTyping ? typingUsers.first.id : null;

      if (wasTyping != isTyping) {
        print('Typing status changed: $isTyping');
        notifyListeners();
      }
    }, onError: (error) {
      print('Error listening to typing status: $error');
    });
  }

  void _startStatusTimer() {
    // Update online status every 30 seconds
    _statusTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (currentUserStatus == UserStatus.online) {
        _setUserStatus(UserStatus.online);
      }
    });
  }

  Future<void> setTypingStatus(bool typing) async {
    final currentUserId = isAdmin ? 'admin' : userId!;

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('typing')
          .doc(currentUserId)
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

  static const String uploadEndpoint = '${ApiConstant.baseUrl}${ApiConstant.slug}files/upload';

  // Upload file to server with new endpoint
  Future<String?> _uploadFile(File file, String fileName) async {
    try {
      String? customerId = await globalAccountData.getId();
      String? authToken = await globalAccountData.getToken();

      if (customerId == null) {
        print('Customer ID is null');
        return null;
      }

      final mimeType = lookupMimeType(file.path); // e.g., video/mp4
      final mediaType = mimeType != null ? MediaType.parse(mimeType) : null;

      var request = http.MultipartRequest('POST', Uri.parse(uploadEndpoint));

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
          contentType: mediaType, // ← هنا السحر
        ),
      );

      request.fields['customer_id'] = customerId;

      if (authToken != null) {
        request.headers.addAll({
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        });
      }

      print('Uploading file: $fileName for customer: $customerId');

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);

        String? fileUrl;
        if (jsonResponse is Map<String, dynamic>) {
          var data = jsonResponse['data'];
          if (data != null && data is Map<String, dynamic>) {
            fileUrl = '${data['file_url'].toString().replaceFirst('/', '')}';
          }
        }

        if (fileUrl != null) {
          print('File uploaded successfully: $fileUrl');
          return fileUrl;
        } else {
          print('No URL found in response: $jsonResponse');
          return null;
        }
      } else {
        print('Upload failed with status: ${response.statusCode}');
        var errorData = await response.stream.bytesToString();
        print('Error response: $errorData');
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

    final currentUserId = isAdmin ? 'admin' : userId!;
    final currentUserName = isAdmin ? 'Admin' : (userName ?? 'User');

    String? mediaUrl;

    // Upload file if provided
    if (file != null) {
      print('Uploading file before sending message...');
      mediaUrl = await _uploadFile(file, fileName ?? 'file');
      if (mediaUrl == null) {
        print('Failed to upload file');
        // You might want to show an error message to user here
        return;
      }
    }

    final message = MessageModel(
      id: '',
      senderId: currentUserId,
      senderName: currentUserName,
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
      print('Sending message: ${message.text ?? 'Media message'}');

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

      print('Message sent successfully');
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
      'username': isAdmin ? 'Admin' : (userName ?? 'User'),
      'userId': isAdmin ? 'admin' : userId,
    };

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .set(chatData, SetOptions(merge: true));

      print('Chat metadata updated');
    } catch (e) {
      print('Error updating chat metadata: $e');
    }
  }

  String _getMediaTypeText(MessageType type) {
    switch (type) {
      case MessageType.image:
        return '📷 صورة';
      case MessageType.video:
        return '🎥 فيديو';
      case MessageType.audio:
        return '🎵 صوت';
      case MessageType.pdf:
        return '📄 ملف PDF';
      case MessageType.file:
        return '📎 ملف';
      default:
        return 'رسالة';
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
              'إرفق ملف',
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
                  'صورة',
                      () => _pickMedia(context, MessageType.image),
                ),
                _buildAttachmentOption(
                  context,
                  Icons.videocam,
                  'فيديو',
                      () => _pickMedia(context, MessageType.video),
                ),
                _buildAttachmentOption(
                  context,
                  Icons.audiotrack,
                  'صوت',
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
                  'ملف',
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
        SnackBar(content: Text('فشل في تحديد الملف: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    print('Disposing ChatViewModel');

    _typingTimer?.cancel();
    _statusTimer?.cancel();
    _messagesSubscription?.cancel();
    _userStatusSubscription?.cancel();
    _typingSubscription?.cancel();

    // Set user offline when leaving chat
    _setUserStatus(UserStatus.offline);

    super.dispose();
  }
}