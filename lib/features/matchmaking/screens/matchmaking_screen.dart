import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/oriental_theme.dart';
import '../../../core/widgets/space_particle_background.dart';
import '../../../core/audio/sound_manager.dart';
import '../../game_table/baloot_game_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  final String roomName;
  final int betCoins;

  const MatchmakingScreen({
    super.key,
    this.roomName = 'تحدي السلاطين',
    this.betCoins = 1000,
  });

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _matchTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Auto navigate to game table after 2.5 seconds
    _matchTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        SoundManager().playWinFanfare();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BalootGameScreen(
              roomName: widget.roomName,
              betCoins: widget.betCoins,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _matchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrientalTheme.bgDark,
      body: SpaceParticleBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Header Text
                    Text(
                      'Looking For Opponent',
                      style: GoogleFonts.montserrat(
                        color: OrientalTheme.primaryGold,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 10.r,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'جاري البحث عن منافس...',
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Bet Amount Bar
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: OrientalTheme.primaryGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.monetization_on_rounded,
                            color: OrientalTheme.primaryGold,
                            size: 16.r,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            widget.betCoins.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 35.h),

                    // Matchmaking Avatars & Energy Dice Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left Player (User)
                        Column(
                          children: [
                            Container(
                              width: 80.w,
                              height: 80.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1565C0),
                                border: Border.all(
                                  color: const Color(0xFF00F2FE),
                                  width: 3.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00F2FE).withValues(alpha: 0.6),
                                    blurRadius: 20.r,
                                    spreadRadius: 2.r,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.sports_esports_rounded,
                                color: Colors.white,
                                size: 40.r,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'EJ51608',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            // Flag Badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                '🇪🇬 مصر',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 25.w),

                        // Center Energy Beam & Dice
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: OrientalTheme.primaryGold
                                            .withValues(alpha: 0.6 * _pulseController.value),
                                        blurRadius: 25.r,
                                        spreadRadius: 8.r,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 10.r,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.casino_rounded,
                                  color: Colors.black87,
                                  size: 24.r,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 25.w),

                        // Right Player (Searching Opponent)
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 80.w,
                                  height: 80.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFAD1457),
                                    border: Border.all(
                                      color: const Color(0xFFE91E63),
                                      width: 3.w,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE91E63).withValues(alpha: 0.6),
                                        blurRadius: 20.r,
                                        spreadRadius: 2.r,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.person_outline_rounded,
                                    color: Colors.white70,
                                    size: 40.r,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(4.r),
                                  decoration: const BoxDecoration(
                                    color: OrientalTheme.primaryGold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: Colors.black,
                                    size: 14.r,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Searching...',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 35.h),

                    // CANCEL Button
                    GestureDetector(
                      onTap: () {
                        SoundManager().playButtonClick();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE91E63), Color(0xFFC2185B), Color(0xFF880E4F)],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.white, width: 1.5.w),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE91E63).withValues(alpha: 0.5),
                              blurRadius: 10.r,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'إلغاء — CANCEL',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.w,
                          ),
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
    );
  }
}
