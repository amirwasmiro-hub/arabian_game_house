/// Base interface for all game engines.
abstract class BaseGame<TState, TMove> {
  TState get state;
  List<TMove> getValidMoves(int playerId);
  bool makeMove(TMove move);
  int get currentPlayer;
  bool get isGameOver;
  int? get winner;
  void reset();
}
