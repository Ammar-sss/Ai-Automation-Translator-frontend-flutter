import 'package:flutter/material.dart';

class RadioWaveDot extends StatefulWidget {
  const RadioWaveDot({
    super.key,
    this.color = const Color(0xFF4AE183),
    this.size = 6.0,
    this.duration = const Duration(milliseconds: 1800),
    this.maxScale = 2.6,
    this.ringCount = 2,
  });

  final Color color;
  final double size;
  final Duration duration;
  final double maxScale;
  final int ringCount;

  @override
  State<RadioWaveDot> createState() => _RadioWaveDotState();
}

class _RadioWaveDotState extends State<RadioWaveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Widget _cachedCenterDot;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
    _updateCachedCenterDot();
  }

  void _updateCachedCenterDot() {
    _cachedCenterDot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color,
        boxShadow: [
          BoxShadow(color: widget.color.withValues(alpha: 0.6), blurRadius: 4),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(RadioWaveDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.size != oldWidget.size || widget.color != oldWidget.color) {
      _updateCachedCenterDot();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringCount = widget.ringCount.clamp(1, 4);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < ringCount; i++)
              _buildWaveRing(progress, offset: i / ringCount),
            _cachedCenterDot,
          ],
        );
      },
      child: _cachedCenterDot,
    );
  }

  Widget _buildWaveRing(double overallProgress, {required double offset}) {
    final waveProgress = (overallProgress + offset) % 1.0;
    final scale =
        1.0 +
        (Curves.easeOut.transform(waveProgress) * (widget.maxScale - 1.0));
    final opacity = (1.0 - waveProgress).clamp(0.0, 1.0);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: 0.8),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
