import 'package:flutter/widgets.dart';
import 'sw_card.dart';
import 'sw_stack.dart';

class SwDeck with ChangeNotifier {
  SwDeck(side, title)
      : side = side,
        cards = SwStack(side, [], title),
        title = title;

  String side;
  String title;
  SwStack cards; // TODO: multiple stacks for each step

  int get length => cards.length;
  operator [](int index) => cards[index];

  SwCard startingCard() => cards[0];
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