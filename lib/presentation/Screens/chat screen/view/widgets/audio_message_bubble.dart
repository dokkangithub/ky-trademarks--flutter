import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../../resources/Color_Manager.dart';
import 'dart:math' as math;

class AudioMessageBubble extends StatefulWidget {
  final String audioUrl;
  final bool isFromCurrentUser;
  final Color bubbleColor;
  final Duration? duration;

  const AudioMessageBubble({
    Key? key,
    required this.audioUrl,
    required this.isFromCurrentUser,
    required this.bubbleColor,
    this.duration,
  }) : super(key: key);

  @override
  _AudioMessageBubbleState createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupAudioPlayer();
  }

  void _setupAnimations() {
    _waveController = AnimationController(
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
  }

  void _setupAudioPlayer() {
    // Listen to position changes
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // Listen to duration changes
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    // Listen to player state changes
    _stateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = state == PlayerState.playing && _currentPosition == Duration.zero;
        });

        if (_isPlaying) {
          _waveController.repeat();
        } else {
          _waveController.stop();
        }

        // Auto stop when completed
        if (state == PlayerState.completed) {
          _audioPlayer.stop();
          setState(() {
            _currentPosition = Duration.zero;
            _isPlaying = false;
          });
        }
      }
    });
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_currentPosition == Duration.zero) {
          await _audioPlayer.play(UrlSource(widget.audioUrl));
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      print('Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play audio')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _waveController.dispose();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: widget.isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
              minWidth: 200,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: widget.isFromCurrentUser
                    ? Radius.circular(20)
                    : Radius.circular(5),
                bottomRight: widget.isFromCurrentUser
                    ? Radius.circular(5)
                    : Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play/Pause button
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.isFromCurrentUser
                          ? Colors.white.withOpacity(0.2)
                          : ColorManager.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: _isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.isFromCurrentUser
                              ? Colors.white
                              : ColorManager.primary,
                        ),
                      ),
                    )
                        : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: widget.isFromCurrentUser
                          ? Colors.white
                          : ColorManager.primary,
                      size: 20,
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // Waveform and duration
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Waveform visualization
                      Container(
                        height: 30,
                        child: AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: AudioWaveformPainter(
                                animationValue: _isPlaying ? _waveAnimation.value : 0.0,
                                progress: _totalDuration.inMilliseconds > 0
                                    ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                                    : 0.0,
                                color: widget.isFromCurrentUser
                                    ? Colors.white.withOpacity(0.8)
                                    : ColorManager.primary.withOpacity(0.6),
                                progressColor: widget.isFromCurrentUser
                                    ? Colors.white
                                    : ColorManager.primary,
                              ),
                              size: Size(double.infinity, 30),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 4),

                      // Duration text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_currentPosition),
                            style: TextStyle(
                              color: widget.isFromCurrentUser
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            _formatDuration(_totalDuration),
                            style: TextStyle(
                              color: widget.isFromCurrentUser
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8),

                // Audio icon
                Icon(
                  IconlyBroken.voice,
                  color: widget.isFromCurrentUser
                      ? Colors.white.withOpacity(0.8)
                      : ColorManager.primary.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudioWaveformPainter extends CustomPainter {
  final double animationValue;
  final double progress;
  final Color color;
  final Color progressColor;

  AudioWaveformPainter({
    required this.animationValue,
    required this.progress,
    required this.color,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = progressColor;

    final centerY = size.height / 2;
    final barWidth = 2.0;
    final barSpacing = 3.0;
    final totalBars = (size.width / (barWidth + barSpacing)).floor();
    final progressX = size.width * progress;

    for (int i = 0; i < totalBars; i++) {
      final x = i * (barWidth + barSpacing);

      // Create varying heights with animation
      final normalizedPosition = i / totalBars;
      final baseHeight = 0.2 + 0.6 * (0.5 + 0.3 * math.sin(normalizedPosition * 8));
      final animatedHeight = animationValue > 0
          ? baseHeight + 0.2 * (0.5 + 0.5 * math.sin(animationValue * 4 * math.pi + normalizedPosition * 6))
          : baseHeight;

      final barHeight = size.height * animatedHeight * 0.8;
      final startY = centerY - barHeight / 2;
      final endY = centerY + barHeight / 2;

      // Use progress color if this bar is before the current position
      paint.color = x <= progressX ? progressColor : color;

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

