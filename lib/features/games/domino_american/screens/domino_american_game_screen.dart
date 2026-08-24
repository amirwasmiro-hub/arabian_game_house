import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/providers/game_user_provider.dart';
import '../../../home/widgets/interactive_throw_overlay.dart';
import '../../../home/widgets/mega_win_dialog.dart';
import '../logic/domino_american_engine.dart';
import '../models/domino_piece.dart';
import '../widgets/domino_board_layout.dart';
import '../../domino_classic/widgets/domino_tile_rack.dart';
import '../../domino_classic/widgets/domino_player_hud.dart';

class DominoAmericanGameScreen extends StatefulWidget {
  final int? betCoins;
  const DominoAmericanGameScreen({super.key, this.betCoins = 80000});

  @override
  State<DominoAmericanGameScreen> createState() => _DominoAmericanGameScreenState();
}

class _DominoAmericanGameScreenState extends State<DominoAmericanGameScreen> {
  final DominoAmericanEngine _engine = DominoAmericanEngine();
  DominoPiece? _selectedPiece;
  bool _botThinking = false;

  int _playerTurnSeconds = 15;
  int _botTurnSeconds = 15;
  Timer? _turnTimer;

  String? _playerBubble;
  String? _botBubble;
  Timer? _bubbleDismissTimer;

  final List<String> _quickTaunts = [
    'العب يا معلم! ⏳',
    'عاش يا بطل! 👏',
    'حظك نار 🔥',
    'صباح الروقان ☕',
    'يلا مستنيك! ⚡',
    'أمريكاني نار! 🀄',
  ];

  @override
  void initState() {
    super.initState();
    _engine.startNewGame();
    _startTurnTimer();
    _checkBotTurn();
  }

  void _startTurnTimer() {
    _turnTimer?.cancel();
    _playerTurnSeconds = 15;
    _botTurnSeconds = 15;

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_engine.isPlayerTurn) {
          if (_playerTurnSeconds > 0) {
            _playerTurnSeconds--;
          } else {
            _onAutoPlayTimeout();
          }
        } else {
          if (_botTurnSeconds > 0) {
            _botTurnSeconds--;
          }
        }
      });
    });
  }

  void _onAutoPlayTimeout() {
    final validPieces = _engine.playerHand
        .where((p) => _engine.getValidEdgesFor(p).isNotEmpty)
        .toList();

    if (validPieces.isNotEmpty) {
      final piece = validPieces.first;
      final edge = _engine.getValidEdgesFor(piece).first;
      _onPlacePiece(piece, edge);
    } else if (_engine.boneyard.isNotEmpty) {
      _drawFromBoneyard();
    } else {
      _passTurn();
    }
  }

  void _checkBotTurn() {
    if (!_engine.isPlayerTurn && !_engine.isGameOver && !_botThinking) {
      _triggerBotPlay();
    }
  }

  void _triggerBotPlay() {
    setState(() {
      _botThinking = true;
      _botTurnSeconds = 15;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      _engine.triggerBotMove();
      SoundManager().playTilePlace();

      if (_engine.botHand.length <= 2 && _botBubble == null) {
        _showBotSpeech('النقطة دي بتاعتي! 😉');
      }

      setState(() {
        _botThinking = false;
        _playerTurnSeconds = 15;
      });

      _checkGameOver();
      _checkBotTurn();
    });
  }

  void _onTileTap(DominoPiece piece) {
    if (!_engine.isPlayerTurn || _engine.isGameOver) return;

    final validEdges = _engine.getValidEdgesFor(piece);
    if (validEdges.isEmpty) return;

    if (validEdges.length == 1) {
      _onPlacePiece(piece, validEdges.first);
    } else {
      setState(() {
        _selectedPiece = (_selectedPiece == piece) ? null : piece;
      });
    }
  }

  void _onPlacePiece(DominoPiece piece, DominoEdgeLocation edge) {
    if (!_engine.isPlayerTurn || _engine.isGameOver) return;

    _engine.playPiece(piece, edge);
    SoundManager().playTilePlace();

    setState(() {
      _selectedPiece = null;
      _playerTurnSeconds = 15;
    });

    _checkGameOver();
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

  void _passTurn() {
    if (!_engine.isPlayerTurn || _engine.boneyard.isNotEmpty) return;
    _engine.passTurn();
    SoundManager().playButtonClick();
    setState(() {});
    _checkBotTurn();
  }

  void _checkGameOver() {
    if (_engine.isGameOver) {
      _turnTimer?.cancel();
      final playerWon = _engine.playerScore >= 100 || _engine.playerHand.isEmpty;
      if (playerWon) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          MegaWinDialog.show(
            context,
            prizeCoins: (widget.betCoins ?? 80000) * 2,
            gameName: 'دومينو أمريكاني (All Fives)',
          );
        });
      }
    }
  }

  void _showPlayerSpeech(String text) {
    SoundManager().playButtonClick();
    setState(() {
      _playerBubble = text;
    });
    _bubbleDismissTimer?.cancel();
    _bubbleDismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _playerBubble = null);
    });
  }

  void _showBotSpeech(String text) {
    setState(() {
      _botBubble = text;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _botBubble = null);
    });
  }

  void _showQuickChatDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E0A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        side: const BorderSide(color: Color(0xFFFFD700), width: 1),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '💬 عبارات سريعة وحماسية',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _quickTaunts.map((taunt) {
                  return ActionChip(
                    backgroundColor: const Color(0xFF3E1A4D),
                    side: const BorderSide(color: Color(0xFFFFD700), width: 0.8),
                    label: Text(
                      taunt,
                      style: GoogleFonts.cairo(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showPlayerSpeech(taunt);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _bubbleDismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validPieces = _engine.playerHand
        .where((p) => _engine.getValidEdgesFor(p).isNotEmpty)
        .toSet();

    final userProvider = Provider.of<GameUserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFF07020E),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: InteractiveThrowOverlay(
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildTopCasinoBar(userProvider),

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        child: Stack(
                          children: [
                            DominoBoardLayout(
                              engine: _engine,
                              selectedPiece: _selectedPiece,
                              onPlacePiece: _onPlacePiece,
                            ),

                            // Opponent HUD
                            Positioned(
                              top: 8.h,
                              right: 12.w,
                              child: DominoPlayerHud(
                                name: 'الكابتن حسام 👑',
                                avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
                                flag: '🇪🇬',
                                vipTier: 'VIP 5',
                                coins: 3400000,
                                tilesCount: _engine.botHand.length,
                                isCurrentTurn: !_engine.isPlayerTurn,
                                remainingSeconds: _botTurnSeconds,
                                activeSpeechBubble: _botBubble,
                              ),
                            ),

                            // Player HUD
                            Positioned(
                              bottom: 8.h,
                              left: 12.w,
                              child: DominoPlayerHud(
                                name: user.name,
                                avatarUrl: user.avatarUrl,
                                flag: '🇸🇦',
                                vipTier: user.vipTier,
                                coins: user.coins,
                                tilesCount: _engine.playerHand.length,
                                isCurrentTurn: _engine.isPlayerTurn,
                                remainingSeconds: _playerTurnSeconds,
                                activeSpeechBubble: _playerBubble,
                              ),
                            ),

                            // Turn Indicator
                            if (_engine.isPlayerTurn)
                              Positioned(
                                top: 44.h,
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                                          blurRadius: 10.r,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '🎯 دورك للعب (مضاعفات الـ 5)!',
                                      style: GoogleFonts.cairo(
                                        fontSize: 8.5.sp,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF3E2723),
                                      ),
                                    ),
                                  )
                                      .animate(onPlay: (c) => c.repeat(reverse: true))
                                      .scale(duration: 800.ms, begin: const Offset(0.96, 0.96), end: const Offset(1.04, 1.04)),
                                ),
                              ),

                            // Boneyard Draw Button
                            Positioned(
                              bottom: 8.h,
                              right: 12.w,
                              child: _buildBoneyardButton(validPieces.isEmpty),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Player 3D Wooden Tile Rack
                    DominoTileRack(
                      playerHand: _engine.playerHand,
                      validPieces: validPieces,
                      selectedPiece: _selectedPiece,
                      isPlayerTurn: _engine.isPlayerTurn,
                      onTileTap: (piece) => _onTileTap(piece as DominoPiece),
                    ),
                  ],
                ),

                // Floating Interactive Throwing Emojis Toolbar
                Positioned(
                  left: 12.w,
                  bottom: 85.h,
                  child: InteractiveEmojiToolbar(
                    myPosition: Offset(100.w, 320.h),
                    opponentPosition: Offset(750.w, 40.h),
                  ),
                ),

                // Quick Chat Button
                Positioned(
                  left: 12.w,
                  bottom: 130.h,
                  child: GestureDetector(
                    onTap: _showQuickChatDialog,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD700), width: 1.w),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                            blurRadius: 8.r,
                          ),
                        ],
                      ),
                      child: Icon(Icons.chat_bubble_rounded, color: const Color(0xFFFFD700), size: 16.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopCasinoBar(GameUserProvider userProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0726),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFFFD700).withValues(alpha: 0.35),
            width: 1.w,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFFD700), size: 16),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8.w),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'دومينو أمريكاني (All Fives) 🌟',
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFD700),
                ),
              ),
              Text(
                'أنت: ${_engine.playerScore} نقطة | الخصم: ${_engine.botScore} نقطة',
                style: GoogleFonts.cairo(
                  fontSize: 6.5.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const Spacer(),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on_rounded, color: const Color(0xFFFFD700), size: 12.r),
                SizedBox(width: 4.w),
                Text(
                  'الرهان: ${_formatNumber(widget.betCoins ?? 80000)}',
                  style: GoogleFonts.cairo(
                    fontSize: 7.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '🟢 ${userProvider.pingMs}ms',
              style: GoogleFonts.montserrat(
                fontSize: 7.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00E676),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFFD700), size: 18),
            onPressed: () {
              setState(() {
                _engine.startNewGame();
                _playerTurnSeconds = 15;
                _botTurnSeconds = 15;
              });
              _checkBotTurn();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBoneyardButton(bool mustDraw) {
    final canDraw = _engine.isPlayerTurn && _engine.boneyard.isNotEmpty;
    final canPass = _engine.isPlayerTurn && _engine.boneyard.isEmpty && mustDraw;

    if (canPass) {
      return GestureDetector(
        onTap: _passTurn,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF1744), Color(0xFFFF5252)]),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white, width: 1.w),
          ),
          child: Text(
            'باص ⏭️',
            style: GoogleFonts.cairo(fontSize: 8.5.sp, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: canDraw ? _drawFromBoneyard : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: mustDraw && canDraw ? const Color(0xFFFF9100) : Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: mustDraw && canDraw ? Colors.white : const Color(0xFFFFD700), width: 1.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers_rounded, color: mustDraw && canDraw ? Colors.black : const Color(0xFFFFD700), size: 14.r),
            SizedBox(width: 4.w),
            Text(
              'سحب (${_engine.boneyard.length}) 🀄',
              style: GoogleFonts.cairo(
                fontSize: 8.sp,
                fontWeight: FontWeight.bold,
                color: mustDraw && canDraw ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
