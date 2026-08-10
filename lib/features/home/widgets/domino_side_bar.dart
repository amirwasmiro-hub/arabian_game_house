import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DominoSideBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback? onPlayNowTap;

  const DominoSideBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onPlayNowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65.w,
      margin: EdgeInsets.only(left: 4.w, top: 4.h, bottom: 4.h),
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1304).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
          width: 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10.r,
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 320.h,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                // Home
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'الرئيسية',
                ),
                SizedBox(height: 4.h),

                // Settings
                _buildNavItem(
                  index: 1,
                  icon: Icons.settings_rounded,
                  label: 'إعدادات',
                ),
                SizedBox(height: 4.h),

                // Mail with notification badge
                _buildNavItem(
                  index: 2,
                  icon: Icons.mail_rounded,
                  label: 'البريد',
                  hasBadge: true,
                ),
                SizedBox(height: 4.h),

                // Quests
                _buildNavItem(
                  index: 3,
                  icon: Icons.assignment_rounded,
                  label: 'المهمة',
                ),
                SizedBox(height: 4.h),

                // Store
                _buildNavItem(
                  index: 4,
                  icon: Icons.shopping_cart_rounded,
                  label: 'المتجر',
                  accentColor: const Color(0xFFFF9800),
                ),

                const Spacer(),

                // Big Glowing "العب الآن" Play Now Button at bottom
                GestureDetector(
                  onTap: onPlayNowTap,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE65100), Color(0xFFFF9800)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 1.2.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.7),
                          blurRadius: 6.r,
                          spreadRadius: 1.r,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 18.r,
                        ),
                        Text(
                          'العب الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'عادية',
                          style: GoogleFonts.cairo(
                            fontSize: 6.5.sp,
                            color: Colors.amber.shade100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    Color? accentColor,
    bool hasBadge = false,
  }) {
    final bool isSelected = selectedIndex == index;
    final Color activeColor = accentColor ?? const Color(0xFFFFD700);

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52.w,
        padding: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.8), width: 1.w)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : Colors.amber.shade100.withValues(alpha: 0.8),
                  size: 20.r,
                ),
                if (hasBadge)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 8.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : Colors.amber.shade100.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
