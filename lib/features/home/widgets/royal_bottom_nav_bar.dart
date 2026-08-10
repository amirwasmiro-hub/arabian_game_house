import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RoyalBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const RoyalBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 36.h,
        margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.black.withValues(alpha: 0.35),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            width: 1.2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10.r,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              blurRadius: 12.r,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildGlassTab(
              index: 0,
              icon: Icons.home_rounded,
              label: 'الرئيسية',
            ),
            _buildGlassTab(
              index: 1,
              icon: Icons.swap_horiz_rounded,
              label: 'الاستبدال',
            ),
            _buildGlassTab(
              index: 2,
              icon: Icons.emoji_events_rounded,
              label: 'المسابقات',
            ),
            _buildGlassTab(
              index: 3,
              icon: Icons.person_rounded,
              label: 'البروفايل',
            ),
            _buildGlassTab(
              index: 4,
              icon: Icons.settings_rounded,
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = selectedIndex == index;
    final Color activeGold = const Color(0xFFFFD700);
    final Color inactiveColor = Colors.white.withValues(alpha: 0.75);

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: isSelected
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    activeGold.withValues(alpha: 0.3),
                    activeGold.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: activeGold.withValues(alpha: 0.7),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: activeGold.withValues(alpha: 0.35),
                    blurRadius: 8.r,
                  ),
                ],
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeGold : inactiveColor,
              size: 16.r,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? activeGold : inactiveColor,
                shadows: isSelected
                    ? [
                        Shadow(
                          color: activeGold.withValues(alpha: 0.8),
                          blurRadius: 6.r,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
