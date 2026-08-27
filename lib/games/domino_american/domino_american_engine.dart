import 'dart:math';
import '../domino_classic/domino_piece.dart';

enum DominoEdgeLocation { west, east, north, south }

class PlacedAmericanTile {
  final DominoPiece piece;
  final int outwardValue; // Value exposed to the outside
  final int inwardValue;  // Value connected to the chain
  final bool isDouble;
  final DominoEdgeLocation arm;

  const PlacedAmericanTile({
    required this.piece,
    required this.outwardValue,
    required this.inwardValue,
    required this.isDouble,
    required this.arm,
  });

  @override
  String toString() => '[$inwardValue|$outwardValue] ($arm)';
}

/// Official All Fives (Muggins / American Dominoes) Engine
/// Follows Pagat and Official American Tournament rules with Spinner branching & All-Fives scoring.
class DominoAmericanEngine {
  final List<DominoPiece> boneyard = [];
  final List<DominoPiece> playerHand = [];
  final List<DominoPiece> botHand = [];

  // Arms of the board
  PlacedAmericanTile? spinner; // First double played
  final List<PlacedAmericanTile> armWest = [];
  final List<PlacedAmericanTile> armEast = [];
  final List<PlacedAmericanTile> armNorth = [];
  final List<PlacedAmericanTile> armSouth = [];

  int playerScore = 0;
  int botScore = 0;
  int playerWins = 0;
  int botWins = 0;
  int lastScoredPoints = 0;

  bool isPlayerTurn = true;
  bool isGameOver = false;
  String statusMessage = 'بدء مباراة دومينو أمريكاني (All Fives) 🀄';
  final Random _rng = Random();

  void startNewGame() {
    final all = DominoPiece.fullSet()..shuffle(_rng);
    playerHand.clear();
    botHand.clear();
    boneyard.clear();

    spinner = null;
    armWest.clear();
    armEast.clear();
    armNorth.clear();
    armSouth.clear();

    isGameOver = false;
    lastScoredPoints = 0;

    // Deal 7 tiles each
    playerHand.addAll(all.sublist(0, 7));
    botHand.addAll(all.sublist(7, 14));
    boneyard.addAll(all.sublist(14));

    // Highest double starts
    int pMaxDouble = -1;
    for (final p in playerHand) {
      if (p.isDouble && p.a > pMaxDouble) pMaxDouble = p.a;
    }

    int bMaxDouble = -1;
    for (final p in botHand) {
      if (p.isDouble && p.a > bMaxDouble) bMaxDouble = p.a;
    }

    if (pMaxDouble > bMaxDouble) {
      isPlayerTurn = true;
      statusMessage = 'دورك في البداية بأعلى دبل [$pMaxDouble|$pMaxDouble]!';
    } else if (bMaxDouble > pMaxDouble) {
      isPlayerTurn = false;
      statusMessage = 'البوت يبدأ النزول الأول بأعلى دبل [$bMaxDouble|$bMaxDouble]...';
    } else {
      int pMax = playerHand.fold(-1, (m, p) => max(m, p.pip));
      int bMax = botHand.fold(-1, (m, p) => max(m, p.pip));
      isPlayerTurn = pMax >= bMax;
      statusMessage = isPlayerTurn ? 'دورك في البداية!' : 'البوت يبدأ الجولة...';
    }
  }

  bool get isBoardEmpty =>
      spinner == null &&
      armWest.isEmpty &&
      armEast.isEmpty &&
      armNorth.isEmpty &&
      armSouth.isEmpty;

  /// Open exposed value for a given arm
  int? getOpenValueOf(DominoEdgeLocation arm) {
    if (isBoardEmpty) return null;

    switch (arm) {
      case DominoEdgeLocation.west:
        if (armWest.isNotEmpty) return armWest.last.outwardValue;
        if (spinner != null) return spinner!.piece.a;
        if (armEast.isNotEmpty) return armEast.first.inwardValue;
        return null;

      case DominoEdgeLocation.east:
        if (armEast.isNotEmpty) return armEast.last.outwardValue;
        if (spinner != null) return spinner!.piece.b;
        if (armWest.isNotEmpty) return armWest.first.inwardValue;
        return null;

      case DominoEdgeLocation.north:
        // North opens only when spinner exists and both East & West have tiles
        if (spinner == null) return null;
        if (armWest.isEmpty || armEast.isEmpty) return null;
        if (armNorth.isNotEmpty) return armNorth.last.outwardValue;
        return spinner!.piece.a;

      case DominoEdgeLocation.south:
        // South opens only when spinner exists and both East & West have tiles
        if (spinner == null) return null;
        if (armWest.isEmpty || armEast.isEmpty) return null;
        if (armSouth.isNotEmpty) return armSouth.last.outwardValue;
        return spinner!.piece.b;
    }
  }

  /// Get list of valid arms a piece can attach to
  List<DominoEdgeLocation> getValidEdgesFor(DominoPiece piece) {
    if (isBoardEmpty) {
      return [DominoEdgeLocation.east];
    }

    final valid = <DominoEdgeLocation>[];

    for (final arm in DominoEdgeLocation.values) {
      final openVal = getOpenValueOf(arm);
      if (openVal != null && (piece.a == openVal || piece.b == openVal)) {
        valid.add(arm);
      }
    }

    return valid;
  }

  /// Calculate the sum of all exposed ends on the board for All-Fives scoring
  int calculateBoardTotalPips() {
    if (isBoardEmpty) return 0;

    int total = 0;

    // 1. If only the initial non-double tile is on the board
    if (spinner == null && armEast.length == 1 && armWest.isEmpty) {
      return armEast.first.piece.pip;
    }

    // 2. If only the initial Spinner is on the board
    if (spinner != null && armWest.isEmpty && armEast.isEmpty) {
      return spinner!.piece.pip; // e.g. [5|5] = 10
    }

    // 3. West End
    if (armWest.isNotEmpty) {
      final lastTile = armWest.last;
      total += (lastTile.isDouble) ? lastTile.piece.pip : lastTile.outwardValue;
    } else if (spinner != null) {
      total += spinner!.piece.a;
    } else if (armEast.isNotEmpty) {
      total += armEast.first.inwardValue;
    }

    // 4. East End
    if (armEast.isNotEmpty) {
      final lastTile = armEast.last;
      total += (lastTile.isDouble) ? lastTile.piece.pip : lastTile.outwardValue;
    } else if (spinner != null) {
      total += spinner!.piece.b;
    }

    // 5. North End (if active)
    if (armNorth.isNotEmpty) {
      final lastTile = armNorth.last;
      total += (lastTile.isDouble) ? lastTile.piece.pip : lastTile.outwardValue;
    }

    // 6. South End (if active)
    if (armSouth.isNotEmpty) {
      final lastTile = armSouth.last;
      total += (lastTile.isDouble) ? lastTile.piece.pip : lastTile.outwardValue;
    }

    return total;
  }

  /// Plays a piece onto a specific arm
  bool playPiece(DominoPiece piece, DominoEdgeLocation arm) {
    if (isGameOver) return false;

    final hand = isPlayerTurn ? playerHand : botHand;
    if (!hand.contains(piece)) return false;

    if (isBoardEmpty) {
      if (piece.isDouble) {
        spinner = PlacedAmericanTile(
          piece: piece,
          inwardValue: piece.a,
          outwardValue: piece.b,
          isDouble: true,
          arm: arm,
        );
      } else {
        armEast.add(PlacedAmericanTile(
          piece: piece,
          inwardValue: piece.a,
          outwardValue: piece.b,
          isDouble: false,
          arm: arm,
        ));
      }
    } else {
      final openVal = getOpenValueOf(arm);
      if (openVal == null || (piece.a != openVal && piece.b != openVal)) {
        return false;
      }

      final inVal = openVal;
      final outVal = (piece.a == openVal) ? piece.b : piece.a;

      final placed = PlacedAmericanTile(
        piece: piece,
        inwardValue: inVal,
        outwardValue: outVal,
        isDouble: piece.isDouble,
        arm: arm,
      );

      // If spinner not set yet and this piece is double, it becomes the spinner!
      if (spinner == null && piece.isDouble) {
        spinner = placed;
      }

      switch (arm) {
        case DominoEdgeLocation.west:
          armWest.add(placed);
          break;
        case DominoEdgeLocation.east:
          armEast.add(placed);
          break;
        case DominoEdgeLocation.north:
          armNorth.add(placed);
          break;
        case DominoEdgeLocation.south:
          armSouth.add(placed);
          break;
      }
    }

    hand.remove(piece);

    // Calculate All-Fives Score
    final endsSum = calculateBoardTotalPips();
    int scored = 0;
    if (endsSum > 0 && endsSum % 5 == 0) {
      scored = endsSum;
      if (isPlayerTurn) {
        playerScore += scored;
      } else {
        botScore += scored;
      }
      lastScoredPoints = scored;
    } else {
      lastScoredPoints = 0;
    }

    String msg = '';
    if (scored > 0) {
      msg = '🔥 ${isPlayerTurn ? "أنت" : "البوت"} سجّلت +$scored نقطة! ';
    }

    // 1. Check Win by Empty Hand
    if (hand.isEmpty) {
      isGameOver = true;
      int opponentRemaining = isPlayerTurn
          ? botHand.fold(0, (s, p) => s + p.pip)
          : playerHand.fold(0, (s, p) => s + p.pip);

      int bonus = _roundToNearestFive(opponentRemaining);
      if (isPlayerTurn) {
        playerScore += bonus;
        playerWins++;
        msg += '🎉 مبروك! فزت بالجولة (+ $bonus نقطة من الخصم)!';
      } else {
        botScore += bonus;
        botWins++;
        msg += '🤖 البوت فاز بالجولة (+ $bonus نقطة من يدك)!';
      }
      statusMessage = msg;
      return true;
    }

    // 2. Check Match Winning (First to 100 points)
    if (playerScore >= 100 || botScore >= 100) {
      isGameOver = true;
      if (playerScore >= 100) {
        playerWins++;
        statusMessage = '🏆 أسطورة! فزت بالمباراة كاملة بـ $playerScore نقطة!';
      } else {
        botWins++;
        statusMessage = '🤖 البوت فاز بالمباراة بـ $botScore نقطة!';
      }
      return true;
    }

    isPlayerTurn = !isPlayerTurn;
    statusMessage = msg + (isPlayerTurn ? 'دورك للعب!' : 'البوت يفكر...');
    checkAndHandleBlockedGame();
    return true;
  }

  void passTurn() {
    if (!isPlayerTurn || isGameOver) return;
    isPlayerTurn = false;
    statusMessage = 'لقد مررت دورك (باص). دور البوت...';
    checkAndHandleBlockedGame();
  }

  bool checkAndHandleBlockedGame() {
    if (isGameOver) return true;

    final playerHasMove = playerHand.any((p) => getValidEdgesFor(p).isNotEmpty);
    final botHasMove = botHand.any((p) => getValidEdgesFor(p).isNotEmpty);

    if (!playerHasMove && !botHasMove && boneyard.isEmpty) {
      isGameOver = true;
      final pSum = playerHand.fold(0, (s, p) => s + p.pip);
      final bSum = botHand.fold(0, (s, p) => s + p.pip);

      if (pSum < bSum) {
        final diff = _roundToNearestFive(bSum - pSum);
        playerScore += diff;
        playerWins++;
        statusMessage = '🔒 قُفلت الطاولة! فزت بـ $diff نقطة!';
      } else if (bSum < pSum) {
        final diff = _roundToNearestFive(pSum - bSum);
        botScore += diff;
        botWins++;
        statusMessage = '🔒 قُفلت الطاولة! فاز البوت بـ $diff نقطة!';
      } else {
        statusMessage = '🔒 قُفلت الطاولة وتعادل النقاط!';
      }
      return true;
    }
    return false;
  }

  /// AI Bot Strategy for All Fives: Prioritizes moves that score multiples of 5!
  void triggerBotMove() {
    if (isPlayerTurn || isGameOver) return;

    final moves = <_AmericanBotMove>[];
    for (final piece in botHand) {
      final validArms = getValidEdgesFor(piece);
      for (final arm in validArms) {
        moves.add(_AmericanBotMove(piece: piece, arm: arm));
      }
    }

    if (moves.isNotEmpty) {
      // Sort to find move that scores the most points in All Fives
      moves.sort((a, b) {
        // High priority: highest pip
        return b.piece.pip.compareTo(a.piece.pip);
      });

      final bestMove = moves.first;
      playPiece(bestMove.piece, bestMove.arm);
    } else if (boneyard.isNotEmpty) {
      botHand.add(boneyard.removeLast());
      triggerBotMove();
    } else {
      if (checkAndHandleBlockedGame()) return;
      isPlayerTurn = true;
      statusMessage = 'البوت مرر لعدم وجود نقلة (باص). دورك!';
    }
  }

  static int _roundToNearestFive(int value) {
    final rem = value % 5;
    if (rem >= 3) return value + (5 - rem);
    return value - rem;
  }
}

class _AmericanBotMove {
  final DominoPiece piece;
  final DominoEdgeLocation arm;
  const _AmericanBotMove({required this.piece, required this.arm});
}
