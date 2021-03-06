import 'SwCard.dart';
import '../rules/ExpansionSets.dart';

class SwStack {
  List<SwCard> cards;
  String title;
  dynamic sortRepo;
  bool _starting;

  String get side => cards.isEmpty ? null : cards[0].side;
  int get length => cards.length;
  operator [](int index) => cards[index];

  add(SwCard card) => cards.add(card);
  insert(int index, SwCard card) => cards.insert(index, card);
  addCards(List<SwCard> cards) => cards.addAll(cards);
  addStack(SwStack stack) => cards.addAll(stack.cards);
  SwCard removeAt(int index) => cards.removeAt(index);
  SwCard firstWhere(Function fn) => cards.firstWhere(fn);
  SwStack where(Function fn) => SwStack(cards.where(fn).toList(), title);
  SwStack uniq() => subset(cards.toSet().toList());

  List<SwCard> sublist(int start, int end) => cards.sublist(start, end);

  bool isEmpty() => cards.isEmpty;
  bool isNotEmpty() => cards.isNotEmpty;

  clear() => cards.clear();

  void refresh(SwStack stack, {starting}) {
    title = stack.title;
    clear();
    addStack(stack);
    sort(starting: starting);
  }

  // TODO: 2 params, sort by inclusion/frequency/default, by archetype/meta(overall)
  // TODO: frequency/inclusion can look at starting/main or not
  // TODO: default sort by type (at first, just by type, in the future, an order of types (character, then weapon, etc.))
  // TODO: Popularity in meta as tie-breaker for popularity in archetype
  // TODO: reverse?

  void sort({starting}) {
    _starting = starting == null ? _starting : starting;
    if (sortRepo != null) {
      sortByInclusion(sortRepo, starting: _starting);
    }
  }

  SwStack concat(SwStack that) {
    return new SwStack(this.cards + that.cards, this.title);
  }

  SwStack subset(List<SwCard> cards) {
    return new SwStack(cards, this.title);
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

  SwCard findByName(String query, {String set}) {
    return set != null
        ? cards.firstWhere((e) =>
            e.title.toLowerCase() == query.toLowerCase() &&
            e.set == setNumberFromName[set])
        : cards.firstWhere((e) => e.title.toLowerCase() == query.toLowerCase());
  }

  SwStack findAllByNames(List<String> queries, {bool includeVirtual}) {
    String vSub =
        (includeVirtual == null || includeVirtual == false) ? '' : ' (V)';
    List<SwCard> foundCards = queries
        .map((query) => cards.where((card) =>
            card.title.toLowerCase() == query.toLowerCase() ||
            card.title.toLowerCase() == "$query$vSub".toLowerCase()))
        .expand((e) => e)
        .whereType<SwCard>()
        .toSet()
        .toList();

    return new SwStack(foundCards, 'Found all by name');
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

  // TODO: Should implement an interface?
  void sortByInclusion(dynamic repo, {starting}) {
    sortRepo = repo;
    cards.sort((SwCard a, SwCard b) => sortRepo
        .inclusion(b, starting: starting)
        .compareTo(sortRepo.inclusion(a, starting: starting)));
  }

  // TODO: Should implement an interface?
  void sortByFrequency(dynamic repo, {starting}) {
    sortRepo = repo;
    cards.sort((SwCard a, SwCard b) => sortRepo
        .frequency(b, starting: starting)
        .compareTo(sortRepo.frequency(a, starting: starting)));
  }

  int qtyFor(SwCard card) => cards.where((c) => card == c).length;

  SwStack.fromStack(SwStack s, String title)
      : cards = new List<SwCard>.from(s.cards),
        title = title != null ? title : s.title;

  SwStack(List<SwCard> cards, String title)
      : cards = cards,
        title = title;

  SwStack.fromCardNames(List<String> names, SwStack library, String title)
      : cards = names
            .map((name) {
              return library.cards.firstWhere(
                  (c) => (SwCard.normalizeTitle(c.title) ==
                          SwCard.normalizeTitle(name) &&
                      c.side == library.side), orElse: () {
                print("Could not find $name when creating Stack");
                return null;
              });
            })
            .where((value) => value != null)
            .toList()
            .cast<SwCard>(),
        title = title;
}
