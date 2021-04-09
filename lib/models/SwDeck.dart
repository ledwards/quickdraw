import 'package:flutter/widgets.dart';
import 'SwCard.dart';
import 'SwStack.dart';

class SwDeck with ChangeNotifier {
  SwDeck(String title)
      : cards = SwStack([], title),
        _side = null,
        title = title;

  String _side;
  String title;
  SwStack cards; // TODO: multiple stacks for each step

  String get side => _side;
  int get length => cards.length;
  operator [](int index) => cards[index];

  SwCard startingCard() => cards[0];
  SwCard startingInterrupt() => cards.matchesSubType('Starting')[0];
  SwCard lastCard() => cards[length - 1];
  List<SwCard> sublist(start, end) => cards.sublist(start, end);

  set side(String value) {
    _side = value;
    notifyListeners();
  }

  add(SwCard c) {
    cards.add(c);
    notifyListeners();
  }

  addStack(SwStack s) {
    cards.addStack(s);
    notifyListeners();
  }
}
