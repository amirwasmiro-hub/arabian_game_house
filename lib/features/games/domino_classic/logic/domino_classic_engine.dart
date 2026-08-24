import 'dart:math';
import '../models/domino_piece.dart';

enum DominoEdgeLocation { left, right }

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

/// Official, battle-tested standard Domino Game Engine (Draw & Block Dominoes)
/// Follows Pagat & International Domino Tournament standard Double-Six rules.
class DominoClassicEngine {
  final List<DominoPiece> boneyard = [];
  final List<DominoPiece> playerHand = [];
  final List<DominoPiece> botHand = [];

  /// The linear chain of dominoes on the table from Left (index 0) to Right (index length-1)
  final List<PlacedDomino> board = [];

  int playerScore = 0;
  int botScore = 0;
  int playerWins = 0;
  int botWins = 0;

  bool isPlayerTurn = true;
  bool isGameOver = false;
  String statusMessage = 'بدء مباراة جديدة 🀄';
  final Random _rng = Random();

  void startNewGame() {
    final all = DominoPiece.fullSet()..shuffle(_rng);
    playerHand.clear();
    botHand.clear();
    boneyard.clear();
    board.clear();
    isGameOver = false;

    // Deal 7 tiles each in 2-player game
    playerHand.addAll(all.sublist(0, 7));
    botHand.addAll(all.sublist(7, 14));
    boneyard.addAll(all.sublist(14)); // 14 tiles in boneyard

    // In official rules: player with the highest double leads
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
      statusMessage = 'دورك في النزول الأول (تمتلك أعلى دبل [$pMaxDouble|$pMaxDouble])!';
    } else if (bMaxDouble > pMaxDouble) {
      isPlayerTurn = false;
      statusMessage = 'البوت يبدأ النزول الأول بأعلى دبل [$bMaxDouble|$bMaxDouble]...';
    } else {
      // If neither has doubles, highest pip count starts
      int pMaxPip = playerHand.fold(-1, (maxP, p) => max(maxP, p.pip));
      int bMaxPip = botHand.fold(-1, (maxP, p) => max(maxP, p.pip));
      isPlayerTurn = pMaxPip >= bMaxPip;
      statusMessage = isPlayerTurn ? 'دورك في البداية!' : 'البوت يبدأ الجولة...';
    }
  }

  /// Exposed value at the Left end of the board
  int? get leftEnd => board.isEmpty ? null : board.first.leftValue;

  /// Exposed value at the Right end of the board
  int? get rightEnd => board.isEmpty ? null : board.last.rightValue;

  /// Check which ends a piece can legally attach to
  List<DominoEdgeLocation> getValidEdgesFor(DominoPiece piece) {
    if (board.isEmpty) {
      final hand = isPlayerTurn ? playerHand : botHand;
      final doubles = hand.where((p) => p.isDouble).toList();
      if (doubles.isNotEmpty) {
        doubles.sort((a, b) => b.a.compareTo(a.a));
        // Highest double must lead
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

    // Check Left end: piece must have one side matching leftEnd
    if (piece.a == l || piece.b == l) {
      valid.add(DominoEdgeLocation.left);
    }

    // Check Right end: piece must have one side matching rightEnd
    if (piece.a == r || piece.b == r) {
      valid.add(DominoEdgeLocation.right);
    }

    return valid;
  }

  /// Plays a piece to the left or right end of the board
  bool playPiece(DominoPiece piece, DominoEdgeLocation edge) {
    if (isGameOver) return false;

    final hand = isPlayerTurn ? playerHand : botHand;
    if (!hand.contains(piece)) return false;

    if (board.isEmpty) {
      // First piece on table: left is 'a', right is 'b'
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

        // If piece.b == l, [a | b] connects 'b' to 'l', and 'a' becomes new leftValue
        // If piece.a == l, [b | a] connects 'a' to 'l', and 'b' becomes new leftValue
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
      } else {
        final r = rightEnd!;
        if (piece.a != r && piece.b != r) return false;

        // If piece.a == r, [a | b] connects 'a' to 'r', and 'b' becomes new rightValue
        // If piece.b == r, [b | a] connects 'b' to 'r', and 'a' becomes new rightValue
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

    // 1. Check Win by Domino (Empty Hand)
    if (hand.isEmpty) {
      isGameOver = true;
      int opponentRemaining = isPlayerTurn
          ? botHand.fold(0, (s, p) => s + p.pip)
          : playerHand.fold(0, (s, p) => s + p.pip);

      if (isPlayerTurn) {
        playerScore += opponentRemaining;
        playerWins++;
        statusMessage = '🎉 دومينو! فزت بهذه الجولة (+ $opponentRemaining نقطة)!';
      } else {
        botScore += opponentRemaining;
        botWins++;
        statusMessage = '🤖 البوت نزل دومينو وفاز بالجولة (+ $opponentRemaining نقطة)!';
      }
      return true;
    }

    // 2. Switch turn and check for blocked game
    isPlayerTurn = !isPlayerTurn;
    statusMessage = isPlayerTurn ? 'دورك للعب!' : 'البوت يفكر...';
    checkAndHandleBlockedGame();
    return true;
  }

  /// Pass current player's turn (allowed only when no moves possible and boneyard is empty)
  void passTurn() {
    if (!isPlayerTurn || isGameOver) return;
    isPlayerTurn = false;
    statusMessage = 'لقد مررت دورك (باص). دور البوت...';
    checkAndHandleBlockedGame();
  }

  /// Check if the game is locked/blocked (القفلة)
  bool checkAndHandleBlockedGame() {
    if (isGameOver) return true;

    final playerHasMove = playerHand.any((p) => getValidEdgesFor(p).isNotEmpty);
    final botHasMove = botHand.any((p) => getValidEdgesFor(p).isNotEmpty);

    // Blocked if neither player can make a move AND boneyard is empty
    if (!playerHasMove && !botHasMove && boneyard.isEmpty) {
      isGameOver = true;
      final pSum = playerHand.fold(0, (s, p) => s + p.pip);
      final bSum = botHand.fold(0, (s, p) => s + p.pip);

      if (pSum < bSum) {
        final diff = bSum - pSum;
        playerScore += diff;
        playerWins++;
        statusMessage = '🔒 قُفلت اللعبة! فزت بـ $diff نقطة ($pSum مقابل $bSum للخصم)!';
      } else if (bSum < pSum) {
        final diff = pSum - bSum;
        botScore += diff;
        botWins++;
        statusMessage = '🔒 قُفلت اللعبة! فاز البوت بـ $diff نقطة ($bSum مقابل $pSum لك)!';
      } else {
        statusMessage = '🔒 قُفلت اللعبة وتعادل الفريمان ($pSum نقطة لكل منهما)!';
      }
      return true;
    }
    return false;
  }

  /// Strategic AI for Bot: Prioritizes heavy pips and doubles, draws if needed
  void triggerBotMove() {
    if (isPlayerTurn || isGameOver) return;

    final possibleMoves = <_ClassicBotMove>[];
    for (final piece in botHand) {
      final validEdges = getValidEdgesFor(piece);
      for (final edge in validEdges) {
        possibleMoves.add(_ClassicBotMove(piece: piece, edge: edge));
      }
    }

    if (possibleMoves.isNotEmpty) {
      // Sort: doubles first, then highest pip count (to reduce penalty if blocked)
      possibleMoves.sort((a, b) {
        if (a.piece.isDouble && !b.piece.isDouble) return -1;
        if (!a.piece.isDouble && b.piece.isDouble) return 1;
        return b.piece.pip.compareTo(a.piece.pip);
      });

      final bestMove = possibleMoves.first;
      playPiece(bestMove.piece, bestMove.edge);
    } else if (boneyard.isNotEmpty) {
      // Must draw from boneyard
      botHand.add(boneyard.removeLast());
      triggerBotMove();
    } else {
      // Pass turn
      if (checkAndHandleBlockedGame()) return;
      isPlayerTurn = true;
      statusMessage = 'البوت مرر لعدم وجود نقلة (باص). دورك!';
    }
  }
}

class _ClassicBotMove {
  final DominoPiece piece;
  final DominoEdgeLocation edge;
  const _ClassicBotMove({required this.piece, required this.edge});
}
