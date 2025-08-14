import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/Constant/Api_Constant.dart';
import '../model/message_model.dart';
import 'package:mime/mime.dart'; // لـ lookupMimeType
import 'package:http_parser/http_parser.dart'; // لـ MediaType
import 'dart:math' as math; // لـ _generateRandomString
// FFmpeg removed; no local conversion


class ChatViewModel extends ChangeNotifier {
  final String chatId;
  List<MessageModel> _messages = [];
  bool isLoading = true;
  String? userId;
  String? userName;
  String? userEmail;
  // Admin mode removed: chat is user-to-user
  UserStatus currentUserStatus = UserStatus.online;
  UserStatus otherUserStatus = UserStatus.offline; // Status UI will be removed
  bool isTyping = false; // Typing feature removed
  String? typingUserId; // Typing feature removed
  Timer? _typingTimer; // Typing feature removed
  Timer? _statusTimer; // Status feature removed
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _userStatusSubscription; // Removed
  StreamSubscription? _typingSubscription; // Removed

  ChatViewModel(this.chatId) {
    _initializeChat();
  }

  List<MessageModel> get messages => _messages;

  Future<void> _initializeChat() async {
    await _getUserData();
    _fetchMessages();
    // Status and typing removed
  }

  Future<void> _getUserData() async {
    userId = await globalAccountData.getId();
    userName = await globalAccountData.getUsername();
    userEmail = await globalAccountData.getEmail();
    print('Chat initialized - User: $userId, ChatId: $chatId');

    // Status removed
  }

  // Removed: do not create chat document on open; it will be created/updated on first message

  void _fetchMessages() {
    print('Fetching messages for chat: $chatId');

    _messagesSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      print('Received ${snapshot.docs.length} messages');

      _messages = snapshot.docs
          .map((doc) {
        final message = MessageModel.fromJson(doc.data(), doc.id);
        final currentUserId = userId;
        
        // Determine message ownership
        final bool isFromCurrentUser =
            currentUserId != null && message.senderId == currentUserId;
        
        return message.copyWith(
          isFromCurrentUser: isFromCurrentUser,
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
    final currentUserId = userId!;

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

  // User status feature removed

  // Typing listener removed

  // Status timer removed

  Future<void> setTypingStatus(bool typing) async { /* typing removed */ }

  static const String uploadEndpoint = '${ApiConstant.baseUrl}${ApiConstant.slug}files/upload';

  // Upload file to server with new endpoint
  Future<String?> _uploadFile({File? file, Uint8List? bytes, required String fileName}) async {
    try {
      String? customerId = await globalAccountData.getId();
      String? authToken = await globalAccountData.getToken();

      if (customerId == null) {
        print('Customer ID is null');
        return null;
      }

      final pathForMime = file != null ? file.path : fileName;
      final mimeType = lookupMimeType(pathForMime); // e.g., video/mp4 or audio/webm
      final mediaType = mimeType != null ? MediaType.parse(mimeType) : null;

      // إنشاء اسم فريد للملف
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomString = _generateRandomString(8);
      final fileExtension = fileName.split('.').last;
      final uniqueFileName = '${customerId}_${timestamp}_${randomString}.$fileExtension';

      var request = http.MultipartRequest('POST', Uri.parse(uploadEndpoint));

      if (bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: uniqueFileName,
            contentType: mediaType,
          ),
        );
      } else if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            filename: uniqueFileName,
            contentType: mediaType,
          ),
        );
      } else {
        print('No file or bytes provided to upload');
        return null;
      }

      request.fields['customer_id'] = customerId;

      if (authToken != null) {
        request.headers.addAll({
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        });
      }

      print('Uploading file: $uniqueFileName (original: $fileName) for customer: $customerId');

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);

        String? fileUrl;
        if (jsonResponse is Map<String, dynamic>) {
          var data = jsonResponse['data'];
          if (data != null && data is Map<String, dynamic>) {
            fileUrl = '${data['file_url'].toString().replaceFirst(' ', '')}';
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

  // دالة لإنشاء سلسلة عشوائية
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = math.Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // Audio conversion removed; handle webm at playback time

  Future<void> sendMessage({
    String? text,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
    MessageType type = MessageType.text,
  }) async {
    if ((text?.trim().isEmpty ?? true) && file == null && fileBytes == null) return;

    final currentUserId = userId!;
    final currentUserName = userName ?? 'User';

    // حفظ الاسم الأصلي للملف للعرض في الرسالة
    final originalFileName = fileName;

    // Create message immediately with sending status
    final message = MessageModel(
      id: '',
      senderId: currentUserId,
      senderName: currentUserName,
      chatId: chatId,
      text: text?.trim(),
      mediaUrl: null, // Will be updated after upload
      fileName: originalFileName, // استخدام الاسم الأصلي للعرض
      fileSize: file != null ? await file.length() : (fileBytes != null ? fileBytes.length : null),
      type: type,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
      isFromCurrentUser: true, // Ensure it's marked as from current user
    );

    try {
      print('Sending message: ${message.text ?? 'Media message'}');

      // Add to Firestore immediately with sending status
      final docRef = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toJson());

      // Update message ID
      final updatedMessage = MessageModel(
        id: docRef.id,
        senderId: currentUserId,
        senderName: currentUserName,
        chatId: chatId,
        text: text?.trim(),
        mediaUrl: null,
        fileName: originalFileName, // استخدام الاسم الأصلي للعرض
        fileSize: file != null ? await file.length() : (fileBytes != null ? fileBytes.length : null),
        type: type,
        status: MessageStatus.sending,
        createdAt: DateTime.now(),
        isFromCurrentUser: true, // Ensure it's marked as from current user
      );

      // Upload file if provided
      String? mediaUrl;
      if (file != null || fileBytes != null) {
        print('Uploading file after adding message...');
        mediaUrl = await _uploadFile(file: file, bytes: fileBytes, fileName: fileName ?? 'file');
        if (mediaUrl == null) {
          print('Failed to upload file');
          // Update message status to failed
          await docRef.update({
            'status': 'failed',
            'error': 'Upload failed',
          });
          return;
        }
      }

      // Update message with media URL and sent status
      await docRef.update({
        'mediaUrl': mediaUrl,
        'status': MessageStatus.sent.toString().split('.').last,
      });

      // Update chat metadata
      await _updateChatMetadata(updatedMessage);

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
        return '📷 ${'image'.tr()}';
      case MessageType.video:
        return '🎥 ${'video'.tr()}';
      case MessageType.audio:
        return '🎵 ${'audio'.tr()}';
      case MessageType.pdf:
        return '📄 ${'pdf'.tr()}';
      case MessageType.file:
        return '📎 ${'file'.tr()}';
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
              'attach_file'.tr(),
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
                  'image'.tr(),
                      () => _pickMedia(context, MessageType.image),
                ),
                _buildAttachmentOption(
                  context,
                  Icons.videocam,
                  'video'.tr(),
                      () => _pickMedia(context, MessageType.video),
                ),
                _buildAttachmentOption(
                  context,
                  Icons.audiotrack,
                  'audio'.tr(),
                      () => _pickMedia(context, MessageType.audio),
                ),
                _buildAttachmentOption(
                  context,
                  Icons.picture_as_pdf,
                  'pdf'.tr(),
                      () => _pickMedia(context, MessageType.pdf),
                ),
                _buildAttachmentOption(
                  context,
                  Icons.insert_drive_file,
                  'file'.tr(),
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
            if (kIsWeb) {
              final bytes = await image.readAsBytes();
              await sendMessage(
                fileBytes: bytes,
                fileName: image.name,
                type: MessageType.image,
              );
            } else {
              await sendMessage(
                file: File(image.path),
                fileName: image.name,
                type: MessageType.image,
              );
            }
          }
          break;

        case MessageType.video:
          final ImagePicker picker = ImagePicker();
          final XFile? video = await picker.pickVideo(
            source: ImageSource.gallery,
            maxDuration: Duration(minutes: 5),
          );
          if (video != null) {
            if (kIsWeb) {
              final bytes = await video.readAsBytes();
              await sendMessage(
                fileBytes: bytes,
                fileName: video.name,
                type: MessageType.video,
              );
            } else {
              await sendMessage(
                file: File(video.path),
                fileName: video.name,
                type: MessageType.video,
              );
            }
          }
          break;

        case MessageType.audio:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['webm','mp3','m4a','wav','ogg'],
            allowMultiple: false,
          );
          if (result != null && result.files.isNotEmpty) {
            final file = result.files.single;
            if (kIsWeb && file.bytes != null) {
              await sendMessage(
                fileBytes: file.bytes!,
                fileName: file.name,
                type: MessageType.audio,
              );
            } else if (file.path != null) {
              await sendMessage(
                file: File(file.path!),
                fileName: file.name,
                type: MessageType.audio,
              );
            }
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
            if (kIsWeb && file.bytes != null) {
              await sendMessage(
                fileBytes: file.bytes!,
                fileName: file.name,
                type: MessageType.pdf,
              );
            } else if (file.path != null) {
              await sendMessage(
                file: File(file.path!),
                fileName: file.name,
                type: MessageType.pdf,
              );
            }
          }
          break;

        case MessageType.file:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: false,
          );
          if (result != null && result.files.isNotEmpty) {
            final file = result.files.single;
            if (kIsWeb && file.bytes != null) {
              await sendMessage(
                fileBytes: file.bytes!,
                fileName: file.name,
                type: MessageType.file,
              );
            } else if (file.path != null) {
              await sendMessage(
                file: File(file.path!),
                fileName: file.name,
                type: MessageType.file,
              );
            }
          }
          break;

        default:
          break;
      }
    } catch (e) {
      print('Error picking media: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed_pick_document'.tr() + ': ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    print('Disposing ChatViewModel');

    _typingTimer?.cancel();
    _messagesSubscription?.cancel();
    _userStatusSubscription?.cancel();
    _typingSubscription?.cancel();

    super.dispose();
  }
}