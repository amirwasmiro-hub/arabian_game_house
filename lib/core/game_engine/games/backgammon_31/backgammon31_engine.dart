import 'dart:math';

enum Bg31Phase { rolling, waiting, gameOver }
enum Bg31Turn { player, bot }

class Backgammon31State {
  final int playerTotal, botTotal;
  final int playerWins, botWins;
  final List<int> dice;
  final Bg31Turn turn;
  final Bg31Phase phase;
  final String message;
  const Backgammon31State({
    required this.playerTotal, required this.botTotal,
    required this.playerWins, required this.botWins,
    required this.dice, required this.turn, required this.phase, required this.message,
  });
  Backgammon31State copyWith({int? playerTotal, int? botTotal, int? playerWins, int? botWins,
    List<int>? dice, Bg31Turn? turn, Bg31Phase? phase, String? message}) =>
    Backgammon31State(playerTotal: playerTotal??this.playerTotal, botTotal: botTotal??this.botTotal,
      playerWins: playerWins??this.playerWins, botWins: botWins??this.botWins,
      dice: dice??this.dice, turn: turn??this.turn, phase: phase??this.phase, message: message??this.message);
}

class Backgammon31Engine {
  late Backgammon31State _state;
  final _rng = Random();
  Backgammon31Engine() { _state = _newRound(0, 0); }
  Backgammon31State get state => _state;

  Backgammon31State _newRound(int pw, int bw) => Backgammon31State(
    playerTotal: 0, botTotal: 0, playerWins: pw, botWins: bw,
    dice: [], turn: Bg31Turn.player, phase: Bg31Phase.rolling,
    message: 'دورك — ارمِ الزهر (الهدف: 31)',
  );

  List<int> roll() {
    if (_state.phase != Bg31Phase.rolling || _state.turn != Bg31Turn.player) return [];
    final d = [1 + _rng.nextInt(6), 1 + _rng.nextInt(6)];
    final sum = _state.playerTotal + d[0] + d[1];
    if (sum > 31) {
      _state = _state.copyWith(dice: d, playerTotal: sum, phase: Bg31Phase.gameOver,
        message: 'تجاوزت 31 بـ$sum! البوت فاز!', botWins: _state.botWins + 1);
    } else if (sum == 31) {
      _state = _state.copyWith(dice: d, playerTotal: sum, phase: Bg31Phase.gameOver,
        message: '🎉 وصلت 31 بالضبط! أنت فزت!', playerWins: _state.playerWins + 1);
    } else {
      _state = _state.copyWith(dice: d, playerTotal: sum, phase: Bg31Phase.waiting,
        message: 'مجموعك: $sum — ارمِ مجدداً أم تقف؟');
    }
    return d;
  }

  void stand() {
    if (_state.phase != Bg31Phase.waiting || _state.turn != Bg31Turn.player) return;
    _state = _state.copyWith(turn: Bg31Turn.bot, phase: Bg31Phase.rolling, message: 'البوت يفكر...');
  }

  void rollAgain() {
    if (_state.phase != Bg31Phase.waiting || _state.turn != Bg31Turn.player) return;
    _state = _state.copyWith(phase: Bg31Phase.rolling);
    roll();
  }

  void executeBotTurn() {
    if (_state.turn != Bg31Turn.bot) return;
    int botTotal = _state.botTotal;
    final rng = _rng;
    while (true) {
      final d = [1 + rng.nextInt(6), 1 + rng.nextInt(6)];
      botTotal += d[0] + d[1];
      if (botTotal > 31) {
        _state = _state.copyWith(botTotal: botTotal, phase: Bg31Phase.gameOver,
          message: '🎉 البوت تجاوز 31 ($botTotal)! أنت فزت!', playerWins: _state.playerWins + 1);
        return;
      }
      if (botTotal == 31) {
        _state = _state.copyWith(botTotal: botTotal, phase: Bg31Phase.gameOver,
          message: '🤖 البوت وصل 31! البوت فاز!', botWins: _state.botWins + 1);
        return;
      }
      // Bot stops if > 25 or risky to continue
      if (botTotal > 25) {
        _endRound(botTotal);
        return;
      }
    }
  }

  void _endRound(int botFinal) {
    final pp = _state.playerTotal, bp = botFinal;
    final pdiff = (31 - pp).abs(), bdiff = (31 - bp).abs();
    if (pdiff < bdiff) {
      _state = _state.copyWith(botTotal: bp, phase: Bg31Phase.gameOver,
        message: '🎉 فزت! (أنت: $pp، البوت: $bp)', playerWins: _state.playerWins + 1);
    } else if (bdiff < pdiff) {
      _state = _state.copyWith(botTotal: bp, phase: Bg31Phase.gameOver,
        message: '🤖 البوت فاز! (أنت: $pp، البوت: $bp)', botWins: _state.botWins + 1);
    } else {
      _state = _state.copyWith(botTotal: bp, phase: Bg31Phase.gameOver,
        message: '🤝 تعادل! (كلاكما: $pp)');
    }
  }

  void newRound() { _state = _newRound(_state.playerWins, _state.botWins); }
  void reset() { _state = _newRound(0, 0); }
}
