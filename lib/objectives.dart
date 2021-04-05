import 'package:swccg_builder/sw_card.dart';
import 'package:swccg_builder/sw_stack.dart';

SwStack pullByObjective(SwCard objective, SwStack library) {
  SwStack startingCards =
      new SwStack(objective.side, [], "Pulled by ${objective.title}");

  switch (objective.title) {
    case 'Bring Him Before Me':
      SwStack stack = library.findAllByName([
        'Death Star II: Throne Room',
        'Insignificant Rebellion',
        'Your Destiny'
      ]);

      startingCards = startingCards.concat(stack);
      break;
  }

  return startingCards;
}
