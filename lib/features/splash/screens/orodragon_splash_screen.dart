import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrodragonSplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OrodragonSplashScreen({
    super.key,
    required this.onFinish,
  });

  @override
  State<OrodragonSplashScreen> createState() => _OrodragonSplashScreenState();
}

class _OrodragonSplashScreenState extends State<OrodragonSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onFinish();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dragon Circular Emblem
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20.r,
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // ORODRAGON Text
              Text(
                'ORODRAGON',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.w,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
