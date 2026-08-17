import 'package:flutter_test/flutter_test.dart';
import 'package:arabian_game_house/features/games/domino_classic/models/domino_piece.dart';
import 'package:arabian_game_house/features/games/domino_classic/logic/domino_classic_engine.dart';

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

    test('orienting tiles for left and right ends', () {
      const piece = DominoPiece(6, 4);
      final leftOriented = piece.orientedForLeft(4);
      expect(leftOriented.a, equals(6));
      expect(leftOriented.b, equals(4));

      final rightOriented = piece.orientedForRight(4);
      expect(rightOriented.a, equals(4));
      expect(rightOriented.b, equals(6));
    });
  });

  group('DominoClassicEngine Tests', () {
    test('Engine resets and deals 7 pieces to each player', () {
      final engine = DominoClassicEngine();
      engine.startNewGame();
      expect(engine.playerHand.length, equals(7));
      expect(engine.botHand.length, equals(7));
      expect(engine.boneyard.length, equals(14));
      expect(engine.rowWest, isEmpty);
      expect(engine.rowEast, isEmpty);
    });

    test('Bot turn executes successfully without error', () {
      final engine = DominoClassicEngine();
      engine.startNewGame();
      engine.isPlayerTurn = false;
      engine.triggerBotMove();
      expect(engine.isPlayerTurn, isTrue);
    });
  });
}
