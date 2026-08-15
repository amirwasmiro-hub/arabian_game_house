import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'dart:math' as math;
import '../../../core/audio/sound_manager.dart';

/// 👑 Flame Game Canvas for Dynamic Golden Sparkle & Particle Explosions
class FlameNavBarParticleGame extends FlameGame {
  final math.Random _random = math.Random();

  void triggerParticleBurst(Vector2 position) {
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 36,
          lifespan: 1.1,
          generator: (i) {
            final speed = _random.nextDouble() * 90 + 35;
            final angle = _random.nextDouble() * 2 * math.pi;
            return AcceleratedParticle(
              position: position.clone(),
              speed: Vector2(
                  math.cos(angle) * speed, math.sin(angle) * speed - 30),
              acceleration: Vector2(0, 40),
              child: CircleParticle(
                radius: _random.nextDouble() * 3.8 + 1.2,
                paint: Paint()
                  ..color = Color.lerp(
                    const Color(0xFFFFD700), // 24k Gold
                    const Color(0xFFE040FB), // Royal Purple Sparkle
                    _random.nextDouble(),
                  )!
                      .withValues(alpha: 0.95),
              ),
            );
          },
        ),
      ),
    );
  }
}

class NavItemData {
  final String label;
  final String iconAsset;

  const NavItemData({
    required this.label,
    required this.iconAsset,
  });
}

/// 🌟 Royal Interactive Navigation Bar with Individual 3D Icons
class RoyalRiveFlameNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const RoyalRiveFlameNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<RoyalRiveFlameNavBar> createState() => _RoyalRiveFlameNavBarState();
}

class _RoyalRiveFlameNavBarState extends State<RoyalRiveFlameNavBar> {
  late final FlameNavBarParticleGame _particleGame;

  final List<NavItemData> _navItems = const [
    NavItemData(label: 'الرئيسية', iconAsset: 'assets/images/icon_home.png'),
    NavItemData(label: 'التحويل', iconAsset: 'assets/images/icon_exchange.png'),
    NavItemData(label: 'المسابقات', iconAsset: 'assets/images/icon_trophy.png'),
    NavItemData(
        label: 'البروفايل', iconAsset: 'assets/images/icon_profile.png'),
    NavItemData(
        label: 'الإعدادات', iconAsset: 'assets/images/icon_settings.png'),
    NavItemData(label: 'المتجر', iconAsset: 'assets/images/icon_store.png'),
  ];

  @override
  void initState() {
    super.initState();
    _particleGame = FlameNavBarParticleGame();
  }

  void _handleTabTap(int index, GlobalKey key) {
    SoundManager().playButtonClick();
    widget.onTabSelected(index);

    // Trigger Flame particle burst at exact tapped button position
    final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final pos = box.localToGlobal(Offset.zero);
      final size = box.size;
      _particleGame.triggerParticleBurst(
        Vector2(pos.dx + size.width / 2, pos.dy + size.height / 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const activeGold = Color(0xFFFFD700);

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Flame Particle Layer
        Positioned.fill(
          child: IgnorePointer(
            child: GameWidget(game: _particleGame),
          ),
        ),

        // 2. Royal Luxury Glassmorphism Dock
        Container(
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
                final key = GlobalKey();
                final isSelected = widget.selectedIndex == index;
                final item = _navItems[index];

                return Expanded(
                  child: GestureDetector(
                    key: key,
                    onTap: () => _handleTabTap(index, key),
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
                                        color:
                                            activeGold.withValues(alpha: 0.6),
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
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
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
        ),
      ],
    );
  }
}
