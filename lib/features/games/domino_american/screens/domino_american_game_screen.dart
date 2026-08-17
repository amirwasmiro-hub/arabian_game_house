import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/audio/sound_manager.dart';
import '../logic/domino_american_engine.dart';
import '../models/domino_piece.dart';
import '../widgets/domino_board_layout.dart';
import '../widgets/domino_tile_widget.dart';

class DominoAmericanGameScreen extends StatefulWidget {
  const DominoAmericanGameScreen({super.key});

  @override
  State<DominoAmericanGameScreen> createState() => _DominoAmericanGameScreenState();
}

class _DominoAmericanGameScreenState extends State<DominoAmericanGameScreen> {
  final _engine = DominoAmericanEngine();
  DominoPiece? _selected;
  bool _botThinking = false;
  final DominoTileStyle _currentStyle = DominoTileStyle.classicIvory;

  @override
  void initState() {
    super.initState();
    _engine.startNewGame();
    _checkBotTurn();
  }

  void _checkBotTurn() {
    if (!_engine.isPlayerTurn && !_engine.isGameOver && !_botThinking) {
      _triggerBotPlay();
    }
  }

  void _triggerBotPlay() {
    setState(() => _botThinking = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _engine.triggerBotMove();
      SoundManager().playTilePlace();
      setState(() => _botThinking = false);
      _checkBotTurn();
    });
  }

  void _onTileTap(DominoPiece piece) {
    if (!_engine.isPlayerTurn || _engine.isGameOver) return;

    final validEdges = _engine.getValidEdgesFor(piece);
    if (validEdges.isEmpty) return;

    if (validEdges.length == 1) {
      _engine.playPiece(piece, validEdges.first);
      SoundManager().playTilePlace();
      setState(() => _selected = null);
      _checkBotTurn();
    } else {
      setState(() {
        _selected = (_selected == piece) ? null : piece;
      });
    }
  }

  void _onPlacePiece(DominoPiece piece, DominoEdgeLocation edge) {
    if (!_engine.isPlayerTurn) return;
    _engine.playPiece(piece, edge);
    SoundManager().playTilePlace();
    setState(() => _selected = null);
    _checkBotTurn();
  }

  void _drawFromBoneyard() {
    if (!_engine.isPlayerTurn || _engine.boneyard.isEmpty) return;
    final drawn = _engine.boneyard.removeLast();
    _engine.playerHand.add(drawn);
    SoundManager().playTileDraw();
    setState(() {});
    _checkBotTurn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.r),
                  child: DominoBoardLayout(
                    engine: _engine,
                    selectedPiece: _selected,
                    style: _currentStyle,
                    onPlacePiece: _onPlacePiece,
                  ),
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() => Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          border: Border(bottom: BorderSide(color: const Color(0xFFFFD700).withValues(alpha: 0.3))),
        ),
        child: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFFD700), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 8.w),
            Text(
              'دومينو أمريكاني (All Fives) 🇺🇸',
              style: GoogleFonts.cairo(fontSize: 13.sp, color: const Color(0xFFFFD700), fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 12.w),
            _scoreBadge('أنت', _engine.playerWins, _engine.playerScore, const Color(0xFFFFD700)),
            SizedBox(width: 8.w),
            _scoreBadge('البوت', _engine.botWins, _engine.botScore, Colors.cyanAccent),
            SizedBox(width: 12.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.smart_toy, color: Colors.white54, size: 14),
                SizedBox(width: 4.w),
                Text('${_engine.botHand.length} قطع', style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11.sp)),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFFD700)),
              onPressed: () {
                setState(() => _engine.startNewGame());
                _checkBotTurn();
              },
            ),
          ],
        ),
      );

  Widget _scoreBadge(String label, int wins, int score, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$label: $score نقطة ($wins جولات)',
        style: GoogleFonts.cairo(color: color, fontSize: 10.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBottomSection() {
    final validTiles = _engine.playerHand.where((p) => _engine.getValidEdgesFor(p).isNotEmpty).toSet();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _engine.statusMessage,
                style: GoogleFonts.cairo(color: Colors.amberAccent, fontSize: 11.sp, fontWeight: FontWeight.w600),
              ),
              if (_engine.isPlayerTurn && _engine.boneyard.isNotEmpty && validTiles.isEmpty)
                ElevatedButton.icon(
                  onPressed: _drawFromBoneyard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                  ),
                  icon: const Icon(Icons.download, size: 14),
                  label: Text('سحب من المجمع (${_engine.boneyard.length})', style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          SizedBox(
            height: 65.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _engine.playerHand.length,
              itemBuilder: (context, index) {
                final tile = _engine.playerHand[index];
                final isValid = validTiles.contains(tile) && _engine.isPlayerTurn;
                final isSelected = _selected == tile;

                final tileWidget = DominoTileWidget(
                  piece: tile,
                  isValid: isValid,
                  isSelected: isSelected,
                  style: _currentStyle,
                  onTap: () => _onTileTap(tile),
                );

                if (!isValid) return tileWidget;

                return Draggable<DominoPiece>(
                  data: tile,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Transform.scale(
                      scale: 1.15,
                      child: DominoTileWidget(
                        piece: tile,
                        style: _currentStyle,
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: tileWidget,
                  ),
                  child: tileWidget,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
