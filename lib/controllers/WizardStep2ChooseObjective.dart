import 'Wizard.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';
import '../models/SwArchetype.dart';
import '../models/SwDeck.dart';
import '../rules/Metagame.dart';

WizardStep pickObjectiveStep(Wizard wizard, Metagame meta, SwDeck deck) {
  return WizardStep(wizard, () {
    print('Setting up step 2');
    List<SwArchetype> archetypes = meta.archetypes;
    SwStack library = meta.library;

    SwStack objectives = library.byType('Objective');
    SwStack startingLocations = new SwStack(
      archetypes.map((a) => a.startingCard).toSet().toList(),
      'Starting Locations',
    ).bySide(deck.side).byType('Location');

    wizard.currentStack = objectives.concat(startingLocations);

    wizard.addCurrentStepListener(deck);
  }, () {
    wizard.nextStep();
  });
}
