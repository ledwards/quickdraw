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

    wizard.sideStacks['allCards'].refresh(library, starting: false);

    SwStack newCurrentStack = library
        .where((SwCard card) => archetype.inclusion(card, starting: false) > 0);
    wizard.currentStack.refresh(newCurrentStack);
    wizard.currentStack.title = 'Main Deck';

// TODO: Extract into #pad method and see where else it should be used
    // duplicate commonly duplicated cards
    newCurrentStack.cards.forEach((card) {
      double inclusions =
          meta.averageFrequencyPerInclusion(card, starting: false);
      int index = wizard.currentStack.cards.lastIndexWhere((c) => c == card);

      if (index > -1) {
        for (int i = 0; i < inclusions.ceil() - 1; i = i + 1) {
          wizard.currentStack.cards.insert(index, card);
        }
      }
    });

    wizard.addCurrentStepListener(deck);
  }, () {
    // wizard.nextStep();
  });
}
