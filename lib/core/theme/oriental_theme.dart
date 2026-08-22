import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrientalTheme {
  // ══════════════════════════════════════════════
  // BACKGAMMON PLUS & ARABIAN GAME HOUSE THEME
  // ══════════════════════════════════════════════
  static const Color bgDark = Color(0xFF0B061A);       // Deep space purple-black
  static const Color bgCard = Color(0xFF1D0E38);       // Dark purple tile
  static const Color bgElevated = Color(0xFF2C164F);   // Elevated container

  // Backgammon Plus Cream Dialog & Card Colors
  static const Color cardCreamBg = Color(0xFFFFF8EA);   // Cream ivory card background
  static const Color cardCreamInner = Color(0xFFFFF2DC); // Inner light cream
  static const Color cardBorderGold = Color(0xFFE5A93B); // Golden border line

  // Gold Tokens
  static const Color primaryGold = Color(0xFFFFD700);   // Glistening royal gold
  static const Color goldLight = Color(0xFFFFF59D);     // Pale gold highlight
  static const Color goldDark = Color(0xFFC59B27);      // Antique gold
  static const Color goldBorder = Color(0xFFFFE082);    // Card frame gold

  // Accents & Buttons
  static const Color vibrantGreen = Color(0xFF10C044);  // Backgammon Plus ACCEPT / PLAY NOW green
  static const Color magentaHeader = Color(0xFFD81B60);  // Store banner magenta
  static const Color facebookBlue = Color(0xFF1877F2);   // Facebook button blue
  static const Color emailMagenta = Color(0xFFD81B60);   // Email button magenta
  static const Color guestDark = Color(0xFF2B2D42);      // Guest pill button dark

  // Standard Accents
  static const Color primaryRed = Color(0xFFD32F2F);    
  static const Color accentOrange = Color(0xFFFF6D00);  
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentEmerald = Color(0xFF00E676);
  static const Color accentRuby = Color(0xFFD32F2F);
  static const Color accentCyan = Color(0xFF00F2FE);    
  static const Color accentPurple = Color(0xFF9D4EDD);  

  // Text Colors
  static const Color textLight = Color(0xFFFFFDF7);     // Warm ivory text
  static const Color textDark = Color(0xFF2A1C08);      // Dark brownish text for cream cards
  static const Color textMuted = Color(0xFFB0A2C3);     // Muted lavender
  static const Color textGold = Color(0xFFFFECB3);      // Gold text

  // ── Gradients ──────────────────────────────────
  static const LinearGradient spaceCosmicGradient = LinearGradient(
    colors: [
      Color(0xFF080314),
      Color(0xFF14082D),
      Color(0xFF240A42),
      Color(0xFF160630),
      Color(0xFF070211),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient vibrantGreenGradient = LinearGradient(
    colors: [
      Color(0xFF45F973),
      Color(0xFF10C044),
      Color(0xFF067827),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient magentaHeaderGradient = LinearGradient(
    colors: [
      Color(0xFFEC407A),
      Color(0xFFD81B60),
      Color(0xFF880E4F),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gold3DGradient = LinearGradient(
    colors: [
      Color(0xFFFFF9C4),
      Color(0xFFFFD700),
      Color(0xFFFFB300),
      Color(0xFFB78103),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldCardGradient = LinearGradient(
    colors: [Color(0xFFFFF59D), Color(0xFFFFD700), Color(0xFFB78103)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient playNowGradient = vibrantGreenGradient;

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
