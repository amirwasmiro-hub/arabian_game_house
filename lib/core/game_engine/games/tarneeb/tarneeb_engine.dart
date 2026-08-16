import 'dart:math';
import '../../playing_card.dart';

enum TarneebPhase { dealing, bidding, playing, roundOver }

class TarneebState {
  final List<List<PlayingCard>> hands; // [0=player, 1=bot1, 2=bot2, 3=bot3]
  final List<PlayingCard> currentTrick;
  final List<int> tricksWon; // per team: [team0(0+2), team1(1+3)]
  final int bid, bidWinner;
  final CardSuit? trump;
  final int currentPlayer;
  final TarneebPhase phase;
  final int biddingPlayer, currentBid;
  final List<int> scores; // [team0, team1]
  final String message;

  const TarneebState({
    required this.hands, required this.currentTrick, required this.tricksWon,
    required this.bid, required this.bidWinner, required this.trump,
    required this.currentPlayer, required this.phase,
    required this.biddingPlayer, required this.currentBid,
    required this.scores, required this.message,
  });

  TarneebState copyWith({List<List<PlayingCard>>? hands, List<PlayingCard>? currentTrick,
    List<int>? tricksWon, int? bid, int? bidWinner, CardSuit? trump, int? currentPlayer,
    TarneebPhase? phase, int? biddingPlayer, int? currentBid, List<int>? scores, String? message}) =>
    TarneebState(hands: hands??this.hands, currentTrick: currentTrick??this.currentTrick,
      tricksWon: tricksWon??this.tricksWon, bid: bid??this.bid, bidWinner: bidWinner??this.bidWinner,
      trump: trump??this.trump, currentPlayer: currentPlayer??this.currentPlayer,
      phase: phase??this.phase, biddingPlayer: biddingPlayer??this.biddingPlayer,
      currentBid: currentBid??this.currentBid, scores: scores??this.scores, message: message??this.message);
}

class TarneebEngine {
  late TarneebState _state;
  final _rng = Random();
  TarneebEngine() { reset(); }
  TarneebState get state => _state;

  static const suitNames = {CardSuit.spades: '♠ بستوني', CardSuit.hearts: '♥ قلب', CardSuit.diamonds: '♦ ديموني', CardSuit.clubs: '♣ سباتي'};

  void reset() {
    final deck = CardDeck()..shuffle();
    final hands = List.generate(4, (i) => deck.drawMultiple(13));
    _state = TarneebState(
      hands: hands, currentTrick: [], tricksWon: [0, 0],
      bid: 0, bidWinner: 0, trump: null, currentPlayer: 0,
      phase: TarneebPhase.bidding, biddingPlayer: 0, currentBid: 6,
      scores: [0, 0], message: 'مرحلة المزايدة — أدنى مزايدة هي 7',
    );
  }

  // Player bids
  bool playerBid(int amount) {
    if (_state.phase != TarneebPhase.bidding || _state.biddingPlayer != 0) return false;
    if (amount < 7 || amount > 13) return false;
    _state = _state.copyWith(currentBid: amount, bidWinner: 0);
    _advanceBidding();
    return true;
  }

  // Player passes bidding
  bool playerPass() {
    if (_state.phase != TarneebPhase.bidding || _state.biddingPlayer != 0) return false;
    _advanceBidding();
    return true;
  }

  void _advanceBidding() {
    int next = (_state.biddingPlayer + 1) % 4;
    if (next == 0) {
      // All bid — winner picks trump
      if (_state.bidWinner == 0) {
        _state = _state.copyWith(phase: TarneebPhase.playing, biddingPlayer: 0,
          bid: _state.currentBid, trump: null,
          message: 'أنت الفائز بالمزايدة (${_state.currentBid}) — اختر الكبة');
      } else {
        // Bot picked trump
        final t = CardSuit.values[_rng.nextInt(4)];
        _state = _state.copyWith(phase: TarneebPhase.playing, trump: t,
          currentPlayer: _state.bidWinner, bid: _state.currentBid,
          message: 'الكبة: ${suitNames[t]} — دور ${_getBotName(_state.bidWinner)}');
      }
    } else {
      // Bot bids
      final botHand = _state.hands[next];
      final botBid = _botBidValue(botHand);
      if (botBid > _state.currentBid) {
        _state = _state.copyWith(biddingPlayer: next, currentBid: botBid, bidWinner: next,
          message: '${_getBotName(next)} زايد بـ $botBid');
      } else {
        _state = _state.copyWith(biddingPlayer: next,
          message: '${_getBotName(next)} مرر');
      }
      _advanceBidding();
    }
  }

  int _botBidValue(List<PlayingCard> hand) {
    int score = 0;
    for (final c in hand) {
      if (c.rank == CardRank.ace) {
        score += 4;
      } else if (c.rank == CardRank.king) {
        score += 3;
      } else if (c.rank == CardRank.queen) {
        score += 2;
      } else if (c.rank == CardRank.jack) {
        score += 1;
      }
    }
    return (7 + (score / 4)).round().clamp(7, 13);
  }

  // Player selects trump suit
  bool selectTrump(CardSuit suit) {
    if (_state.phase != TarneebPhase.playing || _state.trump != null) return false;
    _state = _state.copyWith(trump: suit, currentPlayer: _state.bidWinner,
      message: 'الكبة: ${suitNames[suit]} — ابدأ اللعب!');
    return true;
  }

  // Player plays a card
  bool playCard(PlayingCard card) {
    if (_state.currentPlayer != 0 || _state.trump == null) return false;
    if (!_state.hands[0].contains(card)) return false;
    return _playCardForPlayer(0, card);
  }

  bool _playCardForPlayer(int player, PlayingCard card) {
    final hand = List<PlayingCard>.from(_state.hands[player])..remove(card);
    final hands = List<List<PlayingCard>>.from(_state.hands);
    hands[player] = hand;
    final trick = List<PlayingCard>.from(_state.currentTrick)..add(card);

    if (trick.length < 4) {
      _state = _state.copyWith(hands: hands, currentTrick: trick,
        currentPlayer: (player + 1) % 4, message: 'دور ${_getBotName((player+1)%4)}');
      return true;
    }

    // Evaluate trick
    final trickWinner = _trickWinner(trick, player);
    final tricksWon = List<int>.from(_state.tricksWon);
    tricksWon[trickWinner % 2]++;

    if (_state.hands[0].isEmpty) {
      _endRound(tricksWon);
      return true;
    }

    _state = _state.copyWith(hands: hands, currentTrick: [], tricksWon: tricksWon,
      currentPlayer: trickWinner,
      message: '${_getBotName(trickWinner)} أخذ الأخذة! دوره الآن');
    return true;
  }

  int _trickWinner(List<PlayingCard> trick, int lastPlayer) {
    final firstPlayer = (lastPlayer - 3 + 4) % 4;
    int winnerIdx = 0;
    PlayingCard winner = trick[0];
    for (int i = 1; i < 4; i++) {
      final c = trick[i];
      if (c.suit == winner.suit && c.value > winner.value) { winner = c; winnerIdx = i; }
      else if (c.suit == _state.trump && winner.suit != _state.trump) { winner = c; winnerIdx = i; }
    }
    return (firstPlayer + winnerIdx) % 4;
  }

  void _endRound(List<int> tricksWon) {
    final bidTeam = _state.bidWinner % 2;
    final bidTeamTricks = tricksWon[bidTeam];
    final newScores = List<int>.from(_state.scores);
    if (bidTeamTricks >= _state.bid) {
      newScores[bidTeam] += bidTeamTricks;
      newScores[1 - bidTeam] += tricksWon[1 - bidTeam];
    } else {
      newScores[bidTeam] -= _state.bid;
      newScores[1 - bidTeam] += tricksWon[1 - bidTeam];
    }
    final winMsg = newScores[0] >= 31 ? '🏆 فريقك فاز المباراة!' :
        newScores[1] >= 31 ? '🤖 فريق البوت فاز المباراة!' : 'نهاية الجولة — العب مجدداً؟';
    _state = _state.copyWith(scores: newScores, phase: TarneebPhase.roundOver,
      tricksWon: tricksWon, message: winMsg);
  }

  void executeBotTurn() {
    if (_state.currentPlayer == 0 || _state.phase != TarneebPhase.playing) return;
    final player = _state.currentPlayer;
    final hand = _state.hands[player];
    PlayingCard card = _botChooseCard(player, hand);
    _playCardForPlayer(player, card);
  }

  PlayingCard _botChooseCard(int player, List<PlayingCard> hand) {
    if (_state.currentTrick.isEmpty) {
      // Lead with highest trump or highest card
      final trumpCards = hand.where((c) => c.suit == _state.trump).toList();
      if (trumpCards.isNotEmpty) return trumpCards.reduce((a,b) => a.value > b.value ? a : b);
      return hand.reduce((a,b) => a.value > b.value ? a : b);
    }
    final leadSuit = _state.currentTrick[0].suit;
    final follow = hand.where((c) => c.suit == leadSuit).toList();
    if (follow.isNotEmpty) return follow.reduce((a,b) => a.value > b.value ? a : b);
    final trumps = hand.where((c) => c.suit == _state.trump).toList();
    if (trumps.isNotEmpty) return trumps.reduce((a,b) => a.value < b.value ? a : b);
    return hand.reduce((a,b) => a.value < b.value ? a : b);
  }

  String _getBotName(int p) => ['أنت', 'بوت1', 'شريكك', 'بوت3'][p];
}
