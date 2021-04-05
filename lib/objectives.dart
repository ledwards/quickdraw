import 'models/sw_card.dart';
import 'models/sw_stack.dart';

Map<String, SwStack> pullByObjective(SwCard objective, SwStack library) {
  SwStack mandatory = new SwStack(objective.side, [], "");
  SwStack optional =
      new SwStack(objective.side, [], "Pulled by ${objective.title}");

  switch (objective.title) {
    case 'A Stunning Move':
      SwStack mandatory = library.findAllByName([
        'Coruscant: 500 Republica',
        'Insidious Prisoner',
        'Coruscant: Private Platform'
      ]);

      break;
    case 'Bring Him Before Me':
      SwStack mandatory = library.findAllByName([
        'Death Star II: Throne Room',
        'Insignificant Rebellion',
        'Your Destiny'
      ]);
      break;
  }

  return {
    "mandatory": mandatory,
    "optional": optional,
  };
}
