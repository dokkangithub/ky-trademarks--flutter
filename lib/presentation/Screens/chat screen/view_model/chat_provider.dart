import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/message_model.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../view/widgets/video_player.dart';


class ChatViewModel extends ChangeNotifier {
  final String chatId;
  List<ChatMessage> _messages = [];
  bool isLoading = true;
  String? userId;
  String? userName;
  String? token;


  ChatViewModel(this.chatId) {
    _getUserData();
    _fetchMessages();
  }


  Future<void> _getUserData() async {
    userId = await globalAccountData.getId();
    userName = await globalAccountData.getUsername();
    token= await globalAccountData.getEmail();
  }


  List<ChatMessage> get messages => _messages;

  void _fetchMessages() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _messages = snapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data(), doc.id))
          .toList();
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage(ChatMessage message) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toJson());

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('chatModel')
    .add({'':''});
  }

  // Open PDF file using URL launcher
  Future<void> _openPDF(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open the PDF file';
    }
  }


  Future<void> onMessageTap(types.Message message,context) async {
    if (message is types.FileMessage) {
      final uri = message.uri;
      if (uri != null) {
        final fileExtension = uri.split('.').last.toLowerCase();

        if (fileExtension == 'pdf') {
          // Open PDF using url_launcher
          _openPDF(uri);
        } else if (fileExtension == 'mp4') {
          // Navigate to the video player screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(videoUrl: uri),
            ),
          );
        }
      }
    }
  }


  final ImagePicker _picker = ImagePicker();
  Future<void> _pickMedia(String type,context) async {
    Navigator.pop(context); // Close the dialog

    if (type == 'image') {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null) {
        for (var image in images) {
          final fileMessage = {
            'author': userId,
            'name': image.name,
            'size': await image.length(),
            'uri': image.path,
            'createdAt': FieldValue.serverTimestamp(),
            'type': 'image',
          };

          FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .add(fileMessage);
        }
      }
    } else if (type == 'pdf') {
      // PDF selection using file_picker
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        final file = result.files.single;
        final fileMessage = {
          'author': userId,
          'name': file.name,
          'size': file.size,
          'uri': file.path,
          'createdAt': FieldValue.serverTimestamp(),
          'type': 'file',
        };

        FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add(fileMessage);
      }
    } else if (type == 'video') {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        final fileMessage = {
          'author': userId,
          'name': video.name,
          'size': await video.length(),
          'uri': video.path,
          'createdAt': FieldValue.serverTimestamp(),
          'type': 'file',
        };

        FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add(fileMessage);
      }
    }
  }

  Future<void> handleAttachmentPressed(context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: () => _pickMedia('image',context),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: () => _pickMedia('pdf',context),
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Video'),
              onTap: () => _pickMedia('video',context),
            ),
          ],
        ),
      ),
    );
  }


}
