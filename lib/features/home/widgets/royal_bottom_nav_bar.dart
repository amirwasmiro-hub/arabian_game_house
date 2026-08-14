import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    return Container(
      height: 48.h,
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: activeGold.withValues(alpha: 0.40),
            blurRadius: 20.r,
            spreadRadius: 1.r,
          ),
          BoxShadow(
            color: const Color(0xFF8E2DE2).withValues(alpha: 0.3),
            blurRadius: 24.r,
            spreadRadius: 2.r,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.85),
            blurRadius: 16.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Design 1 Full Graphic Artwork Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/royal_nav_bar_bg.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xF5180B2B),
                        Color(0xF52E0B54),
                        Color(0xF5180B2B),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Ambient Golden Shimmer Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.25),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Interactive Clickable Button Overlays for Each Icon
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: List.generate(5, (index) {
                  final isSelected = selectedIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        SoundManager().playButtonClick();
                        onTabSelected(index);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        margin: EdgeInsets.all(4.r),
                        decoration: isSelected
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color: activeGold,
                                  width: 1.6.w,
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    activeGold.withValues(alpha: 0.25),
                                    const Color(0xFF8E2DE2)
                                        .withValues(alpha: 0.20),
                                    activeGold.withValues(alpha: 0.10),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: activeGold.withValues(alpha: 0.5),
                                    blurRadius: 10.r,
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
