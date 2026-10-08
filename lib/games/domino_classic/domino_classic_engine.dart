import 'dart:math';
import 'domino_piece.dart';

enum DominoEdgeLocation { left, right }

enum DominoPlayMode {
  oneVsOne,      // 1v1 (2 players with boneyard)
  partnership4P, // 2v2 (4 players, partnership, no boneyard)
}

enum DominoDifficulty {
  casual,       // عادي
  pro,          // محترف
  grandmaster,  // داهية القهاوي
}

enum DominoWinType {
  domino,   // نزول كل القطع
  blocked,  // قفلة (صاك)
  draw,     // تعادل
}

class PlacedDomino {
  final DominoPiece piece;
  final int leftValue;  // The value facing left/outward on left or connecting on right
  final int rightValue; // The value facing right/outward on right or connecting on left
  final bool isDouble;
  final DominoEdgeLocation placedOn;

  const PlacedDomino({
    required this.piece,
    required this.leftValue,
    required this.rightValue,
    required this.isDouble,
    required this.placedOn,
  });

  @override
  String toString() => 'Placed[$leftValue|$rightValue]';
}

class DominoRoundResult {
  final DominoWinType winType;
  final int winningPlayerIndex;
  final int winningTeam; // 1: You & Partner, 2: Opponents
  final int pointsEarned;
  final Map<int, int> playerPipSums;
  final bool isMatchOver;
  final String title;
  final String description;

  const DominoRoundResult({
    required this.winType,
    required this.winningPlayerIndex,
    required this.winningTeam,
    required this.pointsEarned,
    required this.playerPipSums,
    required this.isMatchOver,
    required this.title,
    required this.description,
  });
}

/// Official, battle-tested standard Domino Game Engine (Draw & Block Dominoes)
/// Supports 1v1 & 2v2 Partnership, Smart AI levels, Cumulative Matches (to 101) & Sak/Blocked detection.
class DominoClassicEngine {
  DominoPlayMode mode = DominoPlayMode.oneVsOne;
  DominoDifficulty difficulty = DominoDifficulty.pro;

  final List<DominoPiece> boneyard = [];
  
  // 4 Player hands:
  // 0: You (South)
  // 1: Opponent Right (East - Abu Ali)
  // 2: Partner (North - El Moallem Mahrous) [In 4P mode]
  // 3: Opponent Left (West - King Ramy)
  final List<List<DominoPiece>> hands = [[], [], [], []];

  List<DominoPiece> get playerHand => hands[0];
  List<DominoPiece> get botHand => hands[mode == DominoPlayMode.oneVsOne ? 3 : 3];

  /// The linear chain of dominoes on the table from Left (index 0) to Right (index length-1)
  final List<PlacedDomino> board = [];

  /// Index of the first tile ever placed in the current round, guaranteed to be anchored at (0, 0).
  int initialTileIndex = 0;
  int get safeInitialTileIndex =>
      board.isEmpty ? 0 : initialTileIndex.clamp(0, board.length - 1);

  // Match cumulative scoring
  int targetScore = 101; // First team to 101 wins the match
  int team1MatchScore = 0; // You (+ Partner in 4P)
  int team2MatchScore = 0; // Opponents
  int currentRound = 1;

  // Backward compatibility legacy fields
  int get playerScore => team1MatchScore;
  set playerScore(int v) => team1MatchScore = v;
  int get botScore => team2MatchScore;
  set botScore(int v) => team2MatchScore = v;
  int playerWins = 0;
  int botWins = 0;

  int currentTurnIndex = 0; // 0: South (player), 1: East, 2: North, 3: West
  bool get isPlayerTurn => currentTurnIndex == 0;
  set isPlayerTurn(bool v) {
    currentTurnIndex = v ? 0 : 3;
  }

  bool isGameOver = false;
  bool isMatchOver = false;
  DominoRoundResult? lastRoundResult;
  String statusMessage = 'بدء مباراة جديدة 🀄';
  final Random _rng = Random();

  // AI Knowledge: Values that each player couldn't play when they drew or passed
  final Map<int, Set<int>> knownMissingValues = {0: {}, 1: {}, 2: {}, 3: {}};
  int consecutivePasses = 0;

  int get activePlayerCount => mode == DominoPlayMode.partnership4P ? 4 : 2;

  // Player Names & Info
  static const List<String> playerNames = [
    'أنت',
    'أبو علي ⚡',
    'المعلم محروس 🤝',
    'الكينج رامي 👑',
  ];

  void resetEntireMatch({int target = 101, DominoPlayMode? newMode, DominoDifficulty? newDiff}) {
    if (newMode != null) mode = newMode;
    if (newDiff != null) difficulty = newDiff;
    targetScore = target;
    team1MatchScore = 0;
    team2MatchScore = 0;
    playerWins = 0;
    botWins = 0;
    currentRound = 1;
    isMatchOver = false;
    startNewGame();
  }

  void startNewGame({bool advanceRound = false}) {
    if (advanceRound) currentRound++;

    final all = DominoPiece.fullSet()..shuffle(_rng);
    for (final hand in hands) {
      hand.clear();
    }
    boneyard.clear();
    board.clear();
    initialTileIndex = 0;
    isGameOver = false;
    lastRoundResult = null;
    consecutivePasses = 0;
    knownMissingValues.forEach((key, set) => set.clear());

    if (mode == DominoPlayMode.partnership4P) {
      // 4 Players: 7 tiles each, no boneyard
      hands[0].addAll(all.sublist(0, 7));   // You (South)
      hands[1].addAll(all.sublist(7, 14));  // Opponent Right (East)
      hands[2].addAll(all.sublist(14, 21)); // Partner (North)
      hands[3].addAll(all.sublist(21, 28)); // Opponent Left (West)
    } else {
      // 1v1: 7 tiles each to Player 0 and Opponent 3, 14 in boneyard
      hands[0].addAll(all.sublist(0, 7));   // You
      hands[3].addAll(all.sublist(7, 14));  // Bot (West)
      boneyard.addAll(all.sublist(14));     // 14 tiles in boneyard
    }

    // Determine who starts:
    // In Double-Six: Player with highest double starts the first round!
    int highestDouble = -1;
    int startingPlayer = 0;

    final playersToCheck = mode == DominoPlayMode.partnership4P ? [0, 1, 2, 3] : [0, 3];
    for (final p in playersToCheck) {
      for (final tile in hands[p]) {
        if (tile.isDouble && tile.a > highestDouble) {
          highestDouble = tile.a;
          startingPlayer = p;
        }
      }
    }

    if (highestDouble != -1) {
      currentTurnIndex = startingPlayer;
      statusMessage = startingPlayer == 0
          ? 'دورك في البداية (تمتلك أعلى دبل [$highestDouble|$highestDouble])!'
          : '${playerNames[startingPlayer]} يبدأ بأعلى دبل [$highestDouble|$highestDouble]...';
    } else {
      // If no doubles held, highest pip count starts
      int maxPip = -1;
      for (final p in playersToCheck) {
        for (final tile in hands[p]) {
          if (tile.pip > maxPip) {
            maxPip = tile.pip;
            startingPlayer = p;
          }
        }
      }
      currentTurnIndex = startingPlayer;
      statusMessage = startingPlayer == 0
          ? 'دورك في البداية بأعلى قطعة!'
          : '${playerNames[startingPlayer]} يبدأ الجولة...';
    }
  }

  /// Exposed value at the Left end of the board
  int? get leftEnd => board.isEmpty ? null : board.first.leftValue;

  /// Exposed value at the Right end of the board
  int? get rightEnd => board.isEmpty ? null : board.last.rightValue;

  /// Check which ends a piece can legally attach to
  List<DominoEdgeLocation> getValidEdgesFor(DominoPiece piece, [int? playerIdx]) {
    final idx = playerIdx ?? currentTurnIndex;
    if (board.isEmpty) {
      final hand = hands[idx];
      final doubles = hand.where((p) => p.isDouble).toList();
      if (doubles.isNotEmpty) {
        doubles.sort((a, b) => b.a.compareTo(a.a));
        // Highest double must lead on first move
        if (piece == doubles.first) {
          return [DominoEdgeLocation.left, DominoEdgeLocation.right];
        }
        return [];
      }
      return [DominoEdgeLocation.left, DominoEdgeLocation.right];
    }

    final valid = <DominoEdgeLocation>[];
    final l = leftEnd!;
    final r = rightEnd!;

    if (piece.a == l || piece.b == l) {
      valid.add(DominoEdgeLocation.left);
    }
    if (piece.a == r || piece.b == r) {
      valid.add(DominoEdgeLocation.right);
    }

    return valid;
  }

  /// Plays a piece to the left or right end of the board
  bool playPiece(DominoPiece piece, DominoEdgeLocation edge) {
    if (isGameOver) return false;

    final hand = hands[currentTurnIndex];
    if (!hand.contains(piece)) return false;

    if (board.isEmpty) {
      initialTileIndex = 0;
      board.add(PlacedDomino(
        piece: piece,
        leftValue: piece.a,
        rightValue: piece.b,
        isDouble: piece.isDouble,
        placedOn: edge,
      ));
    } else {
      if (edge == DominoEdgeLocation.left) {
        final l = leftEnd!;
        if (piece.a != l && piece.b != l) return false;

        final newLeft = (piece.b == l) ? piece.a : piece.b;
        final newRight = l;

        board.insert(
          0,
          PlacedDomino(
            piece: piece,
            leftValue: newLeft,
            rightValue: newRight,
            isDouble: piece.isDouble,
            placedOn: edge,
          ),
        );
        initialTileIndex++;
      } else {
        final r = rightEnd!;
        if (piece.a != r && piece.b != r) return false;

        final newLeft = r;
        final newRight = (piece.a == r) ? piece.b : piece.a;

        board.add(
          PlacedDomino(
            piece: piece,
            leftValue: newLeft,
            rightValue: newRight,
            isDouble: piece.isDouble,
            placedOn: edge,
          ),
        );
      }
    }

    hand.remove(piece);
    consecutivePasses = 0; // Move made, reset pass counter

    // 1. Check Win by Domino (Empty Hand)
    if (hand.isEmpty) {
      _handleDominoWin(currentTurnIndex);
      return true;
    }

    // 2. Next player turn
    _advanceTurn();
    return true;
  }

  void _advanceTurn() {
    if (isGameOver) return;

    if (mode == DominoPlayMode.partnership4P) {
      currentTurnIndex = (currentTurnIndex + 1) % 4;
    } else {
      currentTurnIndex = (currentTurnIndex == 0) ? 3 : 0;
    }

    statusMessage = currentTurnIndex == 0
        ? 'دورك للعب! 🎯'
        : '${playerNames[currentTurnIndex]} يفكر في نقلته...';

    _checkAndHandleBlockedGame();
  }

  void _handleDominoWin(int winnerIndex) {
    isGameOver = true;
    final winnerTeam = (winnerIndex == 0 || winnerIndex == 2) ? 1 : 2;

    int points = 0;
    final pipSums = <int, int>{};

    for (int i = 0; i < 4; i++) {
      final sum = hands[i].fold(0, (s, p) => s + p.pip);
      pipSums[i] = sum;
    }

    // Winner's team earns all pips remaining in opposing team's hands
    if (winnerTeam == 1) {
      points = pipSums[1]! + pipSums[3]!;
      team1MatchScore += points;
      playerWins++;
    } else {
      points = pipSums[0]! + pipSums[2]!;
      team2MatchScore += points;
      botWins++;
    }

    if (targetScore > 0 && (team1MatchScore >= targetScore || team2MatchScore >= targetScore)) {
      isMatchOver = true;
    }

    final isPlayerTeam = winnerTeam == 1;
    final winnerTitle = winnerIndex == 0
        ? 'دومـــيـنـو! 🀄🎉'
        : '${playerNames[winnerIndex]} نزل دومينو! 🀄';

    final desc = isPlayerTeam
        ? 'أنهيتم الجولة بنجاح وكسبتم +$points نقطة! 🏆'
        : 'فاز الفريق الخصم بالجولة وحصل على +$points نقطة.';

    lastRoundResult = DominoRoundResult(
      winType: DominoWinType.domino,
      winningPlayerIndex: winnerIndex,
      winningTeam: winnerTeam,
      pointsEarned: points,
      playerPipSums: pipSums,
      isMatchOver: isMatchOver,
      title: winnerTitle,
      description: desc,
    );

    statusMessage = '$winnerTitle (+ $points نقطة)';
  }

  /// Pass current player's turn
  void passTurn() {
    if (isGameOver) return;

    // Record missing values
    if (leftEnd != null) knownMissingValues[currentTurnIndex]?.add(leftEnd!);
    if (rightEnd != null) knownMissingValues[currentTurnIndex]?.add(rightEnd!);

    consecutivePasses++;

    final passingPlayer = playerNames[currentTurnIndex];
    statusMessage = '$passingPlayer مرر دوره (باص) ⏭️';

    if (_checkAndHandleBlockedGame()) return;

    _advanceTurn();
  }

  /// Check if the game is locked/blocked (القفلة / صاك)
  bool _checkAndHandleBlockedGame() {
    if (isGameOver) return true;

    final activePlayers = mode == DominoPlayMode.partnership4P ? [0, 1, 2, 3] : [0, 3];
    final anyCanMove = activePlayers.any((p) => hands[p].any((tile) => getValidEdgesFor(tile, p).isNotEmpty));

    // In 1v1: blocked if neither player can move AND boneyard is empty
    // In 4P: blocked if no player can move (boneyard is always empty)
    final boneyardDepleted = boneyard.isEmpty;

    if (!anyCanMove && boneyardDepleted) {
      isGameOver = true;

      final pipSums = <int, int>{};
      for (int i = 0; i < 4; i++) {
        pipSums[i] = hands[i].fold(0, (s, p) => s + p.pip);
      }

      int team1Sum = pipSums[0]! + pipSums[2]!;
      int team2Sum = pipSums[1]! + pipSums[3]!;

      // Individual with lowest pips wins for the team
      int lowestPip = 999;
      int lowestPlayer = 0;
      for (final p in activePlayers) {
        if (pipSums[p]! < lowestPip) {
          lowestPip = pipSums[p]!;
          lowestPlayer = p;
        }
      }

      final winningTeam = (team1Sum < team2Sum)
          ? 1
          : (team2Sum < team1Sum ? 2 : ((lowestPlayer == 0 || lowestPlayer == 2) ? 1 : 2));

      int points = 0;
      if (team1Sum != team2Sum) {
        points = (team1Sum - team2Sum).abs();
      } else {
        points = 0;
      }

      if (winningTeam == 1 && points > 0) {
        team1MatchScore += points;
        playerWins++;
      } else if (winningTeam == 2 && points > 0) {
        team2MatchScore += points;
        botWins++;
      }

      if (targetScore > 0 && (team1MatchScore >= targetScore || team2MatchScore >= targetScore)) {
        isMatchOver = true;
      }

      final isTeam1 = winningTeam == 1;
      final title = '🔒 قـفـلـة (صـــاك)!';
      final desc = points > 0
          ? (isTeam1
              ? 'فزتم بالقفلة! مجموع نقطكم ($team1Sum) أقل من الخصم ($team2Sum). الفارق: +$points نقطة 🌟'
              : 'فاز الخصم بالقفلة! مجموع نقطهم ($team2Sum) أقل منكم ($team1Sum). الفارق: +$points نقطة.')
          : 'تعادلت القفلة بمجموع نقط ($team1Sum) لكل فريق!';

      lastRoundResult = DominoRoundResult(
        winType: points > 0 ? DominoWinType.blocked : DominoWinType.draw,
        winningPlayerIndex: lowestPlayer,
        winningTeam: winningTeam,
        pointsEarned: points,
        playerPipSums: pipSums,
        isMatchOver: isMatchOver,
        title: title,
        description: desc,
      );

      statusMessage = '$title (+ $points نقطة)';
      return true;
    }
    return false;
  }

  /// Check and select the best move for the active bot without playing it immediately
  ClassicBotMoveResult? pickBotMove() {
    if (isPlayerTurn || isGameOver) return null;

    final botIdx = currentTurnIndex;
    final botHand = hands[botIdx];

    final possibleMoves = <_ClassicBotMove>[];
    for (final piece in botHand) {
      final validEdges = getValidEdgesFor(piece, botIdx);
      for (final edge in validEdges) {
        possibleMoves.add(_ClassicBotMove(piece: piece, edge: edge));
      }
    }

    if (possibleMoves.isEmpty) return null;

    _ClassicBotMove bestMove;

    if (difficulty == DominoDifficulty.casual) {
      // Casual: random or simple double priority
      possibleMoves.shuffle(_rng);
      possibleMoves.sort((a, b) => b.piece.isDouble ? 1 : -1);
      bestMove = possibleMoves.first;
    } else if (difficulty == DominoDifficulty.pro) {
      // Pro: dump doubles and high pips first
      possibleMoves.sort((a, b) {
        if (a.piece.isDouble && !b.piece.isDouble) return -1;
        if (!a.piece.isDouble && b.piece.isDouble) return 1;
        return b.piece.pip.compareTo(a.piece.pip);
      });
      bestMove = possibleMoves.first;
    } else {
      bestMove = _evaluateGrandmasterMove(possibleMoves, botIdx);
    }

    return ClassicBotMoveResult(
      piece: bestMove.piece,
      edge: bestMove.edge,
      playerIndex: botIdx,
    );
  }

  /// Draws a single tile from boneyard into current bot's hand in 1v1 mode
  DominoPiece? botDrawFromBoneyard() {
    if (boneyard.isEmpty || mode != DominoPlayMode.oneVsOne) return null;
    final drawn = boneyard.removeLast();
    hands[currentTurnIndex].add(drawn);
    return drawn;
  }

  /// Advanced Strategic AI for Bot players (Levels: casual, pro, grandmaster)
  void triggerBotMove() {
    if (isPlayerTurn || isGameOver) return;

    final move = pickBotMove();
    if (move != null) {
      playPiece(move.piece, move.edge);
    } else if (boneyard.isNotEmpty && mode == DominoPlayMode.oneVsOne) {
      botDrawFromBoneyard();
      triggerBotMove();
    } else {
      passTurn();
    }
  }

  _ClassicBotMove _evaluateGrandmasterMove(List<_ClassicBotMove> moves, int botIdx) {
    int bestScore = -9999;
    _ClassicBotMove bestMove = moves.first;

    final isTeam2 = (botIdx == 1 || botIdx == 3);
    final opponentIdx = isTeam2 ? 0 : 1;
    final partnerIdx = isTeam2 ? (botIdx == 1 ? 3 : 1) : 2;

    for (final m in moves) {
      int score = 0;

      // 1. Heavy tile weight (prefer shedding dangerous high tiles)
      score += m.piece.pip * 2;
      if (m.piece.isDouble) score += 12;

      // Calculate resulting open end
      final resultingOpenEnd = (m.edge == DominoEdgeLocation.left)
          ? ((m.piece.b == leftEnd) ? m.piece.a : m.piece.b)
          : ((m.piece.a == rightEnd) ? m.piece.b : m.piece.a);

      // 2. Starve opponent: If opponent is missing this value, big bonus!
      if (knownMissingValues[opponentIdx]?.contains(resultingOpenEnd) == true) {
        score += 25;
      }

      // 3. In 4P mode: Don't starve partner!
      if (mode == DominoPlayMode.partnership4P) {
        if (knownMissingValues[partnerIdx]?.contains(resultingOpenEnd) == true) {
          score -= 30; // Strongly avoid feeding values partner lacks
        }
      }

      // 4. Synergize with own hand: Keep ends where bot has matching tiles
      final botMatches = hands[botIdx].where((p) => p != m.piece && (p.a == resultingOpenEnd || p.b == resultingOpenEnd)).length;
      score += botMatches * 6;

      if (score > bestScore) {
        bestScore = score;
        bestMove = m;
      }
    }

    return bestMove;
  }
}

class ClassicBotMoveResult {
  final DominoPiece piece;
  final DominoEdgeLocation edge;
  final int playerIndex;

  const ClassicBotMoveResult({
    required this.piece,
    required this.edge,
    required this.playerIndex,
  });
}

class _ClassicBotMove {
  final DominoPiece piece;
  final DominoEdgeLocation edge;
  const _ClassicBotMove({required this.piece, required this.edge});
}
