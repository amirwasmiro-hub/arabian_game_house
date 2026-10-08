import 'domino_classic_engine.dart';

/// Layout descriptor for a single placed domino tile on the 2D snake board.
class DominoTileLayoutItem {
  final int boardIndex;
  final PlacedDomino placed;
  final double x; // Center X relative to table center (0, 0)
  final double y; // Center Y relative to table center (0, 0)
  final bool isHorizontal;
  final int topValue;
  final int bottomValue;
  final double width;
  final double height;
  final bool isFirst;
  final bool isLast;

  const DominoTileLayoutItem({
    required this.boardIndex,
    required this.placed,
    required this.x,
    required this.y,
    required this.isHorizontal,
    required this.topValue,
    required this.bottomValue,
    required this.width,
    required this.height,
    required this.isFirst,
    required this.isLast,
  });
}

/// Layout descriptor for an interactive ghost drop slot at an open end of the snake.
class DominoGhostLayoutItem {
  final DominoEdgeLocation edge;
  final double x; // Center X relative to table center (0, 0)
  final double y; // Center Y relative to table center (0, 0)
  final bool isHorizontal;
  final double width;
  final double height;

  const DominoGhostLayoutItem({
    required this.edge,
    required this.x,
    required this.y,
    required this.isHorizontal,
    required this.width,
    required this.height,
  });
}

/// The result returned by [DominoSnakeLayout.compute].
class DominoSnakeLayoutResult {
  final List<DominoTileLayoutItem> tiles;
  final DominoGhostLayoutItem? leftGhost;
  final DominoGhostLayoutItem? rightGhost;

  const DominoSnakeLayoutResult({
    required this.tiles,
    this.leftGhost,
    this.rightGhost,
  });
}

/// Computes the exact 2D rectangular / winding snake layout for dominoes on the table.
///
/// Features:
/// 1. Zero card size reduction: cards stay 100% full, natural size.
/// 2. Initial tile is strictly anchored at (0, 0); cards never shift unexpectedly.
/// 3. Center row runs horizontally (y = 0.0).
/// 4. Before reaching table edges (after [maxCenterTiles] tiles), branches bend 90°:
///    - Right branch turns UP at the right corner and winds LEFT along the top row (y = -rowSpacing).
///    - Left branch turns DOWN at the left corner and winds RIGHT along the bottom row (y = +rowSpacing).
/// 5. Touching ends always display matching pip values physically facing each other.
class DominoSnakeLayout {
  static const int maxCenterTiles = 4;

  static DominoSnakeLayoutResult compute({
    required List<PlacedDomino> board,
    required int initialTileIndex,
    required double tileShort,
    required double tileLong,
    required double gap,
    required double rowSpacing,
    bool includeGhosts = true,
  }) {
    if (board.isEmpty) {
      return const DominoSnakeLayoutResult(tiles: []);
    }

    if (board.length == 1) {
      final placed = board[0];
      final isDouble = placed.isDouble;
      final isHoriz = !isDouble;
      final w = isHoriz ? tileLong : tileShort;
      final h = isHoriz ? tileShort : tileLong;

      final tileItem = DominoTileLayoutItem(
        boardIndex: 0,
        placed: placed,
        x: 0.0,
        y: 0.0,
        isHorizontal: isHoriz,
        topValue: placed.leftValue,
        bottomValue: placed.rightValue,
        width: w,
        height: h,
        isFirst: true,
        isLast: true,
      );

      final leftGhost = DominoGhostLayoutItem(
        edge: DominoEdgeLocation.left,
        x: -(w / 2 + gap + tileLong / 2),
        y: 0.0,
        isHorizontal: true,
        width: tileLong,
        height: tileShort,
      );

      final rightGhost = DominoGhostLayoutItem(
        edge: DominoEdgeLocation.right,
        x: (w / 2 + gap + tileLong / 2),
        y: 0.0,
        isHorizontal: true,
        width: tileLong,
        height: tileShort,
      );

      return DominoSnakeLayoutResult(
        tiles: [tileItem],
        leftGhost: includeGhosts ? leftGhost : null,
        rightGhost: includeGhosts ? rightGhost : null,
      );
    }

    final safeInitialIndex = initialTileIndex.clamp(0, board.length - 1);
    final rootPlaced = board[safeInitialIndex];
    final bool rootIsDouble = rootPlaced.isDouble;
    final bool rootIsHoriz = !rootIsDouble;
    final double rootW = rootIsHoriz ? tileLong : tileShort;
    final double rootH = rootIsHoriz ? tileShort : tileLong;

    final rootItem = DominoTileLayoutItem(
      boardIndex: safeInitialIndex,
      placed: rootPlaced,
      x: 0.0,
      y: 0.0,
      isHorizontal: rootIsHoriz,
      topValue: rootPlaced.leftValue,
      bottomValue: rootPlaced.rightValue,
      width: rootW,
      height: rootH,
      isFirst: safeInitialIndex == 0,
      isLast: safeInitialIndex == board.length - 1,
    );

    // Exact row Y positions that guarantee 100% flush corner connection with gap spacing
    // and ample clearance between horizontal rows to eliminate any double-card overlaps
    final double topRowY = -(tileLong / 2 + tileShort + gap);
    final double bottomRowY = tileLong / 2 + tileShort + gap;

    // ==========================================
    // RIGHT BRANCH (Index: safeInitialIndex + 1 -> board.length - 1)
    // ==========================================
    final rightTiles = <DominoTileLayoutItem>[];
    double prevRightX = 0.0;
    double prevRightW = rootW;
    int countCenterRight = 0;
    bool turnedRight = false;
    double rightCornerX = 0.0;

    for (int i = safeInitialIndex + 1; i < board.length; i++) {
      final placed = board[i];
      final isLast = (i == board.length - 1);

      if (!turnedRight) {
        if (countCenterRight < maxCenterTiles) {
          countCenterRight++;
          final isDouble = placed.isDouble;
          final isHoriz = !isDouble;
          final w = isHoriz ? tileLong : tileShort;
          final h = isHoriz ? tileShort : tileLong;
          final x = prevRightX + (prevRightW / 2) + gap + (w / 2);
          const y = 0.0;

          rightTiles.add(DominoTileLayoutItem(
            boardIndex: i,
            placed: placed,
            x: x,
            y: y,
            isHorizontal: isHoriz,
            topValue: placed.leftValue,
            bottomValue: placed.rightValue,
            width: w,
            height: h,
            isFirst: false,
            isLast: isLast,
          ));
          prevRightX = x;
          prevRightW = w;
        } else {
          // Corner turn tile bridging UP
          turnedRight = true;
          const isHoriz = false; // vertical
          final w = tileShort;
          final h = tileLong;
          final x = prevRightX + (prevRightW / 2) + gap + (w / 2);
          final y = -tileShort / 2;
          rightCornerX = x;

          rightTiles.add(DominoTileLayoutItem(
            boardIndex: i,
            placed: placed,
            x: x,
            y: y,
            isHorizontal: isHoriz,
            topValue: placed.rightValue,
            bottomValue: placed.leftValue,
            width: w,
            height: h,
            isFirst: false,
            isLast: isLast,
          ));
          prevRightX = x;
          prevRightW = w;
        }
      } else {
        // Top row moving LEFT
        final isDouble = placed.isDouble;
        final isHoriz = !isDouble;
        final w = isHoriz ? tileLong : tileShort;
        final h = isHoriz ? tileShort : tileLong;
        final double x;
        if (rightTiles.isNotEmpty && rightTiles.last.y == -tileShort / 2) {
          // Align right edge with vertical corner tile
          x = rightCornerX + (tileShort / 2) - (w / 2);
        } else {
          x = prevRightX - (prevRightW / 2) - gap - (w / 2);
        }

        rightTiles.add(DominoTileLayoutItem(
          boardIndex: i,
          placed: placed,
          x: x,
          y: topRowY,
          isHorizontal: isHoriz,
          topValue: placed.rightValue,
          bottomValue: placed.leftValue,
          width: w,
          height: h,
          isFirst: false,
          isLast: isLast,
        ));
        prevRightX = x;
        prevRightW = w;
      }
    }

    DominoGhostLayoutItem? rightGhost;
    if (includeGhosts) {
      if (!turnedRight) {
        if (countCenterRight < maxCenterTiles) {
          final w = tileLong;
          final h = tileShort;
          final x = prevRightX + (prevRightW / 2) + gap + (w / 2);
          rightGhost = DominoGhostLayoutItem(
            edge: DominoEdgeLocation.right,
            x: x,
            y: 0.0,
            isHorizontal: true,
            width: w,
            height: h,
          );
        } else {
          final w = tileShort;
          final h = tileLong;
          final x = prevRightX + (prevRightW / 2) + gap + (w / 2);
          rightGhost = DominoGhostLayoutItem(
            edge: DominoEdgeLocation.right,
            x: x,
            y: -tileShort / 2,
            isHorizontal: false,
            width: w,
            height: h,
          );
        }
      } else {
        final w = tileLong;
        final h = tileShort;
        final double x;
        if (rightTiles.isNotEmpty && rightTiles.last.y == -tileShort / 2) {
          x = rightCornerX + (tileShort / 2) - (w / 2);
        } else {
          x = prevRightX - (prevRightW / 2) - gap - (w / 2);
        }
        rightGhost = DominoGhostLayoutItem(
          edge: DominoEdgeLocation.right,
          x: x,
          y: topRowY,
          isHorizontal: true,
          width: w,
          height: h,
        );
      }
    }

    // ==========================================
    // LEFT BRANCH (Index: safeInitialIndex - 1 -> 0)
    // ==========================================
    final leftTiles = <DominoTileLayoutItem>[];
    double prevLeftX = 0.0;
    double prevLeftW = rootW;
    int countCenterLeft = 0;
    bool turnedLeft = false;
    double leftCornerX = 0.0;

    for (int i = safeInitialIndex - 1; i >= 0; i--) {
      final placed = board[i];
      final isFirst = (i == 0);

      if (!turnedLeft) {
        if (countCenterLeft < maxCenterTiles) {
          countCenterLeft++;
          final isDouble = placed.isDouble;
          final isHoriz = !isDouble;
          final w = isHoriz ? tileLong : tileShort;
          final h = isHoriz ? tileShort : tileLong;
          final x = prevLeftX - (prevLeftW / 2) - gap - (w / 2);
          const y = 0.0;

          leftTiles.add(DominoTileLayoutItem(
            boardIndex: i,
            placed: placed,
            x: x,
            y: y,
            isHorizontal: isHoriz,
            topValue: placed.leftValue,
            bottomValue: placed.rightValue,
            width: w,
            height: h,
            isFirst: isFirst,
            isLast: false,
          ));
          prevLeftX = x;
          prevLeftW = w;
        } else {
          // Corner turn tile bridging DOWN
          turnedLeft = true;
          const isHoriz = false; // vertical
          final w = tileShort;
          final h = tileLong;
          final x = prevLeftX - (prevLeftW / 2) - gap - (w / 2);
          final y = tileShort / 2;
          leftCornerX = x;

          leftTiles.add(DominoTileLayoutItem(
            boardIndex: i,
            placed: placed,
            x: x,
            y: y,
            isHorizontal: isHoriz,
            topValue: placed.rightValue,
            bottomValue: placed.leftValue,
            width: w,
            height: h,
            isFirst: isFirst,
            isLast: false,
          ));
          prevLeftX = x;
          prevLeftW = w;
        }
      } else {
        // Bottom row moving RIGHT
        final isDouble = placed.isDouble;
        final isHoriz = !isDouble;
        final w = isHoriz ? tileLong : tileShort;
        final h = isHoriz ? tileShort : tileLong;
        final double x;
        if (leftTiles.isNotEmpty && leftTiles.last.y == tileShort / 2) {
          // Align left edge with vertical corner tile
          x = leftCornerX - (tileShort / 2) + (w / 2);
        } else {
          x = prevLeftX + (prevLeftW / 2) + gap + (w / 2);
        }

        leftTiles.add(DominoTileLayoutItem(
          boardIndex: i,
          placed: placed,
          x: x,
          y: bottomRowY,
          isHorizontal: isHoriz,
          topValue: placed.rightValue,
          bottomValue: placed.leftValue,
          width: w,
          height: h,
          isFirst: isFirst,
          isLast: false,
        ));
        prevLeftX = x;
        prevLeftW = w;
      }
    }

    DominoGhostLayoutItem? leftGhost;
    if (includeGhosts) {
      if (!turnedLeft) {
        if (countCenterLeft < maxCenterTiles) {
          final w = tileLong;
          final h = tileShort;
          final x = prevLeftX - (prevLeftW / 2) - gap - (w / 2);
          leftGhost = DominoGhostLayoutItem(
            edge: DominoEdgeLocation.left,
            x: x,
            y: 0.0,
            isHorizontal: true,
            width: w,
            height: h,
          );
        } else {
          final w = tileShort;
          final h = tileLong;
          final x = prevLeftX - (prevLeftW / 2) - gap - (w / 2);
          leftGhost = DominoGhostLayoutItem(
            edge: DominoEdgeLocation.left,
            x: x,
            y: tileShort / 2,
            isHorizontal: false,
            width: w,
            height: h,
          );
        }
      } else {
        final w = tileLong;
        final h = tileShort;
        final double x;
        if (leftTiles.isNotEmpty && leftTiles.last.y == tileShort / 2) {
          x = leftCornerX - (tileShort / 2) + (w / 2);
        } else {
          x = prevLeftX + (prevLeftW / 2) + gap + (w / 2);
        }
        leftGhost = DominoGhostLayoutItem(
          edge: DominoEdgeLocation.left,
          x: x,
          y: bottomRowY,
          isHorizontal: true,
          width: w,
          height: h,
        );
      }
    }

    final allTiles = [...leftTiles.reversed, rootItem, ...rightTiles];

    return DominoSnakeLayoutResult(
      tiles: allTiles,
      leftGhost: leftGhost,
      rightGhost: rightGhost,
    );
  }
}
