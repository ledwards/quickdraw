import 'package:flutter/widgets.dart';
import 'sw_card.dart';

class SwStack with ChangeNotifier {
  SwStack(this.side, this.cards, this.title);

  String side;
  List<SwCard> cards;
  String title;

  int get length => cards.length;
  operator [](int index) => cards[index];
  List<SwCard> sublist(int start, int end) => cards.sublist(start, end);

  add(SwCard card) => cards.add(card);
  addCards(List<SwCard> cards) => cards.addAll(cards);
  addStack(SwStack stack) => cards.addAll(stack.cards);
  insert(int index, SwCard card) => cards.insert(index, card);
  SwCard removeAt(int index) => cards.removeAt(index);
  SwCard firstWhere(Function fn) => cards.firstWhere(fn);

  clear() => cards.clear();

  SwStack subset(List<SwCard> cards) {
    return new SwStack.fromCards(this.side, cards, this.title);
  }

  SwStack bySide(String q) {
    return this.subset(this.cards.where((c) => c.side == q).toList());
  }

  SwStack byType(String q) {
    return this.subset(this.cards.where((c) => c.type == q).toList());
  }

  SwStack bySubType(String q) {
    return this.subset(this.cards.where((c) => c.subType == q).toList());
  }

  SwStack matchesSubType(String q) {
    return this.subset(this.cards.where((c) => c.subType.contains(q)).toList());
  }

  SwStack matchesGametext(String q) {
    return this
        .subset(this.cards.where((c) => c.gametext.contains(q)).toList());
  }

  SwStack hasCharacteristic(String q) {
    List<SwCard> matches = cards.where((e) {
      return e.characteristics != null && e.characteristics.contains(q);
    }).toList();
    return this.subset(matches);
  }

  SwCard findByName(String q) {
    return cards.firstWhere((e) => e.title.toLowerCase() == q.toLowerCase());
  }

  SwStack findAllByNames(List<String> qs) {
    List<SwCard> foundCards = qs
        .map((q) {
          return cards.firstWhere(
              (e) => e.title.toLowerCase() == q.toLowerCase(), orElse: () {
            print("findAllByName: Failed to find $q");
            return null;
          });
        })
        .whereType<SwCard>()
        .toList();

    return new SwStack(this.side, foundCards, 'Found all by name');
  }

  SwStack concat(SwStack that) {
    return new SwStack(this.side, this.cards + that.cards, this.title);
  }

  SwStack.from(SwStack s)
      : side = s.side,
        cards = s.cards,
        title = s.title;

  SwStack.fromCards(String side, List<SwCard> cards, String title)
      : side = side,
        cards = cards,
        title = title;

  SwStack.fromCardNames(
      String side, List<String> names, List<SwCard> cardLibrary, String title)
      : side = side,
        cards = names
            .map((name) {
              return cardLibrary.firstWhere(
                  (c) => (c.title == name && c.side == side), orElse: () {
                print("Could not find card when creating Stack");
                print(name);
                return null;
              });
            })
            .where((value) => value != null)
            .toList()
            .cast<SwCard>(),
        title = title;

  void onChange() {
    notifyListeners();
  }
}
