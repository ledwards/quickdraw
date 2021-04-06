import 'models/sw_card.dart';
import 'models/sw_stack.dart';

Map<String, dynamic> pullByObjective(SwCard objective, SwStack library) {
  SwStack mandatory = new SwStack(objective.side, [], "");
  List<SwStack> optionals = [];

  switch (objective.title) {
    case 'A Stunning Move':
      mandatory = library.findAllByNames([
        'Coruscant: 500 Republica',
        'Insidious Prisoner',
        'Coruscant: Private Platform (Docking Bay)',
      ]);
      break;

    case 'Bring Him Before Me':
      mandatory = library.findAllByNames([
        'Death Star II: Throne Room',
        'Insignificant Rebellion',
        'Your Destiny',
      ]);
      break;

    case 'Hunt Down And Destroy The Jedi':
      mandatory = library.findAllByNames([
        'Executor: Holotheatre',
        'Visage Of The Emperor',
      ]);

      optionals.add(new SwStack(
          objective.side,
          [library.findByName('Executor: Meditation Chamber')],
          '(Optional) Meditation Chamber'));

      optionals.add(new SwStack(objective.side,
          [library.findByName('Epic Duel')], '(Optional) Epic Duel'));
      break;
  }

  return {
    "mandatory": mandatory,
    "optionals": optionals,
  };
}
