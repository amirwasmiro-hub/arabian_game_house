import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/audio/sound_manager.dart';
import '../../core/providers/game_user_provider.dart';
import '../../features/home/widgets/interactive_throw_overlay.dart';
import '../../features/home/widgets/mega_win_dialog.dart';
import 'domino_classic_engine.dart';
import 'domino_piece.dart';
import 'domino_cafe_board.dart';
import 'domino_tile_rack.dart';
import 'domino_player_hud.dart';
import 'domino_round_result_dialog.dart';
import 'domino_face_down_tile.dart';
import 'domino_3d_tile.dart';

class DominoClassicGameScreen extends StatefulWidget {
  final int? betCoins;
  final bool showInitialSettings;

  const DominoClassicGameScreen({
    super.key,
    this.betCoins = 80000,
    this.showInitialSettings = true,
  });

  @override
  State<DominoClassicGameScreen> createState() =>
      _DominoClassicGameScreenState();
}

class _DominoClassicGameScreenState extends State<DominoClassicGameScreen>
    with TickerProviderStateMixin {
  final DominoClassicEngine _engine = DominoClassicEngine();
  DominoPiece? _selectedPiece;
  bool _botThinking = false;

  // Turn Timers
  int _activeTurnSeconds = 15;
  Timer? _turnTimer;

  // Speech Bubbles for up to 4 players
  String? _playerBubble;
  String? _eastBubble;
  String? _partnerBubble;
  String? _westBubble;
  Timer? _bubbleDismissTimer;
  bool _showEmojiMenu = false;

  // Global Keys for precise card flight coordinates
  final GlobalKey _tableStackKey = GlobalKey();
  final Map<int, GlobalKey> _hudKeys = {
    1: GlobalKey(),
    2: GlobalKey(),
    3: GlobalKey(),
  };

  // Flying Opponent Tile Animation
  late AnimationController _flyingCardController;
  DominoPiece? _flyingPiece;
  Offset? _flyingStartPos;
  Offset? _flyingTargetPos;
  bool _showImpactRipple = false;
  Offset? _impactPosition;
  bool _isTileDragging = false;
  bool _isPlacingPiece = false;
  bool _isAutoDrawing = false;
  bool _isAutoPassing = false;

  // Boneyard -> player hand draw flight animation
  late AnimationController _drawFlightController;
  DominoPiece? _drawFlyingPiece;
  Offset? _drawStartPos;
  Offset? _drawTargetPos;

  final List<String> _quickTaunts = [
    'العب يا معلم! ⏳',
    'صاااك في عين العدو! 🔒🔥',
    'دوش يا عمنا! 🀄',
    'شاي بالنعناع هنا! ☕',
    'على مهلك بتفكر في إيه! 🤔',
    'حظك نار الليلة! 🔥',
    'واحد سحلب للأستاذ! 🥛',
    'عاش يا بطل! 👏',
    'صباح الروقان ☕',
    'يا ساتر يا رب! 😅',
  ];

  bool _hasShownInitialSettings = false;

  @override
  void initState() {
    super.initState();
    _flyingCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
    _flyingCardController.addListener(() {
      if (mounted) setState(() {});
    });

    _drawFlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _drawFlightController.addListener(() {
      if (mounted) setState(() {});
    });

    _engine.startNewGame();
    if (widget.showInitialSettings && !_hasShownInitialSettings) {
      _hasShownInitialSettings = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showSettingsDialog(isInitial: true);
        }
      });
    } else {
      _startTurnTimer();
      _checkBotTurn();
    }
  }

  @override
  void dispose() {
    _flyingCardController.dispose();
    _drawFlightController.dispose();
    _turnTimer?.cancel();
    _bubbleDismissTimer?.cancel();
    super.dispose();
  }

  void _startTurnTimer() {
    _turnTimer?.cancel();
    _activeTurnSeconds = 15;

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_activeTurnSeconds > 0) {
          _activeTurnSeconds--;
        } else {
          _onTurnTimeout();
        }
      });
    });
  }

  void _onTurnTimeout() {
    if (_engine.isGameOver) return;

    if (_engine.isPlayerTurn) {
      final validPieces = _engine.playerHand
          .where((p) => _engine.getValidEdgesFor(p).isNotEmpty)
          .toList();

      if (validPieces.isNotEmpty) {
        final piece = validPieces.first;
        final edge = _engine.getValidEdgesFor(piece).first;
        _onPlacePiece(piece, edge);
      } else if (_engine.boneyard.isNotEmpty &&
          _engine.mode == DominoPlayMode.oneVsOne) {
        _drawFromBoneyard();
      } else {
        _passTurn();
      }
    } else {
      // Force bot move
      _triggerBotPlay();
    }
  }

  void _checkBotTurn() {
    if (!_engine.isPlayerTurn && !_engine.isGameOver && !_botThinking) {
      _triggerBotPlay();
    } else {
      _checkPlayerAutoDraw();
    }
  }

  /// When it's the player's turn and no tile in hand can be played:
  /// - 1v1 with tiles in the boneyard: auto-draw until a playable tile is found.
  /// - Otherwise (boneyard empty / 4P): auto-pass the turn to the next player.
  void _checkPlayerAutoDraw() {
    if (!_engine.isPlayerTurn ||
        _engine.isGameOver ||
        _isAutoDrawing ||
        _isAutoPassing) return;
    if (_engine.board.isEmpty) return;

    final hasValidMoves =
        _engine.playerHand.any((p) => _engine.getValidEdgesFor(p).isNotEmpty);
    if (hasValidMoves) return;

    final canDraw =
        _engine.mode == DominoPlayMode.oneVsOne && _engine.boneyard.isNotEmpty;

    if (canDraw) {
      // Short pause so the player sees the bot's move before drawing starts
      Future.delayed(const Duration(milliseconds: 450), () {
        if (!mounted) return;
        _startAutoDrawFromBoneyard();
      });
      return;
    }

    // No playable tile and nothing to draw -> pass automatically
    _isAutoPassing = true;
    Future.delayed(const Duration(milliseconds: 700), () {
      _isAutoPassing = false;
      if (!mounted || !_engine.isPlayerTurn || _engine.isGameOver) return;
      final stillNoMoves = !_engine.playerHand
          .any((p) => _engine.getValidEdgesFor(p).isNotEmpty);
      if (stillNoMoves) _passTurn();
    });
  }

  Offset _getBotStartOffset(int botIdx, Size tableSize) {
    try {
      final hudContext = _hudKeys[botIdx]?.currentContext;
      final tableContext = _tableStackKey.currentContext;
      if (hudContext != null && tableContext != null) {
        final hudBox = hudContext.findRenderObject() as RenderBox?;
        final tableBox = tableContext.findRenderObject() as RenderBox?;
        if (hudBox != null &&
            tableBox != null &&
            hudBox.hasSize &&
            tableBox.hasSize) {
          final hudGlobal = hudBox.localToGlobal(Offset.zero);
          final tableGlobal = tableBox.localToGlobal(Offset.zero);
          final relativeOffset = hudGlobal - tableGlobal;
          // Emerge directly from beneath the avatar icon HUD
          return Offset(
            relativeOffset.dx + (hudBox.size.width / 2) - 24.w,
            relativeOffset.dy + hudBox.size.height + 4.h,
          );
        }
      }
    } catch (_) {}

    // Precise fallback positioning
    final is4P = _engine.mode == DominoPlayMode.partnership4P;
    if (!is4P) {
      return Offset(tableSize.width - 95.w, 46.h);
    }
    switch (botIdx) {
      case 1: // Opponent East
        return Offset(tableSize.width - 95.w, 118.h);
      case 2: // Partner North
        return Offset((tableSize.width / 2) - 24.w, 46.h);
      case 3: // Opponent West
      default:
        return Offset(32.w, 118.h);
    }
  }

  Offset _getBoardTargetOffset(DominoEdgeLocation edge, Size tableSize) {
    final board = _engine.board;
    final centerY =
        (tableSize.height * 0.44).clamp(70.h, tableSize.height - 70.h);
    if (board.isEmpty) {
      return Offset((tableSize.width / 2) - 24.w, centerY);
    }

    // Estimate width of domino chain
    final double unscaledWidth = board.fold<double>(
      0.0,
      (sum, p) => sum + (p.isDouble ? 24.r : 45.r),
    );
    final double autoScale = (680.w / unscaledWidth).clamp(0.65, 1.0);
    final double halfChainWidth = (unscaledWidth * autoScale) / 2;

    if (edge == DominoEdgeLocation.left) {
      final targetX = (tableSize.width / 2 - halfChainWidth - 32.w)
          .clamp(30.w, tableSize.width / 2 - 20.w);
      return Offset(targetX, centerY);
    } else {
      final targetX = (tableSize.width / 2 + halfChainWidth + 8.w)
          .clamp(tableSize.width / 2 + 10.w, tableSize.width - 80.w);
      return Offset(targetX, centerY);
    }
  }

  void _triggerBotPlay() {
    if (_engine.isPlayerTurn || _engine.isGameOver || _botThinking) return;

    setState(() {
      _botThinking = true;
      _activeTurnSeconds = 15;
    });

    // Realistic cafe thinking duration
    Future.delayed(const Duration(milliseconds: 800), () async {
      if (!mounted || _engine.isGameOver || _engine.isPlayerTurn) {
        if (mounted) setState(() => _botThinking = false);
        return;
      }

      final botIdx = _engine.currentTurnIndex;

      // Check if bot has a move in hand
      ClassicBotMoveResult? move = _engine.pickBotMove();

      // If bot has no move and mode is 1v1, draw from boneyard until playable or empty
      if (move == null &&
          _engine.mode == DominoPlayMode.oneVsOne &&
          _engine.boneyard.isNotEmpty) {
        while (move == null && _engine.boneyard.isNotEmpty && mounted) {
          _engine.botDrawFromBoneyard();
          SoundManager().playTileDraw();
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 400));
          if (!mounted) return;
          move = _engine.pickBotMove();
        }
      }

      if (move == null) {
        // No move possible -> Pass turn
        _engine.passTurn();
        if (mounted) {
          setState(() {
            _botThinking = false;
            _activeTurnSeconds = 15;
          });
          _checkGameOver();
          _checkBotTurn();
        }
        return;
      }

      // We have a valid move: calculate flying positions
      final size = MediaQuery.of(context).size;
      final tableSize = Size(size.width, size.height - 40.h);
      final startPos = _getBotStartOffset(botIdx, tableSize);
      final targetPos = _getBoardTargetOffset(move.edge, tableSize);

      if (!mounted) return;

      setState(() {
        _flyingPiece = move!.piece;
        _flyingStartPos = startPos;
        _flyingTargetPos = targetPos;
      });

      // Whoosh / card fly sound
      SoundManager().playButtonClick();

      // Run flying animation across the green velvet table
      try {
        await _flyingCardController.forward(from: 0.0);
      } catch (_) {}

      if (!mounted) return;

      // Card landed! Play slam/place sound
      if (move.piece.isDouble) {
        SoundManager().playTileSlam();
      } else {
        SoundManager().playTilePlace();
      }

      // Trigger impact ripple at destination
      setState(() {
        _impactPosition = targetPos;
        _showImpactRipple = true;
      });

      // Commit the move to the engine board
      _engine.playPiece(move.piece, move.edge);

      // Clear flying tile state
      setState(() {
        _flyingPiece = null;
        _flyingStartPos = null;
        _flyingTargetPos = null;
      });

      // Clear impact ripple after brief delay
      Future.delayed(const Duration(milliseconds: 260), () {
        if (mounted && _showImpactRipple) {
          setState(() => _showImpactRipple = false);
        }
      });

      // Occasional banter from the active bot
      if (botIdx == 3 && _engine.hands[3].length <= 2 && _westBubble == null) {
        _showSpeech(3, 'قربت أخلص يا رجالة! 😉');
      } else if (botIdx == 2 && _partnerBubble == null && _engine.isGameOver) {
        _showSpeech(2, 'عاش يا شريكي! 🤝');
      }

      setState(() {
        _botThinking = false;
        _activeTurnSeconds = 15;
      });

      _checkGameOver();
      _checkBotTurn();
    });
  }

  void _onTileTap(DominoPiece piece) {
    if (!_engine.isPlayerTurn || _engine.isGameOver || _isPlacingPiece) return;
    if (_isTileDragging) return; // Guard against tap racing with active drag

    final validEdges = _engine.getValidEdgesFor(piece);
    if (validEdges.isEmpty) return;

    SoundManager().playButtonClick();

    setState(() {
      if (_selectedPiece == piece) {
        // إلغاء الدبل كليك: الضغط مرة أخرى يقوم بإلغاء التحديد فقط ولا يلعب الكارت
        _selectedPiece = null;
      } else {
        _selectedPiece = piece;
      }
    });
  }

  void _onTileDragStarted(DominoPiece piece) {
    if (!_engine.isPlayerTurn || _engine.isGameOver || _isPlacingPiece) return;
    _isTileDragging = true;
    setState(() {
      _selectedPiece = piece;
    });
  }

  void _onTileDragEnded() {
    if (!mounted) return;
    setState(() {
      _isTileDragging = false;
    });
  }

  void _onPlacePiece(DominoPiece piece, DominoEdgeLocation edge) {
    if (!_engine.isPlayerTurn || _engine.isGameOver || _isPlacingPiece) return;
    if (!_engine.playerHand.contains(piece))
      return; // Guard against duplicate drop execution

    _isPlacingPiece = true;
    _isTileDragging = false;
    final isDouble = piece.isDouble;
    _engine.playPiece(piece, edge);

    if (isDouble) {
      SoundManager().playTileSlam(); // Heavy slam for doubles
    } else {
      SoundManager().playTilePlace();
    }

    setState(() {
      _selectedPiece = null;
      _activeTurnSeconds = 15;
    });

    _checkGameOver();
    _checkBotTurn();
    _isPlacingPiece = false;
  }

  Future<void> _startAutoDrawFromBoneyard([int? preferredIndex]) async {
    if (!_engine.isPlayerTurn ||
        _engine.boneyard.isEmpty ||
        _isAutoDrawing ||
        _isPlacingPiece) return;

    // Rule: Cannot draw if there is already a valid playable piece in hand!
    var hasValidMoves =
        _engine.playerHand.any((p) => _engine.getValidEdgesFor(p).isNotEmpty);
    if (hasValidMoves) return;

    _isAutoDrawing = true;
    setState(() {});

    while (!hasValidMoves &&
        _engine.boneyard.isNotEmpty &&
        mounted &&
        _engine.isPlayerTurn) {
      final drawnIndex =
          (preferredIndex != null && preferredIndex < _engine.boneyard.length)
              ? preferredIndex
              : (_engine.boneyard.length - 1);
      preferredIndex = null; // Only use preferredIndex for the very first draw

      final drawn = _engine.boneyard.removeAt(drawnIndex);

      // Animate the tile flying from the boneyard into the player's hand
      final flight = _computeDrawFlightPositions();
      SoundManager().playTileDraw();
      setState(() {
        _drawFlyingPiece = drawn;
        _drawStartPos = flight.$1;
        _drawTargetPos = flight.$2;
      });
      try {
        await _drawFlightController.forward(from: 0.0);
      } catch (_) {}
      if (!mounted) return;

      _engine.playerHand.add(drawn);
      SoundManager().playTilePlace();
      setState(() {
        _drawFlyingPiece = null;
        _drawStartPos = null;
        _drawTargetPos = null;
      });

      hasValidMoves =
          _engine.playerHand.any((p) => _engine.getValidEdgesFor(p).isNotEmpty);

      // Stop once an available/playable tile is drawn or boneyard is empty
      if (hasValidMoves || _engine.boneyard.isEmpty) {
        break;
      }

      await Future.delayed(const Duration(milliseconds: 140));
    }

    _isAutoDrawing = false;
    if (mounted) {
      setState(() {});
      _checkGameOver();
      _checkBotTurn();
    }
  }

  void _drawFromBoneyard() {
    _startAutoDrawFromBoneyard();
  }

  void _passTurn() {
    if (!_engine.isPlayerTurn) return;
    _engine.passTurn();
    SoundManager().playButtonClick();
    setState(() {
      _activeTurnSeconds = 15;
    });
    _checkGameOver();
    _checkBotTurn();
  }

  void _checkGameOver() {
    if (_engine.isGameOver) {
      _turnTimer?.cancel();

      if (_engine.lastRoundResult != null) {
        Future.delayed(const Duration(milliseconds: 550), () {
          if (!mounted) return;
          DominoRoundResultDialog.show(
            context,
            result: _engine.lastRoundResult!,
            engine: _engine,
            onNextRound: () {
              setState(() {
                _engine.startNewGame(advanceRound: true);
                _startTurnTimer();
              });
              _checkBotTurn();
            },
            onNewMatch: () {
              setState(() {
                _flyingPiece = null;
                _flyingStartPos = null;
                _flyingTargetPos = null;
                _showImpactRipple = false;
                _engine.resetEntireMatch();
                _startTurnTimer();
              });
              _checkBotTurn();
            },
          );

          // If match is won by player team, award mega win dialog
          if (_engine.isMatchOver &&
              _engine.lastRoundResult?.winningTeam == 1) {
            Future.delayed(const Duration(milliseconds: 600), () {
              if (!mounted) return;
              MegaWinDialog.show(
                context,
                prizeCoins: (widget.betCoins ?? 80000) * 2,
                gameName: 'دومينو كافيه 🀄',
              );
            });
          }
        });
      }
    }
  }

  void _showSpeech(int playerIdx, String text) {
    setState(() {
      if (playerIdx == 0) _playerBubble = text;
      if (playerIdx == 1) _eastBubble = text;
      if (playerIdx == 2) _partnerBubble = text;
      if (playerIdx == 3) _westBubble = text;
    });
    _bubbleDismissTimer?.cancel();
    _bubbleDismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          if (playerIdx == 0) _playerBubble = null;
          if (playerIdx == 1) _eastBubble = null;
          if (playerIdx == 2) _partnerBubble = null;
          if (playerIdx == 3) _westBubble = null;
        });
      }
    });
  }

  void _showSettingsDialog({bool isInitial = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1B0726),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
              side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
            ),
            title: Row(
              children: [
                const Icon(Icons.settings_suggest_rounded,
                    color: Color(0xFFFFD700)),
                SizedBox(width: 8.w),
                Text(
                  'إعدادات طاولة الدومينو 🀄',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFD700),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('طور اللعب:',
                      style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp)),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      _buildConfigChip(
                        label: 'فردي (1 ضد 1) 👤',
                        isSelected: _engine.mode == DominoPlayMode.oneVsOne,
                        onTap: () {
                          setDialogState(
                              () => _engine.mode = DominoPlayMode.oneVsOne);
                        },
                      ),
                      SizedBox(width: 8.w),
                      _buildConfigChip(
                        label: 'شراكة (2 ضد 2) 👥',
                        isSelected:
                            _engine.mode == DominoPlayMode.partnership4P,
                        onTap: () {
                          setDialogState(() =>
                              _engine.mode = DominoPlayMode.partnership4P);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text('مستوى الذكاء الاصطناعي:',
                      style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp)),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 6.w,
                    children: [
                      _buildConfigChip(
                        label: 'عادي 🟢',
                        isSelected:
                            _engine.difficulty == DominoDifficulty.casual,
                        onTap: () => setDialogState(
                            () => _engine.difficulty = DominoDifficulty.casual),
                      ),
                      _buildConfigChip(
                        label: 'محترف 🟡',
                        isSelected: _engine.difficulty == DominoDifficulty.pro,
                        onTap: () => setDialogState(
                            () => _engine.difficulty = DominoDifficulty.pro),
                      ),
                      _buildConfigChip(
                        label: 'داهية القهاوي 🔴',
                        isSelected:
                            _engine.difficulty == DominoDifficulty.grandmaster,
                        onTap: () => setDialogState(() =>
                            _engine.difficulty = DominoDifficulty.grandmaster),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text('هدف الماتش (نقاط الفوز):',
                      style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp)),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      _buildConfigChip(
                        label: '101 نقطة 🏆',
                        isSelected: _engine.targetScore == 101,
                        onTap: () =>
                            setDialogState(() => _engine.targetScore = 101),
                      ),
                      SizedBox(width: 6.w),
                      _buildConfigChip(
                        label: '50 نقطة ⚡',
                        isSelected: _engine.targetScore == 50,
                        onTap: () =>
                            setDialogState(() => _engine.targetScore = 50),
                      ),
                      SizedBox(width: 6.w),
                      _buildConfigChip(
                        label: 'جولة واحدة 🎯',
                        isSelected: _engine.targetScore == 0,
                        onTap: () =>
                            setDialogState(() => _engine.targetScore = 0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (isInitial) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  isInitial ? 'خروج' : 'إلغاء',
                  style:
                      GoogleFonts.cairo(color: Colors.white60, fontSize: 10.sp),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _engine.resetEntireMatch();
                    _startTurnTimer();
                  });
                  _checkBotTurn();
                },
                child: Text(
                  isInitial
                      ? 'تأكيد وبدء اللعب 🎲'
                      : 'تطبيق وبدء مباراة جديدة 🎲',
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 10.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigChip(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : Colors.black45,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
              color: isSelected ? const Color(0xFFFFD700) : Colors.white24),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 7.5.sp,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
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
                '💬 عبارات قهوة سريعة وحماسية',
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
                    backgroundColor: const Color(0xFF2C103D),
                    side:
                        const BorderSide(color: Color(0xFFFFD700), width: 0.5),
                    label: Text(
                      taunt,
                      style: GoogleFonts.cairo(
                          color: Colors.white, fontSize: 10.sp),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showSpeech(0, taunt);
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
  Widget build(BuildContext context) {
    final userProvider = Provider.of<GameUserProvider>(context);
    final user = userProvider.user;

    final validPieces = _engine.playerHand
        .where((p) => _engine.getValidEdgesFor(p).isNotEmpty)
        .toSet();

    final is4P = _engine.mode == DominoPlayMode.partnership4P;

    return Scaffold(
      backgroundColor: const Color(0xFF04180C),
      body: SafeArea(
        left: false,
        right: false,
        child: InteractiveThrowOverlay(
          child: Container(
            decoration: const BoxDecoration(
              // Full Screen Casino Table Green Velvet Felt
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.25,
                colors: [
                  Color(0xFF0F4D2A),
                  Color(0xFF0A331C),
                  Color(0xFF04180C),
                ],
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Top Casino & Match Bar
                    _buildTopCasinoBar(userProvider),

                    // Table Surface + Players HUD Overlays (Full Screen without margins)
                    Expanded(
                      child: Stack(
                        key: _tableStackKey,
                        children: [
                          // Domino Cafe Green Velvet Board (Full Screen)
                          DominoCafeBoard(
                            engine: _engine,
                            selectedPiece: _selectedPiece,
                            onPlacePiece: _onPlacePiece,
                            totalPotCoins: (widget.betCoins ?? 80000) * 2,
                            isDragging: _isTileDragging,
                          ),

                          // Opponent West (Left or Top Right in 1v1)
                          if (!is4P)
                            Positioned(
                              top: 8.h,
                              right: 12.w,
                              child: DominoPlayerHud(
                                key: _hudKeys[3],
                                name: 'الكينج رامي 👑',
                                avatarUrl:
                                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                                flag: '🇪🇬',
                                vipTier: 'VIP 4',
                                coins: 1850000,
                                tilesCount: _engine.hands[3].length,
                                isCurrentTurn: _engine.currentTurnIndex == 3,
                                remainingSeconds: _activeTurnSeconds,
                                activeSpeechBubble: _westBubble,
                                showFaceDownTiles: true,
                              ),
                            )
                          else ...[
                            // 4-Player Layout:
                            // Top Center: Partner (North)
                            Positioned(
                              top: 8.h,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: DominoPlayerHud(
                                  key: _hudKeys[2],
                                  name: 'المعلم محروس (شريكك) 🤝',
                                  avatarUrl:
                                      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
                                  flag: '🇪🇬',
                                  vipTier: 'VIP 3',
                                  coins: 1200000,
                                  tilesCount: _engine.hands[2].length,
                                  isCurrentTurn: _engine.currentTurnIndex == 2,
                                  remainingSeconds: _activeTurnSeconds,
                                  activeSpeechBubble: _partnerBubble,
                                  showFaceDownTiles: true,
                                ),
                              ),
                            ),

                            // Right: Opponent East (أبو علي)
                            Positioned(
                              top: 75.h,
                              right: 12.w,
                              child: DominoPlayerHud(
                                key: _hudKeys[1],
                                name: 'أبو علي ⚡',
                                avatarUrl:
                                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
                                flag: '🇪🇬',
                                vipTier: 'VIP 2',
                                coins: 950000,
                                tilesCount: _engine.hands[1].length,
                                isCurrentTurn: _engine.currentTurnIndex == 1,
                                remainingSeconds: _activeTurnSeconds,
                                activeSpeechBubble: _eastBubble,
                                showFaceDownTiles: true,
                              ),
                            ),

                            // Left: Opponent West (الكينج رامي)
                            Positioned(
                              top: 75.h,
                              left: 12.w,
                              child: DominoPlayerHud(
                                key: _hudKeys[3],
                                name: 'الكينج رامي 👑',
                                avatarUrl:
                                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                                flag: '🇪🇬',
                                vipTier: 'VIP 4',
                                coins: 1850000,
                                tilesCount: _engine.hands[3].length,
                                isCurrentTurn: _engine.currentTurnIndex == 3,
                                remainingSeconds: _activeTurnSeconds,
                                activeSpeechBubble: _westBubble,
                                showFaceDownTiles: true,
                              ),
                            ),
                          ],

                          // Player HUD + Throw & Chat Action Buttons (Bottom Left of Table)
                          Positioned(
                            bottom: 6.h,
                            left: 10.w,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                DominoPlayerHud(
                                  name: user.name,
                                  avatarUrl: user.avatarUrl,
                                  flag: '🇸🇦',
                                  vipTier: user.vipTier,
                                  coins: user.coins,
                                  tilesCount: _engine.playerHand.length,
                                  isCurrentTurn: _engine.isPlayerTurn,
                                  remainingSeconds: _activeTurnSeconds,
                                  activeSpeechBubble: _playerBubble,
                                ),
                                SizedBox(width: 6.w),
                                // Actions next to Avatar (Tomato/Egg throw trigger & Chat)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Quick Chat Icon Button
                                    GestureDetector(
                                      onTap: _showQuickChatDialog,
                                      child: Container(
                                        padding: EdgeInsets.all(5.w),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.75),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: const Color(0xFFFFD700),
                                              width: 1.w),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFFD700)
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 6.r,
                                            ),
                                          ],
                                        ),
                                        child: Icon(Icons.chat_bubble_rounded,
                                            color: const Color(0xFFFFD700),
                                            size: 14.r),
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    // Tomato & Egg Throw Icon Button
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showEmojiMenu = !_showEmojiMenu;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4.w),
                                        decoration: BoxDecoration(
                                          color: _showEmojiMenu
                                              ? const Color(0xFFFFD700)
                                              : Colors.black
                                                  .withValues(alpha: 0.75),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFFFFD700),
                                            width: 1.w,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFFD700)
                                                  .withValues(
                                                      alpha: _showEmojiMenu
                                                          ? 0.7
                                                          : 0.4),
                                              blurRadius: 8.r,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '🍅',
                                          style: TextStyle(fontSize: 13.sp),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Popup Throwing Emojis Toolbar (Appears ONLY when tapping the Tomato icon next to avatar)
                          if (_showEmojiMenu)
                            Positioned(
                              left: 10.w,
                              bottom: 50.h,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 2.h),
                                child: InteractiveEmojiToolbar(
                                  myPosition: Offset(100.w, 320.h),
                                  opponentPosition: Offset(750.w, 40.h),
                                ),
                              )
                                  .animate()
                                  .scale(
                                      duration: 200.ms,
                                      curve: Curves.easeOutBack,
                                      alignment: Alignment.bottomLeft)
                                  .fadeIn(),
                            ),

                          // Player Domino Tiles (Floating directly over the green velvet table)
                          Positioned(
                            bottom: 4.h,
                            left: 175.w,
                            right: 50.w,
                            child: DominoTileRack(
                              playerHand: _engine.playerHand,
                              validPieces: validPieces,
                              selectedPiece: _selectedPiece,
                              isPlayerTurn: _engine.isPlayerTurn,
                              onTileTap: (piece) =>
                                  _onTileTap(piece as DominoPiece),
                              onTileDragStarted: (piece) =>
                                  _onTileDragStarted(piece as DominoPiece),
                              onTileDragEnded: _onTileDragEnded,
                            ),
                          ),

                          // Boneyard Face-down Tiles (Vertical Column on the Right Edge of the Screen)
                          Positioned(
                            right: 8.w,
                            top: 72.h,
                            bottom: 10.h,
                            child: Center(
                              child: _buildBoneyardArea(
                                  mustDraw: validPieces.isEmpty),
                            ),
                          ),

                          // Flying Opponent Tile Overlay (Appears under bot avatar and flies to target)
                          if (_flyingPiece != null &&
                              _flyingStartPos != null &&
                              _flyingTargetPos != null)
                            _buildFlyingTileOverlay(),

                          // Drawn tile flying from the boneyard into the player's hand
                          if (_drawFlyingPiece != null &&
                              _drawStartPos != null &&
                              _drawTargetPos != null)
                            _buildDrawFlightOverlay(),

                          // Landing Impact Ripple Effect
                          if (_showImpactRipple && _impactPosition != null)
                            _buildLandingImpactRipple(),
                        ],
                      ),
                    ),
                  ],
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
        color: Colors.black.withValues(alpha: 0.65),
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
            icon: const Icon(Icons.arrow_back_ios,
                color: Color(0xFFFFD700), size: 16),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8.w),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'دومينو كافيه ☕🀄',
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFD700),
                ),
              ),
              Text(
                _engine.mode == DominoPlayMode.partnership4P
                    ? 'شراكة 4 لاعبين (2 ضد 2)'
                    : 'مباراة ثنائية (1 ضد 1)',
                style: GoogleFonts.cairo(
                  fontSize: 6.5.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          SizedBox(width: 12.w),

          // Match Scoreboard Pill (Team 1 vs Team 2 / Target)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الماتش (الجولة ${_engine.currentRound}): ',
                  style:
                      GoogleFonts.cairo(fontSize: 7.sp, color: Colors.white70),
                ),
                Text(
                  '${_engine.team1MatchScore}',
                  style: GoogleFonts.montserrat(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00E676)),
                ),
                Text(' : ',
                    style: GoogleFonts.montserrat(
                        fontSize: 8.sp, color: Colors.white)),
                Text(
                  '${_engine.team2MatchScore}',
                  style: GoogleFonts.montserrat(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF5252)),
                ),
                if (_engine.targetScore > 0) ...[
                  Text(' / ${_engine.targetScore}',
                      style: GoogleFonts.montserrat(
                          fontSize: 7.sp, color: const Color(0xFFFFD700))),
                ],
              ],
            ),
          ),

          const Spacer(),

          // Stakes Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on_rounded,
                    color: const Color(0xFFFFD700), size: 12.r),
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

          // Ping Indicator
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
        ],
      ),
    );
  }

  Widget _buildBoneyardArea({required bool mustDraw}) {
    final is1v1 = _engine.mode == DominoPlayMode.oneVsOne;
    final canDraw = _engine.isPlayerTurn &&
        _engine.boneyard.isNotEmpty &&
        is1v1 &&
        mustDraw;

    // No pass button: passing happens automatically in _checkPlayerAutoDraw
    if (!is1v1 || _engine.boneyard.isEmpty) {
      return const SizedBox.shrink(); // No boneyard needed in 4P or if empty
    }

    final boneyardCount = _engine.boneyard.length;

    // Two columns of face-down domino cards on the right side ("عمودين")
    // Sized dynamically with auto-draw on tap
    final col1Count = (boneyardCount + 1) ~/ 2;
    const tileWidth = 25.0;
    const tileHeight = 12.5;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Column 1 (Left of the 2 columns)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(col1Count, (i) {
              return DominoFaceDownTile(
                width: tileWidth,
                height: tileHeight,
                margin:
                    EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 1.5.w),
                isSelectable: canDraw && !_isAutoDrawing,
                onTap: () {
                  if (canDraw && !_isAutoDrawing) {
                    _startAutoDrawFromBoneyard(i);
                  }
                },
              );
            }),
          ),
          SizedBox(width: 2.w),
          // Column 2 (Right of the 2 columns)
          if (boneyardCount > col1Count)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(boneyardCount - col1Count, (i) {
                final idx = col1Count + i;
                return DominoFaceDownTile(
                  width: tileWidth,
                  height: tileHeight,
                  margin:
                      EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 1.5.w),
                  isSelectable: canDraw && !_isAutoDrawing,
                  onTap: () {
                    if (canDraw && !_isAutoDrawing) {
                      _startAutoDrawFromBoneyard(idx);
                    }
                  },
                );
              }),
            ),
        ],
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

  /// Start (boneyard on the right edge) and target (end of player's hand rack)
  /// positions, relative to the table Stack.
  (Offset, Offset) _computeDrawFlightPositions() {
    Size tableSize;
    final box = _tableStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      tableSize = box.size;
    } else {
      final size = MediaQuery.of(context).size;
      tableSize = Size(size.width, size.height - 40.h);
    }

    final start = Offset(tableSize.width - 44.w, tableSize.height / 2 - 10.h);

    // Rack spans left: 175.w -> right: 50.w and is centered; new tile lands at its end
    final rackLeft = 175.w;
    final rackWidth = tableSize.width - 175.w - 50.w;
    final handCount = _engine.playerHand.length + 1;
    final targetX = (rackLeft + rackWidth / 2 + handCount * 16.r)
        .clamp(rackLeft, tableSize.width - 80.w)
        .toDouble();
    final target = Offset(targetX, tableSize.height - 66.r);

    return (start, target);
  }

  /// Drawn tile flying from the boneyard to the hand: arcs up, spins and
  /// flips from face-down to face-up halfway through the flight.
  Widget _buildDrawFlightOverlay() {
    final t = _drawFlightController.value;
    final p = Curves.easeInOutCubic.transform(t);
    final start = _drawStartPos!;
    final target = _drawTargetPos!;

    final x = lerpDouble(start.dx, target.dx, p)!;
    final arc = math.sin(t * math.pi);
    final y = lerpDouble(start.dy, target.dy, p)! - 60.h * arc;

    final scale = 0.9 + 0.35 * arc;
    final spin = lerpDouble(-0.6, 0.0, p)!;

    // 3D flip around the Y axis: face-down for first half, face-up after
    final flipAngle = t * math.pi;
    final showFace = flipAngle > math.pi / 2;
    final displayAngle = showFace ? flipAngle - math.pi : flipAngle;

    final Widget face = showFace
        ? Domino3DTile(
            top: _drawFlyingPiece!.top,
            bottom: _drawFlyingPiece!.bottom,
          )
        : const DominoFaceDownTile(
            width: 34, height: 17, margin: EdgeInsets.zero);

    return Positioned(
      left: x,
      top: y,
      child: IgnorePointer(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateZ(spin)
            ..rotateY(displayAngle)
            ..scaleByDouble(scale, scale, 1.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3 + 0.3 * arc),
                  blurRadius: (6 + 14 * arc).r,
                  offset: Offset(2, 4 + 10 * arc),
                ),
              ],
            ),
            child: face,
          ),
        ),
      ),
    );
  }

  /// Animated Domino Tile that emerges from beneath the bot's avatar HUD,
  /// lifts into the air with a parabolic 3D flight arc, rotates, and lands smoothly on the table.
  Widget _buildFlyingTileOverlay() {
    final t = _flyingCardController.value;
    final curvedProgress = Curves.easeInOutCubic.transform(t);

    final start = _flyingStartPos!;
    final target = _flyingTargetPos!;

    final currentX = lerpDouble(start.dx, target.dx, curvedProgress)!;
    final currentY = lerpDouble(start.dy, target.dy, curvedProgress)!;

    // Flight Arc: Parabolic lift into the air (reaches apex at t = 0.5)
    final flightArc = math.sin(t * math.pi);
    final visualY = currentY - (38.h * flightArc);

    // Dynamic 3D elevation shadow as the tile flies above the felt
    final shadowElevation = 18.0 * flightArc;
    final shadowBlur = 8.0 + shadowElevation;
    final shadowOffset = Offset(2.0, 4.0 + (shadowElevation * 0.7));

    // Scale begins at 0.75 emerging from under avatar, grows to 1.0 on table
    final currentScale = lerpDouble(0.75, 1.0, curvedProgress)!;

    // Start tilt rotation based on flight direction, smoothly aligns to 0
    final startAngle = (start.dx > target.dx) ? 0.35 : -0.35;
    final currentAngle = lerpDouble(startAngle, 0.0, curvedProgress)!;

    // Smooth emergence fade-in
    final opacity = (t * 5.0).clamp(0.0, 1.0);

    return Positioned(
      left: currentX,
      top: visualY,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: currentAngle,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.35 + (0.35 * flightArc)),
                    blurRadius: shadowBlur.r,
                    offset: shadowOffset,
                    spreadRadius: (1.5 + (2.5 * flightArc)).r,
                  ),
                ],
              ),
              child: Domino3DTile(
                top: _flyingPiece!.a,
                bottom: _flyingPiece!.b,
                isHorizontal: !_flyingPiece!.isDouble,
                onTable: true,
                scale: currentScale,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Subtle natural felt contact ripple effect when the card hits the table (no glowing)
  Widget _buildLandingImpactRipple() {
    return Positioned(
      left: _impactPosition!.dx - 8.w,
      top: _impactPosition!.dy - 8.h,
      child: IgnorePointer(
        child: Container(
          width: 56.w,
          height: 38.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8.r,
                spreadRadius: 1.r,
              ),
            ],
          ),
        )
            .animate()
            .scale(
              duration: 220.ms,
              begin: const Offset(0.7, 0.7),
              end: const Offset(1.2, 1.2),
              curve: Curves.easeOutQuad,
            )
            .fadeOut(duration: 220.ms),
      ),
    );
  }
}
