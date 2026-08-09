import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom Painter for rendering the Royal Casino Lounge Deck background:
/// - Starry night sky with dusk gradient.
/// - City skyline silhouette with glowing windows.
/// - Golden panoramic archway framing the view.
/// - Mahogany wood deck floor & leather lounge atmosphere.
class LoungeBackgroundPainter extends CustomPainter {
  const LoungeBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky Gradient (Deep Night Blue to Dusk Purple/Magenta)
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF090414),
          Color(0xFF14082B),
          Color(0xFF2B0E4E),
          Color(0xFF4A125E),
          Color(0xFF751E69),
          Color(0xFF9E2C68),
        ],
        stops: [0.0, 0.25, 0.50, 0.70, 0.85, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // 2. Stars in the upper sky
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    final rng = math.Random(123);
    for (int i = 0; i < 60; i++) {
      final sx = rng.nextDouble() * size.width;
      final sy = rng.nextDouble() * (size.height * 0.45);
      final r = 0.5 + rng.nextDouble() * 1.2;
      canvas.drawCircle(Offset(sx, sy), r, starPaint);
    }

    // 3. City Skyline Silhouette & Glowing Lights (Horizon at 55% height)
    final horizonY = size.height * 0.55;
    final skylinePaint = Paint()..color = const Color(0xFF1A0A2E).withValues(alpha: 0.85);

    final path = Path()..moveTo(0, horizonY);
    double curX = 0;
    while (curX < size.width) {
      final w = 15.0 + rng.nextDouble() * 30.0;
      final h = 30.0 + rng.nextDouble() * 80.0;
      path.lineTo(curX, horizonY - h);
      path.lineTo(curX + w, horizonY - h);
      curX += w;
    }
    path.lineTo(size.width, horizonY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, skylinePaint);

    // Skyline Horizon Glow Line
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFF9E00).withValues(alpha: 0.35),
          const Color(0xFFFF2A6D).withValues(alpha: 0.35),
          const Color(0xFF00F2FE).withValues(alpha: 0.35),
        ],
      ).createShader(Rect.fromLTWH(0, horizonY - 10, size.width, 20));
    canvas.drawRect(Rect.fromLTWH(0, horizonY - 2, size.width, 4), glowPaint);

    // 4. Balcony Railing & Deck Floor (Bottom 30%)
    final deckY = size.height * 0.70;

    // Wood Floor Gradient
    final floorPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF5A2508),
          Color(0xFF3D1603),
          Color(0xFF260D01),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, deckY, size.width, size.height - deckY));
    canvas.drawRect(Rect.fromLTWH(0, deckY, size.width, size.height - deckY), floorPaint);

    // Balcony Railing Line
    final railPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.6)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, deckY), Offset(size.width, deckY), railPaint);

    // Vertical Railing Posts
    final postPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    for (double px = 20; px < size.width; px += 45) {
      canvas.drawLine(Offset(px, deckY), Offset(px, deckY + 25), postPaint);
    }

    // 5. Golden Panoramic Archway Framing the View
    final archBorderPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.5)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final archPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.25)
      ..cubicTo(
        size.width * 0.25, -20,
        size.width * 0.75, -20,
        size.width, size.height * 0.25,
      )
      ..lineTo(size.width, size.height);

    canvas.drawPath(archPath, archBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
