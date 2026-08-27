import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/audio/sound_manager.dart';
import '../../../core/providers/game_user_provider.dart';
import '../../../games/domino_classic/domino_classic_game_screen.dart';
import '../../../games/domino_american/domino_american_game_screen.dart';
import '../../store/screens/store_screen.dart';
import 'star_explosion_overlay.dart';

class DominoRoomTier {
  final int level;
  final String titleAr;
  final String subtitleAr;
  final int betCoins;
  final int prizeCoins;
  final String imagePath;
  final List<Color> cardGradient;
  final Color borderColor;
  final Color glowColor;
  final Color particleColor;

  const DominoRoomTier({
    required this.level,
    required this.titleAr,
    required this.subtitleAr,
    required this.betCoins,
    required this.prizeCoins,
    required this.imagePath,
    required this.cardGradient,
    required this.borderColor,
    required this.glowColor,
    required this.particleColor,
  });
}

class DominoRoomsDialog extends StatefulWidget {
  final String gameTitleAr;
  final String gameTitleEn;
  final IconData icon;
  final bool isAmerican;

  const DominoRoomsDialog({
    super.key,
    required this.gameTitleAr,
    required this.gameTitleEn,
    required this.icon,
    this.isAmerican = false,
  });

  static void show(
    BuildContext context, {
    required String gameTitleAr,
    required String gameTitleEn,
    required IconData icon,
    bool isAmerican = false,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DominoRoomsDialog',
      barrierColor: Colors.black.withValues(alpha: 0.84),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim1, anim2) => DominoRoomsDialog(
        gameTitleAr: gameTitleAr,
        gameTitleEn: gameTitleEn,
        icon: icon,
        isAmerican: isAmerican,
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved =
            CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<DominoRoomsDialog> createState() => _DominoRoomsDialogState();
}

class _DominoRoomsDialogState extends State<DominoRoomsDialog> {
  final ScrollController _scrollController = ScrollController();

  static const List<DominoRoomTier> _tiers = [
    // 1. مجلس الحارة (طابع شرقي ريفي دافئ)
    DominoRoomTier(
      level: 1,
      titleAr: 'مجلس الحارة',
      subtitleAr: 'أجواء الحارة الدافئة وبداية التحدي',
      betCoins: 5000,
      prizeCoins: 10000,
      imagePath: 'assets/images/domino_room_1.jpg',
      cardGradient: [Color(0xFF0C2415), Color(0xFF144525), Color(0xFF05120A)],
      borderColor: Color(0xFF4CAF50),
      glowColor: Color(0xFF4CAF50),
      particleColor: Color(0xFF81C784),
    ),
    // 2. مقهى الفيشاوي (طابع قاهري تراثي)
    DominoRoomTier(
      level: 2,
      titleAr: 'مقهى الفيشاوي',
      subtitleAr: 'أصالة المقاهي القديمة وروح التحدي',
      betCoins: 25000,
      prizeCoins: 50000,
      imagePath: 'assets/images/domino_room_2.jpg',
      cardGradient: [Color(0xFF071F3D), Color(0xFF0F3E78), Color(0xFF020C1A)],
      borderColor: Color(0xFF29B6F6),
      glowColor: Color(0xFF0288D1),
      particleColor: Color(0xFF80D8FF),
    ),
    // 3. صالون الأمراء (طابع كهرماني مذهب)
    DominoRoomTier(
      level: 3,
      titleAr: 'صالون الأمراء',
      subtitleAr: 'جلسات الوجهاء وصراع المحترفين',
      betCoins: 100000,
      prizeCoins: 200000,
      imagePath: 'assets/images/domino_room_3.jpg',
      cardGradient: [Color(0xFF381802), Color(0xFF6E3307), Color(0xFF1B0A00)],
      borderColor: Color(0xFFFFB300),
      glowColor: Color(0xFFFF8F00),
      particleColor: Color(0xFFFFE082),
    ),
    // 4. ديوان الباشا (طابع مخملي قرمزي فخم)
    DominoRoomTier(
      level: 4,
      titleAr: 'ديوان الباشا',
      subtitleAr: 'طاولات كبار الشخصيات والرهان العالي',
      betCoins: 500000,
      prizeCoins: 1000000,
      imagePath: 'assets/images/domino_room_4.jpg',
      cardGradient: [Color(0xFF380512), Color(0xFF700E26), Color(0xFF190107)],
      borderColor: Color(0xFFFF2A6D),
      glowColor: Color(0xFFD81B60),
      particleColor: Color(0xFFFF80AB),
    ),
    // 5. قصر السلاطين (طابع بنفسجي ملكي باذخ)
    DominoRoomTier(
      level: 5,
      titleAr: 'قصر السلاطين',
      subtitleAr: 'قاعات الملوك وأصحاب الملايين',
      betCoins: 2000000,
      prizeCoins: 4000000,
      imagePath: 'assets/images/domino_room_5.jpg',
      cardGradient: [Color(0xFF260442), Color(0xFF4E0E82), Color(0xFF11011F)],
      borderColor: Color(0xFFBA68C8),
      glowColor: Color(0xFF8E24AA),
      particleColor: Color(0xFFE1BEE7),
    ),
    // 6. عرش الأساطير (طابع ذهبي أسطوري مشع)
    DominoRoomTier(
      level: 6,
      titleAr: 'عرش الأساطير',
      subtitleAr: 'أقوى مواجهات القمة لكبار النجوم',
      betCoins: 10000000,
      prizeCoins: 20000000,
      imagePath: 'assets/images/domino_room_6.jpg',
      cardGradient: [Color(0xFF331E00), Color(0xFF6B4202), Color(0xFF140B00)],
      borderColor: Color(0xFFFFD700),
      glowColor: Color(0xFFFFD700),
      particleColor: Color(0xFFFFF9C4),
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCoins(int coins) {
    if (coins >= 1000000) {
      final m = coins / 1000000;
      return m % 1 == 0 ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      final k = coins / 1000;
      return k % 1 == 0 ? '${k.toInt()}K' : '${k.toStringAsFixed(0)}K';
    }
    return coins.toString();
  }

  void _onSelectRoom(DominoRoomTier tier, int userCoins) {
    SoundManager().playButtonClick();
    if (userCoins < tier.betCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFFFD700)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'رصيد الذهب غير كافٍ لدخول ${tier.titleAr}! تحتاج إلى ${_formatCoins(tier.betCoins)} ذهب على الأقل.',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StoreScreen()),
                    );
                  },
                  child: Text(
                    'شحن الآن ⚡',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.w900,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: const Color(0xFF4A0E17),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final userProvider = Provider.of<GameUserProvider>(context, listen: false);
    userProvider.deductCoins(tier.betCoins);

    Navigator.of(context).pop(); // Close room selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => widget.isAmerican
            ? DominoAmericanGameScreen(betCoins: tier.betCoins)
            : DominoClassicGameScreen(betCoins: tier.betCoins),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<GameUserProvider>(context);
    final userCoins = userProvider.user.coins;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Column(
              children: [
                // 1. FLOATING TOP BAR (FRAMELESS)
                _buildTopBar(userCoins),

                SizedBox(height: 10.h),

                // 2. HORIZONTAL RIGHT-TO-LEFT 7 ROOM CARDS
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: _tiers.length,
                    itemBuilder: (context, index) {
                      final tier = _tiers[index];
                      final isUnlocked = userCoins >= tier.betCoins;
                      return _buildRoomCard(tier, isUnlocked, userCoins, index);
                    },
                  ),
                ),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(int userCoins) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () {
              SoundManager().playButtonClick();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.6),
                border:
                    Border.all(color: const Color(0xFFFFD700), width: 1.2.w),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                    blurRadius: 10.r,
                  ),
                ],
              ),
              child: Icon(Icons.close_rounded,
                  color: const Color(0xFFFFD700), size: 16.r),
            ),
          ),

          SizedBox(width: 12.w),

          // Game Title & Room Subtitle
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                  width: 1.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10.r,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: const Color(0xFFFFD700), size: 16.r),
                SizedBox(width: 6.w),
                Text(
                  'غرف ${widget.gameTitleAr}',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  width: 3.w,
                  height: 12.h,
                  color: Colors.white24,
                ),
                SizedBox(width: 6.w),
                Text(
                  'اختر طاولتك المفضلة',
                  style: GoogleFonts.cairo(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Live Gold Balance Pill
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreScreen()),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E1700), Color(0xFF593002)],
                ),
                borderRadius: BorderRadius.circular(20.r),
                border:
                    Border.all(color: const Color(0xFFFFD700), width: 1.2.w),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 10.r,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 6.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'رصيدك الحالي',
                        style: GoogleFonts.cairo(
                          fontSize: 6.5.sp,
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        _formatCoins(userCoins),
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: Colors.black, size: 10.r),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(
      DominoRoomTier tier, bool isUnlocked, int userCoins, int index) {
    return GestureDetector(
      onTapDown: (details) {
        StarExplosionOverlay.spawnExplosion(context, details.globalPosition);
      },
      onTap: () => _onSelectRoom(tier, userCoins),
      child: Container(
        width: 132.w,
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            colors: tier.cardGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: isUnlocked ? tier.borderColor : Colors.white24,
            width: isUnlocked ? 1.6.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? tier.glowColor.withValues(alpha: 0.38)
                  : Colors.black.withValues(alpha: 0.4),
              blurRadius: isUnlocked ? 16.r : 6.r,
              spreadRadius: isUnlocked ? 1.r : 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Stack(
            children: [
              // 1. EXPRESSIVE BACKGROUND IMAGE (WITH SLOW PULSE/BREATHING ANIMATION)
              Positioned.fill(
                child: Opacity(
                  opacity: isUnlocked ? 0.42 : 0.16,
                  child: Image.asset(
                    tier.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.black45,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.06, 1.06),
                        duration: 4000.ms,
                        curve: Curves.easeInOut,
                      ),
                ),
              ),

              // 2. ANIMATED FLOATING PARTICLES & LIGHT SPARKLES
              if (isUnlocked)
                Positioned.fill(
                  child: _CardFloatingParticles(color: tier.particleColor),
                ),

              // 3. ANIMATED SHIMMER LIGHT BEAM SWEEP
              if (isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          tier.particleColor.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ).animate(onPlay: (c) => c.repeat()).shimmer(
                      duration: 2800.ms,
                      color: Colors.white.withValues(alpha: 0.15)),
                ),

              // 4. LUXURY GRADIENT SCRIM OVERLAY (FOR CRISP TEXT LEGIBILITY)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.96),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // 5. CARD CONTENT (CLEAN, PROMINENT, PRESTIGIOUS)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 6.h),

                    // ROOM NAME (CLEAN & PROMINENT)
                    Center(
                      child: Text(
                        tier.titleAr,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                          color: isUnlocked
                              ? const Color(0xFFFFD700)
                              : Colors.white70,
                          height: 1.2,
                        ),
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // SUBTITLE (DESCRIPTION OF THE LUXURY TIER)
                    Center(
                      child: Text(
                        tier.subtitleAr,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 7.2.sp,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // BET & PRIZE CONTAINER
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isUnlocked
                              ? tier.borderColor.withValues(alpha: 0.35)
                              : Colors.white12,
                          width: 0.8.w,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '🪙 الرهان:',
                                style: GoogleFonts.cairo(
                                  fontSize: 7.5.sp,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _formatCoins(tier.betCoins),
                                style: GoogleFonts.cairo(
                                  fontSize: 8.2.sp,
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '🏆 الجائزة:',
                                style: GoogleFonts.cairo(
                                  fontSize: 7.5.sp,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _formatCoins(tier.prizeCoins),
                                style: GoogleFonts.cairo(
                                  fontSize: 8.2.sp,
                                  color: const Color(0xFF00E676),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // ENTER / LOCKED BUTTON
                    Container(
                      height: 26.h,
                      decoration: BoxDecoration(
                        gradient: isUnlocked
                            ? LinearGradient(
                                colors: [tier.borderColor, tier.glowColor],
                              )
                            : null,
                        color: isUnlocked ? null : Colors.white12,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: tier.glowColor.withValues(alpha: 0.45),
                                  blurRadius: 8.r,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isUnlocked
                                  ? Icons.play_arrow_rounded
                                  : Icons.lock_rounded,
                              color: isUnlocked ? Colors.black : Colors.white38,
                              size: 14.r,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isUnlocked
                                  ? 'دخول الغرفة'
                                  : 'مغلق (تحتاج ${_formatCoins(tier.betCoins)})',
                              style: GoogleFonts.cairo(
                                fontSize: 7.5.sp,
                                fontWeight: FontWeight.w900,
                                color:
                                    isUnlocked ? Colors.black : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}

/// Floating particles overlay that adds dynamic life and sparkle to each room card
class _CardFloatingParticles extends StatefulWidget {
  final Color color;

  const _CardFloatingParticles({required this.color});

  @override
  State<_CardFloatingParticles> createState() => _CardFloatingParticlesState();
}

class _CardFloatingParticlesState extends State<_CardFloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ParticleData> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(10, (i) => _createParticle());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  _ParticleData _createParticle() {
    return _ParticleData(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: 1.5 + _random.nextDouble() * 2.5,
      speed: 0.15 + _random.nextDouble() * 0.25,
      opacity: 0.2 + _random.nextDouble() * 0.6,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _ParticleData {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _ParticleData({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_ParticleData> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      final currentY = (p.y - progress * p.speed) % 1.0;
      final currentOpacity = (sin(currentY * pi) * p.opacity).clamp(0.0, 1.0);

      paint.color = color.withValues(alpha: currentOpacity);
      final dx = (p.x + sin((progress + p.x) * 2 * pi) * 0.04) * size.width;
      final dy = currentY * size.height;

      canvas.drawCircle(Offset(dx, dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
