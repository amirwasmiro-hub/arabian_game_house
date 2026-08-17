import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/audio/sound_manager.dart';
import '../logic/tarneeb_engine.dart';
import '../models/playing_card.dart';

class TarneebGameScreen extends StatefulWidget {
  const TarneebGameScreen({super.key});
  @override State<TarneebGameScreen> createState() => _TarneebGameScreenState();
}

class _TarneebGameScreenState extends State<TarneebGameScreen> {
  final _engine = TarneebEngine();
  bool _botThinking = false;

  @override Widget build(BuildContext context) {
    final s = _engine.state;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(s),
              Expanded(child: _buildTableCenter(s)),
              _buildPlayerSection(s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(TarneebState s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
    color: Colors.black54,
    child: Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFF2A6D), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        SizedBox(width: 6.w),
        Text('الطرنيب 🎴', style: GoogleFonts.cairo(fontSize: 13.sp, color: const Color(0xFFFF2A6D), fontWeight: FontWeight.bold)),
        SizedBox(width: 12.w),
        _scoreTag('فريقك', s.scores[0], s.tricksWon[0], const Color(0xFFFFD700)),
        SizedBox(width: 6.w),
        _scoreTag('الخصم', s.scores[1], s.tricksWon[1], const Color(0xFFFF2A6D)),
        SizedBox(width: 8.w),
        if (s.trump != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6.r)),
            child: Text('الكبة: ${_suitName(s.trump!)} (مزايدة ${s.bid})', style: GoogleFonts.cairo(color: Colors.amber, fontSize: 10.sp)),
          ),
        const Spacer(),
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8.r)),
            child: Text(s.message, style: GoogleFonts.cairo(color: const Color(0xFFFF2A6D), fontSize: 11.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        const Spacer(),
        if (_botThinking)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFFF2A6D), strokeWidth: 2)),
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

  Widget _scoreTag(String name, int score, int tricks, Color c) => Container(
    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r), border: Border.all(color: c.withValues(alpha: 0.3))),
    child: Text('$name: $scoreن ($tricks أكلات)', style: GoogleFonts.cairo(color: c, fontSize: 10.sp)),
  );

  String _suitName(CardSuit s) => ['♣سباتي','♦ديموني','♥قلب','♠بستوني'][s.index];

  Widget _buildTableCenter(TarneebState s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _botBadge('الشريك', s.hands[2].length, s.currentPlayer == 2),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _botBadge('بوت 1', s.hands[1].length, s.currentPlayer == 1),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: _botBadge('بوت 3', s.hands[3].length, s.currentPlayer == 3),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: const Color(0xFF1A3A5C).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.white12)),
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
      color: isActive ? const Color(0xFFFF2A6D).withValues(alpha: 0.25) : Colors.white10,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: isActive ? const Color(0xFFFF2A6D) : Colors.white24, width: isActive ? 1.5 : 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.smart_toy, color: isActive ? const Color(0xFFFF2A6D) : Colors.white38, size: 12.r),
        SizedBox(width: 4.w),
        Text('$name ($count🃏)', style: GoogleFonts.cairo(color: isActive ? const Color(0xFFFF2A6D) : Colors.white54, fontSize: 10.sp)),
      ],
    ),
  );

  Widget _buildPlayerSection(TarneebState s) {
    if (s.phase == TarneebPhase.bidding) return _buildBidding(s);
    if (s.phase == TarneebPhase.playing && s.trump == null && s.currentPlayer == 0) return _buildTrumpPicker(s);
    if (s.phase == TarneebPhase.roundOver) return _buildRoundOver(s);

    return Container(
      height: 75.h,
      color: Colors.black38,
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        children: s.hands[0].map((c) {
          final playable = s.currentPlayer == 0 && s.phase == TarneebPhase.playing && s.trump != null;
          final canPlay = playable && (s.currentTrick.isEmpty || c.suit == s.currentTrick[0].suit || !s.hands[0].any((x) => x.suit == s.currentTrick[0].suit));
          return GestureDetector(
            onTap: !canPlay ? null : () {
              SoundManager().playButtonClick();
              final ok = _engine.playCard(c);
              setState(() {});
              if (ok && _engine.state.currentPlayer != 0 && _engine.state.phase == TarneebPhase.playing) _doBotTurns();
            },
            child: _cardWidget(c, playable: canPlay),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBidding(TarneebState s) => Container(
    height: 75.h,
    color: Colors.black45,
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('المزايدة:', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11.sp)),
        SizedBox(width: 8.w),
        ...List.generate(7, (i) {
          final bid = i + 7;
          return GestureDetector(
            onTap: () { SoundManager().playButtonClick(); setState(() => _engine.playerBid(bid)); },
            child: Container(
              width: 32.w, height: 32.h, margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(color: const Color(0xFFFF2A6D).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6.r), border: Border.all(color: const Color(0xFFFF2A6D))),
              child: Center(child: Text('$bid', style: GoogleFonts.cairo(color: const Color(0xFFFF2A6D), fontWeight: FontWeight.bold, fontSize: 11.sp))),
            ),
          );
        }),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: () { SoundManager().playButtonClick(); setState(() => _engine.playerPass()); },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6.r), border: Border.all(color: Colors.white38)),
            child: Text('مرر', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 10.sp)),
          ),
        ),
      ],
    ),
  );

  Widget _buildTrumpPicker(TarneebState s) => Container(
    height: 75.h,
    color: Colors.black45,
    padding: EdgeInsets.symmetric(horizontal: 8.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('اختر الكبة:', style: GoogleFonts.cairo(color: const Color(0xFFFF2A6D), fontSize: 12.sp)),
        SizedBox(width: 12.w),
        ...CardSuit.values.map((st) => GestureDetector(
          onTap: () { SoundManager().playButtonClick(); setState(() => _engine.selectTrump(st)); },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8.r), border: Border.all(color: const Color(0xFFFF2A6D))),
            child: Text(_suitName(st), style: GoogleFonts.cairo(color: const Color(0xFFFF2A6D), fontSize: 12.sp, fontWeight: FontWeight.bold)),
          ),
        )),
      ],
    ),
  );

  Widget _buildRoundOver(TarneebState s) => Container(
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
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A6D), padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h)),
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
        border: Border.all(color: playable ? const Color(0xFFFF2A6D) : Colors.grey.shade400, width: playable ? 2 : 1),
        boxShadow: playable ? [BoxShadow(color: const Color(0xFFFF2A6D).withValues(alpha: 0.4), blurRadius: 6)] : null,
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

  void _doBotTurns() async {
    if (_botThinking) return;
    setState(() => _botThinking = true);
    while (_engine.state.currentPlayer != 0 && _engine.state.phase == TarneebPhase.playing) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) break;
      _engine.executeBotTurn();
      SoundManager().playButtonClick();
      if (mounted) setState(() {});
    }
    if (mounted) setState(() => _botThinking = false);
  }
}
