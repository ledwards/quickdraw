import 'Wizard.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';
import '../models/SwArchetype.dart';
import '../models/SwDeck.dart';
import '../rules/Metagame.dart';

WizardStep pickObjectiveStep(Wizard wizard, Metagame meta, SwDeck deck) {
  return WizardStep(wizard, () {
    List<SwArchetype> archetypes = meta.archetypes;
    SwStack library = meta.library;

    List<SwArchetype> allPossibleArchetypes =
        archetypes.where((a) => a.side == deck.side).toList();
    SwStack objectives = library.byType('Objective');
    SwStack startingLocations = new SwStack(
      allPossibleArchetypes.map((a) => a.startingCard).toSet().toList(),
      'Starting Locations',
    ).bySide(deck.side).byType('Location');

    wizard.currentStack = objectives.concat(startingLocations);

    wizard.addCurrentStepListener(deck);
  }, () {
    wizard.nextStep();
  });
}
