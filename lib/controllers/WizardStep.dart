class WizardStep {
  WizardStep(setup, callback)
      : setup = setup,
        callback = callback;

  final Function setup;
  final Function callback;
}
