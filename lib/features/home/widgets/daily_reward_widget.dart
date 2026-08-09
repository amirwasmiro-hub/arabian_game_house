import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/oriental_theme.dart';
import '../../../core/audio/sound_manager.dart';

class DailyRewardWidget extends StatefulWidget {
  const DailyRewardWidget({super.key});

  @override
  State<DailyRewardWidget> createState() => _DailyRewardWidgetState();
}

class _DailyRewardWidgetState extends State<DailyRewardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _claimed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _claimReward() {
    if (_claimed) return;
    SoundManager().playWinFanfare();
    setState(() => _claimed = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: OrientalTheme.bgCard,
        content: Text(
          'مبروك! حصلت على 5,000 ذهبية 🪙 وهدية السلطان اليومية!',
          style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12.sp),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                OrientalTheme.bgCard,
                OrientalTheme.bgElevated,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: OrientalTheme.primaryGold.withValues(alpha: 0.4 + (_animController.value * 0.4)),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: OrientalTheme.primaryGold.withValues(alpha: 0.15 * _animController.value),
                blurRadius: 10.r,
                spreadRadius: 1.r,
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: OrientalTheme.primaryGold.withValues(alpha: 0.15),
                ),
                child: Icon(Icons.card_giftcard, color: OrientalTheme.primaryGold, size: 24.r),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'صندوق السلطان اليومي 🎁',
                      style: GoogleFonts.cairo(
                        color: OrientalTheme.primaryGold,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _claimed ? 'تم استلام المكافأة!' : '5,000 ذهبية مجاناً',
                      style: GoogleFonts.cairo(
                        color: OrientalTheme.textMuted,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _claimed ? Colors.grey.shade800 : OrientalTheme.primaryGold,
                  foregroundColor: _claimed ? Colors.white54 : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                ),
                onPressed: _claimReward,
                child: Text(
                  _claimed ? 'تم' : 'استلم',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 10.sp),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
