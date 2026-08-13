import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/effects_game.dart';

class EffectsControlPanel extends StatelessWidget {
  final ExplosionType currentType;
  final ValueChanged<ExplosionType> onTypeChanged;
  final int particleCount;
  final ValueChanged<int> onParticleCountChanged;
  final bool isGlowEnabled;
  final ValueChanged<bool> onGlowToggle;
  final VoidCallback onClear;

  const EffectsControlPanel({
    super.key,
    required this.currentType,
    required this.onTypeChanged,
    required this.particleCount,
    required this.onParticleCountChanged,
    required this.isGlowEnabled,
    required this.onGlowToggle,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xEC1A0D26),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66FFD700),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selector for Explosion Type
          Row(
            children: [
              _buildTypeChip(
                context,
                type: ExplosionType.gold,
                label: 'ذهبي 🌟',
                color: const Color(0xFFFFD700),
              ),
              SizedBox(width: 8.w),
              _buildTypeChip(
                context,
                type: ExplosionType.fire,
                label: 'ناري 🔥',
                color: const Color(0xFFFF4500),
              ),
              SizedBox(width: 8.w),
              _buildTypeChip(
                context,
                type: ExplosionType.magic,
                label: 'سحري 🔮',
                color: const Color(0xFFE040FB),
              ),
              SizedBox(width: 8.w),
              _buildTypeChip(
                context,
                type: ExplosionType.stars,
                label: 'نجوم ✨',
                color: const Color(0xFF00E676),
              ),
            ],
          ),

          SizedBox(width: 16.w),
          Container(width: 1, height: 28.h, color: Colors.white24),
          SizedBox(width: 16.w),

          // Particle Slider
          Row(
            children: [
              Text(
                'الجسيمات: $particleCount',
                style: GoogleFonts.cairo(
                  color: Colors.amberAccent,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6.w),
              SizedBox(
                width: 110.w,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4.h,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                  ),
                  child: Slider(
                    value: particleCount.toDouble(),
                    min: 15,
                    max: 120,
                    activeColor: const Color(0xFFFFD700),
                    inactiveColor: Colors.white24,
                    onChanged: (val) => onParticleCountChanged(val.round()),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: 16.w),
          Container(width: 1, height: 28.h, color: Colors.white24),
          SizedBox(width: 16.w),

          // Glow Toggle Button
          InkWell(
            onTap: () => onGlowToggle(!isGlowEnabled),
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isGlowEnabled
                    ? const Color(0x33FFD700)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isGlowEnabled
                      ? const Color(0xFFFFD700)
                      : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.blur_on_rounded,
                    size: 16.sp,
                    color: isGlowEnabled ? Colors.amber : Colors.grey,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'توهج Blur',
                    style: GoogleFonts.cairo(
                      color: isGlowEnabled ? Colors.amber : Colors.grey,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    BuildContext context, {
    required ExplosionType type,
    required String label,
    required Color color,
  }) {
    final isSelected = currentType == type;

    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? color : Colors.white70,
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
