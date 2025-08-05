import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../resources/Color_Manager.dart';

class VideoMessageBubble extends StatefulWidget {
  final String videoUrl;
  final bool isFromCurrentUser;
  final String? caption;

  const VideoMessageBubble({
    Key? key,
    required this.videoUrl,
    required this.isFromCurrentUser,
    this.caption,
  }) : super(key: key);

  @override
  _VideoMessageBubbleState createState() => _VideoMessageBubbleState();
}

class _VideoMessageBubbleState extends State<VideoMessageBubble> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: widget.isFromCurrentUser ? Colors.white : ColorManager.primary,
          handleColor: widget.isFromCurrentUser ? Colors.white : ColorManager.primary,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade400,
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(
              color: widget.isFromCurrentUser ? Colors.white : ColorManager.primary,
            ),
          ),
        ),
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.caption?.isNotEmpty == true) ...[
          Text(
            widget.caption!,
            style: TextStyle(
              color: widget.isFromCurrentUser ? Colors.white : Colors.black87,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 12),
        ],
        Container(
          constraints: BoxConstraints(
            maxHeight: 300,
            maxWidth: 280,
            minHeight: 200,
            minWidth: 200,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _isInitialized && _chewieController != null
                ? Chewie(controller: _chewieController!)
                : Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isFromCurrentUser ? Colors.white : ColorManager.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'loading_video'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
} 