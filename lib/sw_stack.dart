import 'sw_card.dart';

class SwStack {
  SwStack(this.side, this.cards, this.title);

  String side;
  List<SwCard> cards;
  String title;

  int get length => cards.length;
  operator [](int index) => cards[index];

  insert(int index, SwCard card) => cards.insert(index, card);
  add(SwCard card) => cards.add(card);
  addCards(List<SwCard> cards) => cards.addAll(cards);
  SwCard removeAt(int index) => cards.removeAt(index);

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

  SwCard findByName(String q) {
    return cards.firstWhere((e) => e.title.toLowerCase() == q.toLowerCase());
  }

  SwStack extend(SwStack that) {
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
}
