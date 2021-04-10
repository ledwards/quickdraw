import 'Wizard.dart';
import 'WizardStep.dart';
import '../models/SwStack.dart';
import '../models/SwDeck.dart';

WizardStep pickStartingInterrupt(Wizard wizard, Map<String, dynamic> data) {
  return WizardStep(wizard, () {
    print('Setting up step 4');
    SwStack library = data['library'];
    SwDeck deck = data['deck'];

    SwStack startingInterrupts =
        library.byType('Interrupt').matchesSubType('Starting');
    wizard.currentStack = startingInterrupts;
    wizard.currentStack.title = 'Starting Interrupt';
    wizard.addCurrentStepListener(deck);
  }, () {
    wizard.nextStep();
  });
}
