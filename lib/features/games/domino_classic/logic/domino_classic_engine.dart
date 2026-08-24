import 'dart:math';
import '../models/domino_piece.dart';

enum DominoEdgeLocation { west, east, north, south }

class PlacedDomino {
  final DominoPiece piece;
  final DominoEdgeLocation location;
  final bool isVertical;

  const PlacedDomino({
    required this.piece,
    required this.location,
    required this.isVertical,
  });
}

class DominoClassicEngine {
  final List<DominoPiece> boneyard = [];
  final List<DominoPiece> playerHand = [];
  final List<DominoPiece> botHand = [];

  final List<PlacedDomino> rowWest = [];
  final List<PlacedDomino> rowEast = [];
  PlacedDomino? spinnerTile;

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

    playerHand.addAll(all.sublist(0, 7));
    botHand.addAll(all.sublist(7, 14));
    boneyard.addAll(all.sublist(14));

    rowWest.clear();
    rowEast.clear();
    spinnerTile = null;
    isGameOver = false;

    // Determine who starts (highest double)
    int pMax = -1, bMax = -1;
    for (final p in playerHand) {
      if (p.isDouble && p.a > pMax) pMax = p.a;
    }
    for (final p in botHand) {
      if (p.isDouble && p.a > bMax) bMax = p.a;
    }

    if (pMax > bMax) {
      isPlayerTurn = true;
      statusMessage = 'دورك في النزول الأول (تمتلك أعلى دبل)!';
    } else if (bMax > pMax) {
      isPlayerTurn = false;
      statusMessage = 'البوت يبدأ النزول الأول...';
    } else {
      isPlayerTurn = _rng.nextBool();
      statusMessage = isPlayerTurn ? 'دورك في البداية!' : 'البوت يبدأ الجولة...';
    }
  }

  int get westEnd => rowWest.isEmpty ? (spinnerTile?.piece.a ?? 0) : rowWest.first.piece.a;
  int get eastEnd => rowEast.isEmpty ? (spinnerTile?.piece.b ?? 0) : rowEast.last.piece.b;

  List<DominoEdgeLocation> getValidEdgesFor(DominoPiece piece) {
    final valid = <DominoEdgeLocation>[];

    if (spinnerTile == null && rowWest.isEmpty && rowEast.isEmpty) {
      valid.add(DominoEdgeLocation.east);
      return valid;
    }

    final wE = westEnd;
    final eE = eastEnd;

    if (piece.canFit(wE)) valid.add(DominoEdgeLocation.west);
    if (piece.canFit(eE)) valid.add(DominoEdgeLocation.east);

    return valid;
  }

  bool playPiece(DominoPiece piece, DominoEdgeLocation edge) {
    if (isGameOver) return false;

    final hand = isPlayerTurn ? playerHand : botHand;
    if (!hand.contains(piece)) return false;

    if (spinnerTile == null && rowWest.isEmpty && rowEast.isEmpty) {
      final isDouble = piece.isDouble;
      final placed = PlacedDomino(piece: piece, location: DominoEdgeLocation.east, isVertical: isDouble);
      if (isDouble) {
        spinnerTile = placed;
      } else {
        rowEast.add(placed);
      }
    } else {
      if (edge == DominoEdgeLocation.west) {
        final oriented = piece.orientedForLeft(westEnd);
        rowWest.insert(0, PlacedDomino(piece: oriented, location: edge, isVertical: piece.isDouble));
        if (piece.isDouble && spinnerTile == null) {
          spinnerTile = PlacedDomino(piece: oriented, location: edge, isVertical: true);
        }
      } else if (edge == DominoEdgeLocation.east) {
        final oriented = piece.orientedForRight(eastEnd);
        rowEast.add(PlacedDomino(piece: oriented, location: edge, isVertical: piece.isDouble));
        if (piece.isDouble && spinnerTile == null) {
          spinnerTile = PlacedDomino(piece: oriented, location: edge, isVertical: true);
        }
      }
    }

    hand.remove(piece);

    if (hand.isEmpty) {
      isGameOver = true;
      int opponentRemaining = isPlayerTurn
          ? botHand.fold(0, (s, p) => s + p.pip)
          : playerHand.fold(0, (s, p) => s + p.pip);

      if (isPlayerTurn) {
        playerScore += opponentRemaining;
        playerWins++;
        statusMessage = '🎉 مبروك! فزت بهذه الجولة (+ $opponentRemaining نقطة)!';
      } else {
        botScore += opponentRemaining;
        botWins++;
        statusMessage = '🤖 البوت فاز بهذه الجولة (+ $opponentRemaining نقطة)!';
      }
      return true;
    }

    isPlayerTurn = !isPlayerTurn;
    statusMessage = isPlayerTurn ? 'دورك للعب!' : 'البوت يفكر...';
    return true;
  }

  void passTurn() {
    if (!isPlayerTurn || isGameOver) return;
    isPlayerTurn = false;
    statusMessage = 'لقد مررت دورك. البوت يفكر...';
    checkAndHandleBlockedGame();
  }

  bool checkAndHandleBlockedGame() {
    final playerValid = playerHand.any((p) => getValidEdgesFor(p).isNotEmpty);
    final botValid = botHand.any((p) => getValidEdgesFor(p).isNotEmpty);

    if (!playerValid && !botValid && boneyard.isEmpty) {
      isGameOver = true;
      final pSum = playerHand.fold(0, (s, p) => s + p.pip);
      final bSum = botHand.fold(0, (s, p) => s + p.pip);

      if (pSum < bSum) {
        final diff = bSum - pSum;
        playerScore += diff;
        playerWins++;
        statusMessage = '🔒 قُفلت اللعبة! فزت بـ $diff نقطة ($pSum مقابل $bSum)!';
      } else if (bSum < pSum) {
        final diff = pSum - bSum;
        botScore += diff;
        botWins++;
        statusMessage = '🔒 قُفلت اللعبة! فاز البوت بـ $diff نقطة ($pSum مقابل $bSum)!';
      } else {
        statusMessage = '🔒 قُفلت اللعبة وتعادل الفريمان ($pSum نقطة لكل منهما)!';
      }
      return true;
    }
    return false;
  }

  void triggerBotMove() {
    if (isPlayerTurn || isGameOver) return;

    final moves = <_BotMove>[];
    for (final p in botHand) {
      final validEdges = getValidEdgesFor(p);
      for (final edge in validEdges) {
        moves.add(_BotMove(piece: p, edge: edge));
      }
    }

    if (moves.isNotEmpty) {
      moves.sort((a, b) {
        if (a.piece.isDouble && !b.piece.isDouble) return -1;
        if (!a.piece.isDouble && b.piece.isDouble) return 1;
        return b.piece.pip.compareTo(a.piece.pip);
      });
      final selectedMove = moves.first;
      playPiece(selectedMove.piece, selectedMove.edge);
    } else if (boneyard.isNotEmpty) {
      botHand.add(boneyard.removeLast());
      triggerBotMove();
    } else {
      if (checkAndHandleBlockedGame()) return;
      isPlayerTurn = true;
      statusMessage = 'البوت مرر لعدم وجود نقلة. دورك!';
    }
  }
}

class _BotMove {
  final DominoPiece piece;
  final DominoEdgeLocation edge;
  const _BotMove({required this.piece, required this.edge});
}
