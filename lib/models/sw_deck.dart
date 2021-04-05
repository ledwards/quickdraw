import 'package:flutter/widgets.dart';
import 'sw_card.dart';

class SwDeck with ChangeNotifier {
  SwDeck(this.side, this.cards, this.title);

  String side;
  List<SwCard> cards;
  String title;

  int get length => cards.length;
  operator [](int index) => cards[index];

  SwCard lastCard() => cards[length - 1];

  add(SwCard card) {
    cards.add(card);
    notifyListeners();
  }
}
