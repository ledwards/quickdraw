import '../models/SwArchetype.dart';
import '../models/SwDecklist.dart';
import '../models/SwStack.dart';
import '../models/SwCard.dart';

class Metagame {
  Metagame(String side)
      : side = side,
        allCards = null,
        allArchetypes = [],
        allDecklists = [];

  String side;
  SwStack allCards;
  List<SwArchetype> allArchetypes;
  List<SwDecklist> allDecklists;

  SwStack get library => side == null ? allCards : allCards.bySide(side);
  List<SwArchetype> get archetypes => // by side?
      allArchetypes.where((SwArchetype a) => a.side == side).toList();
  List<SwDecklist> get decklists => // by side?
      allDecklists.where((SwDecklist d) => d.side == side).toList();

  SwStack cardsUsedInArchetype(SwArchetype archetype) {
    SwStack stack = library.findAllByNames(archetype.allCardNames);
    stack.title = archetype.title;
    return stack;
  }

// TODO: Both here and in Archetype, optional key/value for whether popularity is in starting/main
  int inclusion(SwCard card) {
    return decklists
        .where((decklist) => decklist.cardNames.contains(card.title))
        .length;
  }

  int frequency(SwCard card) {
    return decklists.fold(
        0,
        (int sum, SwDecklist decklist) =>
            sum +
            decklist.cardNames.where((name) => name == card.title).length);
  }

  num rateOfInclusion(SwCard card) {
    return inclusion(card) / decklists.length;
  }

  num averageFrequency(SwCard card) {
    return frequency(card) / decklists.length;
  }

  num averageFrequencyPerInclusion(SwCard card) {
    return inclusion(card) == 0 ? 0 : frequency(card) / inclusion(card);
  }

  // // TODO: Add a dimension of starting vs. in deck
  // // TODO: Once it's working - see if this can be pre-loaded into SwCard or MetaCard objects and/or the archetype objects
}
