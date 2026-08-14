import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
          count: 28,
          lifespan: 0.9,
          generator: (i) {
            final speed = _random.nextDouble() * 75 + 25;
            final angle = _random.nextDouble() * 2 * math.pi;
            return AcceleratedParticle(
              position: position.clone(),
              speed: Vector2(math.cos(angle) * speed, math.sin(angle) * speed - 20),
              acceleration: Vector2(0, 35),
              child: CircleParticle(
                radius: _random.nextDouble() * 3.2 + 1.0,
                paint: Paint()
                  ..color = Color.lerp(
                    const Color(0xFFFFD700), // 24k Gold
                    const Color(0xFFE040FB), // Royal Purple Sparkle
                    _random.nextDouble(),
                  )!.withValues(alpha: 0.95),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 🌟 Compact Royal Navigation Bar (Design 1 Artwork with Perfect Button Alignment)
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

  final List<NavTabItem> _tabs = const [
    NavTabItem(
      title: 'الرئيسية',
      assetPath: 'assets/images/nav_home.jpg',
      icon: Icons.castle_rounded,
    ),
    NavTabItem(
      title: 'الاستبدال',
      assetPath: 'assets/images/nav_exchange.jpg',
      icon: Icons.swap_horizontal_circle_rounded,
    ),
    NavTabItem(
      title: 'المسابقات',
      assetPath: 'assets/images/nav_trophy.jpg',
      icon: Icons.emoji_events_rounded,
    ),
    NavTabItem(
      title: 'البروفايل',
      assetPath: 'assets/images/nav_profile.jpg',
      icon: Icons.person_pin_rounded,
    ),
    NavTabItem(
      title: 'الإعدادات',
      assetPath: 'assets/images/nav_settings.jpg',
      icon: Icons.settings_suggest_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _particleGame = FlameNavBarParticleGame();
  }

  void _handleTabTap(int index, GlobalKey key) {
    SoundManager().playButtonClick();
    widget.onTabSelected(index);

    // Trigger Flame particle burst at exact button position
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
        // 1. Flame Particle Layer (Explosions behind the UI)
        Positioned.fill(
          child: IgnorePointer(
            child: GameWidget(game: _particleGame),
          ),
        ),

        // 2. Compact Glassmorphic Royal Navigation Bar Dock
        Directionality(
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
              children: List.generate(_tabs.length, (index) {
                final key = GlobalKey();
                final isSelected = widget.selectedIndex == index;
                final tab = _tabs[index];

                return Expanded(
                  child: GestureDetector(
                    key: key,
                    onTap: () => _handleTabTap(index, key),
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
                          // 3D Golden Artwork Icon for Tab (Exactly aligned inside button)
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
                            tab.title,
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
        ),
      ],
    );
  }
}

class NavTabItem {
  final String title;
  final String assetPath;
  final IconData icon;

  const NavTabItem({
    required this.title,
    required this.assetPath,
    required this.icon,
  });
}
