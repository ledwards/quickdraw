import 'SwCard.dart';
import 'SwStack.dart';
import 'SwDecklist.dart';

class SwArchetype {
  SwArchetype(this.side, this.title, this.startingCard, this.decklists);

  String side;
  String title;
  SwCard startingCard;
  List<SwDecklist> decklists;

  List<String> get allCardNames => decklists
      .fold([], (list, decklist) => list.followedBy(decklist.cardNames))
      .toSet()
      .toList();

  SwStack allCards(SwStack library) {
    SwStack all = library.findAllByNames(allCardNames);
    all.title = title;
    return all;
  }

  int inclusion(SwCard card, {starting}) {
    return decklists
        .where((decklist) =>
            decklist.cardNames(starting: starting).contains(card.title))
        .length;
  }

  int frequency(SwCard card, {starting}) {
    return decklists.fold(
        0,
        (int sum, SwDecklist decklist) =>
            sum +
            decklist
                .cardNames(starting: starting)
                .where((name) => name == card.title)
                .length);
    // TODO: match e.g. effect vs. defensive shield
  }

  num rateOfInclusion(SwCard card, {starting}) {
    return inclusion(card, starting: starting) / decklists.length;
  }

  num averageFrequency(SwCard card, {starting}) {
    return frequency(card, starting: starting) / decklists.length;
  }

  num averageFrequencyPerInclusion(SwCard card, {starting}) {
    return inclusion(card, starting: starting) == 0
        ? 0
        : frequency(card) / inclusion(card);
  }

  SwArchetype.fromDecklist(SwDecklist decklist, List<SwCard> library)
      : side = decklist.side,
        title = decklist.archetypeName,
        startingCard = library.firstWhere(
            (SwCard c) => (c.title.toLowerCase() ==
                    decklist.cardNames(starting: true)[1].toLowerCase() &&
                c.side == decklist.side),
            orElse: () => null),
        decklists = [decklist];
}
