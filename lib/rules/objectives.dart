import '../models/SwCard.dart';
import '../models/SwStack.dart';

Map<String, dynamic> pullByObjective(SwCard objective, SwStack library) {
  SwStack mandatory = new SwStack([], "");
  List<SwStack> optionals = [];

  switch (objective.title) {
    case 'A Stunning Move':
      mandatory = library.findAllByNames([
        'Coruscant: 500 Republica',
        'Insidious Prisoner',
        'Coruscant: Private Platform (Docking Bay)',
      ]);
      break;

    case 'Agents of Black Sun':
      mandatory = library
          .findAllByNames(['Prince Xizor', 'Coruscant: Imperial Square']);
      optionals
          .add(library.findAllByNames(['Coruscant'], includeVirtual: true));
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
          [library.findByName('Executor: Meditation Chamber')],
          '(Optional) Meditation Chamber'));

      optionals.add(new SwStack(
          [library.findByName('Epic Duel')], '(Optional) Epic Duel'));
      break;
  }

  return {
    "mandatory": mandatory,
    "optionals": optionals,
  };
}
