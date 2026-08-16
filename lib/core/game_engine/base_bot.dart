import 'dart:async';
/// Abstract bot interface — swap with server call for online play.
abstract class BaseBot<TState, TMove> {
  int get playerId;
  int get difficulty; // 0=easy, 1=medium, 2=hard
  Future<TMove?> chooseMove(TState state);
}
