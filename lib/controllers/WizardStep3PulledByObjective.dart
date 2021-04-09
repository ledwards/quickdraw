import 'Wizard.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';
import '../models/SwCard.dart';
import '../models/SwDeck.dart';
import '../rules/Objectives.dart';

WizardStep pulledByObjective(Wizard wizard, Map<String, dynamic> data) {
  return WizardStep(wizard, () {
    print('Setting up step 3');
    List<SwStack> futureStacks = data['futureStacks'];
    SwStack library = data['library'];
    SwDeck deck = data['deck'];

    SwCard startingCard = deck.startingCard();

    if (startingCard.type == 'Objective') {
      Map<String, dynamic> pulled = pullByObjective(startingCard, library);
      deck.addStack(pulled['mandatory']);
      futureStacks.addAll(pulled['optionals']);
    }

    if (startingCard.type == 'Objective' && futureStacks.isNotEmpty) {
      wizard.currentStack.clear();
      wizard.currentStack.title = futureStacks[0].title;
      wizard.currentStack.addStack(futureStacks.removeAt(0));
      wizard.addCurrentStepListener(deck);
    } else {
      wizard
          .nextStep(); // Objective is only pulling mandatory cards or is a Location
    }
  }, () {
    if (wizard.futureStacks.isEmpty) {
      wizard.nextStep();
    } else {
      wizard.currentStack = wizard.futureStacks.removeAt(0);
    }
  });
}
