import 'dart:math';
import '../models/playing_card.dart';

enum EstPhase { bidding, playing, roundOver }

class EstimationState {
  final List<List<PlayingCard>> hands;
  final List<PlayingCard> currentTrick;
  final List<int> bids, tricksWon;
  final CardSuit? trump;
  final int currentPlayer, biddingPlayer, dealerPlayer;
  final EstPhase phase;
  final List<int> scores, totalScores;
  final String message;

  const EstimationState({
    required this.hands, required this.currentTrick, required this.bids,
    required this.tricksWon, required this.trump, required this.currentPlayer,
    required this.biddingPlayer, required this.dealerPlayer, required this.phase,
    required this.scores, required this.totalScores, required this.message,
  });

  EstimationState copyWith({List<List<PlayingCard>>? hands, List<PlayingCard>? currentTrick,
    List<int>? bids, List<int>? tricksWon, CardSuit? trump, int? currentPlayer,
    int? biddingPlayer, int? dealerPlayer, EstPhase? phase,
    List<int>? scores, List<int>? totalScores, String? message}) =>
    EstimationState(hands: hands??this.hands, currentTrick: currentTrick??this.currentTrick,
      bids: bids??this.bids, tricksWon: tricksWon??this.tricksWon, trump: trump??this.trump,
      currentPlayer: currentPlayer??this.currentPlayer, biddingPlayer: biddingPlayer??this.biddingPlayer,
      dealerPlayer: dealerPlayer??this.dealerPlayer, phase: phase??this.phase,
      scores: scores??this.scores, totalScores: totalScores??this.totalScores, message: message??this.message);
}

class EstimationEngine {
  late EstimationState _state;
  final _rng = Random();
  EstimationEngine() { reset(); }
  EstimationState get state => _state;

  static const names = ['أنت', 'بوت1', 'بوت2', 'بوت3'];

  void reset() {
    final deck = CardDeck()..shuffle();
    final hands = List.generate(4, (i) => deck.drawMultiple(13));
    final trump = CardSuit.values[_rng.nextInt(4)];
    _state = EstimationState(
      hands: hands, currentTrick: [], bids: [-1, -1, -1, -1], tricksWon: [0,0,0,0],
      trump: trump, currentPlayer: 0, biddingPlayer: 0, dealerPlayer: 3,
      phase: EstPhase.bidding, scores: [0,0,0,0], totalScores: [0,0,0,0],
      message: 'الكبة: ${_suitName(trump)} — كم أخذة تتوقع أخذها؟',
    );
    _botsBid();
  }

  static String _suitName(CardSuit s) => ['♣سباتي','♦ديموني','♥قلب','♠بستوني'][s.index];

  void _botsBid() {
    final bids = List<int>.from(_state.bids);
    for (int i = 1; i < 4; i++) {
      bids[i] = _calcBotBid(i);
    }
    _state = _state.copyWith(bids: bids);
  }

  int _calcBotBid(int player) {
    final hand = _state.hands[player];
    int count = 0;
    for (final c in hand) {
      if (c.suit == _state.trump && c.rank.index >= CardRank.jack.index) count++;
      if (c.rank == CardRank.ace) count++;
    }
    return count.clamp(0, 13);
  }

  bool playerBid(int amount) {
    if (_state.phase != EstPhase.bidding || _state.biddingPlayer != 0) return false;
    final bids = List<int>.from(_state.bids);
    bids[0] = amount;
    _state = _state.copyWith(bids: bids, phase: EstPhase.playing,
      message: 'تقديرك: $amount — ابدأ اللعب!');
    return true;
  }

  bool playCard(PlayingCard card) {
    if (_state.currentPlayer != 0 || _state.phase != EstPhase.playing) return false;
    if (!_state.hands[0].contains(card)) return false;
    return _play(0, card);
  }

  bool _play(int player, PlayingCard card) {
    final hand = List<PlayingCard>.from(_state.hands[player])..remove(card);
    final hands = List<List<PlayingCard>>.from(_state.hands);
    hands[player] = hand;
    final trick = List<PlayingCard>.from(_state.currentTrick)..add(card);

    if (trick.length < 4) {
      _state = _state.copyWith(hands: hands, currentTrick: trick,
        currentPlayer: (player + 1) % 4);
      return true;
    }

    final winner = _trickWinner(trick, player);
    final tw = List<int>.from(_state.tricksWon); tw[winner]++;
    if (hand.isEmpty) { _endRound(tw); return true; }
    _state = _state.copyWith(hands: hands, currentTrick: [], tricksWon: tw,
      currentPlayer: winner, message: '${names[winner]} أخذ الأخذة!');
    return true;
  }

  int _trickWinner(List<PlayingCard> trick, int last) {
    final first = (last - 3 + 4) % 4;
    int wi = 0; PlayingCard w = trick[0];
    for (int i = 1; i < 4; i++) {
      final c = trick[i];
      if (c.suit == w.suit && c.value > w.value) { w = c; wi = i; }
      else if (c.suit == _state.trump && w.suit != _state.trump) { w = c; wi = i; }
    }
    return (first + wi) % 4;
  }

  void _endRound(List<int> tw) {
    final s = List<int>.from(_state.scores);
    final ts = List<int>.from(_state.totalScores);
    for (int i = 0; i < 4; i++) {
      s[i] = tw[i] == _state.bids[i] ? 10 + _state.bids[i] : -_state.bids[i];
      ts[i] += s[i];
    }
    final leader = ts.indexOf(ts.reduce((a,b) => a>b?a:b));
    _state = _state.copyWith(scores: s, totalScores: ts, tricksWon: tw,
      phase: EstPhase.roundOver,
      message: 'نهاية الجولة! ${names[leader]} يتصدر بـ${ts[leader]} نقطة');
  }

  void executeBotTurn() {
    if (_state.currentPlayer == 0 || _state.phase != EstPhase.playing) return;
    final p = _state.currentPlayer;
    final h = _state.hands[p];
    PlayingCard c;
    if (_state.currentTrick.isEmpty) {
      final trumps = h.where((x) => x.suit == _state.trump).toList();
      c = trumps.isNotEmpty ? trumps.reduce((a,b) => a.value>b.value?a:b) : h.reduce((a,b) => a.value>b.value?a:b);
    } else {
      final lead = _state.currentTrick[0].suit;
      final follow = h.where((x) => x.suit == lead).toList();
      if (follow.isNotEmpty) { c = follow.reduce((a,b) => a.value>b.value?a:b); }
      else {
        final t = h.where((x) => x.suit == _state.trump).toList();
        c = t.isNotEmpty ? t.first : h.reduce((a,b) => a.value<b.value?a:b);
      }
    }
    _play(p, c);
  }
}
