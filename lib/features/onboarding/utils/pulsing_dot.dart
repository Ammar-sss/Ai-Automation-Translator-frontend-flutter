import 'package:flutter/material.dart';

class PulsingDot extends StatefulWidget {
  const PulsingDot({
    super.key,
    this.color = const Color(0xFF4AE183),
    this.size = 6.0,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 1000),
    this.minSize = 0.8,
    this.maxSize = 1.4,
  });

  final Color color;
  final double size;
  final Curve curve;
  final Duration duration;
  final double minSize;
  final double maxSize;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minSize,
      end: widget.maxSize,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: [
            BoxShadow(color: widget.color.withValues(alpha: 0.7), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}
