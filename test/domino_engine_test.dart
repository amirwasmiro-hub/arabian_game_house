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
  });
}
