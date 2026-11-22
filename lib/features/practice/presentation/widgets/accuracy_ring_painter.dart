import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class AccuracyRingPainter extends CustomPainter {
  final double progress;
  final Color track;
  final Color start;
  final Color end;

  const AccuracyRingPainter({
    required this.progress,
    required this.track,
    required this.start,
    required this.end,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      arc,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: [start, end],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(rect);

    canvas.drawArc(
      arc,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = start.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawArc(
      arc,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = gradient,
    );
  }

  @override
  bool shouldRepaint(AccuracyRingPainter old) =>
      old.progress != progress ||
      old.track != track ||
      old.start != start ||
      old.end != end;
}
