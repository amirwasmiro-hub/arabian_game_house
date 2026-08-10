import 'dart:math' as math;
import 'package:flutter/material.dart';

class PenthouseLoungePainter extends CustomPainter {
  const PenthouseLoungePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Purple Sunset & Night City Sky Gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF2E0847), // Deep purple top sky
          Color(0xFF53116B),
          Color(0xFF8B2B79),
          Color(0xFFB54C75), // Orange-pink sunset glow at horizon
          Color(0xFF4A1249),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Distant City Skyline Lights
    final cityPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.15);

    final random = math.Random(123);
    for (double x = 0; x < size.width; x += 15) {
      final h = random.nextDouble() * 40 + 20;
      canvas.drawRect(
        Rect.fromLTWH(x, size.height * 0.45 - h, 10, h),
        cityPaint,
      );
    }

    // 3. Curved Golden Arch Window Frames
    final archPaint = Paint()
      ..color = const Color(0xFFC59A3F).withValues(alpha: 0.4)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final pathArch = Path()
      ..moveTo(size.width * 0.15, size.height * 0.1)
      ..cubicTo(
        size.width * 0.35, size.height * 0.02,
        size.width * 0.65, size.height * 0.02,
        size.width * 0.85, size.height * 0.1,
      );

    canvas.drawPath(pathArch, archPaint);

    // Golden Railing Vertical Bars
    for (double x = size.width * 0.15; x <= size.width * 0.85; x += 35) {
      canvas.drawLine(
        Offset(x, size.height * 0.05),
        Offset(x, size.height * 0.55),
        archPaint,
      );
    }

    // Horizontal Railing Support Bars
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.85, size.height * 0.25),
      archPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.45),
      Offset(size.width * 0.85, size.height * 0.45),
      archPaint,
    );

    // 4. Mahogany Deck Floor Base Gradient
    final floorPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF5A2510), // Rich warm mahogany wood
          Color(0xFF3B1508),
          Color(0xFF220B04),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5));

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
      floorPaint,
    );

    // Wooden Floor Planks Lines
    final plankPaint = Paint()
      ..color = const Color(0xFF190602).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    for (double y = size.height * 0.5; y < size.height; y += 25) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        plankPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
