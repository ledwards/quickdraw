import 'Wizard.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';
import '../models/SwCard.dart';
import '../models/SwDeck.dart';
import '../rules/StartingInterrupts.dart';

WizardStep pulledByStartingInterrupt(Wizard wizard, Map<String, dynamic> data) {
  return WizardStep(wizard, () {
    print('Setting up step 5');
    List<SwStack> futureStacks = data['futureStacks'];
    SwStack library = data['library'];
    SwDeck deck = data['deck'];

    SwCard startingInterrupt = deck.startingInterrupt();
    if (startingInterrupt != null) {
      Map<String, dynamic> pulled =
          pullByStartingInterrupt(startingInterrupt, library);
      deck.addStack(pulled['mandatory']);
      futureStacks.addAll(pulled['optionals']);
    } else {
      wizard.nextStep();
    }

    if (startingInterrupt != null && futureStacks.isNotEmpty) {
      wizard.currentStack.clear();
      wizard.currentStack.title = futureStacks[0].title;
      wizard.currentStack.addStack(futureStacks.removeAt(0));
      wizard.addCurrentStepListener(deck);
    } else {
      wizard.nextStep(); // Starting Interrupt is only pulling mandatory cards
    }
  }, () {
    SwDeck deck = data['deck'];
    List<SwStack> futureStacks = data['futureStacks'];

    _handleSpecialPuller(data);
    if (futureStacks.isEmpty) {
      wizard.nextStep();
    } else {
      wizard.currentStack = futureStacks.removeAt(0);
    }
  });
}

_handleSpecialPuller(Map<String, dynamic> data) {
  SwStack library = data['library'];
  List<SwStack> futureStacks = data['futureStacks'];
  SwDeck deck = data['deck'];

  SwCard startingInterrupt = deck.startingInterrupt();
  SwCard lastCard = deck.lastCard();

  switch (startingInterrupt.title) {
    case 'Any Methods Necessary':
      if (lastCard.type == 'Character') {
        if (library.matchingWeapons(lastCard).isNotEmpty()) {
          SwStack matchingWeapons = library.matchingWeapons(lastCard);
          matchingWeapons.title = '(Optional) Matching Weapon';
          futureStacks.add(matchingWeapons);
        }
        if (library.matchingStarships(lastCard).isNotEmpty()) {
          SwStack matchingStarships = library.matchingStarships(lastCard);
          matchingStarships.title = '(Optional) Matching Starship';
          futureStacks.add(matchingStarships);
        }
      } else if (lastCard.title == 'Cloud City: Security Tower (V)') {
        SwStack despairs = library.findAllByNames(['Despair (V)', 'Despair']);
        despairs.title = '(Optional) Despair';
        futureStacks.insert(0, despairs);
      }
      break;
  }
}
