import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrientalTheme {
  // AAA Modern Gaming Color Palette - Cyber Slate & Neon Luxe
  static const Color bgDark = Color(0xFF090C15); // Ultra-dark obsidian
  static const Color bgCard = Color(0xFF131826); // Cyber glassmorphism card
  static const Color bgElevated = Color(0xFF1C2336); // Elevated surface

  static const Color primaryGold = Color(0xFFFFD700); // Cyber Gold
  static const Color goldLight = Color(0xFFFFF1A8);
  static const Color goldDark = Color(0xFFC99700);

  // Modern Neon Accents
  static const Color accentCyan = Color(0xFF00F2FE); // Electric Cyan
  static const Color accentPurple = Color(0xFF9D4EDD); // Neon Purple
  static const Color accentEmerald = Color(0xFF00E676); // Neon Emerald
  static const Color accentRuby = Color(0xFFFF2A6D); // Cyber Ruby/Magenta
  static const Color accentAmber = Color(0xFFFF9E00); // Electric Amber
  static const Color accentSapphire = Color(0xFF0077FF); // Cobalt Blue

  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textGold = Color(0xFFFFE57F);

  // Futuristic Modern Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, primaryGold, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [accentPurple, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00796B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient rubyGradient = LinearGradient(
    colors: [accentRuby, Color(0xFF7B1FA2)],
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
        secondary: accentCyan,
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

/// Custom painter for rendering modern gaming tech hex/grid backgrounds
class ArabianPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  ArabianPatternPainter({
    this.color = OrientalTheme.accentCyan,
    this.opacity = 0.04,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double step = 50.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawHexagon(canvas, Offset(x, y), 18.0, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = i * math.pi / 3;
      double px = center.dx + radius * math.cos(angle);
      double py = center.dy + radius * math.sin(angle);
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
