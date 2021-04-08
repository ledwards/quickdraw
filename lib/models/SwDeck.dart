import 'package:flutter/widgets.dart';
import 'SwCard.dart';
import 'SwStack.dart';

class SwDeck with ChangeNotifier {
  SwDeck(String title)
      : cards = SwStack([], title),
        side = null,
        title = title;

  String side;
  String title;
  SwStack cards; // TODO: multiple stacks for each step

  int get length => cards.length;
  operator [](int index) => cards[index];

  SwCard startingCard() => cards[0];
  SwCard startingInterrupt() => cards.matchesSubType('Starting')[0];
  SwCard lastCard() => cards[length - 1];
  List<SwCard> sublist(start, end) => cards.sublist(start, end);

  add(SwCard c) {
    cards.add(c);
    notifyListeners();
  }

  addStack(SwStack s) {
    cards.addStack(s);
    notifyListeners();
  }
}
