import 'package:flutter/material.dart';
import 'package:smart_translator/features/onboarding/utils/pulsing_dot.dart';
import 'package:smart_translator/features/onboarding/utils/radio_wave_dot.dart';

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.illustrationType,
  });

  final String title;
  final String subtitle;
  final String description;
  final OnboardingIllustrationType illustrationType;
}

enum OnboardingIllustrationType { translate, sync, flashcard }

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({super.key, required this.data});

  final OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Illustration Hero
          Expanded(
            flex: 5,
            child: Center(child: _buildIllustration(data.illustrationType)),
          ),
          const SizedBox(height: 24),
          // Text Content
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  data.subtitle.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFAB8981),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(OnboardingIllustrationType type) {
    switch (type) {
      case OnboardingIllustrationType.translate:
        return _buildTranslateIllustration();
      case OnboardingIllustrationType.sync:
        return _buildSyncIllustration();
      case OnboardingIllustrationType.flashcard:
        return _buildFlashcardIllustration();
    }
  }

  Widget _buildTranslateIllustration() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient orange diffusion glow
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF5A2C).withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5A2C).withValues(alpha: 0.25),
                  blurRadius: 50,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),

          // Outermost dark concentric ring disc
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF181922).withValues(alpha: 0.6),
            ),
          ),

          // Mid concentric ring disc
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF21222D).withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          // Inner concentric ring disc
          Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF181922),
            ),
          ),

          // Overlapping geometric circles + horizontal axis
          CustomPaint(
            size: const Size(200, 200),
            painter: _NeuralCorePainter(),
          ),

          // Glowing Orange Neural Core
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF5A2C),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5A2C).withValues(alpha: 0.7),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
              border: Border.all(color: const Color(0xFFFF7A54), width: 2),
            ),
            child: Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE04218),
                ),
                child: const Center(
                  child: Icon(
                    Icons.g_translate_rounded,
                    color: Color(0xFF3B0800),
                    size: 38,
                  ),
                ),
              ),
            ),
          ),

          // Top-Right Orbit Dot Accent
          Positioned(
            top: 36,
            right: 50,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF5A2C),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5A2C).withValues(alpha: 0.8),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Bottom-Left Orbit Dot Accent
          Positioned(
            bottom: 48,
            left: 42,
            child: PulsingDot(
              color: Colors.yellow,
              size: 5,
              curve: Curves.bounceInOut,
            ),
          ),

          // Top-Left Badge: "● Neural Engine"
          Positioned(
            top: 28,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF252632).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  PulsingDot(color: Color(0xFF4AE183)),
                  SizedBox(width: 6),
                  Text(
                    'Neural Engine',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom-Right Badge: "⚡ 98+ Langs"
          Positioned(
            bottom: 24,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF252632).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.bolt_rounded, color: Color(0xFFFFBD58), size: 15),
                  SizedBox(width: 4),
                  Text(
                    '98+ Langs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncIllustration() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient orange diffusion glow
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF5A2C).withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5A2C).withValues(alpha: 0.25),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),

          // Orbital lines painter (dashed outer ring + tilted ellipses + connecting lines + nodes)
          CustomPaint(size: const Size(280, 280), painter: _SyncOrbitPainter()),

          // Central Kinetic Dark Disc Core
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E1F2A),
              border: Border.all(color: const Color(0xFF333440), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFFFF5A2C).withValues(alpha: 0.25),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.cloud_sync_rounded,
                color: Color(0xFFFF5A2C),
                size: 42,
              ),
            ),
          ),

          // "● SYNC" green tag badge anchored at top edge of the central disc
          Positioned(
            top: 73,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF282935).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF333440), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  RadioWaveDot(color: Color(0xFF4AE183)),
                  SizedBox(width: 6),
                  Text(
                    'SYNC',
                    style: TextStyle(
                      color: Color(0xFF4AE183),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top-Left Badge: "📖 324 terms" (slightly tilted)
          Positioned(
            top: 24,
            left: 12,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF282935).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.auto_stories_rounded,
                      color: Color(0xFFFFBD58),
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '324 terms',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom-Right Badge: "📱 3 devices" (slightly tilted)
          Positioned(
            bottom: 24,
            right: 12,
            child: Transform.rotate(
              angle: 0.05,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF282935).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.devices_rounded,
                      color: Color(0xFFFF5A2C),
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '3 devices',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardIllustration() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient orange diffusion glow
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF5A2C).withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5A2C).withValues(alpha: 0.3),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),

          // Stacked Back Card 2 (Deepest layer, tilted left)
          Transform.translate(
            offset: const Offset(-12, 12),
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: 210,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF14151E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stacked Back Card 1 (Mid layer, tilted right)
          Transform.translate(
            offset: const Offset(10, 4),
            child: Transform.rotate(
              angle: 0.08,
              child: Container(
                width: 220,
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1D27),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Foreground Active Hero Card
          Container(
            width: 236,
            height: 272,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF252632),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFFFF5A2C).withValues(alpha: 0.25),
                  blurRadius: 20,
                ),
              ],
              border: Border.all(
                color: const Color(0xFFFF5A2C).withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Card Header (SR 98% badge + Speaker icon button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1B24),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFFFF5A2C),
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'SR • 98%',
                            style: TextStyle(
                              color: Color(0xFFFF5A2C),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A1B24),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
                  ],
                ),

                // Card Main Content (Fernweh)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Fernweh',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '/ˈfɛʁnveː/ • noun',
                      style: TextStyle(
                        color: Color(0xFFAB8981),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '"An ache to travel, longing for distant places."',
                      style: TextStyle(
                        color: Color(0xFFE4BEB5),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),

                // Card Footer (Interval retention + Mastered progress)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'INTERVAL RETENTION',
                          style: TextStyle(
                            color: Color(0xFFAB8981),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Mastered',
                          style: TextStyle(
                            color: Color(0xFF4AE183),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.84,
                        backgroundColor: const Color(0xFF14151E),
                        color: const Color(0xFFFF5A2C),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top-Right Orbit Sparkle Badge ✨
          Positioned(
            top: 6,
            right: 8,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF282935),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF333440)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFF5A2C),
                size: 16,
              ),
            ),
          ),

          // Bottom-Left Orbit Clock Badge 🕒
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF282935),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF333440)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.schedule_rounded,
                color: Color(0xFF4AE183),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeuralCorePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Horizontal Axis Line
    final axisPaint = Paint()
      ..color = const Color(0xFFFF5A2C).withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx - 65, center.dy),
      Offset(center.dx + 65, center.dy),
      axisPaint,
    );

    // Left Dashed Circle
    final dashedPaint = Paint()
      ..color = const Color(0xFFFF5A2C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final leftCenter = Offset(center.dx - 22, center.dy);
    const radius = 48.0;
    const double dashWidth = 6;
    const double dashSpace = 4;
    double startAngle = 0;
    while (startAngle < 2 * 3.1415926535) {
      canvas.drawArc(
        Rect.fromCircle(center: leftCenter, radius: radius),
        startAngle,
        dashWidth / radius,
        false,
        dashedPaint,
      );
      startAngle += (dashWidth + dashSpace) / radius;
    }

    // Right Solid Gold Circle
    final solidPaint = Paint()
      ..color = const Color(0xFFFFBD58).withValues(alpha: 0.85)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rightCenter = Offset(center.dx + 22, center.dy);
    canvas.drawCircle(rightCenter, radius, solidPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SyncOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Outer Dashed Orbit Circle
    final dashedCirclePaint = Paint()
      ..color = const Color(0xFF3B3C4A).withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const outerRadius = 115.0;
    const double dashWidth = 4;
    const double dashSpace = 6;
    double startAngle = 0;
    while (startAngle < 2 * 3.1415926535) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        dashWidth / outerRadius,
        false,
        dashedCirclePaint,
      );
      startAngle += (dashWidth + dashSpace) / outerRadius;
    }

    // 2. Tilted Ellipse 1 (Orange orbit)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.4);
    final ellipsePaint1 = Paint()
      ..color = const Color(0xFFFF5A2C).withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 220, height: 100),
      ellipsePaint1,
    );
    canvas.restore();

    // 3. Tilted Ellipse 2 (Dark orbit)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.35);
    final ellipsePaint2 = Paint()
      ..color = const Color(0xFF4A4B5A).withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 230, height: 90),
      ellipsePaint2,
    );
    canvas.restore();

    // 4. Connecting Lines from Center to Nodes
    final linePaint = Paint()
      ..color = const Color(0xFFFF5A2C).withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final node1 = Offset(center.dx - 65, center.dy - 45);
    final node2 = Offset(center.dx + 65, center.dy - 25);
    final node3 = Offset(center.dx - 48, center.dy + 50);
    final node4 = Offset(center.dx + 42, center.dy + 56);

    canvas.drawLine(center, node1, linePaint);
    canvas.drawLine(center, node2, linePaint);
    canvas.drawLine(center, node3, linePaint);
    canvas.drawLine(center, node4, linePaint);

    // 5. Draw Glowing Nodes
    _drawGlowingNode(canvas, node1, const Color(0xFFFF8A65), 5);
    _drawGlowingNode(canvas, node2, const Color(0xFFFF5A2C), 6);
    _drawGlowingNode(canvas, node3, const Color(0xFFFF7A54), 5);
    _drawGlowingNode(canvas, node4, const Color(0xFFFFBD58), 5);
  }

  void _drawGlowingNode(Canvas canvas, Offset pos, Color color, double radius) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(pos, radius * 2.5, glowPaint);

    final corePaint = Paint()..color = color;
    canvas.drawCircle(pos, radius, corePaint);

    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(pos, radius * 0.4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
