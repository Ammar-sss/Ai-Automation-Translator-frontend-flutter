import 'package:flutter/material.dart';

class RadioWaveDot extends StatefulWidget {
  const RadioWaveDot({
    super.key,
    this.color = const Color(0xFF4AE183),
    this.size = 6.0,
    this.duration = const Duration(milliseconds: 1500), // Speed of 1 wave cycle
    this.maxScale = 3.2,                                 // How big the wave expands
  });

  final Color color;
  final double size;
  final Duration duration;
  final double maxScale;

  @override
  State<RadioWaveDot> createState() => _RadioWaveDotState();
}

class _RadioWaveDotState extends State<RadioWaveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Loops infinitely from 0.0 to 1.0
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value; // Goes from 0.0 -> 1.0

        // 1. Scale grows from 1.0 up to maxScale (e.g. 3.2x)
        final currentScale = 1.0 + (progress * (widget.maxScale - 1.0));

        // 2. Opacity fades out from 1.0 down to 0.0 (disappears!)
        final currentOpacity = (1.0 - progress).clamp(0.0, 1.0);

        return Stack(
          alignment: Alignment.center,
          children: [
            // --- Radio Wave Ring (Expands & Fades Out) ---
            Transform.scale(
              scale: currentScale,
              child: Opacity(
                opacity: currentOpacity,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // --- Solid Center Dot ---
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}