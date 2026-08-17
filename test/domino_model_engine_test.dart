import 'package:flutter_test/flutter_test.dart';
import 'package:arabian_game_house/features/games/domino_american/models/domino_piece.dart';
import 'package:arabian_game_house/features/games/domino_american/logic/domino_american_engine.dart';

void main() {
  group('DominoAmericanEngine Tests', () {
    test('Game starts with 7 pieces dealt to player and bot, 14 in boneyard', () {
      final engine = DominoAmericanEngine();
      engine.startNewGame();

      expect(engine.playerHand.length, equals(7));
      expect(engine.botHand.length, equals(7));
      expect(engine.boneyard.length, equals(14));
      expect(engine.rowWest, isEmpty);
      expect(engine.rowEast, isEmpty);
      expect(engine.colNorth, isEmpty);
      expect(engine.colSouth, isEmpty);
    });

    test('First piece played sets spinner if double or rowEast if regular', () {
      final engine = DominoAmericanEngine();
      engine.startNewGame();

      final piece = engine.playerHand.first;
      engine.isPlayerTurn = true;
      final valid = engine.getValidEdgesFor(piece);
      expect(valid, contains(DominoEdgeLocation.east));

      engine.playPiece(piece, DominoEdgeLocation.east);
      if (piece.isDouble) {
        expect(engine.spinnerTile, isNotNull);
      } else {
        expect(engine.rowEast.length, equals(1));
      }
    });

    test('Bot turn executes using American Engine', () {
      final engine = DominoAmericanEngine();
      engine.startNewGame();
      engine.isPlayerTurn = false;

      engine.triggerBotMove();
      expect(engine.isPlayerTurn, isTrue);
    });

    test('All Fives scoring calculation works properly', () {
      final engine = DominoAmericanEngine();
      engine.startNewGame();

      const doubleFive = DominoPiece(5, 5);
      engine.playerHand.add(doubleFive);
      engine.isPlayerTurn = true;

      final initialScore = engine.playerScore;
      engine.playPiece(doubleFive, DominoEdgeLocation.east);

      expect(engine.playerScore, equals(initialScore + 10));
    });
  });
}
