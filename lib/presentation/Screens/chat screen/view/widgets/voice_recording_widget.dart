import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart'; // Full import
import '../../../../../resources/Color_Manager.dart';
import 'dart:math' as math;

class VoiceRecordingWidget extends StatefulWidget {
  final Function(File audioFile, String fileName) onAudioRecorded;
  final VoidCallback? onCancel;

  const VoiceRecordingWidget({
    Key? key,
    required this.onAudioRecorded,
    this.onCancel,
  }) : super(key: key);

  @override
  _VoiceRecordingWidgetState createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  // Try AudioRecorder for newer versions, or Record for older versions
  final AudioRecorder _audioRecorder = AudioRecorder(); // For record package 5.x+
  // final Record _audioRecorder = Record(); // For record package 4.x

  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;

  bool _isRecording = false;
  String _recordingTime = "00:00";
  Timer? _timer;
  int _recordingSeconds = 0;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startRecording();
  }

  void _setupAnimations() {
    _waveController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _startRecording() async {
    try {
      // Request microphone permission
      if (!await _requestPermission()) {
        _showPermissionDialog();
        return;
      }

      // Check if recorder has permission
      if (!await _audioRecorder.hasPermission()) {
        _showPermissionDialog();
        return;
      }

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _audioPath = '${directory.path}/$fileName';

      // Start recording with RecordConfig
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _audioPath!,
      );

      setState(() {
        _isRecording = true;
      });

      // Start animations
      _waveController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);

      // Start timer
      _startTimer();

      // Haptic feedback
      HapticFeedback.lightImpact();

    } catch (e) {
      print('Error starting recording: $e');
      _showErrorDialog('Failed to start recording');
    }
  }

  Future<bool> _requestPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
        final minutes = _recordingSeconds ~/ 60;
        final seconds = _recordingSeconds % 60;
        _recordingTime =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });

      // Maximum recording time (5 minutes)
      if (_recordingSeconds >= 300) {
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      _timer?.cancel();
      _waveController.stop();
      _pulseController.stop();

      if (path != null && File(path).existsSync()) {
        final audioFile = File(path);
        final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        widget.onAudioRecorded(audioFile, fileName);
      }

      // Haptic feedback
      HapticFeedback.mediumImpact();

    } catch (e) {
      print('Error stopping recording: $e');
      _showErrorDialog('Failed to save recording');
    }
  }

  void _cancelRecording() async {
    if (_isRecording) {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
    }

    _timer?.cancel();
    _waveController.stop();
    _pulseController.stop();

    // Delete the recorded file
    if (_audioPath != null && File(_audioPath!).existsSync()) {
      try {
        await File(_audioPath!).delete();
      } catch (e) {
        print('Error deleting audio file: $e');
      }
    }

    widget.onCancel?.call();

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Microphone Permission'),
        content: Text('Please allow microphone access to record voice messages.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel?.call();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel?.call();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    _pulseController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel button
          GestureDetector(
            onTap: _cancelRecording,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),

          SizedBox(width: 16),

          // Recording animation and time
          Expanded(
            child: Row(
              children: [
                // Animated microphone icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          IconlyBroken.voice,
                          color: ColorManager.primary,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(width: 12),

                // Wave animation
                Expanded(
                  child: Container(
                    height: 30,
                    child: AnimatedBuilder(
                      animation: _waveAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: WaveformPainter(
                            animationValue: _waveAnimation.value,
                            color: ColorManager.primary,
                          ),
                          size: Size(double.infinity, 30),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // Recording time
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _recordingTime,
                    style: TextStyle(
                      color: ColorManager.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 16),

          // Send button
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorManager.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconlyBroken.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WaveformPainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = 3.0;
    final barSpacing = 5.0;
    final totalBars = (size.width / (barWidth + barSpacing)).floor();

    for (int i = 0; i < totalBars; i++) {
      final x = i * (barWidth + barSpacing);

      // Create random heights with animation
      final normalizedPosition = i / totalBars;
      final heightFactor = 0.3 +
          0.7 * (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi + normalizedPosition * 4));

      final barHeight = size.height * heightFactor * 0.8;
      final startY = centerY - barHeight / 2;
      final endY = centerY + barHeight / 2;

      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}