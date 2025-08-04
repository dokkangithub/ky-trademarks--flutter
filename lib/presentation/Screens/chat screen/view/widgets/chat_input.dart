// lib/presentation/Screens/chat screen/view/widgets/chat_input.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../../../resources/Color_Manager.dart';
import 'voice_recording_widget.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(File, String)? onSendAudio;
  final VoidCallback? onAttachmentPressed;
  final Function(bool)? onTypingChanged;

  const ChatInput({
    Key? key,
    required this.onSendMessage,
    this.onSendAudio,
    this.onAttachmentPressed,
    this.onTypingChanged,
  }) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  bool _isRecording = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _isTyping) {
      setState(() {
        _isTyping = hasText;
      });
      widget.onTypingChanged?.call(hasText);
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _isTyping) {
      widget.onTypingChanged?.call(false);
      setState(() {
        _isTyping = false;
      });
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _textController.clear();
      setState(() {
        _isTyping = false;
      });
      widget.onTypingChanged?.call(false);
    }
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecording = true;
    });
    _animationController.forward();
  }

  void _stopVoiceRecording() {
    setState(() {
      _isRecording = false;
    });
    _animationController.reverse();
  }

  void _onAudioRecorded(File audioFile, String fileName) {
    widget.onSendAudio?.call(audioFile, fileName);
    _stopVoiceRecording();
  }

  void _onRecordingCancelled() {
    _stopVoiceRecording();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: _isRecording ? _buildRecordingWidget() : _buildNormalInput(),
    );
  }

  Widget _buildRecordingWidget() {
    return VoiceRecordingWidget(
      onAudioRecorded: _onAudioRecorded,
      onCancel: _onRecordingCancelled,
    );
  }

  Widget _buildNormalInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            if (widget.onAttachmentPressed != null)
              IconButton(
                onPressed: widget.onAttachmentPressed,
                icon: Icon(
                  IconlyBroken.paper_plus,
                  color: ColorManager.primary,
                  size: 24,
                ),
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
              ),

            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            SizedBox(width: 8),

            // Send button or Voice button
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: _isTyping
                  ? _buildSendButton()
                  : _buildVoiceButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      key: ValueKey('send'),
      decoration: BoxDecoration(
        color: ColorManager.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: _sendMessage,
        icon: Icon(
          IconlyBroken.send,
          color: Colors.white,
          size: 20,
        ),
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      key: ValueKey('voice'),
      onTap: () {
        if (widget.onSendAudio != null) {
          _startVoiceRecording();
        }
      },
      onLongPress: () {
        if (widget.onSendAudio != null) {
          _startVoiceRecording();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          constraints: BoxConstraints(minWidth: 44, minHeight: 44),
          child: Icon(
            IconlyBroken.voice,
            color: Colors.grey.shade600,
            size: 20,
          ),
        ),
      ),
    );
  }
}