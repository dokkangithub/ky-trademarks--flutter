import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final String userName;

  const TypingIndicator({Key? key, required this.userName}) : super(key: key);

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8),

          // Typing bubble
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.userName} is typing',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(width: 8),
                _buildTypingDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDots() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Fixed opacity calculation to ensure value stays between 0.0 and 1.0
            double opacity = 0.4 + 0.6 * ((_animation.value + (index * 0.2)) % 1.0);
            // Clamp to ensure it's within valid range
            opacity = opacity.clamp(0.0, 1.0);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              height: 6,
              width: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade500.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}