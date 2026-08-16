import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';
import '../../../core/game_engine/dice.dart';
import '../../../core/game_engine/games/backgammon/backgammon_engine.dart';

class BackgammonClassicGameScreen extends StatefulWidget {
  const BackgammonClassicGameScreen({super.key});
  @override State<BackgammonClassicGameScreen> createState() => _BackgammonClassicGameScreenState();
}

class _BackgammonClassicGameScreenState extends State<BackgammonClassicGameScreen> {
  final _engine = BackgammonEngine();
  int? _selectedPoint;
  bool _botThinking = false;

  @override Widget build(BuildContext context) {
    final s = _engine.state;
    return Scaffold(
      backgroundColor: const Color(0xFF1E1005),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(s),
              Expanded(
                child: Row(
                  children: [
                    // Board area
                    Expanded(child: _buildBoard(s)),
                    // Side controls / dice
                    Container(
                      width: 140.w,
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      color: Colors.black38,
                      child: _buildSideControls(s),
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

  Widget _buildTopBar(BackgammonState s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
    color: Colors.black54,
    child: Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFFD700), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        SizedBox(width: 6.w),
        Text('طاولة كلاسيك 🎲', style: GoogleFonts.cairo(fontSize: 13.sp, color: const Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        SizedBox(width: 12.w),
        _bornBadge('أنت (أبيض)', s.whiteBorne, s.whiteBar, Colors.white),
        SizedBox(width: 8.w),
        _bornBadge('البوت (أسود)', s.blackBorne, s.blackBar, Colors.brown.shade300),
        const Spacer(),
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10.r)),
            child: Text(s.message, style: GoogleFonts.cairo(color: Colors.amber, fontSize: 11.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        const Spacer(),
        if (_botThinking)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFFFD700), strokeWidth: 2)),
          ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.refresh, color: Colors.white54, size: 18),
          onPressed: () => setState(() { _engine.reset(); _selectedPoint = null; _botThinking = false; }),
        ),
      ],
    ),
  );

  Widget _bornBadge(String name, int bornOff, int bar, Color c) => Container(
    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r), border: Border.all(color: c.withValues(alpha: 0.3))),
    child: Text('$name: $bornOff/15 ${bar > 0 ? " (بار:$bar)" : ""}', style: GoogleFonts.cairo(color: c, fontSize: 10.sp)),
  );

  Widget _buildBoard(BackgammonState s) {
    return Container(
      margin: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: const Color(0xFF5C3310),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        children: [
          // Top row (points 13-24)
          Expanded(
            child: Row(
              children: List.generate(12, (i) {
                final pt = 13 + i;
                return Expanded(child: _buildPoint(s, pt, isTop: true));
              }),
            ),
          ),
          // Center Bar
          Container(
            height: 22.h,
            color: Colors.brown.shade900,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (s.whiteBar > 0)
                  ...List.generate(s.whiteBar.clamp(0, 3), (_) => Container(
                    width: 14.w, height: 10.h, margin: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black54)),
                  )),
                SizedBox(width: 8.w),
                Text('BAR', style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                SizedBox(width: 8.w),
                if (s.blackBar > 0)
                  ...List.generate(s.blackBar.clamp(0, 3), (_) => Container(
                    width: 14.w, height: 10.h, margin: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(color: Colors.brown.shade900, shape: BoxShape.circle, border: Border.all(color: Colors.white54)),
                  )),
              ],
            ),
          ),
          // Bottom row (points 12-1)
          Expanded(
            child: Row(
              children: List.generate(12, (i) {
                final pt = 12 - i;
                return Expanded(child: _buildPoint(s, pt, isTop: false));
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoint(BackgammonState s, int pt, {required bool isTop}) {
    final point = pt >= 1 && pt <= 24 ? s.points[pt] : BgPoint();
    final validTargets = _selectedPoint != null
        ? _engine.getValidMoves(s.turn).where((m) => m.from == _selectedPoint).map((m) => m.to).toSet()
        : <int>{};
    final isValidTarget = validTargets.contains(pt);
    final isSelected = _selectedPoint == pt;
    final triColor = pt % 2 == 0 ? const Color(0xFFCC2200) : const Color(0xFFCCA800);

    return GestureDetector(
      onTap: () => _onPointTap(s, pt),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.withValues(alpha: 0.4)
              : isValidTarget ? Colors.blue.withValues(alpha: 0.3) : Colors.transparent,
          border: isValidTarget ? Border.all(color: Colors.blue, width: 1.5) : null,
        ),
        child: Column(
          verticalDirection: isTop ? VerticalDirection.down : VerticalDirection.up,
          children: [
            Container(
              height: 4.h,
              decoration: BoxDecoration(
                color: triColor,
                borderRadius: isTop
                    ? const BorderRadius.only(topLeft: Radius.circular(3), topRight: Radius.circular(3))
                    : const BorderRadius.only(bottomLeft: Radius.circular(3), bottomRight: Radius.circular(3)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    ...List.generate(point.count.clamp(0, 5), (i) => Padding(
                      padding: EdgeInsets.all(0.5.w),
                      child: Container(
                        width: 14.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: point.owner == BgPlayer.white ? Colors.white : Colors.brown.shade900,
                          shape: BoxShape.circle,
                          border: Border.all(color: point.owner == BgPlayer.white ? Colors.black54 : Colors.white38),
                        ),
                      ),
                    )),
                    if (point.count > 5)
                      Text('+${point.count - 5}', style: TextStyle(color: Colors.white, fontSize: 7.sp)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideControls(BackgammonState s) => Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      // Turn indicator
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: s.turn == BgPlayer.white ? const Color(0xFFFFD700).withValues(alpha: 0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(s.turn == BgPlayer.white ? Icons.person : Icons.smart_toy, color: s.turn == BgPlayer.white ? const Color(0xFFFFD700) : Colors.white54, size: 14),
            SizedBox(width: 4.w),
            Text(s.turn == BgPlayer.white ? 'دورك' : 'دور البوت', style: GoogleFonts.cairo(color: s.turn == BgPlayer.white ? const Color(0xFFFFD700) : Colors.white54, fontSize: 11.sp)),
          ],
        ),
      ),
      // Dice display
      if (s.dice.isNotEmpty)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4.w,
          children: [
            ...s.dice.map((d) => Container(
              width: 32.w, height: 32.w,
              decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(6.r), border: Border.all(color: const Color(0xFFFFD700), width: 1.5)),
              child: Center(child: Text(Dice.face(d), style: TextStyle(fontSize: 18.sp))),
            )),
          ],
        ),
      // Roll Button
      if (s.phase == BgPhase.rolling && s.turn == BgPlayer.white)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100), padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h)),
          onPressed: () { SoundManager().playDiceRoll(); setState(() => _engine.rollDice()); },
          icon: const Icon(Icons.casino, color: Colors.white, size: 16),
          label: Text('ارمِ الزهر', style: GoogleFonts.cairo(color: Colors.white, fontSize: 12.sp)),
        ),
      if (s.phase == BgPhase.gameOver)
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h)),
          onPressed: () => setState(() { _engine.reset(); _selectedPoint = null; }),
          child: Text('لعبة جديدة', style: GoogleFonts.cairo(color: Colors.black, fontSize: 11.sp, fontWeight: FontWeight.bold)),
        ),
    ],
  );

  void _onPointTap(BackgammonState s, int pt) {
    if (s.phase != BgPhase.moving || s.turn != BgPlayer.white) return;
    if (_selectedPoint == null) {
      final hasMoves = _engine.getValidMoves(BgPlayer.white).any((m) => m.from == pt || (pt == 0 && m.from == 0));
      if (!hasMoves) return;
      setState(() => _selectedPoint = pt);
    } else {
      final moves = _engine.getValidMoves(BgPlayer.white).where((m) => m.from == _selectedPoint && m.to == pt).toList();
      if (moves.isNotEmpty) {
        SoundManager().playButtonClick();
        setState(() { _engine.makeMove(moves.first); _selectedPoint = null; });
        if (_engine.state.turn == BgPlayer.black && _engine.state.phase != BgPhase.gameOver) _doBotTurn();
      } else {
        setState(() => _selectedPoint = pt);
      }
    }
  }

  void _doBotTurn() {
    if (_botThinking) return;
    setState(() => _botThinking = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        if (_engine.state.phase == BgPhase.rolling) _engine.executeBotRoll();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            _engine.executeBotMove();
            SoundManager().playButtonClick();
            setState(() => _botThinking = false);
          }
        });
      }
    });
  }
}
