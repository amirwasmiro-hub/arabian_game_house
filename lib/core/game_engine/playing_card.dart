import 'dart:math';

enum CardSuit { clubs, diamonds, hearts, spades }
enum CardRank { two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace }

class PlayingCard implements Comparable<PlayingCard> {
  final CardSuit suit;
  final CardRank rank;
  const PlayingCard(this.suit, this.rank);

  bool get isRed => suit == CardSuit.hearts || suit == CardSuit.diamonds;
  int get value => rank.index + 2;

  String get suitSymbol {
    switch (suit) {
      case CardSuit.clubs: return '♣';
      case CardSuit.diamonds: return '♦';
      case CardSuit.hearts: return '♥';
      case CardSuit.spades: return '♠';
    }
  }

  String get rankSymbol {
    switch (rank) {
      case CardRank.ace: return 'A';
      case CardRank.king: return 'K';
      case CardRank.queen: return 'Q';
      case CardRank.jack: return 'J';
      case CardRank.ten: return '10';
      default: return '${rank.index + 2}';
    }
  }

  @override String toString() => '${suitSymbol}';
  @override int compareTo(PlayingCard other) {
    if (suit.index != other.suit.index) return suit.index.compareTo(other.suit.index);
    return rank.index.compareTo(other.rank.index);
  }
  @override bool operator ==(Object other) =>
      other is PlayingCard && other.suit == suit && other.rank == rank;
  @override int get hashCode => suit.index * 13 + rank.index;
}

class CardDeck {
  final List<PlayingCard> _cards = [];
  CardDeck() { _reset(); }
  void _reset() {
    _cards.clear();
    for (final suit in CardSuit.values)
      for (final rank in CardRank.values)
        _cards.add(PlayingCard(suit, rank));
  }
  void shuffle() => _cards.shuffle(Random());
  PlayingCard? draw() => _cards.isNotEmpty ? _cards.removeLast() : null;
  List<PlayingCard> drawMultiple(int count) {
    final drawn = <PlayingCard>[];
    for (int i = 0; i < count && _cards.isNotEmpty; i++) drawn.add(_cards.removeLast());
    return drawn;
  }
  bool get isEmpty => _cards.isEmpty;
  int get remaining => _cards.length;
}
