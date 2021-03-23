import 'sw_card.dart';

class SwDeck {
  SwDeck(this.side, this.cards, this.title);

  String side;
  List<SwCard> cards;
  String title;

  int get length => cards.length;
  operator [](int index) => cards[index];

  add(SwCard card) => cards.add(card);
  addAll(List<SwCard> cards) => cards.addAll(cards);
}
