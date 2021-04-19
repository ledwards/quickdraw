import 'Wizard.dart';

class WizardStep {
  WizardStep(this.wizard, this.setup, this.callback);

  final Wizard wizard;
  final Function setup;
  final Function callback;
}
