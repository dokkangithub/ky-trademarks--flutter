import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:iconly/iconly.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart'; // Full import
import 'package:easy_localization/easy_localization.dart';
import '../../../../../resources/Color_Manager.dart';
import 'dart:math' as math;
// Web imports guarded by kIsWeb
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class VoiceRecordingWidget extends StatefulWidget {
  final Function(File audioFile, String fileName)? onAudioRecorded;
  final Function(Uint8List bytes, String fileName)? onAudioBytesRecorded;
  final VoidCallback? onCancel;

  const VoiceRecordingWidget({
    Key? key,
    this.onAudioRecorded,
    this.onAudioBytesRecorded,
    this.onCancel,
  }) : super(key: key);

  @override
  _VoiceRecordingWidgetState createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder(); // For mobile/desktop

  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  bool _isRecording = false;
  String _recordingTime = "00:00";
  Timer? _timer;
  int _recordingSeconds = 0;
  String? _audioPath;

  // Web state
  html.MediaRecorder? _mediaRecorder;
  List<html.Blob> _webChunks = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startRecording();
  }

  void _setupAnimations() {
    _waveController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
  }

  Future<void> _startRecording() async {
    try {
      if (kIsWeb) {
        await _startRecordingWeb();
        return;
      }

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

      _waveController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
      _scaleController.forward();
      _startTimer();
      HapticFeedback.lightImpact();
    } catch (e) {
      print('Error starting recording: $e');
      _showErrorDialog('failed_start_recording'.tr());
    }
  }

  Future<void> _startRecordingWeb() async {
    try {
      // Ask for mic stream
      final stream = await html.window.navigator.mediaDevices!
          .getUserMedia({'audio': true});

      _webChunks.clear();

      // Create MediaRecorder with webm opus
      _mediaRecorder = html.MediaRecorder(stream, {'mimeType': 'audio/webm'});

      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final ev = event as html.BlobEvent;
        final dataBlob = ev.data;
        if (dataBlob != null && (dataBlob.size ?? 0) > 0) {
          _webChunks.add(dataBlob);
        }
      });

      _mediaRecorder!.start();

      setState(() {
        _isRecording = true;
      });

      _waveController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
      _scaleController.forward();
      _startTimer();
    } catch (e) {
      print('Web recording start error: $e');
      _showErrorDialog('failed_start_recording'.tr());
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

      if (_recordingSeconds >= 300) {
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      if (kIsWeb) {
        await _stopRecordingWeb();
        return;
      }

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
        widget.onAudioRecorded?.call(audioFile, fileName);
      }

      HapticFeedback.mediumImpact();
    } catch (e) {
      print('Error stopping recording: $e');
      _showErrorDialog('failed_save_recording'.tr());
    }
  }

  Future<void> _stopRecordingWeb() async {
    try {
      final recorder = _mediaRecorder;
      if (recorder == null) return;

      final stopCompleter = Completer<void>();
      void onStop(html.Event _) {
        stopCompleter.complete();
      }
      recorder.addEventListener('stop', onStop);
      recorder.stop();
      await stopCompleter.future;
      recorder.removeEventListener('stop', onStop);

      setState(() {
        _isRecording = false;
      });

      _timer?.cancel();
      _waveController.stop();
      _pulseController.stop();

      if (_webChunks.isNotEmpty) {
        final blob = html.Blob(_webChunks, 'audio/webm');
        final reader = html.FileReader();
        final readCompleter = Completer<void>();
        reader.onLoadEnd.listen((_) => readCompleter.complete());
        reader.readAsArrayBuffer(blob);
        await readCompleter.future;
        final data = reader.result as ByteBuffer;
        final bytes = data.asUint8List();
        final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.webm';
        widget.onAudioBytesRecorded?.call(bytes, fileName);
      }

      HapticFeedback.mediumImpact();
    } catch (e) {
      print('Web stop error: $e');
      _showErrorDialog('failed_save_recording'.tr());
    }
  }

  void _cancelRecording() async {
    if (_isRecording) {
      if (kIsWeb) {
        try {
          _mediaRecorder?.stop();
        } catch (_) {}
      } else {
        await _audioRecorder.stop();
      }
      setState(() {
        _isRecording = false;
      });
    }

    _timer?.cancel();
    _waveController.stop();
    _pulseController.stop();

    if (!kIsWeb) {
      if (_audioPath != null && File(_audioPath!).existsSync()) {
        try {
          await File(_audioPath!).delete();
        } catch (e) {
          print('Error deleting audio file: $e');
        }
      }
    }

    widget.onCancel?.call();
    HapticFeedback.lightImpact();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'microphone_permission'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'microphone_permission_message'.tr(),
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel?.call();
            },
            child: Text(
              'cancel'.tr(),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'settings'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'error'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'ok'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
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
    _scaleController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: Offset(0, -2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Cancel button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _cancelRecording,
                      borderRadius: BorderRadius.circular(20),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.red.shade600,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // Recording animation and time
                Expanded(
                  child: Column(
                    children: [
                      // Animated microphone icon
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: ColorManager.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: ColorManager.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  IconlyBroken.voice,
                                  color: ColorManager.primary,
                                  size: 22,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 8),

                      // Wave animation
                      Container(
                        height: 28,
                        child: AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: ModernWaveformPainter(
                                animationValue: _waveAnimation.value,
                                color: ColorManager.primary,
                              ),
                              size: Size(double.infinity, 28),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 6),

                      // Recording time
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ColorManager.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _recordingTime,
                          style: TextStyle(
                            color: ColorManager.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12),

                // Send button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorManager.primary,
                        ColorManager.primaryByOpacity,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.primary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _stopRecording,
                      borderRadius: BorderRadius.circular(20),
                      child: Center(
                        child: Icon(
                          IconlyBroken.send,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ModernWaveformPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  ModernWaveformPainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = 2.5;
    final barSpacing = 3.0;
    final totalBars = (size.width / (barWidth + barSpacing)).floor();

    for (int i = 0; i < totalBars; i++) {
      final x = i * (barWidth + barSpacing);

      final normalizedPosition = i / totalBars;
      final heightFactor = 0.4 +
          0.6 * (0.5 + 0.5 * math.sin(animationValue * 1.5 * math.pi + normalizedPosition * 3));

      final barHeight = size.height * heightFactor * 0.7;
      final startY = centerY - barHeight / 2;
      final endY = centerY + barHeight / 2;

      final gradient = LinearGradient(
        colors: [
          color.withOpacity(0.7),
          color,
          color.withOpacity(0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

      final rect = Rect.fromLTWH(x, startY, barWidth, barHeight);
      final shader = gradient.createShader(rect);
      paint.shader = shader;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, startY, barWidth, barHeight),
          Radius.circular(1.2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}