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
import 'domino_table_settings_dialog.dart';
import 'domino_snake_layout.dart';

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
  static const int _turnDurationSeconds = 6;
  int _activeTurnSeconds = _turnDurationSeconds;
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
  late final AnimationController _flyingCardController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 680),
  );
  DominoPiece? _flyingPiece;
  Offset? _flyingStartPos;
  Offset? _flyingTargetPos;
  bool _isTileDragging = false;
  bool _isPlacingPiece = false;
  bool _isAutoDrawing = false;
  bool _isAutoPassing = false;
  DominoPiece? _recentlyMovedPiece;
  int? _recentlyMovedTimestamp;

  // Boneyard -> player hand draw flight animation
  late final AnimationController _drawFlightController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  DominoPiece? _drawFlyingPiece;
  Offset? _drawStartPos;
  Offset? _drawTargetPos;

  // Flying Round Bonus Score Animation (رقم المكسب الطائر كبونص مقتنص)
  late final AnimationController _bonusScoreController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1350),
  );
  int? _flyingBonusPoints;
  int? _flyingBonusTeam;
  Offset? _flyingBonusStartPos;
  Offset? _flyingBonusTargetPos;
  bool _isScorePillPulsing = false;
  final GlobalKey _scoreboardKey = GlobalKey();

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

  bool _isTableRevealed = false;

  @override
  void initState() {
    super.initState();
    _engine.startNewGame();
    _isTableRevealed = !widget.showInitialSettings;
    if (_isTableRevealed) {
      _startTurnTimer();
      _checkBotTurn();
    }
  }

  @override
  void dispose() {
    _flyingCardController.dispose();
    _drawFlightController.dispose();
    _bonusScoreController.dispose();
    _turnTimer?.cancel();
    _bubbleDismissTimer?.cancel();
    super.dispose();
  }

  void _startTurnTimer() {
    _turnTimer?.cancel();
    _activeTurnSeconds = _turnDurationSeconds;

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_activeTurnSeconds > 1) {
        setState(() {
          _activeTurnSeconds--;
        });
      } else {
        setState(() {
          _activeTurnSeconds = 0;
        });
        _turnTimer?.cancel();
        _onTurnTimeout();
      }
    });
  }

  Future<void> _onTurnTimeout() async {
    _turnTimer?.cancel();
    if (_engine.isGameOver || _isPlacingPiece) return;

    if (_engine.isPlayerTurn) {
      final validPieces = _engine.playerHand
          .where((p) => _engine.getValidEdgesFor(p).isNotEmpty)
          .toList();

      if (validPieces.isNotEmpty) {
        // Pick best playable piece (highest pip weight / double first)
        validPieces.sort((x, y) => (y.pip + (y.isDouble ? 50 : 0))
            .compareTo(x.pip + (x.isDouble ? 50 : 0)));
        final piece = validPieces.first;
        final edge = _engine.getValidEdgesFor(piece).first;

        // Perform the exact same flying animation as the bot across the table
        final size = MediaQuery.of(context).size;
        final tableSize = Size(size.width, size.height - 40.h);
        final startPos = _getPlayerTileStartOffset(piece, tableSize);
        final targetPos = _getBoardTargetOffset(edge, tableSize);

        if (!mounted) return;

        _isPlacingPiece = true;
        setState(() {
          _flyingPiece = piece;
          _flyingStartPos = startPos;
          _flyingTargetPos = targetPos;
          _selectedPiece = null;
          _isTileDragging = false;
        });

        // Whoosh / card fly sound
        SoundManager().playButtonClick();

        // Run flying animation across the green velvet table
        try {
          await _flyingCardController.forward(from: 0.0);
        } catch (_) {}

        if (!mounted) return;

        // Card landed! Play slam/place sound
        if (piece.isDouble) {
          SoundManager().playTileSlam();
        } else {
          SoundManager().playTilePlace();
        }

        // Commit the move to the engine board
        _engine.playPiece(piece, edge);

        setState(() {
          _flyingPiece = null;
          _flyingStartPos = null;
          _flyingTargetPos = null;
          _activeTurnSeconds = _turnDurationSeconds;
          _isPlacingPiece = false;
        });

        _checkGameOver();
        _checkBotTurn();
      } else if (_engine.boneyard.isNotEmpty &&
          _engine.mode == DominoPlayMode.oneVsOne) {
        _startAutoDrawFromBoneyard();
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
        _isAutoPassing) {
      return;
    }
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

  /// Calculates starting position of a tile in the player's hand rack at the bottom of the table
  Offset _getPlayerTileStartOffset(DominoPiece piece, Size tableSize) {
    final idx = _engine.playerHand.indexOf(piece);
    final handCount = _engine.playerHand.length;
    final rackLeft = 175.w;
    final rackWidth = tableSize.width - 175.w - 50.w;
    final rackCenterX = rackLeft + rackWidth / 2;
    final tileWidth = 32.r;
    final totalHandWidth = handCount * tileWidth;
    final effectiveIdx = (idx >= 0) ? idx : 0;
    final rtlSlotFromLeft =
        (handCount > 0) ? ((handCount - 1) - effectiveIdx) : 0;
    final startX = (rackCenterX -
            (totalHandWidth / 2) +
            (rtlSlotFromLeft + 0.5) * tileWidth)
        .clamp(rackLeft, tableSize.width - 60.w);
    final startY = tableSize.height - 45.h;
    return Offset(startX, startY);
  }

  Offset _getBoardTargetOffset(DominoEdgeLocation edge, Size tableSize) {
    final board = _engine.board;
    final centerX = tableSize.width / 2;
    final centerY =
        (tableSize.height * 0.44).clamp(70.h, tableSize.height - 70.h);
    if (board.isEmpty) {
      return Offset(centerX - 21.r, centerY);
    }

    final layout = DominoSnakeLayout.compute(
      board: board,
      initialTileIndex: _engine.safeInitialTileIndex,
      tileShort: 21.r,
      tileLong: 42.r,
      gap: 2.r,
      rowSpacing: 21.r,
      includeGhosts: true,
    );

    final ghost = edge == DominoEdgeLocation.left
        ? layout.leftGhost
        : layout.rightGhost;

    if (ghost != null) {
      return Offset(
        centerX + ghost.x - (ghost.width / 2),
        centerY + ghost.y - (ghost.height / 2),
      );
    }

    // Fallback if ghost was null
    if (edge == DominoEdgeLocation.left && layout.tiles.isNotEmpty) {
      final first = layout.tiles.first;
      return Offset(centerX + first.x - (first.width / 2), centerY + first.y);
    } else if (layout.tiles.isNotEmpty) {
      final last = layout.tiles.last;
      return Offset(centerX + last.x - (last.width / 2), centerY + last.y);
    }

    return Offset(centerX, centerY);
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

      // Commit the move to the engine board
      _engine.playPiece(move.piece, move.edge);

      setState(() {
        _flyingPiece = null;
        _flyingStartPos = null;
        _flyingTargetPos = null;
        _botThinking = false;
        _activeTurnSeconds = _turnDurationSeconds;
      });

      // Occasional banter from the active bot
      if (botIdx == 3 && _engine.hands[3].length <= 2 && _westBubble == null) {
        _showSpeech(3, 'قربت أخلص يا رجالة! 😉');
      } else if (botIdx == 2 && _partnerBubble == null && _engine.isGameOver) {
        _showSpeech(2, 'عاش يا شريكي! 🤝');
      }

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
    if (_engine.isGameOver || _isPlacingPiece) return;
    setState(() {
      _isTileDragging = true;
      _selectedPiece = null;
    });
  }

  void _onTileDragEnded() {
    if (!mounted) return;
    setState(() {
      _isTileDragging = false;
      _selectedPiece = null;
    });
  }

  void _onReorderTiles(DominoPiece fromPiece, DominoPiece toPiece) {
    final oldIdx = _engine.playerHand.indexOf(fromPiece);
    final toIdx = _engine.playerHand.indexOf(toPiece);
    if (oldIdx != -1 && toIdx != -1 && oldIdx != toIdx) {
      setState(() {
        _engine.playerHand.removeAt(oldIdx);
        final newIdx = _engine.playerHand.indexOf(toPiece);
        if (newIdx != -1) {
          _engine.playerHand.insert(newIdx, fromPiece);
        } else {
          _engine.playerHand.insert(oldIdx.clamp(0, _engine.playerHand.length), fromPiece);
        }
        _recentlyMovedPiece = fromPiece;
        _recentlyMovedTimestamp = DateTime.now().millisecondsSinceEpoch;
        _selectedPiece = null;
        _isTileDragging = false;
      });
      SoundManager().playTilePlace();
    }
  }

  void _onReorderToIndex(DominoPiece piece, int targetIndex) {
    final oldIdx = _engine.playerHand.indexOf(piece);
    if (oldIdx == -1) return;

    setState(() {
      _engine.playerHand.removeAt(oldIdx);
      final clampedIdx = targetIndex.clamp(0, _engine.playerHand.length);
      _engine.playerHand.insert(clampedIdx, piece);
      _recentlyMovedPiece = piece;
      _recentlyMovedTimestamp = DateTime.now().millisecondsSinceEpoch;
      _selectedPiece = null;
      _isTileDragging = false;
    });
    SoundManager().playTilePlace();
  }

  void _onPlacePiece(DominoPiece piece, DominoEdgeLocation edge) {
    if (!_engine.isPlayerTurn || _engine.isGameOver || _isPlacingPiece) return;
    if (!_engine.playerHand.contains(piece)) {
      return; // Guard against duplicate drop execution
    }

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
      _activeTurnSeconds = _turnDurationSeconds;
    });

    _checkGameOver();
    _checkBotTurn();
    _isPlacingPiece = false;
  }

  Future<void> _startAutoDrawFromBoneyard([int? preferredIndex]) async {
    if (!_engine.isPlayerTurn ||
        _engine.boneyard.isEmpty ||
        _isAutoDrawing ||
        _isPlacingPiece) {
      return;
    }

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

      _engine.playerHand.insert(0, drawn);
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

  void _passTurn() {
    if (!_engine.isPlayerTurn) return;
    _engine.passTurn();
    SoundManager().playButtonClick();
    setState(() {
      _activeTurnSeconds = _turnDurationSeconds;
    });
    _checkGameOver();
    _checkBotTurn();
  }

  void _checkGameOver() {
    if (_engine.isGameOver) {
      _turnTimer?.cancel();
      final result = _engine.lastRoundResult;
      if (result == null) return;

      // When round is won and match is not over:
      // NO dialog window! The win appears as a flying bonus score that rises to the scoreboard!
      if (!result.isMatchOver) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (!mounted) return;
          _triggerFlyingBonusScore(result);
        });
      } else {
        // Match is finished!
        if (result.winningTeam == 1) {
          // Player won match! Trigger flying score first, then MegaWinDialog
          _triggerFlyingBonusScore(result, onComplete: () {
            Future.delayed(const Duration(milliseconds: 400), () {
              if (!mounted) return;
              MegaWinDialog.show(
                context,
                prizeCoins: (widget.betCoins ?? 80000) * 2,
                gameName: 'دومينو كافيه 🀄',
              );
            });
          });
        } else {
          // Opponent won match: show final match result dialog
          Future.delayed(const Duration(milliseconds: 550), () {
            if (!mounted) return;
            DominoRoundResultDialog.show(
              context,
              result: result,
              engine: _engine,
              onNextRound: () {},
              onNewMatch: () {
                setState(() {
                  _flyingPiece = null;
                  _flyingStartPos = null;
                  _flyingTargetPos = null;
                  _engine.resetEntireMatch();
                  _startTurnTimer();
                });
                _checkBotTurn();
              },
            );
          });
        }
      }
    }
  }

  /// Triggers the flying bonus score animation when a round is won:
  /// Pops up at the table center like a captured bonus, flies up to the match score pill,
  /// pulses the scoreboard, and smoothly starts the next round with zero dialog popups.
  Future<void> _triggerFlyingBonusScore(DominoRoundResult result,
      {VoidCallback? onComplete}) async {
    if (!mounted) return;

    final points = result.pointsEarned;
    final isPlayerTeam = result.winningTeam == 1;

    final size = MediaQuery.of(context).size;
    final startPos = Offset(
      size.width / 2,
      isPlayerTeam ? (size.height * 0.52) : (size.height * 0.40),
    );

    // Target position: winning team side of the scoreboard pill in the top casino bar
    Offset targetPos;
    final scoreBox =
        _scoreboardKey.currentContext?.findRenderObject() as RenderBox?;
    if (scoreBox != null && scoreBox.hasSize) {
      final scoreGlobal = scoreBox.localToGlobal(Offset.zero);
      final teamXRatio = isPlayerTeam ? 0.38 : 0.62;
      targetPos = Offset(
        scoreGlobal.dx + (scoreBox.size.width * teamXRatio),
        scoreGlobal.dy + (scoreBox.size.height / 2),
      );
    } else {
      targetPos = Offset(
        isPlayerTeam ? size.width * 0.32 : size.width * 0.44,
        18.h,
      );
    }

    if (isPlayerTeam) {
      SoundManager().playCoinSound();
    } else {
      SoundManager().playButtonClick();
    }

    setState(() {
      _flyingBonusPoints = points;
      _flyingBonusTeam = result.winningTeam;
      _flyingBonusStartPos = startPos;
      _flyingBonusTargetPos = targetPos;
    });

    try {
      await _bonusScoreController.forward(from: 0.0);
    } catch (_) {}

    if (!mounted) return;

    // Bonus landed on scoreboard! Trigger score punch pulse
    setState(() {
      _isScorePillPulsing = true;
      _flyingBonusPoints = null;
      _flyingBonusStartPos = null;
      _flyingBonusTargetPos = null;
    });

    SoundManager().playTilePlace();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _isScorePillPulsing = false;
    });

    if (onComplete != null) {
      onComplete();
    } else {
      // Seamless auto-advance to next round! No dialog window!
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _flyingPiece = null;
        _flyingStartPos = null;
        _flyingTargetPos = null;
        _engine.startNewGame(advanceRound: true);
        _startTurnTimer();
      });
      _checkBotTurn();
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
    DominoTableSettingsDialog.show(
      context,
      engine: _engine,
      isInitial: isInitial,
      onApply: () {
        setState(() {
          _engine.resetEntireMatch();
          _startTurnTimer();
        });
        _checkBotTurn();
      },
      onCancel: () {
        if (isInitial) {
          Navigator.pop(context);
        }
      },
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

    // 1. إذا لم يتم بدء/تأكيد اللعب بعد: يظهر صندوق الإعدادات أولاً بالكامل، ولا تظهر طاولة الدومينو إلا بعد الموافقة أو الرفض
    if (!_isTableRevealed) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // خلفية المقهى العربي التراثية
              Positioned.fill(
                child: Image.asset(
                  'assets/images/arabian_cafe_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A0933), Color(0xFF421554)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // تغشية داكنة خفيفة
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.60),
                ),
              ),

              // شريط علوي بسيط للرجوع واسم المقهى
              Positioned(
                top: 8.h,
                right: 14.w,
                left: 14.w,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Color(0xFFFFD700), size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'دومينو كافيه ☕🀄',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // صندوق الإعدادات التراثي يظهر أولاً في المنتصف
              Center(
                child: DominoTableSettingsDialog(
                  engine: _engine,
                  isInitial: true,
                  isDialog: false,
                  onApply: () {
                    // بعد الموافقة: تطبيق الإعدادات وإظهار الطاولة والدومينو وبدء اللعب
                    SoundManager().playCardDeal();
                    setState(() {
                      _engine.resetEntireMatch();
                      _isTableRevealed = true;
                      _startTurnTimer();
                    });
                    _checkBotTurn();
                  },
                  onCancel: () {
                    // بعد الرفض أو التخطي: إظهار الطاولة والدومينو بالإعدادات الافتراضية وبدء اللعب
                    SoundManager().playCardDeal();
                    setState(() {
                      _isTableRevealed = true;
                      _startTurnTimer();
                    });
                    _checkBotTurn();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                          // Domino Cafe Green Velvet Board (Full Screen with isolated repaint boundary)
                          RepaintBoundary(
                            child: DominoCafeBoard(
                              engine: _engine,
                              selectedPiece: _selectedPiece,
                              onPlacePiece: _onPlacePiece,
                              totalPotCoins: (widget.betCoins ?? 80000) * 2,
                              isDragging: _isTileDragging,
                            ),
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
                                  totalTurnSeconds: _turnDurationSeconds,
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
                                totalTurnSeconds: _turnDurationSeconds,
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
                                totalTurnSeconds: _turnDurationSeconds,
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
                                  totalTurnSeconds: _turnDurationSeconds,
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
                              flyingPiece: _flyingPiece,
                              recentlyMovedPiece: _recentlyMovedPiece,
                              recentlyMovedTimestamp: _recentlyMovedTimestamp,
                              isPlayerTurn: _engine.isPlayerTurn,
                              isDraggingActive: _isTileDragging,
                              onTileTap: (piece) =>
                                  _onTileTap(piece as DominoPiece),
                              onTileDragStarted: (piece) =>
                                  _onTileDragStarted(piece as DominoPiece),
                              onTileDragEnded: _onTileDragEnded,
                              onReorderTiles: _onReorderTiles,
                              onReorderToIndex: _onReorderToIndex,
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
                        ],
                      ),
                    ),
                  ],
                ),

                // Flying Bonus Score Overlay (رقم المكسب الطائر كبونص مقتنص)
                if (_flyingBonusPoints != null &&
                    _flyingBonusStartPos != null &&
                    _flyingBonusTargetPos != null)
                  _buildFlyingBonusScoreOverlay(),
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
          AnimatedScale(
            key: _scoreboardKey,
            scale: _isScorePillPulsing ? 1.20 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: _isScorePillPulsing
                    ? const Color(0xFF00E676).withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: _isScorePillPulsing
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFFD700).withValues(alpha: 0.5),
                  width: _isScorePillPulsing ? 1.8.w : 1.w,
                ),
                boxShadow: _isScorePillPulsing
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00E676).withValues(alpha: 0.6),
                          blurRadius: 14.r,
                          spreadRadius: 2.r,
                        ),
                      ]
                    : null,
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

          SizedBox(width: 8.w),

          // Heritage Settings Button
          GestureDetector(
            onTap: () => _showSettingsDialog(isInitial: false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A2508), Color(0xFF261203)],
                ),
                borderRadius: BorderRadius.circular(9.r),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.75),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 6.r,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded,
                      color: const Color(0xFFFFD700), size: 11.r),
                  SizedBox(width: 3.w),
                  Text(
                    'الإعدادات',
                    style: GoogleFonts.cairo(
                      fontSize: 7.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
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

    // Rack spans left: 175.w -> right: 50.w and is centered.
    // The newly drawn tile is placed at index 0 (the RIGHT edge of the hand).
    final rackLeft = 175.w;
    final rackWidth = tableSize.width - 175.w - 50.w;
    final rackCenterX = rackLeft + rackWidth / 2;
    final tileWidth = 32.r;
    final newHandCount = _engine.playerHand.length + 1;
    final totalNewHandWidth = newHandCount * tileWidth;

    // In RTL, index 0 is the rightmost slot:
    final targetX = (rackCenterX + (totalNewHandWidth / 2) - (tileWidth / 2))
        .clamp(rackLeft, tableSize.width - 70.w)
        .toDouble();
    final target = Offset(targetX, tableSize.height - 45.h);

    return (start, target);
  }

  /// Drawn tile flying from the boneyard to the hand: arcs up, spins and
  /// flips from face-down to face-up halfway through the flight.
  Widget _buildDrawFlightOverlay() {
    return Positioned(
      left: 0,
      top: 0,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _drawFlightController,
            builder: (context, _) {
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

              return Transform.translate(
                offset: Offset(x, y),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateZ(spin)
                    ..rotateY(displayAngle)
                    ..scaleByDouble(scale, scale, 1.0, 1.0),
                  child: face,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Animated Domino Tile that emerges from beneath the bot's avatar HUD,
  /// lifts into the air with a parabolic 3D flight arc, rotates, and lands smoothly on the table.
  Widget _buildFlyingTileOverlay() {
    return Positioned(
      left: 0,
      top: 0,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _flyingCardController,
            builder: (context, _) {
              final t = _flyingCardController.value;
              final curvedProgress = Curves.easeInOutCubic.transform(t);

              final start = _flyingStartPos!;
              final target = _flyingTargetPos!;

              final currentX = lerpDouble(start.dx, target.dx, curvedProgress)!;
              final currentY = lerpDouble(start.dy, target.dy, curvedProgress)!;

              // Flight Arc: Parabolic lift into the air (reaches apex at t = 0.5)
              final flightArc = math.sin(t * math.pi);
              final visualY = currentY - (38.h * flightArc);

              // Scale begins at 0.75 emerging from under avatar, grows to 1.0 on table
              final currentScale = lerpDouble(0.75, 1.0, curvedProgress)!;

              // Start tilt rotation based on flight direction, smoothly aligns to 0
              final startAngle = (start.dx > target.dx) ? 0.35 : -0.35;
              final currentAngle = lerpDouble(startAngle, 0.0, curvedProgress)!;

              // Smooth emergence fade-in
              final opacity = (t * 5.0).clamp(0.0, 1.0);

              return Transform.translate(
                offset: Offset(currentX, visualY),
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: currentAngle,
                    alignment: Alignment.center,
                    child: Domino3DTile(
                      top: _flyingPiece!.a,
                      bottom: _flyingPiece!.b,
                      isHorizontal: !_flyingPiece!.isDouble,
                      onTable: true,
                      scale: currentScale,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Animated flying bonus score:
  /// Pops up as a large, faded number only (no window, no glow, no background),
  /// and ascends smoothly to land on the match scoreboard.
  Widget _buildFlyingBonusScoreOverlay() {
    return Positioned(
      left: 0,
      top: 0,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _bonusScoreController,
            builder: (context, _) {
              final t = _bonusScoreController.value;
              final start = _flyingBonusStartPos!;
              final target = _flyingBonusTargetPos!;
              final isPlayerTeam = _flyingBonusTeam == 1;

              final double currentX;
              final double currentY;
              final double currentScale;
              final double opacity;

              if (t < 0.28) {
                final popProgress = (t / 0.28).clamp(0.0, 1.0);
                final curvedPop = Curves.easeOutBack.transform(popProgress);
                currentX = start.dx;
                currentY = start.dy - (12.h * popProgress);
                currentScale = 0.60 + (0.45 * curvedPop);
                // Faded opacity during emergence
                opacity = (popProgress * 0.70).clamp(0.0, 0.70);
              } else {
                final flyProgress = ((t - 0.28) / 0.72).clamp(0.0, 1.0);
                final curvedFly = Curves.easeInOutCubic.transform(flyProgress);
                currentX = lerpDouble(start.dx, target.dx, curvedFly)!;
                final linearY =
                    lerpDouble(start.dy - 12.h, target.dy, curvedFly)!;
                final arc = math.sin(flyProgress * math.pi) * 35.h;
                currentY = linearY - arc;
                currentScale = lerpDouble(1.05, 0.65, curvedFly)!;
                // Soft fade-out upon arriving at scoreboard
                opacity = flyProgress > 0.85
                    ? (((1.0 - flyProgress) / 0.15) * 0.70).clamp(0.0, 0.70)
                    : 0.70;
              }

              // Faded colors for player (soft gold) and opponent (soft coral)
              final Color numberColor = isPlayerTeam
                  ? const Color(0xFFFFE082).withValues(alpha: 0.80)
                  : const Color(0xFFFFAB91).withValues(alpha: 0.80);

              return Transform.translate(
                offset: Offset(currentX, currentY),
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Transform.scale(
                    scale: currentScale,
                    child: Opacity(
                      opacity: opacity,
                      child: Text(
                        '+${_flyingBonusPoints ?? 0}',
                        style: GoogleFonts.montserrat(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w900,
                          color: numberColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
