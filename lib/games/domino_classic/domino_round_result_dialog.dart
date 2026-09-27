import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';
import 'domino_classic_engine.dart';

class DominoRoundResultDialog extends StatelessWidget {
  final DominoRoundResult result;
  final DominoClassicEngine engine;
  final VoidCallback onNextRound;
  final VoidCallback onNewMatch;

  const DominoRoundResultDialog({
    super.key,
    required this.result,
    required this.engine,
    required this.onNextRound,
    required this.onNewMatch,
  });

  static void show(
    BuildContext context, {
    required DominoRoundResult result,
    required DominoClassicEngine engine,
    required VoidCallback onNextRound,
    required VoidCallback onNewMatch,
  }) {
    SoundManager().playTileSlam();
    if (result.winningTeam == 1) {
      SoundManager().playWinFanfare();
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'DominoRoundResultDialog',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) => DominoRoundResultDialog(
        result: result,
        engine: engine,
        onNextRound: onNextRound,
        onNewMatch: onNewMatch,
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPlayerWinner = result.winningTeam == 1;
    final isSak = result.winType == DominoWinType.blocked;

    final primaryColor = isPlayerWinner ? const Color(0xFFFFD700) : const Color(0xFFFF5252);
    final gradientColors = isPlayerWinner
        ? [const Color(0xFF2E1C03), const Color(0xFF140B01)]
        : [const Color(0xFF2B0B0B), const Color(0xFF140303)];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 480.w,
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(color: primaryColor, width: 2.w),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.4),
                  blurRadius: 28.r,
                  spreadRadius: 2.r,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Header Icon & Title Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSak
                                ? Icons.lock_rounded
                                : (isPlayerWinner ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded),
                            color: primaryColor,
                            size: 26.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            result.title,
                            style: GoogleFonts.cairo(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                              shadows: [
                                Shadow(
                                  color: primaryColor.withValues(alpha: 0.6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                      SizedBox(height: 6.h),

                      // Description
                      Text(
                        result.description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 9.5.sp,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // 2. Breakdown of Hands & Pips (خصوصاً عند الصاك أو نهاية الجولة)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildPlayerPipCard(
                                  name: engine.mode == DominoPlayMode.partnership4P ? 'فريقك (أنت + محروس)' : 'أنت 👤',
                                  pips: engine.mode == DominoPlayMode.partnership4P
                                      ? (result.playerPipSums[0]! + result.playerPipSums[2]!)
                                      : result.playerPipSums[0]!,
                                  tilesRemaining: engine.hands[0].length + (engine.mode == DominoPlayMode.partnership4P ? engine.hands[2].length : 0),
                                  isWinner: isPlayerWinner,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '+${result.pointsEarned}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w900,
                                          color: primaryColor,
                                        ),
                                      ),
                                      Text(
                                        'نقطة',
                                        style: GoogleFonts.cairo(
                                          fontSize: 7.sp,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildPlayerPipCard(
                                  name: engine.mode == DominoPlayMode.partnership4P ? 'الخصوم (رامي + علي)' : 'الخصم 🤖',
                                  pips: engine.mode == DominoPlayMode.partnership4P
                                      ? (result.playerPipSums[1]! + result.playerPipSums[3]!)
                                      : result.playerPipSums[3]!,
                                  tilesRemaining: engine.hands[3].length + (engine.mode == DominoPlayMode.partnership4P ? engine.hands[1].length : 0),
                                  isWinner: !isPlayerWinner,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // 3. Match Progress to 101 Scoreboard
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0714),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'مجموع الماتش (الهدف ${engine.targetScore} نقطة) - الجولة ${engine.currentRound}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFD700),
                                  ),
                                ),
                                Text(
                                  '${engine.team1MatchScore}  :  ${engine.team2MatchScore}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6.r),
                              child: LinearProgressIndicator(
                                value: (engine.team1MatchScore / engine.targetScore).clamp(0.0, 1.0),
                                backgroundColor: const Color(0xFFFF5252).withValues(alpha: 0.4),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                                minHeight: 6.h,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // 4. Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (result.isMatchOver)
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD700),
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  onNewMatch();
                                },
                                icon: const Icon(Icons.replay_rounded),
                                label: Text(
                                  'بدء ماتش جديد 🏆',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            )
                          else ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E676),
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  onNextRound();
                                },
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: Text(
                                  'الجولة التالية ⏭️ (الجولة ${engine.currentRound + 1})',
                                  style: GoogleFonts.cairo(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white30),
                                foregroundColor: Colors.white70,
                                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                onNewMatch();
                              },
                              child: Text(
                                'تصفير الماتش',
                                style: GoogleFonts.cairo(fontSize: 8.5.sp),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerPipCard({
    required String name,
    required int pips,
    required int tilesRemaining,
    required bool isWinner,
  }) {
    return Column(
      crossAxisAlignment: isWinner ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          name,
          style: GoogleFonts.cairo(
            fontSize: 8.sp,
            fontWeight: FontWeight.bold,
            color: isWinner ? const Color(0xFF00E676) : Colors.white70,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          '$pips نقطة متبقية ($tilesRemaining قطع)',
          style: GoogleFonts.cairo(
            fontSize: 7.sp,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
