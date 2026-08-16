import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';
import '../../../core/game_engine/games/domino/domino_engine.dart';
import '../../../core/game_engine/games/domino/domino_piece.dart';

class DominoClassicGameScreen extends StatefulWidget {
  const DominoClassicGameScreen({super.key});
  @override State<DominoClassicGameScreen> createState() => _DominoClassicGameScreenState();
}

class _DominoClassicGameScreenState extends State<DominoClassicGameScreen> {
  final _engine = DominoEngine(mode: DominoMode.classic);
  DominoPiece? _selected;
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
              Expanded(child: _buildChainArea(s)),
              _buildBottomSection(s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(DominoState s) => Container(
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
        Text('دومينو كلاسيكية 🀄', style: GoogleFonts.cairo(fontSize: 13.sp, color: const Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        SizedBox(width: 12.w),
        _scoreBadge('أنت', s.playerWins, s.playerScore, const Color(0xFFFFD700)),
        SizedBox(width: 6.w),
        _scoreBadge('البوت', s.botWins, s.botScore, Colors.white54),
        SizedBox(width: 8.w),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy, color: Colors.white38, size: 14),
            SizedBox(width: 3.w),
            Text('${s.botHand.length}', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 11.sp)),
          ],
        ),
        const Spacer(),
        Flexible(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              s.message,
              style: GoogleFonts.cairo(color: Colors.amber, fontSize: 11.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Spacer(),
        if (_botThinking)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFFFD700), strokeWidth: 2)),
          ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.refresh, color: Colors.white54, size: 18),
          onPressed: () => setState(() { _engine.newGame(); _selected = null; _botThinking = false; }),
        ),
      ],
    ),
  );

  Widget _scoreBadge(String name, int wins, int score, Color c) => Container(
    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6.r),
      border: Border.all(color: c.withValues(alpha: 0.3)),
    ),
    child: Text('$name: 🏆$wins (${score}ن)', style: GoogleFonts.cairo(color: c, fontSize: 10.sp)),
  );

  Widget _buildChainArea(DominoState s) {
    if (s.chain.isEmpty) {
      return Center(
        child: Text('ضع أول حجر للبدء!', style: GoogleFonts.cairo(color: Colors.white24, fontSize: 13.sp)),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
          child: Row(
            children: [
              _endTag(s.leftEnd, 'يسار', const Color(0xFF4CAF50)),
              const Spacer(),
              _endTag(s.rightEnd, 'يمين', const Color(0xFF2196F3)),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: s.chain.map((p) => _tile(p, onTable: true)).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _endTag(int? v, String label, Color c) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6.r), border: Border.all(color: c)),
    child: Text('$label: $v', style: GoogleFonts.cairo(color: c, fontWeight: FontWeight.bold, fontSize: 10.sp)),
  );

  Widget _buildBottomSection(DominoState s) {
    if (s.phase == DominoPhase.roundOver) {
      return Container(
        height: 80.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        color: Colors.black45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(s.message, style: GoogleFonts.cairo(color: Colors.amber, fontSize: 13.sp, fontWeight: FontWeight.bold)),
            SizedBox(width: 16.w),
            ElevatedButton(
              onPressed: () => setState(() { _engine.newGame(); _selected = null; }),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h)),
              child: Text('جولة جديدة', style: GoogleFonts.cairo(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    final valid = s.validMovesFor(s.playerHand);
    return Container(
      height: 78.h,
      color: Colors.black45,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('الكومة: ${s.boneyard.length}', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 9.sp)),
              SizedBox(height: 2.h),
              if (s.turn == DominoTurn.player && s.phase == DominoPhase.playing && valid.isEmpty && s.boneyard.isNotEmpty)
                GestureDetector(
                  onTap: () { SoundManager().playButtonClick(); setState(() => _engine.playerDraw()); _checkBot(); },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6.r), border: Border.all(color: Colors.orange)),
                    child: Text('سحب 🎲', style: GoogleFonts.cairo(color: Colors.orange, fontSize: 9.sp)),
                  ),
                )
              else if (s.turn == DominoTurn.player && valid.isEmpty && s.boneyard.isEmpty)
                GestureDetector(
                  onTap: () { SoundManager().playButtonClick(); setState(() => _engine.playerPlay(s.playerHand.first)); },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6.r), border: Border.all(color: Colors.red)),
                    child: Text('مرر', style: GoogleFonts.cairo(color: Colors.red, fontSize: 9.sp)),
                  ),
                ),
            ],
          ),
          SizedBox(width: 6.w),
          VerticalDivider(color: Colors.white12, width: 1),
          SizedBox(width: 6.w),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              children: s.playerHand.map((p) {
                final isV = valid.contains(p);
                final isSel = _selected == p;
                return GestureDetector(
                  onTap: s.turn != DominoTurn.player || s.phase != DominoPhase.playing ? null : () {
                    if (!isV) return;
                    SoundManager().playButtonClick();
                    if (isSel) _showPlace(p); else setState(() => _selected = p);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    transform: isSel ? (Matrix4.identity()..translate(0.0, -4.0)) : Matrix4.identity(),
                    child: _tile(p, isValid: isV, isSelected: isSel),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(DominoPiece p, {bool onTable = false, bool isValid = true, bool isSelected = false}) => Container(
    width: onTable ? 28.w : 34.w,
    height: onTable ? 44.h : 54.h,
    margin: EdgeInsets.all(2.w),
    decoration: BoxDecoration(
      color: onTable ? Colors.white : isValid ? Colors.white : Colors.grey.shade800,
      borderRadius: BorderRadius.circular(4.r),
      border: Border.all(color: isSelected ? const Color(0xFFFFD700) : onTable ? Colors.black54 : isValid ? const Color(0xFFFFD700).withValues(alpha: 0.6) : Colors.white12, width: isSelected ? 2 : 1),
      boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.5), blurRadius: 6)] : null,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('${p.a}', style: GoogleFonts.montserrat(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: onTable ? 10.sp : 11.sp)),
        Divider(color: Colors.black54, height: 1),
        Text('${p.b}', style: GoogleFonts.montserrat(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: onTable ? 10.sp : 11.sp)),
      ],
    ),
  );

  void _showPlace(DominoPiece p) {
    final s = _engine.state;
    if (s.chain.isEmpty) { setState(() { _engine.playerPlay(p); _selected = null; }); _checkBot(); return; }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2D1A08),
        title: Text('ضع الحجر', style: GoogleFonts.cairo(color: const Color(0xFFFFD700))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (p.canFit(s.leftEnd!))
              ListTile(
                leading: const Icon(Icons.arrow_back, color: Colors.green),
                title: Text('يسار (${s.leftEnd})', style: GoogleFonts.cairo(color: Colors.white)),
                onTap: () { Navigator.pop(ctx); setState(() { _engine.playerPlay(p, onLeft: true); _selected = null; }); _checkBot(); },
              ),
            if (p.canFit(s.rightEnd!))
              ListTile(
                leading: const Icon(Icons.arrow_forward, color: Colors.blue),
                title: Text('يمين (${s.rightEnd})', style: GoogleFonts.cairo(color: Colors.white)),
                onTap: () { Navigator.pop(ctx); setState(() { _engine.playerPlay(p, onLeft: false); _selected = null; }); _checkBot(); },
              ),
          ],
        ),
      ),
    );
  }

  void _checkBot() {
    if (_engine.state.turn == DominoTurn.bot && _engine.state.phase == DominoPhase.playing && !_botThinking) {
      setState(() => _botThinking = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _engine.executeBotTurn();
          SoundManager().playButtonClick();
          setState(() => _botThinking = false);
          if (_engine.state.turn == DominoTurn.bot) _checkBot();
        }
      });
    }
  }
}
