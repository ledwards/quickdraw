import 'package:flutter/widgets.dart';
import 'SwCard.dart';
import 'SwStack.dart';
import 'SwArchetype.dart';
import 'SwDeckCard.dart';

class SwDeck with ChangeNotifier {
  SwDeck(String title)
      : _deckCards = [],
        _side = null,
        title = title;

  String _side;
  String title;
  SwArchetype archetype;
  List<SwDeckCard> _deckCards;

  List<SwCard> get cards =>
      _deckCards.map((deckCard) => deckCard.card).toList();
  String get side => _side;
  int get length => cards.length;
  operator [](int index) => cards[index];

  SwCard startingCard() =>
      _deckCards.firstWhere((deckCard) => deckCard.stepNumber == 2).card;
  SwCard startingInterrupt() =>
      _deckCards.firstWhere((deckCard) => deckCard.stepNumber == 4).card;
  SwCard lastCard() => cards[length - 1];
  List<SwCard> sublist(start, end) => cards.sublist(start, end);

  set side(String value) {
    _side = value;
    notifyListeners();
  }

  List<SwCard> cardsForStep(int step) {
    return _deckCards
        .where((deckCard) => deckCard.stepNumber == step)
        .map((deckCard) => deckCard.card)
        .toList();
  }

  Map<int, List<SwCard>> get cardsByStep {
    Map<int, List<SwCard>> map = {};
    [1, 2, 3, 4, 5, 6, 7].forEach((step) => map[step] = cardsForStep(step));
    map.removeWhere((key, value) => value.isEmpty);
    return map;
  }

  add(SwCard card, int stepNumber) {
    _deckCards.add(SwDeckCard(card, stepNumber));
    notifyListeners();
  }

  addStack(SwStack stack, int stepNumber) {
    _deckCards.addAll(stack.cards.map((card) => SwDeckCard(card, stepNumber)));
    notifyListeners();
  }
}
