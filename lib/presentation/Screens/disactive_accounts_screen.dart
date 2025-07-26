import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InactiveAccountScreen extends StatelessWidget {
  const InactiveAccountScreen({Key? key}) : super(key: key);

  // Ky Trademarks Colors
  static const Color primary = Color(0xff155E7D);
  static const Color primaryByOpacity = Color(0xff00ACC8);

  void _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Cannot launch phone: $phone');
      }
    } catch (e) {
      debugPrint('Error launching phone: $e');
    }
  }

  void _launchEmail(String email) async {
    // Email subject and body in Arabic
    String subject = 'طلب إنشاء حساب جديد - Ky Trademarks';
    String body = 'مرحباً،\n\nمن فضلك أريد إنشاء حساب جديد في تطبيق Ky Trademarks وأحتاج مساعدة في تفعيل الحساب.\n\nشكراً لكم';

    // Try simple mailto scheme first
    try {
      final Uri uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    } catch (e) {
      debugPrint('Email with subject and body failed: $e');
    }

    // Fallback: Try with subject only
    try {
      final Uri uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    } catch (e) {
      debugPrint('Email with subject failed: $e');
    }

    // Final fallback: Simple mailto
    try {
      final Uri uri = Uri.parse('mailto:$email');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    } catch (e) {
      debugPrint('Simple mailto failed: $e');
    }

    debugPrint('Could not launch email: $email');
  }

  void _launchWhatsApp(BuildContext context, String phone) async {
    // Clean the phone number
    String cleanPhone = phone.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '');

    // Message text in Arabic
    String message = 'مرحباً، من فضلك أحتاج مساعدة في تفعيل الحساب';
    String encodedMessage = Uri.encodeComponent(message);

    // First, try the direct WhatsApp scheme
    try {
      final Uri whatsappUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedMessage');
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      return;
    } catch (e) {
      debugPrint('WhatsApp app not available: $e');
    }

    // Fallback to web WhatsApp
    try {
      final Uri webUri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    } catch (e) {
      debugPrint('Web WhatsApp failed: $e');
    }

    // Final fallback - show a dialog with instructions
    _showWhatsAppNotAvailable(context, phone);
  }

  void _showWhatsAppNotAvailable(BuildContext context, String phone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('واتساب غير متوفر'),
          content: Text('لا يمكن فتح واتساب. يمكنك نسخ الرقم والتواصل يدوياً:\n$phone'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  Widget buildContactItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: primaryByOpacity.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: primary.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 80, color: primary),
                  const SizedBox(height: 24),
                  Text(
                    'حسابك غير مفعل',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'برجاء التواصل مع الدعم الفني لتفعيل حسابك',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Phone 1
                  buildContactItem(
                    icon: Icons.phone,
                    label: '+201004000856',
                    onTap: () => _launchPhone('+201004000856'),
                  ),

                  // Phone 2
                  buildContactItem(
                    icon: Icons.phone,
                    label: '+0225608189',
                    onTap: () => _launchPhone('+0225608189'),
                  ),

                  // Email
                  buildContactItem(
                    icon: Icons.email,
                    label: 'info@kytrademarks.com',
                    onTap: () => _launchEmail('info@kytrademarks.com'),
                  ),

                  // WhatsApp
                  buildContactItem(
                    icon: Icons.chat,
                    label: '+201118125550 (واتساب)',
                    onTap: () => _launchWhatsApp(context, '+201118125550'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}