import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/audio/sound_manager.dart';
import '../logic/backgammon31_engine.dart';

class Backgammon31GameScreen extends StatefulWidget {
  const Backgammon31GameScreen({super.key});
  @override State<Backgammon31GameScreen> createState() => _Backgammon31GameScreenState();
}

class _Backgammon31GameScreenState extends State<Backgammon31GameScreen> {
  final _engine = Backgammon31Engine();
  bool _botThinking = false;

  @override Widget build(BuildContext context) {
    final s = _engine.state;
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(s),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 85.h,
                                height: 85.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(colors: [
                                    const Color(0xFFFFD700).withValues(alpha: 0.25),
                                    const Color(0xFFE65100).withValues(alpha: 0.05),
                                  ]),
                                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                                  boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.3), blurRadius: 15)],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('الهدف', style: GoogleFonts.cairo(color: Colors.white54, fontSize: 10.sp)),
                                    Text('31', style: GoogleFonts.montserrat(color: const Color(0xFFFFD700), fontSize: 24.sp, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 12.w),
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  s.message,
                                  style: GoogleFonts.cairo(color: Colors.amber, fontSize: 11.sp),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(color: Colors.white12, width: 1),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _totalCard('أنت', s.playerTotal, s.playerWins, const Color(0xFFFFD700), s.turn == Bg31Turn.player),
                                _totalCard('البوت', s.botTotal, s.botWins, Colors.white54, s.turn == Bg31Turn.bot),
                              ],
                            ),
                            if (s.dice.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: s.dice.map((d) => Container(
                                  width: 38.w, height: 38.w, margin: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(8.r)),
                                  child: Center(child: Text('$d', style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black))),
                                )).toList(),
                              ),
                            _buildControls(s),
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
    );
  }

  Widget _buildHeader(Backgammon31State s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    color: Colors.black54,
    child: Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFFD700), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        SizedBox(width: 8.w),
        Text('طاولة 31 🎲', style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        const Spacer(),
        if (_botThinking)
          Row(
            children: [
              Text('البوت يفكر...', style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11.sp)),
              SizedBox(width: 6.w),
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFFFD700), strokeWidth: 2)),
            ],
          ),
        SizedBox(width: 12.w),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.refresh, color: Colors.white54, size: 18),
          onPressed: () => setState(() { _engine.newRound(); _botThinking = false; }),
        ),
      ],
    ),
  );

  Widget _totalCard(String name, int total, int wins, Color c, bool isTurn) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: c.withValues(alpha: isTurn ? 0.2 : 0.08),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: isTurn ? c : c.withValues(alpha: 0.3), width: isTurn ? 2 : 1),
    ),
    child: Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: GoogleFonts.cairo(color: c, fontSize: 11.sp)),
            SizedBox(width: 6.w),
            Text('🏆$wins', style: GoogleFonts.cairo(color: c, fontSize: 10.sp)),
          ],
        ),
        Text('$total', style: GoogleFonts.montserrat(color: c, fontSize: 24.sp, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildControls(Backgammon31State s) {
    if (s.phase == Bg31Phase.rolling && s.turn == Bg31Turn.player) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100), padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h)),
        onPressed: () { SoundManager().playDiceRoll(); setState(() => _engine.roll()); },
        icon: const Icon(Icons.casino, color: Colors.white, size: 16),
        label: Text('ارمِ الزهر 🎲', style: GoogleFonts.cairo(color: Colors.white, fontSize: 13.sp)),
      );
    }
    if (s.phase == Bg31Phase.waiting) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)),
            onPressed: () { SoundManager().playDiceRoll(); setState(() => _engine.rollAgain()); },
            child: Text('ارمِ مجدداً', style: GoogleFonts.cairo(color: Colors.white, fontSize: 12.sp)),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)),
            onPressed: () { SoundManager().playButtonClick(); setState(() => _engine.stand()); _doBotTurn(); },
            child: Text('قف! (${s.playerTotal})', style: GoogleFonts.cairo(color: Colors.white, fontSize: 12.sp)),
          ),
        ],
      );
    }
    if (s.phase == Bg31Phase.gameOver) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h)),
        onPressed: () => setState(() { _engine.newRound(); _botThinking = false; }),
        child: Text('جولة جديدة', style: GoogleFonts.cairo(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.bold)),
      );
    }
    return const SizedBox.shrink();
  }

  void _doBotTurn() {
    if (_botThinking) return;
    setState(() => _botThinking = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) { _engine.executeBotTurn(); setState(() => _botThinking = false); }
    });
  }
}
