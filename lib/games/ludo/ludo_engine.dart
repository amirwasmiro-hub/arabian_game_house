import 'dart:math';

enum LudoColor { red, green, blue, yellow }
enum LudoPhase { rolling, moving, gameOver }

class LudoToken {
  final LudoColor color;
  final int id;
  int position;
  LudoToken({required this.color, required this.id, this.position = -1});
  bool get isHome => position == -1;
  bool get isFinished => position == 56;
  bool get isActive => !isHome && !isFinished;
  LudoToken copy() => LudoToken(color: color, id: id, position: position);
}

class LudoState {
  final List<List<LudoToken>> tokens;
  final int currentPlayer;
  final LudoPhase phase;
  final int diceValue;
  final String message;
  final List<int> movableTokenIds;
  final List<int> winners;

  const LudoState({
    required this.tokens, required this.currentPlayer, required this.phase,
    required this.diceValue, required this.message, required this.movableTokenIds, required this.winners,
  });

  LudoState copyWith({List<List<LudoToken>>? tokens, int? currentPlayer, LudoPhase? phase,
    int? diceValue, String? message, List<int>? movableTokenIds, List<int>? winners}) =>
    LudoState(tokens: tokens??this.tokens, currentPlayer: currentPlayer??this.currentPlayer,
      phase: phase??this.phase, diceValue: diceValue??this.diceValue,
      message: message??this.message, movableTokenIds: movableTokenIds??this.movableTokenIds,
      winners: winners??this.winners);
}

class LudoEngine {
  late LudoState _state;
  final _rng = Random();

  static const safes = {0, 8, 13, 21, 26, 34, 39, 47};
  static const starts = {0: 0, 1: 13, 2: 26, 3: 39};
  static const colorNames = ['أحمر', 'أخضر', 'أزرق', 'أصفر'];
  static const colorEmoji = ['🔴', '🟢', '🔵', '🟡'];

  LudoEngine() { reset(); }
  LudoState get state => _state;

  void reset() {
    final tokens = List.generate(4, (c) =>
        List.generate(4, (i) => LudoToken(color: LudoColor.values[c], id: i)));
    _state = LudoState(
      tokens: tokens, currentPlayer: 0, phase: LudoPhase.rolling,
      diceValue: 0, message: 'أنت (أحمر) — ارمِ الزهر', movableTokenIds: [], winners: [],
    );
  }

  int roll() {
    if (_state.phase != LudoPhase.rolling) return 0;
    final d = 1 + _rng.nextInt(6);
    final player = _state.currentPlayer;
    final movable = _getMovable(player, d);
    if (movable.isEmpty) {
      final msg = '${colorEmoji[player]} رمى $d — لا حركة متاحة';
      if (d == 6) {
        _state = _state.copyWith(diceValue: d, phase: LudoPhase.rolling, message: '$msg — ارمِ مجدداً');
      } else {
        _nextPlayer();
        _state = _state.copyWith(diceValue: d, message: msg);
      }
    } else {
      _state = _state.copyWith(
        diceValue: d, phase: LudoPhase.moving,
        movableTokenIds: movable, message: '${colorEmoji[player]} رمى $d — اختر قطعة');
    }
    return d;
  }

  List<int> _getMovable(int player, int dice) {
    final result = <int>[];
    for (final t in _state.tokens[player]) {
      if (t.isFinished) continue;
      if (t.isHome && dice == 6) { result.add(t.id); continue; }
      if (!t.isHome && t.position + dice <= 55) result.add(t.id);
    }
    return result;
  }

  bool moveToken(int tokenId) {
    if (_state.phase != LudoPhase.moving) return false;
    final player = _state.currentPlayer;
    if (!_state.movableTokenIds.contains(tokenId)) return false;
    final tokens = _state.tokens.map((c) => c.map((t) => t.copy()).toList()).toList();
    final t = tokens[player][tokenId];
    final dice = _state.diceValue;

    if (t.isHome) {
      t.position = starts[player]!;
    } else {
      t.position += dice;
      if (t.position >= 56) t.position = 56;
    }

    if (!t.isFinished) {
      final absPos = _relativeToAbsolute(player, t.position);
      if (!safes.contains(absPos)) {
        for (int c = 0; c < 4; c++) {
          if (c == player) continue;
          for (final ot in tokens[c]) {
            if (ot.isActive && _relativeToAbsolute(c, ot.position) == absPos) {
              ot.position = -1;
            }
          }
        }
      }
    }

    final winners = List<int>.from(_state.winners);
    if (tokens[player].every((t) => t.isFinished) && !winners.contains(player)) {
      winners.add(player);
    }

    _state = _state.copyWith(tokens: tokens, movableTokenIds: [], winners: winners);

    if (winners.length >= 3) {
      _state = _state.copyWith(phase: LudoPhase.gameOver,
        message: winners[0] == 0 ? '🏆 أنت فزت! (المركز الأول)' : '${colorEmoji[winners[0]]} فاز أولاً!');
      return true;
    }

    if (dice == 6 && !t.isFinished) {
      _state = _state.copyWith(phase: LudoPhase.rolling,
        message: '${colorEmoji[player]} رمى 6 — ارمِ مجدداً!');
    } else {
      _nextPlayer();
    }
    return true;
  }

  int _relativeToAbsolute(int player, int relPos) => (starts[player]! + relPos) % 52;

  void _nextPlayer() {
    int next = (_state.currentPlayer + 1) % 4;
    while (_state.winners.contains(next) || _state.tokens[next].every((t) => t.isFinished)) {
      next = (next + 1) % 4;
      if (next == _state.currentPlayer) break;
    }
    _state = _state.copyWith(currentPlayer: next, phase: LudoPhase.rolling,
      message: next == 0 ? 'دورك — ارمِ الزهر' : '${colorEmoji[next]} ${colorNames[next]} يرمي...');
  }

  int botRollAndMove() {
    if (_state.currentPlayer == 0) return 0;
    final d = roll();
    if (_state.phase == LudoPhase.moving && _state.movableTokenIds.isNotEmpty) {
      final player = _state.currentPlayer;
      int? bestId; int bestPriority = -1;
      for (final id in _state.movableTokenIds) {
        final t = _state.tokens[player][id];
        int priority = 0;
        if (!t.isHome) {
          final newPos = t.position + _state.diceValue;
          if (newPos >= 56) priority = 1000;
          final abs = _relativeToAbsolute(player, newPos.clamp(0, 55));
          for (int c = 0; c < 4; c++) {
            if (c == player) continue;
            for (final ot in _state.tokens[c]) {
              if (ot.isActive && _relativeToAbsolute(c, ot.position) == abs && !safes.contains(abs)) {
                priority = max(priority, 500);
              }
            }
          }
          priority = max(priority, newPos);
        } else {
          priority = 100;
        }
        if (priority > bestPriority) { bestPriority = priority; bestId = id; }
      }
      if (bestId != null) moveToken(bestId);
    }
    return d;
  }
}
