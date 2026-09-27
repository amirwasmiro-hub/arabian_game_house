import 'package:flutter_test/flutter_test.dart';
import 'package:arabian_game_house/games/domino_classic/domino_piece.dart';
import 'package:arabian_game_house/games/domino_classic/domino_classic_engine.dart';

void main() {
  group('DominoPiece Tests', () {
    test('fullSet creates 28 unique tiles', () {
      final set = DominoPiece.fullSet();
      expect(set.length, equals(28));
      final uniquePips = set.map((p) => '${p.a}-${p.b}').toSet();
      expect(uniquePips.length, equals(28));
    });

    test('isDouble correctly identifies double tiles', () {
      expect(const DominoPiece(6, 6).isDouble, isTrue);
      expect(const DominoPiece(0, 0).isDouble, isTrue);
      expect(const DominoPiece(3, 5).isDouble, isFalse);
    });

    test('canFit checks matching ends', () {
      const piece = DominoPiece(6, 4);
      expect(piece.canFit(6), isTrue);
      expect(piece.canFit(4), isTrue);
      expect(piece.canFit(3), isFalse);
    });
  });

  group('DominoClassicEngine Tests', () {
    test('Engine resets and deals 7 pieces to each player', () {
      final engine = DominoClassicEngine();
      engine.startNewGame();
      expect(engine.playerHand.length, equals(7));
      expect(engine.botHand.length, equals(7));
      expect(engine.boneyard.length, equals(14));
      expect(engine.board, isEmpty);
    });

    test('First move places tile on board and sets left/right exposed ends', () {
      final engine = DominoClassicEngine();
      engine.startNewGame();
      engine.isPlayerTurn = true;

      const piece = DominoPiece(6, 4);
      engine.playerHand.add(piece);

      final success = engine.playPiece(piece, DominoEdgeLocation.right);
      expect(success, isTrue);
      expect(engine.board.length, equals(1));
      expect(engine.leftEnd, equals(6));
      expect(engine.rightEnd, equals(4));
    });

    test('Subsequent moves connect matching values accurately on Left and Right', () {
      final engine = DominoClassicEngine();
      engine.startNewGame();
      engine.isPlayerTurn = true;

      const first = DominoPiece(6, 4);
      const rightPiece = DominoPiece(4, 2);
      const leftPiece = DominoPiece(1, 6);
      const extra = DominoPiece(0, 0); // Keep hand non-empty

      engine.playerHand.clear();
      engine.playerHand.addAll([first, rightPiece, leftPiece, extra]);

      // Play [6|4]
      final ok1 = engine.playPiece(first, DominoEdgeLocation.right);
      expect(ok1, isTrue);

      // Play [4|2] on Right
      engine.isPlayerTurn = true;
      final okRight = engine.playPiece(rightPiece, DominoEdgeLocation.right);
      expect(okRight, isTrue);
      expect(engine.rightEnd, equals(2));
      expect(engine.leftEnd, equals(6));

      // Play [1|6] on Left
      engine.isPlayerTurn = true;
      final okLeft = engine.playPiece(leftPiece, DominoEdgeLocation.left);
      expect(okLeft, isTrue);
      expect(engine.leftEnd, equals(1));
      expect(engine.rightEnd, equals(2));
    });

    test('Bot turn executes moves intelligently', () {
      final engine = DominoClassicEngine();
      engine.startNewGame();
      engine.isPlayerTurn = false;
      engine.triggerBotMove();
      expect(engine.isPlayerTurn, isTrue);
    });

    test('Partnership 4P mode deals 7 tiles to all 4 players and empty boneyard', () {
      final engine = DominoClassicEngine();
      engine.resetEntireMatch(newMode: DominoPlayMode.partnership4P);
      expect(engine.hands[0].length, equals(7));
      expect(engine.hands[1].length, equals(7));
      expect(engine.hands[2].length, equals(7));
      expect(engine.hands[3].length, equals(7));
      expect(engine.boneyard, isEmpty);
    });

    test('Blocked game (صاك) calculates hand pips difference and sets result', () {
      final engine = DominoClassicEngine();
      engine.startNewGame();
      engine.boneyard.clear();

      // Board has leftEnd = 5, rightEnd = 5
      engine.board.add(const PlacedDomino(
        piece: DominoPiece(5, 5),
        leftValue: 5,
        rightValue: 5,
        isDouble: true,
        placedOn: DominoEdgeLocation.right,
      ));

      // Hands have tiles that cannot fit (0 and 1 only)
      engine.hands[0].clear();
      engine.hands[0].add(const DominoPiece(0, 1)); // 1 pip (Player)

      engine.hands[3].clear();
      engine.hands[3].add(const DominoPiece(1, 4)); // 5 pips (Opponent)

      // Player passes
      engine.currentTurnIndex = 0;
      engine.passTurn();

      // Bot passes
      engine.passTurn();

      expect(engine.isGameOver, isTrue);
      expect(engine.lastRoundResult, isNotNull);
      expect(engine.lastRoundResult!.winType, equals(DominoWinType.blocked));
      expect(engine.lastRoundResult!.winningTeam, equals(1)); // Player has 1 pip vs 5 pips
      expect(engine.lastRoundResult!.pointsEarned, equals(4)); // 5 - 1 = 4 points
    });

    test('Match ends when a team reaches target score 101', () {
      final engine = DominoClassicEngine();
      engine.resetEntireMatch(target: 101);
      engine.team1MatchScore = 95;

      // Finish with a domino win earning 10 points
      engine.hands[0].clear();
      engine.hands[0].add(const DominoPiece(6, 6));

      engine.hands[3].clear();
      engine.hands[3].add(const DominoPiece(5, 5)); // 10 pips

      engine.currentTurnIndex = 0;
      engine.playPiece(const DominoPiece(6, 6), DominoEdgeLocation.right);

      expect(engine.isGameOver, isTrue);
      expect(engine.isMatchOver, isTrue);
      expect(engine.team1MatchScore, greaterThanOrEqualTo(101));
    });

    test('Every adjacent pair of tiles in engine.board has strictly matching touching values', () {
      final engine = DominoClassicEngine();
      engine.startNewGame();
      engine.isPlayerTurn = true;

      // Create a sequence of connected moves: [6|6], [6|5], [5|3], [3|1], [1|0]
      engine.playerHand.clear();
      engine.playerHand.addAll([
        const DominoPiece(6, 6),
        const DominoPiece(6, 5),
        const DominoPiece(3, 5),
        const DominoPiece(3, 1),
        const DominoPiece(1, 0),
        const DominoPiece(6, 2),
        const DominoPiece(0, 0),
      ]);

      // Move 1: [6|6]
      engine.playPiece(const DominoPiece(6, 6), DominoEdgeLocation.right);
      // Move 2: [6|5] on Right -> [6|6][6|5]
      engine.isPlayerTurn = true;
      engine.playPiece(const DominoPiece(6, 5), DominoEdgeLocation.right);
      // Move 3: [3|5] on Right -> [6|6][6|5][5|3]
      engine.isPlayerTurn = true;
      engine.playPiece(const DominoPiece(3, 5), DominoEdgeLocation.right);
      // Move 4: [3|1] on Right -> [6|6][6|5][5|3][3|1]
      engine.isPlayerTurn = true;
      engine.playPiece(const DominoPiece(3, 1), DominoEdgeLocation.right);
      // Move 5: [6|2] on Left -> [2|6][6|6][6|5][5|3][3|1]
      engine.isPlayerTurn = true;
      engine.playPiece(const DominoPiece(6, 2), DominoEdgeLocation.left);

      expect(engine.board.length, equals(5));
      for (int i = 0; i < engine.board.length - 1; i++) {
        expect(
          engine.board[i].rightValue,
          equals(engine.board[i + 1].leftValue),
          reason: 'Mismatch at index $i: [${engine.board[i].leftValue}|${engine.board[i].rightValue}] touches [${engine.board[i+1].leftValue}|${engine.board[i+1].rightValue}]',
        );
      }
    });

    test('Player drawing eligibility: only allowed when player has no valid playable pieces in hand', () {
      final engine = DominoClassicEngine();
      engine.startNewGame();
      engine.isPlayerTurn = true;

      // Board has [6|4]
      engine.playerHand.clear();
      engine.playerHand.addAll([const DominoPiece(6, 4), const DominoPiece(4, 2), const DominoPiece(1, 1)]);
      engine.playPiece(const DominoPiece(6, 4), DominoEdgeLocation.right);

      // Remaining hand: [4|2] (playable!), [1|1] (unplayable)
      final validPieces = engine.playerHand.where((p) => engine.getValidEdgesFor(p).isNotEmpty).toList();
      expect(validPieces, isNotEmpty);
      expect(validPieces.contains(const DominoPiece(4, 2)), isTrue);
      // Player cannot draw because validPieces is not empty!
      final mustDraw = validPieces.isEmpty;
      expect(mustDraw, isFalse);

      // Remove the playable piece [4|2]
      engine.playerHand.remove(const DominoPiece(4, 2));
      // Remaining hand: [1|1] (unplayable against ends 6 and 4)
      final validPiecesAfter = engine.playerHand.where((p) => engine.getValidEdgesFor(p).isNotEmpty).toList();
      expect(validPiecesAfter, isEmpty);
      // Now mustDraw is true, so player must draw!
      expect(validPiecesAfter.isEmpty, isTrue);
    });
  });
}

