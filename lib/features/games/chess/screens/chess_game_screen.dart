import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/audio/sound_manager.dart';
import '../logic/chess_engine.dart';

class ChessGameScreen extends StatefulWidget {
  const ChessGameScreen({super.key});
  @override State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  final _engine = ChessEngine();
  bool _botThinking = false;

  @override Widget build(BuildContext context) {
    final s = _engine.state;
    return Scaffold(
      backgroundColor: const Color(0xFF140D07),
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
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: 240.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildPlayerTag('البوت (أسود)', Icons.smart_toy, Colors.white54, s.turn == ChessColor.black),
                                SizedBox(height: 6.h),
                                _buildStatusCard(s),
                                SizedBox(height: 6.h),
                                _buildPlayerTag('أنت (أبيض)', Icons.person, const Color(0xFFFFD700), s.turn == ChessColor.white),
                                SizedBox(height: 8.h),
                                _buildActions(s),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(color: Colors.white12, width: 1),
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

  Widget _buildHeader(ChessState s) => Container(
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
        Text('الشطرنج ♟️', style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFFFFD700), fontWeight: FontWeight.bold)),
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
          icon: const Icon(Icons.refresh, color: Colors.white60, size: 20),
          onPressed: () => setState(() { _engine.reset(); _botThinking = false; }),
        ),
      ],
    ),
  );

  Widget _buildPlayerTag(String name, IconData icon, Color color, bool isTurn) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: isTurn ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: isTurn ? color : Colors.white12, width: isTurn ? 1.5 : 1),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 16.r),
        SizedBox(width: 6.w),
        Text(name, style: GoogleFonts.cairo(color: color, fontSize: 12.sp, fontWeight: isTurn ? FontWeight.bold : FontWeight.normal)),
        const Spacer(),
        if (isTurn)
          Container(
            width: 8.w, height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
      ],
    ),
  );

  Widget _buildStatusCard(ChessState s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: _statusColor(s).withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: _statusColor(s).withValues(alpha: 0.4)),
    ),
    child: Row(
      children: [
        Icon(_statusIcon(s), color: _statusColor(s), size: 18.r),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            s.message,
            style: GoogleFonts.cairo(color: _statusColor(s), fontSize: 11.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  Color _statusColor(ChessState s) {
    switch (s.phase) {
      case ChessPhase.check: return Colors.orange;
      case ChessPhase.checkmate: return Colors.greenAccent;
      case ChessPhase.stalemate: return Colors.blueAccent;
      default: return s.turn == ChessColor.white ? const Color(0xFFFFD700) : Colors.white54;
    }
  }

  IconData _statusIcon(ChessState s) {
    switch (s.phase) {
      case ChessPhase.check: return Icons.warning_amber_rounded;
      case ChessPhase.checkmate: return Icons.emoji_events;
      case ChessPhase.stalemate: return Icons.handshake;
      default: return s.turn == ChessColor.white ? Icons.person : Icons.smart_toy;
    }
  }

  Widget _buildBoard(ChessState s) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final size = (constraints.maxHeight - 16).clamp(180.0, 320.0);
        final cellSize = size / 8;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.25), blurRadius: 15)],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
            itemCount: 64,
            itemBuilder: (ctx, idx) {
              final row = idx ~/ 8, col = idx % 8;
              final isLight = (row + col) % 2 == 0;
              final piece = s.board[row][col];
              final isSelected = s.selectedRow == row && s.selectedCol == col;
              final isValidTarget = s.validMoves.any((m) => m.toRow == row && m.toCol == col);
              final isLastMove = s.lastMove != null &&
                ((s.lastMove!.fromRow == row && s.lastMove!.fromCol == col) ||
                 (s.lastMove!.toRow == row && s.lastMove!.toCol == col));

              Color bgColor = isLight ? const Color(0xFFE8D5B7) : const Color(0xFF4A2C0A);
              if (isSelected) bgColor = const Color(0xFF6BAE3C);
              if (isLastMove) bgColor = bgColor.withValues(alpha: 0.7);

              return GestureDetector(
                onTap: () {
                  if (s.phase == ChessPhase.checkmate || s.phase == ChessPhase.stalemate || _botThinking) return;
                  if (s.turn != ChessColor.white) return;
                  SoundManager().playButtonClick();
                  setState(() => _engine.selectSquare(row, col));
                  if (_engine.state.turn == ChessColor.black && _engine.state.phase != ChessPhase.checkmate) {
                    _doBotMove();
                  }
                },
                child: Container(
                  color: bgColor,
                  child: Stack(
                    children: [
                      if (isValidTarget)
                        Center(
                          child: Container(
                            width: piece != null ? cellSize * 0.85 : cellSize * 0.35,
                            height: piece != null ? cellSize * 0.85 : cellSize * 0.35,
                            decoration: BoxDecoration(
                              shape: piece != null ? BoxShape.rectangle : BoxShape.circle,
                              border: piece != null ? Border.all(color: const Color(0xFF6BAE3C), width: 2.5) : null,
                              color: piece == null ? const Color(0xFF6BAE3C).withValues(alpha: 0.6) : null,
                            ),
                          ),
                        ),
                      if (piece != null)
                        Center(
                          child: Text(
                            piece.symbol,
                            style: TextStyle(
                              fontSize: cellSize * 0.65,
                              color: piece.color == ChessColor.white ? const Color(0xFFFFFFFF) : const Color(0xFF111111),
                              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActions(ChessState s) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _actionBtn(Icons.flag, 'استسلام', () => setState(() => _engine.reset())),
      SizedBox(width: 8.w),
      _actionBtn(Icons.lightbulb, 'تلميح', () {
        if (s.validMoves.isNotEmpty) {
          final m = s.validMoves.first;
          setState(() => _engine.selectSquare(m.fromRow, m.fromCol));
        }
      }),
    ],
  );

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 14.r),
            SizedBox(width: 4.w),
            Text(label, style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11.sp)),
          ],
        ),
      ),
    ),
  );

  Future<void> _doBotMove() async {
    if (_botThinking) return;
    setState(() => _botThinking = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      _engine.executeBotMove();
      SoundManager().playButtonClick();
      setState(() => _botThinking = false);
    }
  }
}
