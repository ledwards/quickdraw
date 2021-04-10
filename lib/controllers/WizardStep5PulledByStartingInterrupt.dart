import 'Wizard.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';
import '../models/SwCard.dart';
import '../models/SwDeck.dart';
import '../rules/StartingInterrupts.dart';
import '../rules/Metagame.dart';
import '../rules/MultistagePullers.dart';

WizardStep pulledByStartingInterrupt(
    Wizard wizard, Metagame meta, SwDeck deck) {
  return WizardStep(wizard, () {
    print('Setting up step 5');
    List<SwStack> futureStacks = wizard.futureStacks;
    SwStack library = meta.library;

    SwCard startingInterrupt = deck.startingInterrupt();
    if (startingInterrupt != null) {
      Map<String, dynamic> pulled =
          pullByStartingInterrupt(startingInterrupt, library);
      deck.addStack(pulled['mandatory'], wizard.stepNumber);
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
    SwCard startingInterrupt = deck.startingInterrupt();
    List<SwStack> futureStacks = wizard.futureStacks;

    handleMultistagePuller(startingInterrupt, meta, {
      'lastCard': deck.lastCard(),
      'futureStacks': wizard.futureStacks,
    });

    if (futureStacks.isEmpty) {
      wizard.nextStep();
    } else {
      wizard.currentStack = futureStacks.removeAt(0);
    }
  });
}
