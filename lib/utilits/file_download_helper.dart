import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileDownloadHelper {
  static const _fileSaverChannel = MethodChannel('com.kytrademarks/file_saver');

  static Future<void> download({
    required BuildContext context,
    required String url,
    required String fileName,
    required String extension,
    String? authToken,
  }) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري تحميل الملف...')),
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw Exception('Download failed: ${response.statusCode}');
      }

      if (!kIsWeb && Platform.isAndroid) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes, flush: true);
        final savedUri =
            await _fileSaverChannel.invokeMethod<String>('saveFile', {
          'filePath': file.path,
          'fileName': fileName,
        });
        if (savedUri == null || savedUri.isEmpty) {
          throw Exception('File was not saved');
        }
        try {
          await _fileSaverChannel.invokeMethod<bool>('openFile', {
            'uri': savedUri,
            'fileName': fileName,
          });
        } on PlatformException {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم التحميل، ولا يوجد تطبيق مناسب لفتح الملف'),
              ),
            );
          }
        }
      } else {
        final path = await FilePicker.saveFile(
          dialogTitle: 'حفظ الملف',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: [extension],
          bytes: response.bodyBytes,
        );
        if (path == null && !kIsWeb) return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحميل الملف بنجاح')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تحميل الملف'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
