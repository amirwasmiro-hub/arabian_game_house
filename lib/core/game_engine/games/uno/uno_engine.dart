import 'dart:math';

enum UnoColor { red, green, blue, yellow, wild }
enum UnoValue { zero, one, two, three, four, five, six, seven, eight, nine, skip, reverse, drawTwo, wild, wildDrawFour }

class UnoCard {
  final UnoColor color;
  final UnoValue value;
  const UnoCard(this.color, this.value);
  bool get isWild => color == UnoColor.wild;
  bool canPlayOn(UnoCard top, UnoColor? chosenColor) {
    if (isWild) return true;
    if (top.isWild) return chosenColor == null || color == chosenColor;
    return color == top.color || value == top.value;
  }
  String get colorStr => ['🔴','🟢','🔵','🟡','⚫'][color.index];
  String get valueStr {
    if (value.index <= 9) return '${value.index}';
    return ['','','','','','','','','','','🚫','↩️','+2','🃏','+4'][value.index];
  }
  @override String toString() => '$colorStr$valueStr';
  static List<UnoCard> buildDeck() {
    final d = <UnoCard>[];
    for (final c in [UnoColor.red, UnoColor.green, UnoColor.blue, UnoColor.yellow]) {
      d.add(UnoCard(c, UnoValue.zero));
      for (int i = 0; i < 2; i++) {
        for (final v in UnoValue.values) {
          if (v == UnoValue.zero || v == UnoValue.wild || v == UnoValue.wildDrawFour) continue;
          d.add(UnoCard(c, v));
        }
      }
    }
    for (int i = 0; i < 4; i++) {
      d.add(UnoCard(UnoColor.wild, UnoValue.wild));
      d.add(UnoCard(UnoColor.wild, UnoValue.wildDrawFour));
    }
    return d;
  }
}

enum UnoPhase { playing, choosingColor, gameOver }

class UnoState {
  final List<List<UnoCard>> hands; // [0=player, 1,2,3=bots]
  final List<UnoCard> deck, discard;
  final UnoCard? topCard;
  final UnoColor? chosenColor;
  final int currentPlayer;
  final UnoPhase phase;
  final bool clockwise;
  final String message;
  final List<int> scores;

  const UnoState({
    required this.hands, required this.deck, required this.discard, required this.topCard,
    required this.chosenColor, required this.currentPlayer, required this.phase,
    required this.clockwise, required this.message, required this.scores,
  });

  UnoState copyWith({List<List<UnoCard>>? hands, List<UnoCard>? deck, List<UnoCard>? discard,
    UnoCard? topCard, UnoColor? chosenColor, int? currentPlayer, UnoPhase? phase,
    bool? clockwise, String? message, List<int>? scores}) =>
    UnoState(hands: hands??this.hands, deck: deck??this.deck, discard: discard??this.discard,
      topCard: topCard??this.topCard, chosenColor: chosenColor??this.chosenColor,
      currentPlayer: currentPlayer??this.currentPlayer, phase: phase??this.phase,
      clockwise: clockwise??this.clockwise, message: message??this.message, scores: scores??this.scores);

  List<UnoCard> validMoves(int player) =>
    hands[player].where((c) => c.canPlayOn(topCard!, chosenColor)).toList();
}

class UnoEngine {
  late UnoState _state;
  final _rng = Random();
  UnoEngine() { reset(); }
  UnoState get state => _state;
  static const names = ['أنت','بوت1','بوت2','بوت3'];

  void reset() {
    final deck = UnoCard.buildDeck()..shuffle(_rng);
    final hands = List.generate(4, (i) => deck.sublist(i*7, i*7+7));
    final remaining = deck.sublist(28);
    UnoCard top = remaining.removeLast();
    while (top.isWild) { remaining.insert(0, top); top = remaining.removeLast(); }
    _state = UnoState(
      hands: hands, deck: remaining, discard: [top], topCard: top,
      chosenColor: null, currentPlayer: 0, phase: UnoPhase.playing,
      clockwise: true, message: 'دورك! العب كرتاً', scores: [0,0,0,0],
    );
  }

  bool playerPlay(UnoCard card, {UnoColor? colorChoice}) {
    if (_state.currentPlayer != 0 || _state.phase != UnoPhase.playing) return false;
    if (!_state.validMoves(0).any((c) => c == card)) return false;
    return _play(0, card, colorChoice: colorChoice);
  }

  bool playerDraw() {
    if (_state.currentPlayer != 0 || _state.phase != UnoPhase.playing) return false;
    _drawCards(0, 1);
    _advance();
    return true;
  }

  bool _play(int p, UnoCard card, {UnoColor? colorChoice}) {
    final h = List<UnoCard>.from(_state.hands[p])..removeWhere((c) => identical(c, card) || c == card);
    final hands = List<List<UnoCard>>.from(_state.hands); hands[p] = h;

    if (h.isEmpty) {
      _state = _state.copyWith(hands: hands, topCard: card, discard: [..._state.discard, card],
        phase: UnoPhase.gameOver, message: '${names[p]} فاز! 🎉');
      return true;
    }

    bool cw = _state.clockwise;
    UnoColor? cc = colorChoice ?? (card.isWild ? null : null);

    // Special effects
    int skip = 0;
    if (card.value == UnoValue.skip) skip = 1;
    if (card.value == UnoValue.reverse) cw = !cw;
    if (card.value == UnoValue.drawTwo) { _drawCards(_nextPlayer(p, cw), 2); skip = 1; }
    if (card.value == UnoValue.wildDrawFour) { _drawCards(_nextPlayer(p, cw), 4); skip = 1; }

    if (card.isWild && cc == null && p == 0) {
      _state = _state.copyWith(hands: hands, topCard: card, clockwise: cw, currentPlayer: p,
        discard: [..._state.discard, card], phase: UnoPhase.choosingColor,
        message: 'اختر لون الكبة!');
      return true;
    }
    if (card.isWild && cc == null) cc = UnoColor.values[_rng.nextInt(4)];

    final msg = h.length == 1 ? '${names[p]} قال UNO! 🃏' : 'دور ${names[_nextPlayer(p, cw, skip: skip)]}';
    _state = _state.copyWith(hands: hands, topCard: card, clockwise: cw, chosenColor: cc,
      discard: [..._state.discard, card], currentPlayer: _nextPlayer(p, cw, skip: skip),
      message: msg);
    return true;
  }

  bool playerChooseColor(UnoColor c) {
    if (_state.phase != UnoPhase.choosingColor || _state.currentPlayer != 0) return false;
    final next = _nextPlayer(0, _state.clockwise);
    _state = _state.copyWith(chosenColor: c, phase: UnoPhase.playing,
      currentPlayer: next, message: 'اللون: ${['🔴','🟢','🔵','🟡'][c.index]} — دور ${names[next]}');
    return true;
  }

  void _drawCards(int p, int count) {
    final d = List<UnoCard>.from(_state.deck);
    final h = List<UnoCard>.from(_state.hands[p]);
    for (int i = 0; i < count && d.isNotEmpty; i++) {
      h.add(d.removeLast());
    }
    final hands = List<List<UnoCard>>.from(_state.hands); hands[p] = h;
    _state = _state.copyWith(hands: hands, deck: d);
  }

  int _nextPlayer(int p, bool cw, {int skip = 0}) =>
    cw ? (p + 1 + skip) % 4 : (p - 1 - skip + 8) % 4;

  void _advance() {
    _state = _state.copyWith(currentPlayer: _nextPlayer(_state.currentPlayer, _state.clockwise));
  }

  void executeBotTurn() {
    if (_state.currentPlayer == 0) return;
    if (_state.phase == UnoPhase.choosingColor && _state.currentPlayer != 0) {
      // Bot chose color
      final p = _state.currentPlayer;
      final bestColor = _botBestColor(p);
      _state = _state.copyWith(chosenColor: bestColor, phase: UnoPhase.playing,
        currentPlayer: _nextPlayer(p, _state.clockwise),
        message: '${names[p]} اختار ${["🔴","🟢","🔵","🟡"][bestColor.index]}');
      return;
    }
    if (_state.phase != UnoPhase.playing) return;
    final p = _state.currentPlayer;
    final valid = _state.validMoves(p);
    if (valid.isEmpty) { _drawCards(p, 1); _advance(); return; }
    // Bot prefers: action cards > high value
    valid.sort((a, b) => b.value.index.compareTo(a.value.index));
    final card = valid.first;
    _play(p, card, colorChoice: card.isWild ? _botBestColor(p) : null);
  }

  UnoColor _botBestColor(int p) {
    final counts = List.filled(4, 0);
    for (final c in _state.hands[p]) {
      if (!c.isWild) counts[c.color.index]++;
    }
    int best = 0;
    for (int i = 1; i < 4; i++) {
      if (counts[i] > counts[best]) best = i;
    }
    return UnoColor.values[best];
  }
}
