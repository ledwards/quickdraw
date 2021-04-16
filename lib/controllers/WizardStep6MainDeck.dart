import 'Wizard.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';
import '../models/SwCard.dart';
import '../models/SwDeck.dart';
import '../models/SwArchetype.dart';
import '../rules/Metagame.dart';

WizardStep buildMainDeck(Wizard wizard, Metagame meta, SwDeck deck) {
  return WizardStep(wizard, () {
    SwStack library = meta.library;
    SwArchetype archetype = deck.archetype;

    wizard.sideStacks['allCards'].refresh(library);

    wizard.currentStack.refresh(library.where(
        (SwCard card) => archetype.inclusion(card, starting: false) > 0));
    wizard.currentStack.title = 'Main Deck';

    wizard.addCurrentStepListener(deck);
  }, () {
    // wizard.nextStep();
  });
}
