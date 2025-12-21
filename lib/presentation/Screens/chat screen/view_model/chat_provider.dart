import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';
import 'package:mime/mime.dart';

import '../../../../core/Constant/Api_Constant.dart';
import '../model/message_model.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel(this.chatId) {
    _initializeChat();
  }

  /// الـ UI لسه بيباصي `chatId`، لكن فعلياً الشات مربوط بـ conversation من الـ API.
  final String chatId;

  final List<MessageModel> _messages = [];
  bool isLoading = true;
  bool isSending = false;
  String? userId;
  String? userName;
  String? userEmail;
  String? _authToken;

  /// الـ ID بتاع الـ conversation اللي بيرجع من `/support/conversation`
  int? conversationId;

  /// `customer_id` اللي بيرجع من نفس الريكوست وبيتباصى تحت.
  int? customerId;

  Timer? _refreshTimer;

  List<MessageModel> get messages => List.unmodifiable(_messages);

  // ==================== INITIALIZATION ====================

  Future<void> _initializeChat() async {
    await _getUserData();
    await _createOrGetConversation();
    await fetchMessages();
    await _markConversationAsRead();

    // Poll بسيط لتحديث الشات (مفيش WebSocket).
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => fetchMessages(silent: true),
    );
  }

  Future<void> _getUserData() async {
    userId = await globalAccountData.getId();
    userName = await globalAccountData.getUsername();
    userEmail = await globalAccountData.getEmail();
    _authToken = await globalAccountData.getToken();

    debugPrint('Support chat init: userId=$userId, email=$userEmail');
  }

  // ==================== API HELPERS ====================

  /// Base = `https://app.kytrademarks.com/api` (بدون سلاش زيادة في الآخر)
  static String get _baseApi {
    final raw = '${ApiConstant.baseUrl}${ApiConstant.slug}';
    return raw.replaceAll(RegExp(r'\/+$'), '');
  }

  Uri get _conversationUrl => Uri.parse('$_baseApi/support/conversation');

  Uri get _messagesUrl {
    if (conversationId == null) {
      throw StateError(
          'conversationId is null – call _createOrGetConversation first');
    }
    return Uri.parse(
        '$_baseApi/support/conversations/$conversationId/messages');
  }

  Uri get _readUrl {
    if (conversationId == null) {
      throw StateError(
          'conversationId is null – call _createOrGetConversation first');
    }
    return Uri.parse('$_baseApi/support/conversations/$conversationId/read');
  }

  Map<String, String> get _authHeaders {
    final token = _authToken;
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> get _jsonHeaders => {
        ..._authHeaders,
        'Content-Type': 'application/json',
      };

  Future<void> _createOrGetConversation() async {
    try {
      // الـ API بحسب الرسالة بيدعم GET مش POST
      final response = await http.get(_conversationUrl, headers: _authHeaders);

      if (response.statusCode != 200) {
        debugPrint(
            'support/conversation failed: status=${response.statusCode}, body=${response.body}');
        throw Exception('Failed to open support conversation');
      }

      final data = MessageModel.safeJsonDecode(response.body);
      final conversation = data['data']?['conversation'];

      if (conversation == null) {
        throw Exception('conversation object missing in response');
      }

      conversationId = conversation['id'] is int
          ? conversation['id'] as int
          : int.tryParse(conversation['id'].toString());

      customerId = conversation['customer_id'] is int
          ? conversation['customer_id'] as int
          : int.tryParse(conversation['customer_id'].toString());

      debugPrint(
          'Support conversation: id=$conversationId, customerId=$customerId');
    } catch (e) {
      debugPrint('Error creating/getting support conversation: $e');
      // ما نرميش exception عشان ما يوقعش الشاشة كلها؛
      // لو في مشكلة في الـ API هيبان اللوج بس.
    }
  }

  // ==================== FETCH / READ ====================

  Future<void> fetchMessages({bool silent = false}) async {
    if (conversationId == null) return;

    if (!silent) {
      isLoading = true;
      notifyListeners();
    }

    try {
      final response = await http.get(_messagesUrl, headers: _authHeaders);

      if (response.statusCode != 200) {
        debugPrint(
            'GET support/conversations/$conversationId/messages failed: status=${response.statusCode}, body=${response.body}');
        throw Exception('Failed to load messages');
      }

      final jsonMap = MessageModel.safeJsonDecode(response.body);
      final List<dynamic> rawMessages = jsonMap['data']?['messages'] ?? [];

      final currentUserId = userId ?? '';

      _messages
        ..clear()
        ..addAll(
          rawMessages
              .map(
                (m) => MessageModel.fromSupportApiJson(
                  m as Map<String, dynamic>,
                  currentUserId: currentUserId,
                ),
              )
              .toList()
            ..sort(
              (a, b) => b.createdAt.compareTo(a.createdAt),
            ),
        );

      isLoading = false;
      // دائماً نحدث الـ UI حتى لو كان silent
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching support messages: $e');
      isLoading = false;
      // دائماً نحدث الـ UI حتى لو كان silent
      notifyListeners();
    }
  }

  Future<void> _markConversationAsRead() async {
    if (conversationId == null) return;

    try {
      final body = <String, dynamic>{};
      if (customerId != null) {
        body['customer_id'] = customerId;
      } else if (userId != null) {
        body['customer_id'] = int.tryParse(userId!);
      }

      final response = await http.post(_readUrl,
          headers: _jsonHeaders, body: MessageModel.toJsonString(body));

      if (response.statusCode != 200) {
        debugPrint(
            'POST support/conversations/$conversationId/read failed: status=${response.statusCode}, body=${response.body}');
      }
    } catch (e) {
      debugPrint('Error marking conversation as read: $e');
    }
  }

  // ==================== SENDING ====================

  static const String uploadEndpoint =
      '${ApiConstant.baseUrl}${ApiConstant.slug}files/upload';

  /// نفس رفع الملفات القديم، لكن النتيجة بتُستخدم في `attachment_url` للـ API.
  Future<String?> _uploadFile({
    File? file,
    Uint8List? bytes,
    required String fileName,
  }) async {
    try {
      final customer = await globalAccountData.getId();
      final token = await globalAccountData.getToken();

      if (customer == null) {
        debugPrint('Customer ID is null while uploading file');
        return null;
      }

      final pathForMime = file != null ? file.path : fileName;
      final mimeType = lookupMimeType(pathForMime);
      final mediaType = mimeType != null ? MediaType.parse(mimeType) : null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomString = _generateRandomString(8);
      final ext = fileName.split('.').last;
      final uniqueFileName = '${customer}_${timestamp}_$randomString.$ext';

      final request = http.MultipartRequest('POST', Uri.parse(uploadEndpoint));

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
        debugPrint('No file or bytes provided to upload');
        return null;
      }

      request.fields['customer_id'] = customer;

      if (token != null) {
        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });
      }

      final response = await request.send();

      if (response.statusCode != 200) {
        debugPrint('Upload failed: status=${response.statusCode}');
        debugPrint('Error response: ${await response.stream.bytesToString()}');
        return null;
      }

      final responseData = await response.stream.bytesToString();
      final jsonResponse = MessageModel.safeJsonDecode(responseData);

      final data = jsonResponse['data'];
      if (data is Map<String, dynamic> && data['file_url'] != null) {
        final url = data['file_url'].toString().replaceFirst(' ', '');
        debugPrint('File uploaded successfully: $url');
        return url;
      }

      debugPrint('No file_url found in upload response: $jsonResponse');
      return null;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  String _generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = math.Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  String _mapMessageTypeToApi(MessageType type) {
    switch (type) {
      case MessageType.image:
        return 'image';
      case MessageType.video:
        return 'video';
      case MessageType.audio:
        return 'audio';
      case MessageType.pdf:
        return 'pdf';
      case MessageType.file:
        return 'file';
      case MessageType.text:
      default:
        return 'text';
    }
  }

  Future<void> sendMessage({
    String? text,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
    MessageType type = MessageType.text,
  }) async {
    if ((text?.trim().isEmpty ?? true) && file == null && fileBytes == null)
      return;
    if (conversationId == null) {
      await _createOrGetConversation();
    }

    final currentUserId = userId ?? '';
    final currentUserName = userName ?? 'User';

    final trimmedText = text?.trim();
    int? fileSize;
    final bool hasAttachment = file != null || fileBytes != null;

    try {
      if (hasAttachment) {
        fileSize = file != null ? await file.length() : fileBytes?.length;
      }

      final localMessage = MessageModel(
        id: '',
        senderId: currentUserId,
        senderName: currentUserName,
        chatId: (conversationId ?? 0).toString(),
        text: trimmedText,
        mediaUrl: null, // هيتم جلب الـ URL الحقيقي بعد ما السيرفر يحفظ الرسالة
        fileName: fileName,
        fileSize: fileSize,
        type: type,
        status: MessageStatus.sending,
        createdAt: DateTime.now(),
        isFromCurrentUser: true,
      );

      _messages.insert(0, localMessage);
      notifyListeners();

      if (hasAttachment) {
        // في حالة وجود ملف، الـ API طالب حقل "file" يكون فايل حقيقي (multipart)
        final request = http.MultipartRequest('POST', _messagesUrl);
        request.headers.addAll(_authHeaders);

        final customer =
            customerId ?? (userId != null ? int.tryParse(userId!) : null);
        if (customer != null) {
          request.fields['customer_id'] = customer.toString();
        }

        request.fields['message_type'] = _mapMessageTypeToApi(type);

        if (trimmedText?.isNotEmpty == true) {
          request.fields['message'] = trimmedText!;
        }

        if (file != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              file.path,
              filename: fileName ?? file.path.split('/').last,
            ),
          );
        } else if (fileBytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              fileBytes,
              filename: fileName ?? 'file',
            ),
          );
        }

        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);

        if (response.statusCode != 200 && response.statusCode != 201) {
          debugPrint(
              'POST support/conversations/$conversationId/messages failed (multipart): status=${response.statusCode}, body=${response.body}');
          final failedIndex = _messages.indexOf(localMessage);
          if (failedIndex != -1) {
            _messages[failedIndex] =
                localMessage.copyWith(status: MessageStatus.failed);
          }
          notifyListeners();
          return;
        }
      } else {
        // رسالة نصية فقط بدون مرفق
        final payload = <String, dynamic>{
          'customer_id':
              customerId ?? (userId != null ? int.tryParse(userId!) : null),
          'message_type': _mapMessageTypeToApi(type),
        };

        if (trimmedText?.isNotEmpty == true) {
          payload['message'] = trimmedText;
        }

        final response = await http.post(
          _messagesUrl,
          headers: _jsonHeaders,
          body: MessageModel.toJsonString(payload),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          debugPrint(
              'POST support/conversations/$conversationId/messages failed: status=${response.statusCode}, body=${response.body}');
          final failedIndex = _messages.indexOf(localMessage);
          if (failedIndex != -1) {
            _messages[failedIndex] =
                localMessage.copyWith(status: MessageStatus.failed);
          }
          notifyListeners();
          return;
        }
      }

      await fetchMessages(silent: true);
      await _markConversationAsRead();
    } catch (e) {
      debugPrint('Error sending support message: $e');

      // في حالة الفشل نعلّم آخر رسالة مضافة من المستخدم إنها Failed (لو لسه موجودة)
      if (_messages.isNotEmpty && _messages.first.isFromCurrentUser) {
        _messages[0] = _messages[0].copyWith(status: MessageStatus.failed);
        notifyListeners();
      }
    }
  }

  Future<void> setTypingStatus(bool typing) async {
    // لا يوجد API للـ typing حالياً – ممكن يتضاف بعدين
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
            allowedExtensions: ['webm', 'mp3', 'm4a', 'wav', 'ogg'],
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
        SnackBar(
            content: Text('failed_pick_document'.tr() + ': ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    debugPrint('Disposing ChatViewModel');
    _refreshTimer?.cancel();
    super.dispose();
  }
}
