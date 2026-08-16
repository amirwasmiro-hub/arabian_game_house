import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';
import '../../../core/game_engine/games/ludo/ludo_engine.dart';

class LudoGameScreen extends StatefulWidget {
  const LudoGameScreen({super.key});
  @override State<LudoGameScreen> createState() => _LudoGameScreenState();
}

class _LudoGameScreenState extends State<LudoGameScreen> {
  final _engine = LudoEngine();
  bool _botThinking = false;

  static const _playerColors = [
    Color(0xFFE53935), Color(0xFF43A047), Color(0xFF1E88E5), Color(0xFFFFB300),
  ];

  @override Widget build(BuildContext context) {
    final s = _engine.state;
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A2E),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(s),
              Expanded(
                child: Row(
                  children: [
                    // Side Controls
                    Container(
                      width: 200.w,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      color: Colors.black26,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPlayersList(s),
                          _buildDiceSection(s),
                        ],
                      ),
                    ),
                    VerticalDivider(color: Colors.white12, width: 1),
                    // Center Board
                    Expanded(
                      child: Center(
                        child: _buildBoard(s),
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

  Widget _buildTopBar(LudoState s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
    color: Colors.black54,
    child: Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFE91E63), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        SizedBox(width: 6.w),
        Text('لودو 🎯', style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFFE91E63), fontWeight: FontWeight.bold)),
        const Spacer(),
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8.r)),
            child: Text(s.message, style: GoogleFonts.cairo(color: Colors.amber, fontSize: 11.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        const Spacer(),
        if (_botThinking)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFE91E63), strokeWidth: 2)),
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

  Widget _buildPlayersList(LudoState s) => Wrap(
    spacing: 4.w,
    runSpacing: 4.h,
    alignment: WrapAlignment.center,
    children: List.generate(4, (i) {
      final color = _playerColors[i];
      final isActive = s.currentPlayer == i;
      final rank = s.winners.indexOf(i);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.3) : Colors.white10,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: isActive ? color : Colors.white24, width: isActive ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(LudoEngine.colorEmoji[i], style: TextStyle(fontSize: 12.sp)),
            SizedBox(width: 3.w),
            Text(LudoEngine.colorNames[i], style: GoogleFonts.cairo(color: isActive ? color : Colors.white54, fontSize: 9.sp)),
            if (rank >= 0) ...[
              SizedBox(width: 2.w),
              Text('#${rank+1}', style: GoogleFonts.cairo(color: Colors.amber, fontSize: 8.sp, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      );
    }),
  );

  Widget _buildBoard(LudoState s) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final size = (constraints.maxHeight - 12).clamp(180.0, 320.0);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [BoxShadow(color: const Color(0xFFE91E63).withValues(alpha: 0.2), blurRadius: 15)],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 15),
            itemCount: 225,
            itemBuilder: (_, idx) {
              final row = idx ~/ 15, col = idx % 15;
              final isSafe = LudoEngine.safes.contains((row * 15 + col) % 52);
              return Container(color: _cellColor(row, col, isSafe), child: _cellContent(row, col, s));
            },
          ),
        );
      },
    );
  }

  Color _cellColor(int r, int c, bool safe) {
    if (r < 6 && c < 6) return const Color(0xFFE53935).withValues(alpha: 0.6);
    if (r < 6 && c > 8) return const Color(0xFF43A047).withValues(alpha: 0.6);
    if (r > 8 && c < 6) return const Color(0xFFFFB300).withValues(alpha: 0.6);
    if (r > 8 && c > 8) return const Color(0xFF1E88E5).withValues(alpha: 0.6);
    if (r == 7 && c == 7) return const Color(0xFF4A148C);
    if (safe) return Colors.white.withValues(alpha: 0.2);
    return Colors.black26;
  }

  Widget? _cellContent(int r, int c, LudoState s) {
    for (int p = 0; p < 4; p++) {
      for (final t in s.tokens[p]) {
        if (t.isHome || t.isFinished) continue;
        final absPos = (LudoEngine.starts[p]! + t.position) % 52;
        final gridPos = _trackPos(absPos);
        if (gridPos != null && gridPos[0] == r && gridPos[1] == c) {
          return Center(
            child: Container(
              width: 10.w, height: 10.w,
              decoration: BoxDecoration(color: _playerColors[p], shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1)),
            ),
          );
        }
      }
    }
    return null;
  }

  List<int>? _trackPos(int pos) {
    final track = [
      [6,1],[6,2],[6,3],[6,4],[6,5],[5,6],[4,6],[3,6],[2,6],[1,6],[0,6],
      [0,7],[0,8],[1,8],[2,8],[3,8],[4,8],[5,8],[6,9],[6,10],[6,11],[6,12],[6,13],[6,14],
      [7,14],[8,14],[8,13],[8,12],[8,11],[8,10],[8,9],[9,8],[10,8],[11,8],[12,8],[13,8],
      [14,8],[14,7],[14,6],[13,6],[12,6],[11,6],[10,6],[9,6],[8,5],[8,4],[8,3],[8,2],[8,1],[8,0],
      [7,0],[6,0],
    ];
    if (pos >= 0 && pos < track.length) return track[pos];
    return null;
  }

  Widget _buildDiceSection(LudoState s) {
    if (s.phase == LudoPhase.gameOver) {
      return ElevatedButton(
        onPressed: () => setState(() { _engine.reset(); _botThinking = false; }),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63)),
        child: Text('لعبة جديدة', style: GoogleFonts.cairo(color: Colors.white, fontSize: 11.sp)),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (s.diceValue > 0)
          Container(
            width: 38.w, height: 38.h,
            decoration: BoxDecoration(color: _playerColors[s.currentPlayer], borderRadius: BorderRadius.circular(8.r)),
            child: Center(child: Text('${s.diceValue}', style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white))),
          ),
        SizedBox(height: 6.h),
        if (s.currentPlayer == 0 && s.phase == LudoPhase.rolling)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63), padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h)),
            onPressed: () {
              SoundManager().playDiceRoll();
              _engine.roll();
              setState(() {});
              if (_engine.state.phase == LudoPhase.moving && _engine.state.movableTokenIds.isEmpty) {
                _runBots();
              } else if (_engine.state.currentPlayer != 0) {
                _runBots();
              }
            },
            icon: const Icon(Icons.casino, color: Colors.white, size: 16),
            label: Text('ارمِ الزهر', style: GoogleFonts.cairo(color: Colors.white, fontSize: 11.sp)),
          ),
        if (s.currentPlayer == 0 && s.phase == LudoPhase.moving) ...[
          Text('اختر قطعة:', style: GoogleFonts.cairo(color: Colors.amber, fontSize: 10.sp)),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 4.w,
            children: s.movableTokenIds.map((id) => GestureDetector(
              onTap: () {
                SoundManager().playButtonClick();
                setState(() => _engine.moveToken(id));
                if (_engine.state.currentPlayer != 0) _runBots();
              },
              child: Container(
                width: 28.w, height: 28.h,
                decoration: BoxDecoration(color: const Color(0xFFE53935), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                child: Center(child: Text('${id+1}', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp))),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  void _runBots() async {
    if (_botThinking) return;
    setState(() => _botThinking = true);
    while (_engine.state.currentPlayer != 0 && _engine.state.phase != LudoPhase.gameOver) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) break;
      _engine.botRollAndMove();
      SoundManager().playButtonClick();
      if (mounted) setState(() {});
    }
    if (mounted) setState(() => _botThinking = false);
  }
}
