// lib/presentation/Screens/chat screen/view/widgets/chat_input.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../resources/Color_Manager.dart';
import 'voice_recording_widget.dart';
import 'attachment_picker.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(File, String)? onSendAudio;
  final Function(File, String, String)? onAttachmentSelected;
  final Function(bool)? onTypingChanged;

  const ChatInput({
    Key? key,
    required this.onSendMessage,
    this.onSendAudio,
    this.onAttachmentSelected,
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
  bool _isAttachmentPickerVisible = false;
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

  void _showAttachmentPicker() {
    setState(() {
      _isAttachmentPickerVisible = true;
    });
  }

  void _hideAttachmentPicker() {
    setState(() {
      _isAttachmentPickerVisible = false;
    });
  }

  void _onFileSelected(File file, String fileName, String type) {
    if (widget.onAttachmentSelected != null) {
      widget.onAttachmentSelected!(file, fileName, type);
    }
    _hideAttachmentPicker();
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
    return Column(
      children: [
        // Attachment Picker
        if (_isAttachmentPickerVisible)
          AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: AttachmentPicker(
              key: ValueKey('attachment_picker'),
              onFileSelected: _onFileSelected,
              onClose: _hideAttachmentPicker,
            ),
          ),
        
        // Main Input
        AnimatedSwitcher(
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
        ),
      ],
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
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 12,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            if (widget.onAttachmentSelected != null)
              _buildAttachmentButton(),

            SizedBox(width: 8),

            // Text input field
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 44,
                  maxHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _focusNode.hasFocus 
                        ? ColorManager.primary.withOpacity(0.4)
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'write_message'.tr(),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                  onChanged: (text) {
                    _onTextChanged();
                  },
                ),
              ),
            ),

            SizedBox(width: 8),

            // Action button (Send or Voice)
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: _isTyping ? _buildSendButton() : _buildVoiceButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAttachmentPicker,
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: Icon(
              IconlyBroken.paper_plus,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      key: ValueKey('send'),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary,
            ColorManager.primaryByOpacity,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _sendMessage,
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: Icon(
              IconlyBroken.send,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Container(
      key: ValueKey('voice'),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: Icon(
              IconlyBroken.voice,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}