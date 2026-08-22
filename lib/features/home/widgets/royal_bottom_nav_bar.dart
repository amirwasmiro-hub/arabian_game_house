import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/audio/sound_manager.dart';

class NavItemData {
  final String label;
  final String iconAsset;

  const NavItemData({
    required this.label,
    required this.iconAsset,
  });
}

class RoyalBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const RoyalBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static const List<NavItemData> _navItems = [
    NavItemData(label: 'الرئيسية', iconAsset: 'assets/images/icon_home.png'),
    NavItemData(label: 'التحويل', iconAsset: 'assets/images/icon_exchange.png'),
    NavItemData(label: 'المسابقات', iconAsset: 'assets/images/icon_trophy.png'),
    NavItemData(label: 'البروفايل', iconAsset: 'assets/images/icon_profile.png'),
    NavItemData(label: 'الإعدادات', iconAsset: 'assets/images/icon_settings.png'),
    NavItemData(label: 'المتجر', iconAsset: 'assets/images/icon_store.png'),
  ];

  @override
  Widget build(BuildContext context) {
    const activeGold = Color(0xFFFFD700);

    return Container(
      width: double.infinity,
      height: 46.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xF51A0736),
            Color(0xF5330C59),
            Color(0xF51A0736),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          top: BorderSide(
            color: activeGold.withValues(alpha: 0.70),
            width: 1.2.w,
          ),
          bottom: BorderSide(
            color: activeGold.withValues(alpha: 0.35),
            width: 0.8.w,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: activeGold.withValues(alpha: 0.30),
            blurRadius: 16.r,
            spreadRadius: 1.r,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.85),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: List.generate(_navItems.length, (index) {
            final isSelected = selectedIndex == index;
            final item = _navItems[index];

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  SoundManager().playButtonClick();
                  onTabSelected(index);
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.18 : 0.92,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        padding: EdgeInsets.all(2.r),
                        decoration: isSelected
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: activeGold.withValues(alpha: 0.6),
                                    blurRadius: 12.r,
                                    spreadRadius: 1.r,
                                  ),
                                ],
                              )
                            : null,
                        child: Image.asset(
                          item.iconAsset,
                          height: 30.h,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.stars_rounded,
                            color: isSelected ? activeGold : Colors.white60,
                            size: 24.r,
                          ),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: EdgeInsets.only(top: 2.h),
                        width: 14.w,
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: activeGold,
                          borderRadius: BorderRadius.circular(2.r),
                          boxShadow: [
                            BoxShadow(
                              color: activeGold,
                              blurRadius: 6.r,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
