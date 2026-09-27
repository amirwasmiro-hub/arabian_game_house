import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GamingMastersSplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const GamingMastersSplashScreen({
    super.key,
    required this.onFinish,
  });

  @override
  State<GamingMastersSplashScreen> createState() =>
      _GamingMastersSplashScreenState();
}

class _GamingMastersSplashScreenState extends State<GamingMastersSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _completeTimer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _completeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onFinish();
      }
    });
  }

  @override
  void dispose() {
    _completeTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _skip() {
    _completeTimer?.cancel();
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _skip, // Allow tapping anywhere to skip directly
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full-Screen Artwork (بملء الشاشة بالكامل)
            Positioned.fill(
              child: Image.asset(
                'assets/images/gaming_masters_splash.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // 3. Subtle Animated Neon Loading Bar at the Bottom
            Positioned(
              bottom: 12.h,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing Loading Bar
                    Container(
                      width: 220.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.35),
                          width: 0.8.w,
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 220.w * _progressController.value,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF9100),
                                    Color(0xFFFFD700),
                                    Color(0xFFFFF9C4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700)
                                        .withValues(alpha: 0.8),
                                    blurRadius: 8.r,
                                    spreadRadius: 1.r,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
