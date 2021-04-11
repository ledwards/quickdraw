import 'Wizard.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';
import '../models/SwArchetype.dart';
import '../models/SwDeck.dart';
import '../rules/Metagame.dart';

WizardStep buildMainDeck(Wizard wizard, Metagame meta, SwDeck deck) {
  return WizardStep(wizard, () {
    List<SwArchetype> archetypes = meta.archetypes;
    SwStack library = meta.library;
    wizard.currentStack = library;
    wizard.currentStack.title = 'Main Deck';

    wizard.addCurrentStepListener(deck);
  }, () {
    // wizard.nextStep();
  });
}
