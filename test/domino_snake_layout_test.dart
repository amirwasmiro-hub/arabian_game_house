import 'package:flutter_test/flutter_test.dart';
import 'package:arabian_game_house/games/domino_classic/domino_classic_engine.dart';
import 'package:arabian_game_house/games/domino_classic/domino_piece.dart';
import 'package:arabian_game_house/games/domino_classic/domino_snake_layout.dart';

void main() {
  group('DominoSnakeLayout Tests', () {
    const double tileShort = 21.0;
    const double tileLong = 42.0;
    const double gap = 2.0;
    const double rowSpacing = 21.0;

    test('Empty board returns empty tiles and null ghosts', () {
      final result = DominoSnakeLayout.compute(
        board: [],
        initialTileIndex: 0,
        tileShort: tileShort,
        tileLong: tileLong,
        gap: gap,
        rowSpacing: rowSpacing,
      );

      expect(result.tiles, isEmpty);
      expect(result.leftGhost, isNull);
      expect(result.rightGhost, isNull);
    });

    test('Single tile is anchored at (0, 0) with ghosts on left and right', () {
      final board = [
        const PlacedDomino(
          piece: DominoPiece(3, 4),
          leftValue: 3,
          rightValue: 4,
          isDouble: false,
          placedOn: DominoEdgeLocation.right,
        ),
      ];

      final result = DominoSnakeLayout.compute(
        board: board,
        initialTileIndex: 0,
        tileShort: tileShort,
        tileLong: tileLong,
        gap: gap,
        rowSpacing: rowSpacing,
      );

      expect(result.tiles.length, 1);
      final tile = result.tiles.first;
      expect(tile.x, 0.0);
      expect(tile.y, 0.0);
      expect(tile.isHorizontal, isTrue);
      expect(tile.width, tileLong);
      expect(tile.height, tileShort);

      // Ghosts
      expect(result.leftGhost, isNotNull);
      expect(result.leftGhost!.edge, DominoEdgeLocation.left);
      expect(result.leftGhost!.x, lessThan(0.0));
      expect(result.leftGhost!.y, 0.0);
      expect(result.leftGhost!.isHorizontal, isTrue);

      expect(result.rightGhost, isNotNull);
      expect(result.rightGhost!.edge, DominoEdgeLocation.right);
      expect(result.rightGhost!.x, greaterThan(0.0));
      expect(result.rightGhost!.y, 0.0);
      expect(result.rightGhost!.isHorizontal, isTrue);
    });

    test('Single double tile is anchored vertically at (0, 0)', () {
      final board = [
        const PlacedDomino(
          piece: DominoPiece(6, 6),
          leftValue: 6,
          rightValue: 6,
          isDouble: true,
          placedOn: DominoEdgeLocation.right,
        ),
      ];

      final result = DominoSnakeLayout.compute(
        board: board,
        initialTileIndex: 0,
        tileShort: tileShort,
        tileLong: tileLong,
        gap: gap,
        rowSpacing: rowSpacing,
      );

      expect(result.tiles.length, 1);
      final tile = result.tiles.first;
      expect(tile.x, 0.0);
      expect(tile.y, 0.0);
      expect(tile.isHorizontal, isFalse);
      expect(tile.width, tileShort);
      expect(tile.height, tileLong);
    });

    test('Straight row up to maxCenterTiles (4) stays at y = 0.0', () {
      final engine = DominoClassicEngine();
      engine.board.clear();
      engine.initialTileIndex = 0;

      // Add 1 root + 3 right tiles (total 4)
      engine.board.add(const PlacedDomino(
        piece: DominoPiece(1, 2),
        leftValue: 1,
        rightValue: 2,
        isDouble: false,
        placedOn: DominoEdgeLocation.right,
      ));
      engine.board.add(const PlacedDomino(
        piece: DominoPiece(2, 3),
        leftValue: 2,
        rightValue: 3,
        isDouble: false,
        placedOn: DominoEdgeLocation.right,
      ));
      engine.board.add(const PlacedDomino(
        piece: DominoPiece(3, 4),
        leftValue: 3,
        rightValue: 4,
        isDouble: false,
        placedOn: DominoEdgeLocation.right,
      ));
      engine.board.add(const PlacedDomino(
        piece: DominoPiece(4, 5),
        leftValue: 4,
        rightValue: 5,
        isDouble: false,
        placedOn: DominoEdgeLocation.right,
      ));

      final result = DominoSnakeLayout.compute(
        board: engine.board,
        initialTileIndex: engine.safeInitialTileIndex,
        tileShort: tileShort,
        tileLong: tileLong,
        gap: gap,
        rowSpacing: rowSpacing,
      );

      expect(result.tiles.length, 4);
      for (final t in result.tiles) {
        expect(t.y, 0.0);
        expect(t.isHorizontal, isTrue);
      }
      expect(result.tiles[0].x, 0.0);
      expect(result.tiles[1].x, greaterThan(result.tiles[0].x));
      expect(result.tiles[2].x, greaterThan(result.tiles[1].x));
      expect(result.tiles[3].x, greaterThan(result.tiles[2].x));
    });

    test('Right branch turns UP on 5th tile to bridge to top row', () {
      final engine = DominoClassicEngine();
      engine.board.clear();
      engine.initialTileIndex = 0;

      // 1 root + 4 straight + 1 corner turn (tile 5)
      engine.board.add(const PlacedDomino(
        piece: DominoPiece(0, 1),
        leftValue: 0,
        rightValue: 1,
        isDouble: false,
        placedOn: DominoEdgeLocation.right,
      ));
      for (int i = 1; i <= 4; i++) {
        engine.board.add(PlacedDomino(
          piece: DominoPiece(i, i + 1),
          leftValue: i,
          rightValue: i + 1,
          isDouble: false,
          placedOn: DominoEdgeLocation.right,
        ));
      }
      // Tile 5: the corner turn
      engine.board.add(const PlacedDomino(
        piece: DominoPiece(5, 6),
        leftValue: 5,
        rightValue: 6,
        isDouble: false,
        placedOn: DominoEdgeLocation.right,
      ));

      final result = DominoSnakeLayout.compute(
        board: engine.board,
        initialTileIndex: engine.safeInitialTileIndex,
        tileShort: tileShort,
        tileLong: tileLong,
        gap: gap,
        rowSpacing: rowSpacing,
      );

      expect(result.tiles.length, 6);
      final cornerTile = result.tiles[5];
      // Corner turn is vertical
      expect(cornerTile.isHorizontal, isFalse);
      expect(cornerTile.width, tileShort);
      expect(cornerTile.height, tileLong);
      // Bridges up: y is -tileShort / 2
      expect(cornerTile.y, -tileShort / 2);
      expect(cornerTile.x, greaterThan(result.tiles[4].x));

      final topRowY = -(tileLong / 2 + tileShort + gap);
      // Ghost slot for the next tile after the corner should be on top row
      expect(result.rightGhost, isNotNull);
      expect(result.rightGhost!.y, topRowY);
      expect(result.rightGhost!.isHorizontal, isTrue);
    });

    test('Top row tiles move LEFT along top row', () {
      final engine = DominoClassicEngine();
      engine.board.clear();
      engine.initialTileIndex = 0;

      // 1 root + 4 straight + 1 corner + 1 top row tile
      engine.board.add(const PlacedDomino(
        piece: DominoPiece(0, 1),
        leftValue: 0,
        rightValue: 1,
        isDouble: false,
        placedOn: DominoEdgeLocation.right,
      ));
      for (int i = 1; i <= 5; i++) {
        engine.board.add(PlacedDomino(
          piece: DominoPiece(i, i + 1),
          leftValue: i,
          rightValue: i + 1,
          isDouble: false,
          placedOn: DominoEdgeLocation.right,
        ));
      }
      // 7th tile (i=6) is on top row moving LEFT
      engine.board.add(const PlacedDomino(
        piece: DominoPiece(6, 0),
        leftValue: 6,
        rightValue: 0,
        isDouble: false,
        placedOn: DominoEdgeLocation.right,
      ));

      final result = DominoSnakeLayout.compute(
        board: engine.board,
        initialTileIndex: engine.safeInitialTileIndex,
        tileShort: tileShort,
        tileLong: tileLong,
        gap: gap,
        rowSpacing: rowSpacing,
      );

      expect(result.tiles.length, 7);
      final topRowTile = result.tiles[6];
      final topRowY = -(tileLong / 2 + tileShort + gap);
      expect(topRowTile.y, topRowY);
      expect(topRowTile.isHorizontal, isTrue);
      // It moves left, so its x is less than or equal to the corner tile
      expect(topRowTile.x, lessThan(result.tiles[5].x));
    });

    test('Left branch turns DOWN on 5th tile to bridge to bottom row', () {
      final engine = DominoClassicEngine();
      engine.board.clear();
      engine.initialTileIndex = 0;

      // Root
      engine.board.add(const PlacedDomino(
        piece: DominoPiece(5, 5),
        leftValue: 5,
        rightValue: 5,
        isDouble: true,
        placedOn: DominoEdgeLocation.right,
      ));

      // Play 5 tiles to the left
      for (int i = 0; i < 5; i++) {
        engine.board.insert(
          0,
          PlacedDomino(
            piece: DominoPiece(4 - i, 5 - i),
            leftValue: 4 - i,
            rightValue: 5 - i,
            isDouble: false,
            placedOn: DominoEdgeLocation.left,
          ),
        );
        engine.initialTileIndex++;
      }

      final result = DominoSnakeLayout.compute(
        board: engine.board,
        initialTileIndex: engine.safeInitialTileIndex,
        tileShort: tileShort,
        tileLong: tileLong,
        gap: gap,
        rowSpacing: rowSpacing,
      );

      expect(result.tiles.length, 6);
      // Index 0 in board is the furthest left tile (the corner)
      final leftCorner = result.tiles[0];
      expect(leftCorner.isHorizontal, isFalse);
      expect(leftCorner.width, tileShort);
      expect(leftCorner.height, tileLong);
      expect(leftCorner.y, tileShort / 2); // Bridges down
      expect(leftCorner.x, lessThan(0.0));

      final bottomRowY = tileLong / 2 + tileShort + gap;
      // Left ghost slot should be on bottom row
      expect(result.leftGhost, isNotNull);
      expect(result.leftGhost!.y, bottomRowY);
      expect(result.leftGhost!.isHorizontal, isTrue);
    });
  });
}
