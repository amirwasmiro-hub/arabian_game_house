import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/audio/sound_manager.dart';
import '../logic/uno_engine.dart';

class UnoGameScreen extends StatefulWidget {
  const UnoGameScreen({super.key});
  @override State<UnoGameScreen> createState() => _UnoGameScreenState();
}

class _UnoGameScreenState extends State<UnoGameScreen> {
  final _engine = UnoEngine();
  bool _botThinking = false;

  static const _colorMap = {
    UnoColor.red: Color(0xFFE53935),
    UnoColor.green: Color(0xFF43A047),
    UnoColor.blue: Color(0xFF1E88E5),
    UnoColor.yellow: Color(0xFFFFB300),
    UnoColor.wild: Color(0xFF4A4A4A),
  };

  @override Widget build(BuildContext context) {
    final s = _engine.state;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(s),
              Expanded(child: _buildCenterArea(s)),
              _buildPlayerHand(s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(UnoState s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
    color: Colors.black54,
    child: Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.deepPurpleAccent, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        SizedBox(width: 6.w),
        Text('UNO! 🃏', style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
        SizedBox(width: 12.w),
        ...List.generate(3, (i) {
          final p = i + 1;
          final active = s.currentPlayer == p;
          return Container(
            margin: EdgeInsets.only(left: 6.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: active ? Colors.deepPurple.withValues(alpha: 0.4) : Colors.white10,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: active ? Colors.deepPurpleAccent : Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_toy, color: active ? Colors.deepPurpleAccent : Colors.white38, size: 12.r),
                SizedBox(width: 3.w),
                Text('${UnoEngine.names[p]}: ${s.hands[p].length}', style: GoogleFonts.cairo(color: active ? Colors.deepPurpleAccent : Colors.white38, fontSize: 10.sp)),
              ],
            ),
          );
        }),
        const Spacer(),
        if (_botThinking)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.deepPurpleAccent, strokeWidth: 2)),
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

  Widget _buildCenterArea(UnoState s) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8.r)),
          child: Text(s.message, style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11.sp)),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: s.currentPlayer == 0 && s.phase == UnoPhase.playing ? () {
                SoundManager().playButtonClick();
                setState(() => _engine.playerDraw());
                _runBots();
              } : null,
              child: Container(
                width: 48.w, height: 72.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF311B92), Color(0xFF4527A0)]),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.deepPurpleAccent, width: 2),
                  boxShadow: [BoxShadow(color: Colors.deepPurple.withValues(alpha: 0.5), blurRadius: 8)],
                ),
                child: Center(child: Text('UNO', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.sp))),
              ),
            ),
            SizedBox(width: 16.w),
            if (s.topCard != null)
              Container(
                width: 48.w, height: 72.h,
                decoration: BoxDecoration(
                  color: _colorMap[s.chosenColor ?? s.topCard!.color],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: (_colorMap[s.topCard!.color] ?? Colors.white).withValues(alpha: 0.6), blurRadius: 10)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.topCard!.valueStr, style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                    if (s.chosenColor != null && s.topCard!.isWild)
                      Text(_colorName(s.chosenColor!), style: GoogleFonts.cairo(color: Colors.white, fontSize: 7.sp)),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        Icon(s.clockwise ? Icons.rotate_right : Icons.rotate_left, color: Colors.white38, size: 16.r),
        if (s.phase == UnoPhase.choosingColor && s.currentPlayer == 0) _buildColorPicker(),
        if (s.phase == UnoPhase.gameOver) _buildGameOver(s),
      ],
    ),
  );

  Widget _buildColorPicker() => Container(
    margin: EdgeInsets.only(top: 4.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        UnoColor.red, UnoColor.green, UnoColor.blue, UnoColor.yellow,
      ].map((c) => GestureDetector(
        onTap: () {
          SoundManager().playButtonClick();
          setState(() => _engine.playerChooseColor(c));
          _runBots();
        },
        child: Container(
          width: 32.w, height: 32.h, margin: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: _colorMap[c],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: _colorMap[c]!.withValues(alpha: 0.7), blurRadius: 6)],
          ),
        ),
      )).toList(),
    ),
  );

  Widget _buildGameOver(UnoState s) => Container(
    margin: EdgeInsets.only(top: 6.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(s.message, style: GoogleFonts.cairo(color: Colors.amber, fontSize: 13.sp, fontWeight: FontWeight.bold)),
        SizedBox(width: 12.w),
        ElevatedButton(
          onPressed: () => setState(() { _engine.reset(); _botThinking = false; }),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h)),
          child: Text('لعبة جديدة', style: GoogleFonts.cairo(color: Colors.white, fontSize: 11.sp)),
        ),
      ],
    ),
  );

  Widget _buildPlayerHand(UnoState s) {
    final valid = s.phase == UnoPhase.playing ? s.validMoves(0) : <UnoCard>[];
    return Container(
      height: 75.h,
      color: Colors.black38,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        children: s.hands[0].map((c) {
          final isValid = valid.any((v) => v == c);
          return GestureDetector(
            onTap: s.currentPlayer != 0 || !isValid ? null : () {
              SoundManager().playButtonClick();
              _engine.playerPlay(c);
              setState(() {});
              if (_engine.state.phase != UnoPhase.choosingColor) _runBots();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: isValid ? Matrix4.translationValues(0.0, -4.0, 0.0) : Matrix4.identity(),
              child: _unoCard(c, isValid),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _unoCard(UnoCard card, bool playable) => Container(
    width: 40.w, height: 64.h,
    margin: EdgeInsets.symmetric(horizontal: 2.w),
    decoration: BoxDecoration(
      color: _colorMap[card.color],
      borderRadius: BorderRadius.circular(6.r),
      border: Border.all(color: playable ? Colors.white : Colors.transparent, width: playable ? 2 : 0),
      boxShadow: playable ? [BoxShadow(color: (_colorMap[card.color] ?? Colors.white).withValues(alpha: 0.5), blurRadius: 6)] : null,
      gradient: !playable ? LinearGradient(colors: [_colorMap[card.color]!.withValues(alpha: 0.4), _colorMap[card.color]!.withValues(alpha: 0.3)]) : null,
    ),
    child: Center(child: Text(card.valueStr, style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold))),
  );

  String _colorName(UnoColor c) => ['أحمر','أخضر','أزرق','أصفر','وايلد'][c.index];

  void _runBots() async {
    if (_botThinking) return;
    setState(() => _botThinking = true);
    while (_engine.state.currentPlayer != 0 && _engine.state.phase != UnoPhase.gameOver) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) break;
      _engine.executeBotTurn();
      SoundManager().playButtonClick();
      if (mounted) setState(() {});
      if (_engine.state.phase == UnoPhase.choosingColor) break;
    }
    if (mounted) setState(() => _botThinking = false);
  }
}
