import 'package:flutter/widgets.dart';
import 'SwCard.dart';

class SwStack with ChangeNotifier {
  SwStack(this.side, this.cards, this.title);

  String side;
  List<SwCard> cards;
  String title;

  int get length => cards.length;
  operator [](int index) => cards[index];

  add(SwCard card) => cards.add(card);
  insert(int index, SwCard card) => cards.insert(index, card);
  addCards(List<SwCard> cards) => cards.addAll(cards);
  addStack(SwStack stack) => cards.addAll(stack.cards);
  SwCard removeAt(int index) => cards.removeAt(index);
  SwCard firstWhere(Function fn) => cards.firstWhere(fn);
  SwStack uniq() => subset(cards.toSet().toList());

  List<SwCard> sublist(int start, int end) => cards.sublist(start, end);

  bool isEmpty() => cards.isEmpty;
  bool isNotEmpty() => cards.isNotEmpty;

  clear() => cards.clear();

  SwStack concat(SwStack that) {
    return new SwStack(this.side, this.cards + that.cards, this.title);
  }

  SwStack subset(List<SwCard> cards) {
    return new SwStack.fromCards(this.side, cards, this.title);
  }

  SwStack bySide(String query) {
    return this.subset(this.cards.where((c) => c.side == query).toList());
  }

  SwStack byType(String query) {
    return this.subset(this.cards.where((c) => c.type == query).toList());
  }

  SwStack bySubType(String query) {
    return this.subset(this.cards.where((c) => c.subType == query).toList());
  }

  SwStack matchesSubType(String query) {
    return this.subset(this
        .cards
        .where((c) => c.subType != null && c.subType.contains(query))
        .toList());
  }

  SwStack matchesGametext(String query) {
    return this
        .subset(this.cards.where((c) => c.gametext.contains(query)).toList());
  }

  SwStack hasCharacteristic(String query) {
    List<SwCard> matches = cards.where((e) {
      return e.characteristics != null && e.characteristics.contains(query);
    }).toList();
    return this.subset(matches);
  }

  SwCard findByName(String query) {
    return cards
        .firstWhere((e) => e.title.toLowerCase() == query.toLowerCase());
  }

  SwStack findAllByNames(List<String> queries) {
    List<SwCard> foundCards = queries
        .map((query) {
          return cards.firstWhere(
              (e) => e.title.toLowerCase() == query.toLowerCase(), orElse: () {
            print("findAllByName: Failed to find $query");
            return null;
          });
        })
        .whereType<SwCard>()
        .toList();

    return new SwStack(this.side, foundCards, 'Found all by name');
  }

  SwStack matchingStarships(SwCard character) {
    String persona =
        character.title.split(' ')[0]; // This works for most personas
    SwStack matchFromStarship =
        this.byType('Starship').matchesGametext(persona);
    SwStack matchFromCharacter = this
        .subset(this
            .cards
            .where((element) => character.gametext.contains(element.title))
            .toList())
        .byType('Starship');
    return (matchFromStarship.concat(matchFromCharacter).uniq());
  }

  SwStack matchingWeapons(SwCard character) {
    String persona =
        character.title.split(' ')[0]; // This works for most personas
    SwStack matchFromWeapon =
        this.byType('Weapon').bySubType('Character').matchesGametext(persona);
    SwStack matchFromCharacter = this
        .subset(this
            .cards
            .where((element) => character.gametext.contains(element.title))
            .toList())
        .byType('Weapon')
        .bySubType('Character');
    return (matchFromWeapon.concat(matchFromCharacter).uniq());
  }

  // TODO: Use maps for all these options
  SwStack.fromStack(SwStack s, String title)
      : side = s.side,
        cards = s.cards,
        title = title != null ? title : s.title;

  SwStack.fromCards(side, List<SwCard> cards, String title)
      : side = cards.isNotEmpty ? cards[0].side : null,
        cards = cards,
        title = title;

  SwStack.fromCardNames(List<String> names, SwStack library, String title)
      : side = library.isNotEmpty() ? library.side : null,
        cards = names
            .map((name) {
              return library.cards.firstWhere(
                  (c) => (SwCard.normalizeTitle(c.title) ==
                          SwCard.normalizeTitle(name) &&
                      c.side == library.side), orElse: () {
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
