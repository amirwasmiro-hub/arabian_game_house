import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/game_user_provider.dart';
import '../../../core/audio/sound_manager.dart';

class MegaWinDialog extends StatelessWidget {
  final int prizeCoins;
  final String gameName;
  final VoidCallback? onDismiss;

  const MegaWinDialog({
    super.key,
    required this.prizeCoins,
    required this.gameName,
    this.onDismiss,
  });

  static void show(
    BuildContext context, {
    required int prizeCoins,
    required String gameName,
    VoidCallback? onDismiss,
  }) {
    SoundManager().playVictorySound();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MegaWinDialog(
        prizeCoins: prizeCoins,
        gameName: gameName,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
        child: Container(
          width: 440.w,
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.0,
              colors: [Color(0xFF5A1028), Color(0xFF23030F), Color(0xFF0F0107)],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: const Color(0xFFFFD700),
              width: 2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                blurRadius: 30.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy Icon with Glowing Animation
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF6F00)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                      blurRadius: 20.r,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: const Color(0xFF3E2723),
                  size: 36.r,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(duration: 800.ms, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1))
                  .rotate(duration: 3000.ms, begin: -0.05, end: 0.05),

              SizedBox(height: 10.h),

              // Title
              Text(
                '🎉 فـــوز ســـاحـــق 🎉',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFD700),
                  shadows: [
                    Shadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                      blurRadius: 12.r,
                    ),
                  ],
                ),
              ),

              Text(
                'مبروك! لقد اكتسحت طاولة $gameName',
                style: GoogleFonts.cairo(
                  fontSize: 8.5.sp,
                  color: Colors.white70,
                ),
              ),

              SizedBox(height: 12.h),

              // Prize Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 1.2.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: const Color(0xFFFFD700),
                      size: 20.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '+${_formatNumber(prizeCoins)} كوينز',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),

              SizedBox(height: 16.h),

              // Collect Button
              GestureDetector(
                onTap: () {
                  final provider = Provider.of<GameUserProvider>(context, listen: false);
                  provider.recordWin(prizeCoins);
                  Navigator.pop(context);
                  onDismiss?.call();
                },
                child: Container(
                  width: 180.w,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                        blurRadius: 12.r,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'استلام الجائزة 🪙',
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF3E2723),
                      ),
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(duration: 900.ms, begin: const Offset(0.98, 0.98), end: const Offset(1.03, 1.03)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
