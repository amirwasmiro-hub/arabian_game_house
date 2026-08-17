import '../models/dice.dart';

enum BgPlayer { white, black }
enum BgPhase { rolling, moving, gameOver }

class BgPoint {
  int count;
  BgPlayer? owner;
  BgPoint({this.count = 0, this.owner});
  bool get isEmpty => count == 0;
  bool get isBlot => count == 1;
  bool canEnter(BgPlayer p) => isEmpty || owner == p || isBlot;
  BgPoint copy() => BgPoint(count: count, owner: owner);
}

class BgMove {
  final int from; // 1-24, 0=bar
  final int to;   // 1-24, 25=borne off
  const BgMove(this.from, this.to);
}

class BackgammonState {
  final List<BgPoint> points; // index 1-24 used
  final int whiteBar, blackBar, whiteBorne, blackBorne;
  final List<int> dice;
  final List<int> usedDice;
  final BgPlayer turn;
  final BgPhase phase;
  final String message;

  const BackgammonState({
    required this.points, required this.whiteBar, required this.blackBar,
    required this.whiteBorne, required this.blackBorne,
    required this.dice, required this.usedDice,
    required this.turn, required this.phase, required this.message,
  });

  BackgammonState copyWith({
    List<BgPoint>? points, int? whiteBar, int? blackBar,
    int? whiteBorne, int? blackBorne, List<int>? dice, List<int>? usedDice,
    BgPlayer? turn, BgPhase? phase, String? message,
  }) => BackgammonState(
    points: points ?? this.points, whiteBar: whiteBar ?? this.whiteBar, blackBar: blackBar ?? this.blackBar,
    whiteBorne: whiteBorne ?? this.whiteBorne, blackBorne: blackBorne ?? this.blackBorne,
    dice: dice ?? this.dice, usedDice: usedDice ?? this.usedDice,
    turn: turn ?? this.turn, phase: phase ?? this.phase, message: message ?? this.message,
  );

  bool get whiteWon => whiteBorne >= 15;
  bool get blackWon => blackBorne >= 15;
}

class BackgammonEngine {
  late BackgammonState _state;

  BackgammonEngine() { reset(); }

  BackgammonState get state => _state;

  static List<BgPoint> _initBoard() {
    final pts = List.generate(26, (_) => BgPoint());
    pts[24] = BgPoint(count: 2, owner: BgPlayer.white);
    pts[13] = BgPoint(count: 5, owner: BgPlayer.white);
    pts[8]  = BgPoint(count: 3, owner: BgPlayer.white);
    pts[6]  = BgPoint(count: 5, owner: BgPlayer.white);

    pts[1]  = BgPoint(count: 2, owner: BgPlayer.black);
    pts[12] = BgPoint(count: 5, owner: BgPlayer.black);
    pts[17] = BgPoint(count: 3, owner: BgPlayer.black);
    pts[19] = BgPoint(count: 5, owner: BgPlayer.black);
    return pts;
  }

  void reset() {
    _state = BackgammonState(
      points: _initBoard(), whiteBar: 0, blackBar: 0, whiteBorne: 0, blackBorne: 0,
      dice: [], usedDice: [], turn: BgPlayer.white,
      phase: BgPhase.rolling, message: 'أنت (أبيض) — ارمِ الزهر للبدء',
    );
  }

  List<int> rollDice() {
    if (_state.phase != BgPhase.rolling) return [];
    final d1 = Dice.roll(), d2 = Dice.roll();
    final dice = (d1 == d2) ? [d1, d1, d1, d1] : [d1, d2];
    _state = _state.copyWith(
      dice: dice, usedDice: [],
      phase: BgPhase.moving,
      message: _state.turn == BgPlayer.white ? 'أنت رميت $d1 و $d2 — اختر قطعة للتحريك' : 'البوت رمى $d1 و $d2',
    );
    return dice;
  }

  List<int> availableDice() {
    final used = List<int>.from(_state.usedDice);
    final avail = List<int>.from(_state.dice);
    for (final u in used) {
      avail.remove(u);
    }
    return avail;
  }

  List<BgMove> getValidMoves(BgPlayer player) {
    final avail = availableDice();
    if (avail.isEmpty) return [];
    final moves = <BgMove>[];
    final bar = player == BgPlayer.white ? _state.whiteBar : _state.blackBar;

    if (bar > 0) {
      for (final die in avail.toSet()) {
        final to = player == BgPlayer.white ? (25 - die) : die;
        if (to >= 1 && to <= 24 && _state.points[to].canEnter(player)) {
          moves.add(BgMove(0, to));
        }
      }
      return moves;
    }

    final canBearOff = _canBearOff(player);
    for (int from = 1; from <= 24; from++) {
      final pt = _state.points[from];
      if (pt.owner != player || pt.isEmpty) continue;
      for (final die in avail.toSet()) {
        final to = player == BgPlayer.white ? from - die : from + die;
        if (to >= 1 && to <= 24 && _state.points[to].canEnter(player)) {
          moves.add(BgMove(from, to));
        } else if (canBearOff) {
          if (player == BgPlayer.white && to <= 0) moves.add(BgMove(from, 25));
          if (player == BgPlayer.black && to >= 25) moves.add(BgMove(from, 25));
        }
      }
    }
    return moves;
  }

  bool _canBearOff(BgPlayer p) {
    if (p == BgPlayer.white) {
      if (_state.whiteBar > 0) return false;
      for (int i = 7; i <= 24; i++) {
        if (_state.points[i].owner == BgPlayer.white && !_state.points[i].isEmpty) return false;
      }
    } else {
      if (_state.blackBar > 0) return false;
      for (int i = 1; i <= 18; i++) {
        if (_state.points[i].owner == BgPlayer.black && !_state.points[i].isEmpty) return false;
      }
    }
    return true;
  }

  bool makeMove(BgMove move) {
    if (_state.phase != BgPhase.moving) return false;
    final player = _state.turn;
    final points = _state.points.map((p) => p.copy()).toList();
    int wBar = _state.whiteBar, bBar = _state.blackBar;
    int wBorne = _state.whiteBorne, bBorne = _state.blackBorne;

    if (move.from == 0) {
      if (player == BgPlayer.white) {
        wBar--;
      } else {
        bBar--;
      }
    } else {
      points[move.from].count--;
      if (points[move.from].count == 0) points[move.from].owner = null;
    }

    if (move.to == 25) {
      if (player == BgPlayer.white) {
        wBorne++;
      } else {
        bBorne++;
      }
    } else {
      if (!points[move.to].isEmpty && points[move.to].owner != player) {
        if (points[move.to].owner == BgPlayer.white) {
          wBar++;
        } else {
          bBar++;
        }
        points[move.to].count = 0; points[move.to].owner = null;
      }
      points[move.to].count++;
      points[move.to].owner = player;
    }

    final die = (move.from == 0)
        ? (player == BgPlayer.white ? 25 - move.to : move.to)
        : (player == BgPlayer.white ? move.from - move.to : move.to - move.from).abs();
    final usedDice = List<int>.from(_state.usedDice)..add(die.abs());

    final newState = _state.copyWith(
      points: points, whiteBar: wBar, blackBar: bBar, whiteBorne: wBorne, blackBorne: bBorne,
      usedDice: usedDice,
    );
    _state = newState;

    if (wBorne >= 15) {
      _state = _state.copyWith(phase: BgPhase.gameOver, message: '🏆 أنت فزت بالمباراة!');
      return true;
    }
    if (bBorne >= 15) {
      _state = _state.copyWith(phase: BgPhase.gameOver, message: '🤖 البوت فاز بالمباراة!');
      return true;
    }

    final remaining = availableDice();
    final validNow = getValidMoves(player);
    if (remaining.isEmpty || validNow.isEmpty) _switchTurn();
    return true;
  }

  void _switchTurn() {
    final next = _state.turn == BgPlayer.white ? BgPlayer.black : BgPlayer.white;
    _state = _state.copyWith(
      turn: next, dice: [], usedDice: [], phase: BgPhase.rolling,
      message: next == BgPlayer.white ? 'دورك — ارمِ الزهر' : 'دور البوت — يرمي الزهر...',
    );
  }

  BgMove? botChooseMove() {
    final moves = getValidMoves(BgPlayer.black);
    if (moves.isEmpty) return null;
    BgMove? best; int bestScore = -999;
    for (final m in moves) {
      int score = 0;
      if (m.to != 25 && !_state.points[m.to].isEmpty && _state.points[m.to].owner == BgPlayer.white) {
        score += 100;
      }
      if (m.to == 25) score += 50;
      score += m.to;
      if (score > bestScore) { best = m; bestScore = score; }
    }
    return best;
  }

  void executeBotRoll() {
    if (_state.turn != BgPlayer.black || _state.phase != BgPhase.rolling) return;
    rollDice();
  }

  void executeBotMove() {
    if (_state.turn != BgPlayer.black || _state.phase != BgPhase.moving) return;
    var move = botChooseMove();
    while (move != null) {
      makeMove(move);
      if (_state.turn != BgPlayer.black || _state.phase != BgPhase.moving) break;
      move = botChooseMove();
    }
  }
}
