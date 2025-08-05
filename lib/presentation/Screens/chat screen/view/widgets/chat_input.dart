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
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
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
    print('ChatInput: Starting voice recording...');
    setState(() {
      _isRecording = true;
    });
    _animationController.forward();
  }

  void _stopVoiceRecording() {
    print('ChatInput: Stopping voice recording...');
    setState(() {
      _isRecording = false;
    });
    _animationController.reverse();
  }

  void _onAudioRecorded(File audioFile, String fileName) {
    print('ChatInput: Audio recorded - File: ${audioFile.path}, Name: $fileName');
    if (widget.onSendAudio != null) {
      widget.onSendAudio!(audioFile, fileName);
      print('ChatInput: Audio sent to parent');
    } else {
      print('ChatInput: WARNING - onSendAudio is null!');
    }
    _stopVoiceRecording();
  }

  void _onRecordingCancelled() {
    print('ChatInput: Recording cancelled');
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
      duration: Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: _isRecording ? _buildRecordingWidget() : _buildNormalInput(),
    );
  }

  Widget _buildRecordingWidget() {
    print('ChatInput: Building recording widget');
    return VoiceRecordingWidget(
      onAudioRecorded: _onAudioRecorded,
      onCancel: _onRecordingCancelled,
    );
  }

  Widget _buildNormalInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            if (widget.onAttachmentPressed != null)
              _buildAttachmentButton(),

            SizedBox(width: 12),

            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _focusNode.hasFocus 
                        ? ColorManager.primary.withOpacity(0.3)
                        : Colors.grey.shade200,
                    width: 1.5,
                  ),
                  boxShadow: _focusNode.hasFocus ? [
                    BoxShadow(
                      color: ColorManager.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ] : null,
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
                      fontWeight: FontWeight.w400,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: InputBorder.none,
                    suffixIcon: _isTyping ? null : _buildVoiceButton(),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            SizedBox(width: 12),

            // Send button
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: _isTyping ? _buildSendButton() : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary.withOpacity(0.1),
            ColorManager.primaryByOpacity.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: widget.onAttachmentPressed,
        icon: Icon(
          IconlyBroken.paper_plus,
          color: ColorManager.primary,
          size: 22,
        ),
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      key: ValueKey('send'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary,
            ColorManager.primaryByOpacity,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: _sendMessage,
        icon: Icon(
          IconlyBroken.send,
          color: Colors.white,
          size: 20,
        ),
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      key: ValueKey('voice'),
      onTap: () {
        print('ChatInput: Voice button tapped');
        if (widget.onSendAudio != null) {
          print('ChatInput: onSendAudio is available, starting recording');
          _startVoiceRecording();
        } else {
          print('ChatInput: onSendAudio is null - cannot record!');
        }
      },
      onLongPress: () {
        print('ChatInput: Voice button long pressed');
        if (widget.onSendAudio != null) {
          _startVoiceRecording();
        }
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(
          IconlyBroken.voice,
          color: Colors.grey.shade600,
          size: 20,
        ),
      ),
    );
  }
}