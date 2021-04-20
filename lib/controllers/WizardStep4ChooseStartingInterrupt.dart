import 'Wizard.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';
import '../models/SwDeck.dart';
import '../rules/Metagame.dart';

WizardStep pickStartingInterrupt(Wizard wizard, Metagame meta, SwDeck deck) {
  return WizardStep(wizard, () {
    SwStack library = meta.library;

    SwStack startingInterrupts =
        library.byType('Interrupt').matchesSubType('Starting');
    wizard.currentStack.title = 'Starting Interrupt';
    wizard.currentStack.refresh(startingInterrupts, starting: true);
    wizard.addCurrentStepListener(deck);
  }, () {
    wizard.nextStep();
  });
}
