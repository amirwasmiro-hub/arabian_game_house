import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';
import '../../../core/game_engine/games/estimation/estimation_engine.dart';
import '../../../core/game_engine/playing_card.dart';

class EstimationGameScreen extends StatefulWidget {
  const EstimationGameScreen({super.key});
  @override State<EstimationGameScreen> createState() => _EstimationGameScreenState();
}

class _EstimationGameScreenState extends State<EstimationGameScreen> {
  final _engine = EstimationEngine();
  bool _botThinking = false;

  @override Widget build(BuildContext context) {
    final s = _engine.state;
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F0A),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(s),
              Expanded(child: _buildTableCenter(s)),
              _buildBottomSection(s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(EstimationState s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
    color: Colors.black54,
    child: Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4CAF50), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        SizedBox(width: 6.w),
        Text('الاستميشن 🎴', style: GoogleFonts.cairo(fontSize: 13.sp, color: const Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
        SizedBox(width: 12.w),
        // Score items for 4 players
        ...List.generate(4, (i) {
          final active = s.currentPlayer == i;
          return Container(
            margin: EdgeInsets.only(left: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF4CAF50).withValues(alpha: 0.25) : Colors.white10,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: active ? const Color(0xFF4CAF50) : Colors.white24),
            ),
            child: Text(
              '${EstimationEngine.names[i]}: ${s.totalScores[i]}ن (ت:${s.bids[i] >= 0 ? s.bids[i] : "-"})',
              style: GoogleFonts.cairo(color: active ? const Color(0xFF4CAF50) : Colors.white70, fontSize: 9.sp),
            ),
          );
        }),
        const Spacer(),
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8.r)),
            child: Text(s.message, style: GoogleFonts.cairo(color: const Color(0xFF4CAF50), fontSize: 11.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        const Spacer(),
        if (_botThinking)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFF4CAF50), strokeWidth: 2)),
          ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.refresh, color: Colors.white38, size: 18),
          onPressed: () => setState(() { _engine.reset(); _botThinking = false; }),
        ),
      ],
    ),
  );

  Widget _buildTableCenter(EstimationState s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Stack(
        children: [
          // Bot 2 (Top Center)
          Align(
            alignment: Alignment.topCenter,
            child: _botBadge(EstimationEngine.names[2], s.hands[2].length, s.currentPlayer == 2),
          ),
          // Bot 1 (Right)
          Align(
            alignment: Alignment.centerRight,
            child: _botBadge(EstimationEngine.names[1], s.hands[1].length, s.currentPlayer == 1),
          ),
          // Bot 3 (Left)
          Align(
            alignment: Alignment.centerLeft,
            child: _botBadge(EstimationEngine.names[3], s.hands[3].length, s.currentPlayer == 3),
          ),
          // Center trick
          Center(
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: const Color(0xFF143D14).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.white12)),
              child: s.currentTrick.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      child: Text('الأرضية', style: GoogleFonts.cairo(color: Colors.white24, fontSize: 11.sp)),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: s.currentTrick.map((c) => _cardWidget(c, playable: false, isSmall: true)).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botBadge(String name, int count, bool isActive) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: isActive ? Colors.green.withValues(alpha: 0.3) : Colors.white10,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: isActive ? Colors.green : Colors.white24, width: isActive ? 1.5 : 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.smart_toy, color: isActive ? Colors.green : Colors.white38, size: 12.r),
        SizedBox(width: 4.w),
        Text('$name ($count🃏)', style: GoogleFonts.cairo(color: isActive ? Colors.green : Colors.white54, fontSize: 10.sp)),
      ],
    ),
  );

  Widget _buildBottomSection(EstimationState s) {
    if (s.phase == EstPhase.bidding) return _buildBidding(s);
    if (s.phase == EstPhase.roundOver) return _buildEndPanel(s);

    return Container(
      height: 75.h,
      color: Colors.black38,
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        children: s.hands[0].map((c) {
          final playable = s.currentPlayer == 0 && s.phase == EstPhase.playing;
          return GestureDetector(
            onTap: !playable ? null : () {
              SoundManager().playButtonClick();
              if (_engine.playCard(c)) {
                setState(() {});
                if (_engine.state.currentPlayer != 0 && _engine.state.phase == EstPhase.playing) _runBots();
              }
            },
            child: _cardWidget(c, playable: playable),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBidding(EstimationState s) => Container(
    height: 75.h,
    color: Colors.black45,
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('توقع الأكلات:', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11.sp)),
        SizedBox(width: 8.w),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(14, (i) => GestureDetector(
                onTap: () { SoundManager().playButtonClick(); setState(() => _engine.playerBid(i)); },
                child: Container(
                  width: 30.w, height: 30.h, margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(color: const Color(0xFF4CAF50).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6.r), border: Border.all(color: const Color(0xFF4CAF50))),
                  child: Center(child: Text('$i', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp))),
                ),
              )),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildEndPanel(EstimationState s) => Container(
    height: 75.h,
    color: Colors.black45,
    padding: EdgeInsets.symmetric(horizontal: 12.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(s.message, style: GoogleFonts.cairo(color: Colors.amber, fontSize: 13.sp, fontWeight: FontWeight.bold)),
        SizedBox(width: 16.w),
        ElevatedButton(
          onPressed: () => setState(() { _engine.reset(); _botThinking = false; }),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h)),
          child: Text('جولة جديدة', style: GoogleFonts.cairo(color: Colors.white, fontSize: 11.sp)),
        ),
      ],
    ),
  );

  Widget _cardWidget(PlayingCard card, {bool playable = true, bool isSmall = false}) {
    final isRed = card.isRed;
    return Container(
      width: isSmall ? 32.w : 40.w,
      height: isSmall ? 50.h : 64.h,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: playable ? Colors.green : Colors.grey.shade400, width: playable ? 2 : 1),
        boxShadow: playable ? [BoxShadow(color: Colors.green.withValues(alpha: 0.4), blurRadius: 6)] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(card.suitSymbol, style: TextStyle(color: isRed ? Colors.red : Colors.black, fontSize: isSmall ? 10.sp : 13.sp)),
          Text(card.rankSymbol, style: TextStyle(color: isRed ? Colors.red : Colors.black, fontSize: isSmall ? 9.sp : 11.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _runBots() async {
    if (_botThinking) return;
    setState(() => _botThinking = true);
    while (_engine.state.currentPlayer != 0 && _engine.state.phase == EstPhase.playing) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) break;
      _engine.executeBotTurn();
      SoundManager().playButtonClick();
      if (mounted) setState(() {});
    }
    if (mounted) setState(() => _botThinking = false);
  }
}
