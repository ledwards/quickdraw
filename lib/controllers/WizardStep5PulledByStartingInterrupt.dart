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
      wizard.currentStack.title = futureStacks[0].title;
      wizard.currentStack.refresh(futureStacks.removeAt(0), starting: true);
      wizard.addCurrentStepListener(deck);
    } else {
      wizard.nextStep(); // Starting Interrupt is only pulling mandatory cards
    }
  }, () {
    SwCard startingInterrupt = deck.startingInterrupt();
    RegExp regexp = RegExp(r'(\d) of (\d)');
    Iterable<Match> matches = regexp.allMatches(wizard.currentStack.title);

    handleMultistagePuller(startingInterrupt, meta, {
      'lastCard': deck.lastCard(),
      'futureStacks': wizard.futureStacks,
    });

    // TODO: Extract repeat pulls logic into own method
    if (matches.isNotEmpty) {
      String curStr = wizard.currentStack.title
          .substring(matches.first.start, matches.first.start + 1);
      String maxStr = wizard.currentStack.title
          .substring(matches.first.end - 1, matches.first.end);
      int cur = int.parse(curStr);
      int max = int.parse(maxStr);

      if (curStr != null && maxStr != null && cur < max) {
        String newTitle = wizard.currentStack.title
            .replaceFirst(cur.toString(), (cur + 1).toString());
        SwStack newStack = new SwStack.fromStack(wizard.currentStack, newTitle);
        wizard.futureStacks.insert(0, newStack);
      }
    }

    if (wizard.futureStacks.isEmpty) {
      wizard.nextStep();
    } else {
      wizard.currentStack
          .refresh(wizard.futureStacks.removeAt(0), starting: true);
    }
  });
}
