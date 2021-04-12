import 'Wizard.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';
import '../models/SwArchetype.dart';
import '../models/SwDeck.dart';
import '../rules/Metagame.dart';

WizardStep buildMainDeck(Wizard wizard, Metagame meta, SwDeck deck) {
  return WizardStep(wizard, () {
    SwStack library = meta.library;
    SwArchetype archetype = deck.archetype;

    // wizard.sideStacks['default'].refresh(meta.cardsUsedInArchetype(archetype));
    wizard.sideStacks['allCards'].refresh(library);
    // TODO: Exclude Defensive Sheilds and outside of deck cards

    wizard.refreshCurrentStack(library);
    wizard.currentStack.title = 'Main Deck';

    wizard.addCurrentStepListener(deck);
  }, () {
    // wizard.nextStep();
  });
}
