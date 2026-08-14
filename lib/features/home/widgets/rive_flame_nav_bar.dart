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

/// 🌟 Royal Interactive Image Navigation Bar (Design 1 Image Background Overlay)
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

  final List<String> _tabs = const [
    'الرئيسية',
    'الاستبدال',
    'المسابقات',
    'البروفايل',
    'الإعدادات',
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
        // 1. Flame Particle Layer (Explosions behind the UI)
        Positioned.fill(
          child: IgnorePointer(
            child: GameWidget(game: _particleGame),
          ),
        ),

        // 2. High Resolution Image Navigation Bar Graphic Dock
        Container(
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

                // 3. Interactive Clickable Button Overlays for Each Icon
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: List.generate(_tabs.length, (index) {
                      final key = GlobalKey();
                      final isSelected = widget.selectedIndex == index;

                      return Expanded(
                        child: GestureDetector(
                          key: key,
                          onTap: () => _handleTabTap(index, key),
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
                                        color:
                                            activeGold.withValues(alpha: 0.5),
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
        ),
      ],
    );
  }
}
