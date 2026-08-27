import 'package:flutter/material.dart';
import 'domino_classic_engine.dart';
import 'domino_piece.dart';
import 'domino_cafe_board.dart';
import 'domino_tile_widget.dart';

class DominoBoardLayout extends StatelessWidget {
  final DominoClassicEngine engine;
  final DominoPiece? selectedPiece;
  final DominoTileStyle style;
  final Function(DominoPiece piece, DominoEdgeLocation edge)? onPlacePiece;

  const DominoBoardLayout({
    super.key,
    required this.engine,
    this.selectedPiece,
    this.style = DominoTileStyle.classicIvory,
    this.onPlacePiece,
  });

  @override
  Widget build(BuildContext context) {
    return DominoCafeBoard(
      engine: engine,
      selectedPiece: selectedPiece,
      onPlacePiece: onPlacePiece,
    );
  }
}
