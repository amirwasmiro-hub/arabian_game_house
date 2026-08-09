import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrientalTheme {
  // Color Palette - Imperial Arabian Game House
  static const Color bgDark = Color(0xFF06150F);
  static const Color bgCard = Color(0xFF0D251B);
  static const Color bgElevated = Color(0xFF15382B);
  
  static const Color primaryGold = Color(0xFFE5C158);
  static const Color goldLight = Color(0xFFF7E6AA);
  static const Color goldDark = Color(0xFFB58E2E);

  static const Color accentEmerald = Color(0xFF00E676);
  static const Color accentRuby = Color(0xFFE53935);
  static const Color accentSapphire = Color(0xFF1E88E5);
  static const Color accentAmber = Color(0xFFFFB300);

  static const Color textLight = Color(0xFFF4F7F5);
  static const Color textMuted = Color(0xFF90A4AE);
  static const Color textGold = Color(0xFFF1D58A);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, primaryGold, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF0F4432), Color(0xFF09291E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient rubyGradient = LinearGradient(
    colors: [Color(0xFFD32F2F), Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get themeData {
    final baseTextTheme = GoogleFonts.cairoTextTheme();
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryGold,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: accentEmerald,
        surface: bgCard,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.bold, color: textLight),
        titleLarge: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: textGold),
        titleMedium: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600, color: textLight),
        bodyLarge: GoogleFonts.cairo(fontSize: 16, color: textLight),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, color: textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGold),
      ),
    );
  }
}

/// Custom painter for rendering intricate Arabian geometric star patterns on backgrounds
class ArabianPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  ArabianPatternPainter({
    this.color = OrientalTheme.primaryGold,
    this.opacity = 0.05,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double step = 60.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawEightPointStar(canvas, Offset(x, y), 20.0, paint);
      }
    }
  }

  void _drawEightPointStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      double angle = i * math.pi / 4;
      double r = (i % 2 == 0) ? radius : radius * 0.5;
      double px = center.dx + r * math.cos(angle);
      double py = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
