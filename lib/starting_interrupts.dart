import 'package:swccg_builder/sw_card.dart';
import 'package:swccg_builder/sw_stack.dart';

SwStack pullByStartingInterrupt(SwCard startingInterrupt, SwStack library) {
  SwStack startingCards = new SwStack(
      startingInterrupt.side, [], "Pulled by ${startingInterrupt.title}");

  switch (startingInterrupt.title) {
    case 'According to My Design':
      SwStack emps = library.findAllByName([
        'Emperor Palpatine',
        'The Emperor',
        'Emperor Palpatine, Foreseer',
        'Palpatine, Emperor Returned'
      ]);

      SwStack effects = library
          .bySide(startingInterrupt.side)
          .byType('Effect')
          .bySubType(null)
          .matchesGametext('(Immune to Alter.)');
      SwStack effects_1 = effects.matchesGametext('Deploy on table.');
      SwStack effects_2 = effects.matchesGametext('Deploy on table if');
      SwStack effects_3 = effects
        ..matchesGametext('Deploy on your side of table.');

      startingCards = startingCards
          .concat(emps)
          .concat(effects_1)
          .concat(effects_2)
          .concat(effects_3);
      break;

// TODO: these methods should return a list of Stacks that caller can do things with
    case 'Any Methods Necessary':
      SwStack prisons = library.hasCharacteristic('prison');
      SwStack despair = library.findAllByName(['Despair (V)', 'Despair']);
      SwStack bountyHunters = library.hasCharacteristic('bounty hunter');
      // TODO: matching weapons
      // TODO: matching ship

      startingCards =
          startingCards.concat(prisons).concat(despair).concat(bountyHunters);
      break;
  }

  return startingCards;
}
