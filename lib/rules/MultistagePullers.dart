import '../models/SwStack.dart';
import '../models/SwCard.dart';
import 'Metagame.dart';

handleMultistagePuller(
    SwCard startingInterrupt, Metagame meta, Map<String, dynamic> data) {
  SwCard lastCard = data['lastCard'];
  List<SwStack> futureStacks = data['futureStacks'];

  SwStack library = meta.library;

  switch (startingInterrupt.title) {
    case 'Any Methods Necessary':
      if (lastCard.type == 'Character') {
        if (library.matchingWeapons(lastCard).isNotEmpty()) {
          SwStack matchingWeapons = library.matchingWeapons(lastCard);
          matchingWeapons.title = '(Optional) Matching Weapon';
          futureStacks.add(matchingWeapons);
        }
        if (library.matchingStarships(lastCard).isNotEmpty()) {
          SwStack matchingStarships = library.matchingStarships(lastCard);
          matchingStarships.title = '(Optional) Matching Starship';
          futureStacks.add(matchingStarships);
        }
      } else if (lastCard.title == 'Cloud City: Security Tower (V)') {
        SwStack despairs = library.findAllByNames(['Despair (V)', 'Despair']);
        despairs.title = '(Optional) Despair';
        futureStacks.insert(0, despairs);
      }
      break;
  }
}
