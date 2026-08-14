import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';

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
    const activeGold = Color(0xFFFFD700);

    final tabs = const [
      _TabInfo('الرئيسية', 'assets/images/nav_home.jpg', Icons.castle_rounded),
      _TabInfo('الاستبدال', 'assets/images/nav_exchange.jpg', Icons.swap_horizontal_circle_rounded),
      _TabInfo('المسابقات', 'assets/images/nav_trophy.jpg', Icons.emoji_events_rounded),
      _TabInfo('البروفايل', 'assets/images/nav_profile.jpg', Icons.person_pin_rounded),
      _TabInfo('الإعدادات', 'assets/images/nav_settings.jpg', Icons.settings_suggest_rounded),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 36.h,
        margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 2.h),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: const LinearGradient(
            colors: [
              Color(0xF5140A24), // Deep Obsidian Purple
              Color(0xF52A0C4E), // Royal Gold-Purple Tint
              Color(0xF5140A24),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          border: Border.all(
            color: activeGold.withValues(alpha: 0.65),
            width: 1.2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: activeGold.withValues(alpha: 0.30),
              blurRadius: 14.r,
              spreadRadius: 0.5.r,
            ),
            BoxShadow(
              color: const Color(0xFF8E2DE2).withValues(alpha: 0.25),
              blurRadius: 16.r,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 10.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (index) {
            final isSelected = selectedIndex == index;
            final tab = tabs[index];

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  SoundManager().playButtonClick();
                  onTabSelected(index);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 8.w : 4.w,
                    vertical: 2.h,
                  ),
                  decoration: isSelected
                      ? BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              activeGold.withValues(alpha: 0.35),
                              const Color(0xFF8E2DE2).withValues(alpha: 0.25),
                              activeGold.withValues(alpha: 0.15),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: activeGold,
                            width: 1.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: activeGold.withValues(alpha: 0.45),
                              blurRadius: 8.r,
                            ),
                          ],
                        )
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 18.r,
                        height: 18.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: activeGold, width: 0.8.w)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: activeGold.withValues(alpha: 0.5),
                                    blurRadius: 6.r,
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9.r),
                          child: Image.asset(
                            tab.assetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              tab.icon,
                              size: 14.r,
                              color: isSelected ? activeGold : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        tab.label,
                        style: GoogleFonts.cairo(
                          fontSize: 9.sp,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected
                              ? activeGold
                              : Colors.white.withValues(alpha: 0.75),
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
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TabInfo {
  final String label;
  final String assetPath;
  final IconData icon;

  const _TabInfo(this.label, this.assetPath, this.icon);
}
