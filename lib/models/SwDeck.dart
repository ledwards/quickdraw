import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';
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
  List<SwCard> get uniqueCards => cards.toSet().toList();
  List<SwDeckCard> get uniqueDeckCards => _deckCards.toSet().toList();
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

  List<SwCard> cardsForStep(int step, {unique}) {
    List<SwCard> c = _deckCards
        .where((deckCard) => deckCard.stepNumber == step)
        .map((deckCard) => deckCard.card)
        .toList();
    return unique ? c.toSet().toList() : c;
  }

  Map<int, List<SwCard>> cardsByStep({unique}) {
    Map<int, List<SwCard>> map = {};
    [1, 2, 3, 4, 5, 6, 7, 8].forEach((step) {
      if (unique) {
        map[step] = cardsForStep(step).toSet().toList();
      } else {
        map[step] = cardsForStep(step);
      }
    });
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

  int qtyFor(SwCard card, {step}) => step == null
      ? cards.where((c) => card == c).length
      : _deckCards
          .where((dc) => card == dc.card && dc.stepNumber == step)
          .length;

  Map<String, List<SwCard>> groupByCardType({starting}) {
    Map<String, List<SwCard>> grouped = {};
    _deckCards
        .groupListsBy((SwDeckCard dc) => dc.card.type)
        .forEach((String step, List<SwDeckCard> deckCards) {
      if (starting != null && deckCards[0].starting == starting) {
        grouped[step] = deckCards.map((e) => e.card).toList();
      }
    });
    return grouped;
  }
}
