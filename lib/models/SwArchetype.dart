import 'SwCard.dart';
import 'SwDecklist.dart';

class SwArchetype {
  SwArchetype(this.side, this.title, this.startingCard, this.decklists);

  String side;
  String title;
  SwCard startingCard;
  List<SwDecklist> decklists;

  SwArchetype.fromDecklist(SwDecklist decklist, List<SwCard> library)
      : side = decklist.side,
        title = decklist.archetypeName,
        startingCard = library.firstWhere(
            (SwCard c) =>
                (c.title.toLowerCase() == decklist.cardNames[1].toLowerCase() &&
                    c.side == decklist.side),
            orElse: () => null),
        decklists = [decklist];
}
