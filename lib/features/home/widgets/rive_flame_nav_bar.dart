import 'dart:ui';
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

  @override
  Color backgroundColor() => const Color(0x00000000);

  void triggerParticleBurst(Vector2 position) {
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 24,
          lifespan: 0.8,
          generator: (i) {
            final speed = _random.nextDouble() * 75 + 25;
            final angle = _random.nextDouble() * 2 * math.pi;
            return AcceleratedParticle(
              position: position.clone(),
              speed: Vector2(
                math.cos(angle) * speed,
                math.sin(angle) * speed - 20,
              ),
              acceleration: Vector2(0, 30),
              child: CircleParticle(
                radius: _random.nextDouble() * 2.8 + 1.0,
                paint: Paint()
                  ..color = Color.lerp(
                    const Color(0xFFFFD700), // 24k Gold
                    const Color(0xFF00E676), // Emerald Sparkle
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
  final IconData icon;
  final List<Color> gradientColors;

  const NavItemData({
    required this.label,
    required this.icon,
    required this.gradientColors,
  });
}

/// 🌟 Royal Curved Navigation Bar Dock
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
    NavItemData(
      label: 'الرئيسية',
      icon: Icons.home_rounded,
      gradientColors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFFF8F00)],
    ),
    NavItemData(
      label: 'التحويل',
      icon: Icons.currency_exchange_rounded,
      gradientColors: [Color(0xFF80E8FF), Color(0xFF00B0FF), Color(0xFF0091EA)],
    ),
    NavItemData(
      label: 'المسابقات',
      icon: Icons.emoji_events_rounded,
      gradientColors: [Color(0xFFFFE082), Color(0xFFFFD700), Color(0xFFFFA000)],
    ),
    NavItemData(
      label: 'البروفايل',
      icon: Icons.account_circle_rounded,
      gradientColors: [Color(0xFFE1BEE7), Color(0xFFBA68C8), Color(0xFF8E24AA)],
    ),
    NavItemData(
      label: 'المتجر',
      icon: Icons.storefront_rounded,
      gradientColors: [Color(0xFFFFAB91), Color(0xFFFF7043), Color(0xFFF4511E)],
    ),
    NavItemData(
      label: 'الإعدادات',
      icon: Icons.tune_rounded,
      gradientColors: [Color(0xFFB0BEC5), Color(0xFF78909C), Color(0xFF546E7A)],
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
      alignment: Alignment.bottomCenter,
      children: [
        // 1. Flame Particle Layer
        Positioned.fill(
          child: IgnorePointer(
            child: GameWidget(game: _particleGame),
          ),
        ),

        // 2. Sleek Curved Dock: Top Curved Corners, NO Side or Bottom Borders
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36.r),
            topRight: Radius.circular(36.r),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: double.infinity,
              height: 37.h, // Sleek reduced height
              decoration: BoxDecoration(
                // Ultra-transparent crystal glass (5% alpha)
                color: Colors.white.withValues(alpha: 0.01),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36.r),
                  topRight: Radius.circular(36.r),
                ),
                // Top border only — NO side borders or bottom borders
                border: Border(
                  top: BorderSide(
                    color: activeGold.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: isSelected
                              ? BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment.bottomCenter,
                                    radius: 1.2,
                                    colors: [
                                      activeGold.withValues(alpha: 0.22),
                                      Colors.transparent,
                                    ],
                                  ),
                                )
                              : null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedScale(
                                scale: isSelected ? 1.15 : 0.95,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: isSelected
                                        ? item.gradientColors
                                        : [Colors.white70, Colors.white38],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ).createShader(bounds),
                                  child: Icon(
                                    item.icon,
                                    size: 20.r,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                item.label,
                                style: GoogleFonts.cairo(
                                  fontSize: 10.5.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? activeGold
                                      : Colors.white.withValues(alpha: 0.6),
                                  shadows: isSelected
                                      ? [
                                          Shadow(
                                            color: activeGold.withValues(
                                                alpha: 0.7),
                                            blurRadius: 6,
                                          )
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
          ),
        ),
      ],
    );
  }
}
