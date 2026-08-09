import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrientalTheme {
  // ══════════════════════════════════════════════
  // ROYAL LOUNGE DECK — Luxury Casino Colors
  // ══════════════════════════════════════════════
  static const Color bgDark = Color(0xFF0F081D);       // Midnight lounge purple-black
  static const Color bgCard = Color(0xFF1C0D2E);        // Dark velvet purple tile
  static const Color bgElevated = Color(0xFF2D1645);    // Elevated lounge container

  // Gold Tokens
  static const Color primaryGold = Color(0xFFFFD700);   // Glistening royal gold
  static const Color goldLight = Color(0xFFFFF59D);      // Pale gold highlight
  static const Color goldDark = Color(0xFFC59B27);       // Antique gold
  static const Color goldBorder = Color(0xFFFFE082);     // Card frame gold

  // Accents
  static const Color primaryRed = Color(0xFFD32F2F);    // Casino red
  static const Color redLight = Color(0xFFEF5350);       // Felt red
  static const Color accentOrange = Color(0xFFFF6D00);  // Store button orange
  static const Color accentGreen = Color(0xFF00E676);   // 'New' badge green
  static const Color accentEmerald = Color(0xFF00E676); // Emerald
  static const Color accentRuby = Color(0xFFD32F2F);    // Ruby
  static const Color accentCyan = Color(0xFF00F2FE);    // Electric cyan
  static const Color accentPurple = Color(0xFF9D4EDD);  // Velvet purple

  // Text Colors
  static const Color textLight = Color(0xFFFFFDF7);     // Warm ivory text
  static const Color textMuted = Color(0xFFB0A2C3);     // Muted lavender
  static const Color textGold = Color(0xFFFFECB3);      // Gold text

  // ── Gradients ──────────────────────────────────
  static const LinearGradient goldCardGradient = LinearGradient(
    colors: [Color(0xFFFFF59D), Color(0xFFFFD700), Color(0xFFB78103)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient loungeSkyGradient = LinearGradient(
    colors: [
      Color(0xFF0A041A),
      Color(0xFF1A0A3A),
      Color(0xFF3B1560),
      Color(0xFF5E1B68),
      Color(0xFF8B2B64),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient playNowGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF6D00), Color(0xFFD84315)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient storeBtnGradient = LinearGradient(
    colors: [Color(0xFFFF9100), Color(0xFFFF3D00)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Theme Data ─────────────────────────────────
  static ThemeData get themeData {
    final baseTextTheme = GoogleFonts.cairoTextTheme();
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryGold,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: primaryRed,
        surface: bgCard,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.bold, color: textLight),
        titleLarge: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: textGold),
        titleMedium: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600, color: textLight),
        bodyLarge: GoogleFonts.cairo(fontSize: 16, color: textLight),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, color: textMuted),
      ),
    );
  }
}

class CasinoPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  const CasinoPatternPainter({
    this.color = OrientalTheme.primaryGold,
    this.opacity = 0.02,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    const double step = 50.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        final path = Path()
          ..moveTo(x, y - 8)
          ..lineTo(x + 5, y)
          ..lineTo(x, y + 8)
          ..lineTo(x - 5, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

typedef ArabianPatternPainter = CasinoPatternPainter;
