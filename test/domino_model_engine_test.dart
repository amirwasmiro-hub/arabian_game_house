import 'package:flutter_test/flutter_test.dart';
import 'package:arabian_game_house/features/games/domino_classic/models/domino_piece.dart';
import 'package:arabian_game_house/features/games/domino_american/logic/domino_american_engine.dart';

void main() {
  group('DominoAmericanEngine Tests', () {
    test('Game starts with 7 pieces dealt to player and bot, 14 in boneyard', () {
      final engine = DominoAmericanEngine();
      engine.startNewGame();

      expect(engine.playerHand.length, equals(7));
      expect(engine.botHand.length, equals(7));
      expect(engine.boneyard.length, equals(14));
      expect(engine.armWest, isEmpty);
      expect(engine.armEast, isEmpty);
      expect(engine.armNorth, isEmpty);
      expect(engine.armSouth, isEmpty);
      expect(engine.spinner, isNull);
    });

    test('First piece played sets spinner if double or armEast if regular', () {
      final engine = DominoAmericanEngine();
      engine.startNewGame();

      const doubleFive = DominoPiece(5, 5);
      const extra = DominoPiece(1, 1);
      engine.playerHand.clear();
      engine.playerHand.addAll([doubleFive, extra]); // Keep hand non-empty
      engine.isPlayerTurn = true;

      final valid = engine.getValidEdgesFor(doubleFive);
      expect(valid, contains(DominoEdgeLocation.east));

      engine.playPiece(doubleFive, DominoEdgeLocation.east);
      expect(engine.spinner, isNotNull);
      expect(engine.playerScore, equals(10)); // [5|5] = 10 points
    });

    test('All Fives scoring calculation on consecutive moves', () {
      final engine = DominoAmericanEngine();
      engine.startNewGame();

      // Setup hand with [5|5], [5|0], and an extra tile
      const d5 = DominoPiece(5, 5);
      const p50 = DominoPiece(5, 0);
      const extra = DominoPiece(2, 2);

      engine.playerHand.clear();
      engine.playerHand.addAll([d5, p50, extra]);

      // Place [5|5] -> scores 10
      engine.isPlayerTurn = true;
      engine.playPiece(d5, DominoEdgeLocation.east);
      expect(engine.playerScore, equals(10));

      // Place [5|0] on East -> open ends: 5 (from west spinner) + 0 (from east) = 5 -> total score becomes 15!
      engine.isPlayerTurn = true;
      engine.playPiece(p50, DominoEdgeLocation.east);
      expect(engine.playerScore, equals(15));
    });

    test('Bot turn executes using American Engine', () {
      final engine = DominoAmericanEngine();
      engine.startNewGame();
      engine.isPlayerTurn = false;

      engine.triggerBotMove();
      expect(engine.isPlayerTurn, isTrue);
    });
  });
}
