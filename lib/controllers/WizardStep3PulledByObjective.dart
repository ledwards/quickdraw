import 'Wizard.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';
import '../models/SwCard.dart';
import '../models/SwDeck.dart';
import '../rules/Objectives.dart';
import '../rules/Metagame.dart';

WizardStep pulledByObjective(Wizard wizard, Metagame meta, SwDeck deck) {
  return WizardStep(wizard, () {
    List<SwStack> futureStacks = wizard.futureStacks;
    SwStack library = meta.library;

    SwCard startingCard = deck.startingCard();

    if (startingCard.type == 'Objective') {
      Map<String, dynamic> pulled = pullByObjective(startingCard, library);
      deck.addStack(pulled['mandatory'], wizard.stepNumber);
      futureStacks.addAll(pulled['optionals']);
    }

    if (startingCard.type == 'Objective' && futureStacks.isNotEmpty) {
      wizard.currentStack.title = futureStacks[0].title;
      wizard.currentStack.refresh(futureStacks.removeAt(0));
      wizard.addCurrentStepListener(deck);
    } else {
      wizard
          .nextStep(); // Objective is only pulling mandatory cards or is a Location
    }
  }, () {
    if (wizard.futureStacks.isEmpty) {
      wizard.nextStep();
    } else {
      wizard.currentStack.refresh(wizard.futureStacks.removeAt(0));
    }
  });
}

// TESTING
    // SwCard card = library.findByName("Darth Vader, Emperor's Enforcer");
    // SwArchetype archetype = deck.archetype;

    // print("Card: ${card.title}");
    // print("Archetype: ${archetype.title}");
    // print("Decklists: ${meta.decklists.length}");
    // print("inclusion: ${meta.inclusion(card)}");
    // print("frequency: ${meta.frequency(card)}");
    // print("rate of inclusion: ${meta.rateOfInclusion(card)}");
    // print("avg number per decklist: ${meta.averageFrequency(card)}");
    // print("\n");
    // print("Decklists in Archetype: ${archetype.decklists.length}");
    // print("inclusionInArchetype: ${archetype.inclusion(card)}");
    // print("frequencyInArchetype: ${archetype.frequency(card)}");
    // print("rate of inclusion in archetype: ${archetype.rateOfInclusion(card)}");
    // print(
    //     "avg number per decklist in archetype: ${archetype.averageFrequency(card)}");
// TESTING