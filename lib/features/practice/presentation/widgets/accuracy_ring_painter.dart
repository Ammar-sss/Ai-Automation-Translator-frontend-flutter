import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Gradient arc with a soft glow and round end caps.
class AccuracyRingPainter extends CustomPainter {
  final double progress;
  final Color track;
  final Color start;
  final Color end;
  final double strokeWidth;

  const AccuracyRingPainter({
    required this.progress,
    required this.track,
    required this.start,
    required this.end,
  }) : strokeWidth = 14;

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = -math.pi / 2;
    final arcRect = (Offset.zero & size).deflate(strokeWidth / 2 + 6);
    final center = arcRect.center;
    final radius = arcRect.width / 2;
    final value = math.max(0.0, math.min(1.0, progress));
    final sweep = 2 * math.pi * value;

    canvas.drawArc(
      arcRect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = track,
    );

    if (sweep < 0.001) return;

    // Soft glow under the arc
    canvas.drawArc(
      arcRect,
      startAngle,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = start.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    final shader = SweepGradient(
      startAngle: 0,
      endAngle: sweep,
      colors: [start, end],
      transform: const GradientRotation(startAngle),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      arcRect,
      startAngle,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader = shader,
    );

    // Round caps drawn by hand so each end keeps its own gradient color
    Offset pointAt(double angle) => Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    canvas.drawCircle(
      pointAt(startAngle),
      strokeWidth / 2,
      Paint()..color = start,
    );
    canvas.drawCircle(
      pointAt(startAngle + sweep),
      strokeWidth / 2,
      Paint()..color = end,
    );
  }

  @override
  bool shouldRepaint(AccuracyRingPainter old) =>
      old.progress != progress ||
      old.track != track ||
      old.start != start ||
      old.end != end ||
      old.strokeWidth != strokeWidth;
}
