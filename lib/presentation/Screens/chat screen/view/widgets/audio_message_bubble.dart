import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../../resources/Color_Manager.dart';
import 'dart:math' as math;

class AudioMessageBubble extends StatefulWidget {
  final String audioUrl;
  final bool isFromCurrentUser;
  final Color bubbleColor;
  final Duration? duration;
  final bool isEmbedded;

  const AudioMessageBubble({
    Key? key,
    required this.audioUrl,
    required this.isFromCurrentUser,
    required this.bubbleColor,
    this.duration,
    this.isEmbedded = false,
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
  late AnimationController _pulseController;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;
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
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
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
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
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
          _pulseController.repeat(reverse: true);
        } else {
          _waveController.stop();
          _pulseController.stop();
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
        SnackBar(
          content: Text('Failed to play audio'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
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
    _pulseController.dispose();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmbedded) {
      return _buildEmbeddedAudioPlayer();
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: widget.isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
              minWidth: 220,
            ),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isFromCurrentUser
                    ? [
                        ColorManager.primary,
                        ColorManager.primaryByOpacity,
                      ]
                    : [
                        Colors.grey.shade50,
                        Colors.grey.shade100,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: widget.isFromCurrentUser
                    ? Radius.circular(24)
                    : Radius.circular(8),
                bottomRight: widget.isFromCurrentUser
                    ? Radius.circular(8)
                    : Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
              border: widget.isFromCurrentUser
                  ? null
                  : Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
            ),
            child: _buildAudioPlayerContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedAudioPlayer() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isFromCurrentUser
              ? [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ]
              : [
                  ColorManager.primary.withOpacity(0.1),
                  ColorManager.primaryByOpacity.withOpacity(0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isFromCurrentUser
              ? Colors.white.withOpacity(0.2)
              : ColorManager.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: _buildAudioPlayerContent(),
    );
  }

  Widget _buildAudioPlayerContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Play button and waveform
        Row(
          children: [
            // Play/Pause button
            GestureDetector(
              onTap: _togglePlayPause,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isPlaying ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isFromCurrentUser
                              ? [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ]
                              : [
                                  ColorManager.primary.withOpacity(0.2),
                                  ColorManager.primary.withOpacity(0.1),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.isFromCurrentUser
                                ? Colors.white.withOpacity(0.3)
                                : ColorManager.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.isFromCurrentUser
                                        ? Colors.white
                                        : ColorManager.primary,
                                  ),
                                ),
                              ),
                            )
                          : Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: widget.isFromCurrentUser
                                  ? Colors.white
                                  : ColorManager.primary,
                              size: 24,
                            ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(width: 16),

            // Waveform and progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Waveform visualization
                  Container(
                    height: 40,
                    child: AnimatedBuilder(
                      animation: _waveAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ModernAudioWaveformPainter(
                            animationValue: _isPlaying ? _waveAnimation.value : 0.0,
                            progress: _totalDuration.inMilliseconds > 0
                                ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                                : 0.0,
                            color: widget.isFromCurrentUser
                                ? Colors.white.withOpacity(0.4)
                                : ColorManager.primary.withOpacity(0.3),
                            progressColor: widget.isFromCurrentUser
                                ? Colors.white
                                : ColorManager.primary,
                            isPlaying: _isPlaying,
                          ),
                          size: Size(double.infinity, 40),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 8),

                  // Time indicators
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style: TextStyle(
                          color: widget.isFromCurrentUser
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey.shade600,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ModernAudioWaveformPainter extends CustomPainter {
  final double animationValue;
  final double progress;
  final Color color;
  final Color progressColor;
  final bool isPlaying;

  ModernAudioWaveformPainter({
    required this.animationValue,
    required this.progress,
    required this.color,
    required this.progressColor,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = progressColor;

    final centerY = size.height / 2;
    final barWidth = 3.0;
    final barSpacing = 4.0;
    final totalBars = (size.width / (barWidth + barSpacing)).floor();
    final progressX = size.width * progress;

    for (int i = 0; i < totalBars; i++) {
      final x = i * (barWidth + barSpacing);

      // Create more dynamic heights with animation
      final normalizedPosition = i / totalBars;
      final baseHeight = 0.15 + 0.7 * (0.5 + 0.3 * math.sin(normalizedPosition * 6));
      
      double animatedHeight;
      if (isPlaying) {
        animatedHeight = baseHeight + 0.3 * (0.5 + 0.5 * math.sin(animationValue * 3 * math.pi + normalizedPosition * 8));
      } else {
        animatedHeight = baseHeight;
      }

      final barHeight = size.height * animatedHeight * 0.9;
      final startY = centerY - barHeight / 2;
      final endY = centerY + barHeight / 2;

      // Use progress color if this bar is before the current position
      paint.color = x <= progressX ? progressColor : color;

      // Add gradient effect to bars
      final gradient = LinearGradient(
        colors: [
          paint.color.withOpacity(0.8),
          paint.color,
          paint.color.withOpacity(0.8),
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
          Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

