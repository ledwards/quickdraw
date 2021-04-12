import '../models/SwCard.dart';
import '../models/SwStack.dart';

Map<String, dynamic> pullByStartingInterrupt(
    SwCard startingInterrupt, SwStack library) {
  SwStack mandatory = new SwStack([], "");
  List<SwStack> optionals = [];

  switch (startingInterrupt.title) {
    case 'According To My Design':
      SwStack emps = library.findAllByNames([
        'Emperor Palpatine',
        'The Emperor',
        'Emperor Palpatine, Foreseer',
        'Palpatine, Emperor Returned'
      ]);
      emps.title = '(Choose) Emperor';

      SwStack effects = startableEffects(library);
      effects.title = '(Choose) 3 Deployable Effects';

      optionals = [
        emps,
        effects,
        effects,
        effects
      ]; // TODO: This is the same stack 3 times. Between picks, the stack needs to persist. Use FutureStacks
      // maybe when we move from one optional stack to the other, we remove trash and chosen cards, etc.
      // but this is jarring, the stack should continue as-is
      // so: maybe we indicate the effects stack is 3x, and force 3x picks before moving on
      break;

    case 'Any Methods Necessary':
      SwStack prisons = library.hasCharacteristic('prison');
      SwStack bountyHunters = library.hasCharacteristic('bounty hunter');

      prisons.title = '(Choose) Prison';
      bountyHunters.title = '(Choose) Bounty Hunter';

      optionals = [prisons, bountyHunters];
      break;

    case 'Slip Sliding Away (V)':
    // TODO: SSA needs a battleground too..
    case 'Prepared Defenses':
    case 'Heading For The Medical Frigate':
      SwStack effects = startableEffects(library);
      effects.title = '(Choose) 3 Deployable Effects';

      optionals = [effects, effects, effects];
      break;
  }

  return {
    "mandatory": mandatory,
    "optionals": optionals,
  };
}

SwStack startableEffects(SwStack library) {
  SwStack effects = library
      .byType('Effect')
      .bySubType(null)
      .matchesGametext('(Immune to Alter.)');

  SwStack effects1 = effects.matchesGametext('Deploy on table.');
  SwStack effects2 = effects.matchesGametext('Deploy on table if');
  SwStack effects3 = effects.matchesGametext('Deploy on your side of table.');
  SwStack effects4 = effects.matchesGametext(', deploy on table.');

  return effects1.concat(effects2).concat(effects3).concat(effects4);
}
