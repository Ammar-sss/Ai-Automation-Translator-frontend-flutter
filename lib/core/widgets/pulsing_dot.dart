import 'package:material_ui/material_ui.dart';

class PulsingDot extends StatefulWidget {
  const PulsingDot({
    super.key,
    this.color = const Color(0xFF4AE183),
    this.size = 6.0,
    this.curve = Curves.easeInOutSine,
    this.duration = const Duration(milliseconds: 1200),
    this.minSize = 0.8,
    this.maxSize = 1.35,
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
  late Widget _cachedDot;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _updateAnimation();
    _updateCachedDot();
  }

  void _updateAnimation() {
    _animation = Tween<double>(
      begin: widget.minSize,
      end: widget.maxSize,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  void _updateCachedDot() {
    _cachedDot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color,
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.6),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.size != oldWidget.size || widget.color != oldWidget.color) {
      _updateCachedDot();
    }
    if (widget.minSize != oldWidget.minSize ||
        widget.maxSize != oldWidget.maxSize ||
        widget.curve != oldWidget.curve) {
      _updateAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: _cachedDot);
  }
}
