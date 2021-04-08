import 'Wizard.dart';

class WizardStep {
  WizardStep(Wizard wizard, Function setup, Function callback)
      : wizard = wizard,
        setup = setup,
        callback = callback;

  final Wizard wizard;
  final Function setup;
  final Function callback;
}
