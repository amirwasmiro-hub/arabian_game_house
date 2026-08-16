import 'dart:math';
import 'domino_piece.dart';

enum DominoPhase { playing, roundOver, gameOver }
enum DominoTurn { player, bot }
enum DominoMode { classic, american }

class DominoMove {
  final DominoPiece piece;
  final bool onLeft;
  const DominoMove(this.piece, {this.onLeft = false});
}

class DominoState {
  final List<DominoPiece> chain;
  final int? leftEnd, rightEnd;
  final List<DominoPiece> playerHand, botHand, boneyard;
  final DominoTurn turn;
  final DominoPhase phase;
  final int playerScore, botScore, playerWins, botWins;
  final String message;
  final bool playerPassed, botPassed;

  const DominoState({
    required this.chain, required this.leftEnd, required this.rightEnd,
    required this.playerHand, required this.botHand, required this.boneyard,
    required this.turn, required this.phase,
    required this.playerScore, required this.botScore,
    required this.playerWins, required this.botWins,
    required this.message, required this.playerPassed, required this.botPassed,
  });

  List<DominoPiece> validMovesFor(List<DominoPiece> hand) {
    if (chain.isEmpty) return List.from(hand);
    return hand.where((p) => p.canFit(leftEnd!) || p.canFit(rightEnd!)).toList();
  }

  DominoState copyWith({
    List<DominoPiece>? chain, int? leftEnd, int? rightEnd,
    List<DominoPiece>? playerHand, List<DominoPiece>? botHand, List<DominoPiece>? boneyard,
    DominoTurn? turn, DominoPhase? phase,
    int? playerScore, int? botScore, int? playerWins, int? botWins,
    String? message, bool? playerPassed, bool? botPassed,
  }) => DominoState(
    chain: chain ?? this.chain, leftEnd: leftEnd ?? this.leftEnd, rightEnd: rightEnd ?? this.rightEnd,
    playerHand: playerHand ?? this.playerHand, botHand: botHand ?? this.botHand, boneyard: boneyard ?? this.boneyard,
    turn: turn ?? this.turn, phase: phase ?? this.phase,
    playerScore: playerScore ?? this.playerScore, botScore: botScore ?? this.botScore,
    playerWins: playerWins ?? this.playerWins, botWins: botWins ?? this.botWins,
    message: message ?? this.message, playerPassed: playerPassed ?? this.playerPassed, botPassed: botPassed ?? this.botPassed,
  );
}

class DominoEngine {
  final DominoMode mode;
  late DominoState _state;
  final _rng = Random();

  DominoEngine({this.mode = DominoMode.classic}) { reset(); }

  DominoState get state => _state;

  void reset() { _state = _newGame(0, 0); }
  void newGame() { _state = _newGame(_state.playerWins, _state.botWins); }

  DominoState _newGame(int pw, int bw) {
    final all = DominoPiece.fullSet()..shuffle(_rng);
    final ph = all.sublist(0, 7), bh = all.sublist(7, 14), by = all.sublist(14);
    final first = _firstPlayer(ph, bh);
    return DominoState(
      chain: [], leftEnd: null, rightEnd: null,
      playerHand: ph, botHand: bh, boneyard: by,
      turn: first, phase: DominoPhase.playing,
      playerScore: 0, botScore: 0, playerWins: pw, botWins: bw,
      message: first == DominoTurn.player ? 'دورك! اختر حجراً للعب' : 'البوت يبدأ...',
      playerPassed: false, botPassed: false,
    );
  }

  DominoTurn _firstPlayer(List<DominoPiece> ph, List<DominoPiece> bh) {
    int pm = -1, bm = -1;
    for (final p in ph) {
      if (p.isDouble && p.a > pm) pm = p.a;
    }
    for (final p in bh) {
      if (p.isDouble && p.a > bm) bm = p.a;
    }
    if (pm > bm) return DominoTurn.player;
    if (bm > pm) return DominoTurn.bot;
    return _rng.nextBool() ? DominoTurn.player : DominoTurn.bot;
  }

  bool playerPlay(DominoPiece piece, {bool onLeft = false}) {
    if (_state.turn != DominoTurn.player || _state.phase != DominoPhase.playing) return false;
    return _play(piece, onLeft, DominoTurn.player);
  }

  bool playerDraw() {
    if (_state.turn != DominoTurn.player || _state.boneyard.isEmpty) return false;
    final drawn = _state.boneyard.last;
    final newBy = List<DominoPiece>.from(_state.boneyard)..removeLast();
    final newHand = List<DominoPiece>.from(_state.playerHand)..add(drawn);
    _state = _state.copyWith(playerHand: newHand, boneyard: newBy, message: 'سحبت [$drawn] — اختر حجراً أو اسحب مجدداً');
    if (_state.validMovesFor(newHand).isEmpty && newBy.isEmpty) _pass(DominoTurn.player);
    return true;
  }

  void _pass(DominoTurn who) {
    final otherPassed = who == DominoTurn.player ? _state.botPassed : _state.playerPassed;
    if (otherPassed) { _endRound(); return; }
    final next = who == DominoTurn.player ? DominoTurn.bot : DominoTurn.player;
    _state = _state.copyWith(
      playerPassed: who == DominoTurn.player ? true : _state.playerPassed,
      botPassed: who == DominoTurn.bot ? true : _state.botPassed,
      turn: next, message: who == DominoTurn.player ? 'مررت. البوت يفكر...' : 'البوت مرر. دورك!',
    );
  }

  bool _play(DominoPiece piece, bool onLeft, DominoTurn who) {
    final hand = who == DominoTurn.player ? _state.playerHand : _state.botHand;
    if (!hand.any((p) => p == piece)) return false;
    final chain = List<DominoPiece>.from(_state.chain);
    int? lEnd = _state.leftEnd, rEnd = _state.rightEnd;

    if (chain.isEmpty) {
      chain.add(piece); lEnd = piece.a; rEnd = piece.b;
    } else if (onLeft) {
      if (!piece.canFit(lEnd!)) return false;
      final o = piece.orientedForLeft(lEnd); chain.insert(0, o); lEnd = o.a;
    } else {
      if (!piece.canFit(rEnd!)) return false;
      final o = piece.orientedForRight(rEnd); chain.add(o); rEnd = o.b;
    }

    final newHand = List<DominoPiece>.from(hand)..removeWhere((p) => p == piece);
    int scoreBonus = 0;
    if (mode == DominoMode.american && chain.length > 1) {
      final tot = lEnd! + rEnd!;
      if (tot % 5 == 0) scoreBonus = tot;
    }

    final playerWon = who == DominoTurn.player && newHand.isEmpty;
    final botWon = who == DominoTurn.bot && newHand.isEmpty;

    _state = _state.copyWith(
      chain: chain, leftEnd: lEnd, rightEnd: rEnd,
      playerHand: who == DominoTurn.player ? newHand : _state.playerHand,
      botHand: who == DominoTurn.bot ? newHand : _state.botHand,
      playerScore: _state.playerScore + (who == DominoTurn.player ? scoreBonus : 0),
      botScore: _state.botScore + (who == DominoTurn.bot ? scoreBonus : 0),
      playerPassed: false, botPassed: false,
      turn: who == DominoTurn.player ? DominoTurn.bot : DominoTurn.player,
      phase: (playerWon || botWon) ? DominoPhase.roundOver : DominoPhase.playing,
      playerWins: playerWon ? _state.playerWins + 1 : _state.playerWins,
      botWins: botWon ? _state.botWins + 1 : _state.botWins,
      message: playerWon ? '🎉 أنت فزت بالجولة!' : botWon ? '🤖 البوت فاز بالجولة!' : who == DominoTurn.player ? 'البوت يفكر...' : 'دورك! اختر حجراً',
    );
    return true;
  }

  void _endRound() {
    final pp = _state.playerHand.fold(0, (s, p) => s + p.pip);
    final bp = _state.botHand.fold(0, (s, p) => s + p.pip);
    if (pp < bp) {
      _state = _state.copyWith(phase: DominoPhase.roundOver, message: '🎉 فزت! (أنت: $pp، البوت: $bp)', playerWins: _state.playerWins + 1, playerScore: _state.playerScore + bp);
    } else if (bp < pp) {
      _state = _state.copyWith(phase: DominoPhase.roundOver, message: '🤖 البوت فاز! (أنت: $pp، البوت: $bp)', botWins: _state.botWins + 1, botScore: _state.botScore + pp);
    } else {
      _state = _state.copyWith(phase: DominoPhase.roundOver, message: '🤝 تعادل! ($pp نقطة)');
    }
  }

  DominoMove? botChooseMove() {
    if (_state.turn != DominoTurn.bot) return null;
    final valid = _state.validMovesFor(_state.botHand);
    if (valid.isEmpty) return null;
    if (_state.chain.isEmpty) {
      return DominoMove(valid.reduce((a,b) => a.pip > b.pip ? a : b));
    }
    DominoPiece? bestR, bestL; int brp = -1, blp = -1;
    for (final p in valid) {
      if (p.canFit(_state.rightEnd!)) {
        int sc = p.pip;
        if (mode == DominoMode.american) {
          final nv = p.b == _state.rightEnd ? p.a : p.b;
          if ((_state.leftEnd! + nv) % 5 == 0) sc += 50;
        }
        if (sc > brp) { bestR = p; brp = sc; }
      }
      if (p.canFit(_state.leftEnd!) && p.pip > blp) { bestL = p; blp = p.pip; }
    }
    if (bestR != null) return DominoMove(bestR, onLeft: false);
    if (bestL != null) return DominoMove(bestL, onLeft: true);
    return null;
  }

  void executeBotTurn() {
    if (_state.turn != DominoTurn.bot || _state.phase != DominoPhase.playing) return;
    var move = botChooseMove();
    if (move == null) {
      if (_state.boneyard.isNotEmpty) {
        final drawn = _state.boneyard.last;
        final newBy = List<DominoPiece>.from(_state.boneyard)..removeLast();
        final newHand = List<DominoPiece>.from(_state.botHand)..add(drawn);
        _state = _state.copyWith(botHand: newHand, boneyard: newBy);
        move = botChooseMove();
      }
      if (move == null) { _pass(DominoTurn.bot); return; }
    }
    _play(move.piece, move.onLeft, DominoTurn.bot);
  }
}
