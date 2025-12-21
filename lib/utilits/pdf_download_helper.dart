import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class PdfDownloadHelper {
  /// Download and open PDF file
  /// On iOS, downloads the file and shares it
  /// On Android/Web, opens the URL directly
  static Future<void> downloadPdf({
    required String url,
    required BuildContext context,
    String? fileName,
  }) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('downloading'.tr()),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // For iOS, download the file first, then open the original URL in Safari
      // Safari on iOS handles PDF downloads better than WebView
      if (Platform.isIOS) {
        // Download file silently first
        await _downloadPdfFile(url, fileName);

        // Then open the original URL in Safari - Safari will handle the PDF download/display
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw Exception('Could not launch URL');
        }
      } else if (Platform.isAndroid) {
        // Android: Open URL directly (original method)
        final uri = Uri.parse(url);
        try {
          // On Android, use platformDefault which handles URLs better
          await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        } catch (e) {
          debugPrint('Launch URL error: $e');
          // Fallback: try externalApplication
          try {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
          } catch (e2) {
            debugPrint('External launch error: $e2');
            throw Exception('Could not launch URL: $e2');
          }
        }
      } else {
        // Web or other platforms: Open URL directly
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw Exception('Could not launch URL');
        }
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('failed_to_download_pdf'.tr()),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Download PDF file silently (for iOS - saves file in background)
  static Future<void> _downloadPdfFile(
    String url,
    String? fileName,
  ) async {
    final client = http.Client();
    try {
      // Create HTTP request
      final request = http.Request('GET', Uri.parse(url));
      request.headers['Accept'] = 'application/pdf';

      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode == 200) {
        // Get bytes from response
        final bytes = await streamedResponse.stream.toBytes();

        // On iOS, save to Documents directory so it's accessible in Files app
        final documentsDir = await getApplicationDocumentsDirectory();
        final savedFileName =
            fileName ?? 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final savedFilePath = '${documentsDir.path}/$savedFileName';
        final savedFile = File(savedFilePath);
        await savedFile.writeAsBytes(bytes);

        debugPrint('PDF saved to: $savedFilePath');
      } else {
        debugPrint('Failed to download PDF: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading PDF file: $e');
      // Don't throw - this is a background operation
    } finally {
      client.close();
    }
  }

  /// Download PDF with custom token
  static Future<void> downloadPdfWithToken({
    required String url,
    required BuildContext context,
    String? fileName,
    String? authToken,
  }) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('downloading'.tr()),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // For iOS, download the file first, then open the original URL in Safari
      if (Platform.isIOS) {
        // Download file silently first with token
        await _downloadPdfFileWithToken(url, fileName, authToken);

        // Then open the original URL in Safari - Safari will handle the PDF download/display
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw Exception('Could not launch URL');
        }
      } else if (Platform.isAndroid) {
        // Android: Open URL directly (original method)
        final uri = Uri.parse(url);
        try {
          // On Android, use platformDefault which handles URLs better
          await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        } catch (e) {
          debugPrint('Launch URL error: $e');
          // Fallback: try externalApplication
          try {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
          } catch (e2) {
            debugPrint('External launch error: $e2');
            throw Exception('Could not launch URL: $e2');
          }
        }
      } else {
        // Web or other platforms: Open URL directly
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw Exception('Could not launch URL');
        }
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('failed_to_download_pdf'.tr()),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Download PDF file silently with token (for iOS - saves file in background)
  static Future<void> _downloadPdfFileWithToken(
    String url,
    String? fileName,
    String? authToken,
  ) async {
    final client = http.Client();
    try {
      // Create HTTP request with authorization header
      final request = http.Request('GET', Uri.parse(url));
      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }
      request.headers['Accept'] = 'application/pdf';

      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode == 200) {
        // Get bytes from response
        final bytes = await streamedResponse.stream.toBytes();

        // On iOS, save to Documents directory so it's accessible in Files app
        final documentsDir = await getApplicationDocumentsDirectory();
        final savedFileName =
            fileName ?? 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final savedFilePath = '${documentsDir.path}/$savedFileName';
        final savedFile = File(savedFilePath);
        await savedFile.writeAsBytes(bytes);

        debugPrint('PDF saved to: $savedFilePath');
      } else {
        debugPrint('Failed to download PDF: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading PDF file: $e');
      // Don't throw - this is a background operation
    } finally {
      client.close();
    }
  }
}
