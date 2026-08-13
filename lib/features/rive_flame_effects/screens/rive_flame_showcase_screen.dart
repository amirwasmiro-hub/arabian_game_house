import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart' as rive;
import '../../../core/audio/sound_manager.dart';
import '../game/effects_game.dart';
import '../widgets/effects_control_panel.dart';

class RiveFlameShowcaseScreen extends StatefulWidget {
  const RiveFlameShowcaseScreen({super.key});

  @override
  State<RiveFlameShowcaseScreen> createState() =>
      _RiveFlameShowcaseScreenState();
}

class _RiveFlameShowcaseScreenState extends State<RiveFlameShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late final ArabianEffectsGame _game;
  late final AnimationController _pulseController;

  bool _isBlurOverlayEnabled = false;
  ExplosionType _currentExplosionType = ExplosionType.gold;
  int _particleCount = 45;
  bool _isGlowEnabled = true;

  @override
  void initState() {
    super.initState();
    _game = ArabianEffectsGame();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0716),
      body: Stack(
        children: [
          // 1. Oriental Glow Background Gradient
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 0.8 + (_pulseController.value * 0.4);
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: scale,
                      colors: const [
                        Color(0xFF32124D),
                        Color(0xFF160924),
                        Color(0xFF07020B),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Decorative grid pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
          ),

          // 2. Flame Game Engine Layer (Handles Interactive Taps & Particle Systems)
          Positioned.fill(
            child: GameWidget(
              game: _game,
            ),
          ),

          // 3. Blur Layer Overlay (BackdropFilter) if toggled
          if (_isBlurOverlayEnabled)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ),
            ),

          // 4. Instructions Prompt Header
          Positioned(
            top: 75.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: Colors.amber,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'انقر في أي مكان في الشاشة لإطلاق تفجيرات الجسيمات التفاعلية!',
                      style: GoogleFonts.cairo(
                        color: Colors.amber.shade200,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. Rive Vector Animation Visual Card / Badge
          Positioned(
            bottom: 80.h,
            right: 24.w,
            child: Container(
              width: 140.w,
              height: 100.h,
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xDD1E0D2E),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44FFD700),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            color: Colors.deepPurple.shade900,
                          ),
                          // Sample Rive widget / Animation placeholder
                          const rive.RiveAnimation.network(
                            'https://cdn.rive.app/animations/vehicles.riv',
                            fit: BoxFit.contain,
                            placeHolder: Center(
                              child: CircularProgressIndicator(
                                color: Colors.amber,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'محرك Rive التفاعلي ⚡',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFFFD700),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Top Oriental Bar
          Positioned(
            top: 14.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                InkWell(
                  onTap: () {
                    SoundManager().playButtonClick();
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xDD2A143D),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.amber,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'رجوع',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Title
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xDD2A143D),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55FFD700),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: const Color(0xFFFFD700),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'مختبر التأثيرات و Rive + Flame',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFFFFD700),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Blur Overlay Toggle Switch
                InkWell(
                  onTap: () {
                    setState(() {
                      _isBlurOverlayEnabled = !_isBlurOverlayEnabled;
                    });
                  },
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: _isBlurOverlayEnabled
                          ? const Color(0xFF6A1B9A)
                          : const Color(0xDD2A143D),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isBlurOverlayEnabled
                              ? Icons.blur_on
                              : Icons.blur_off,
                          color: Colors.amber,
                          size: 18.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _isBlurOverlayEnabled ? 'تغبيش مفعّل' : 'تغبيش معطّل',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 7. Floating Bottom Controls Panel
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Center(
              child: EffectsControlPanel(
                currentType: _currentExplosionType,
                onTypeChanged: (type) {
                  setState(() {
                    _currentExplosionType = type;
                    _game.currentExplosionType = type;
                  });
                },
                particleCount: _particleCount,
                onParticleCountChanged: (count) {
                  setState(() {
                    _particleCount = count;
                    _game.explosionParticleCount = count;
                  });
                },
                isGlowEnabled: _isGlowEnabled,
                onGlowToggle: (enabled) {
                  setState(() {
                    _isGlowEnabled = enabled;
                    _game.isGlowEnabled = enabled;
                  });
                },
                onClear: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
