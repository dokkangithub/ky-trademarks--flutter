import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iconly/iconly.dart';

class AttachmentPicker extends StatefulWidget {
  final Function(File file, String fileName, String type) onFileSelected;
  final VoidCallback onClose;

  const AttachmentPicker({
    Key? key,
    required this.onFileSelected,
    required this.onClose,
  }) : super(key: key);

  @override
  _AttachmentPickerState createState() => _AttachmentPickerState();
}

class _AttachmentPickerState extends State<AttachmentPicker>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _closeWithAnimation() {
    _slideController.reverse();
    _fadeController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, -5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 8, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        'إرفق ملف',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: _closeWithAnimation,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.grey.shade600,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Attachment Options
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildAttachmentOption(
                          context,
                          icon: IconlyBroken.image,
                          title: 'صورة',
                          subtitle: 'Gallery',
                          color: Colors.blue.shade500,
                          onTap: () => _pickImage(context),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildAttachmentOption(
                          context,
                          icon: IconlyBroken.video,
                          title: 'فيديو',
                          subtitle: 'Gallery',
                          color: Colors.red.shade500,
                          onTap: () => _pickVideo(context),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildAttachmentOption(
                          context,
                          icon: IconlyBroken.document,
                          title: 'ملف',
                          subtitle: 'Document',
                          color: Colors.orange.shade500,
                          onTap: () => _pickDocument(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        final file = File(image.path);
        final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        widget.onFileSelected(file, fileName, 'image');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to pick image');
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(minutes: 5),
      );

      if (video != null) {
        final file = File(video.path);
        final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        widget.onFileSelected(file, fileName, 'video');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to pick video');
    }
  }

  Future<void> _pickDocument(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final extension = fileName.split('.').last.toLowerCase();
        
        String type = 'file';
        if (extension == 'pdf') {
          type = 'pdf';
        }

        widget.onFileSelected(file, fileName, type);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to pick document');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
} 